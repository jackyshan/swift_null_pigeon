package com.lizhi.lzflutter.push.push_lzflutter

import android.os.Bundle
import com.lizhi.component.net.websocket.WSPushManager
import com.lizhi.component.net.websocket.impl.SubscribeResult
import com.lizhi.component.net.websocket.impl.TopicStatus
import com.lizhi.component.net.websocket.model.ConnConfige
import com.lizhi.component.net.websocket.model.ConnInfo
import com.lizhi.component.net.websocket.model.ConnStatus
import com.lizhi.component.net.websocket.model.PushData
import com.lizhi.flutter_pigeon.*
import com.yibasan.lizhifm.base.websocket.observer.CallbackHandle
import com.yibasan.lizhifm.base.websocket.observer.ConnStatusObserverHandle
import com.yibasan.lizhifm.base.websocket.observer.ITopicsObserver
import com.yibasan.lizhifm.base.websocket.observer.PushObserverHandle
import com.yibasan.socket.network.util.ApplicationUtils
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

class NativePushManager(val flutterPushBridge: FlutterPushBridge) : NativePushBridge {

//    var appId = ""

    val coroutineScope = GlobalScope

    @OptIn(DelicateCoroutinesApi::class)
    override fun connect(param: InitRequestParam, callback: (Result<ResponseParam>) -> Unit) {
        coroutineScope.launch(Dispatchers.Main) {
            try {
                val configParam = param.data
//                appId = configParam.appId
                val configBuilder = ConnConfige.ConfigBuilder()
                    .setHostApp(configParam.hostApp) //例如：lizhi，tiya，pongpong，组件必填,app可以为空
                    //1：必须：例如荔枝对应的appId 为0，注意appId是否已经开通，如果未开通需要先开通，与服务端对应BusinessEnv
                    //2:如果是组件：app由自己命名即可
                    .setAppId(configParam.appId)
                    .setDeviceId(configParam.deviceId)//必须
                //.setPingTime(15)//可选，默认10秒，单位秒
                //.setSocketTimeOut(30)//可选，默认60秒，单位秒
                if (configParam.defaultHosts != null) {
                    val defaultHosts = mutableListOf<String>()
                    configParam.defaultHosts.forEach {
                        if (!it.isNullOrEmpty()) {
                            defaultHosts.add(it)
                        }
                    }
                    configBuilder.setDefaultHosts(//建议增加默认host，内部会优先使用调度中心的host，没有再使用默认
                        defaultHosts
                    )
                }
                val config = configBuilder.build()
                WSPushManager.connect(config, true)
                launch(Dispatchers.Main) {
                    callback(Result.success(ResponseParam(ResponseCode.SUCCESS)))
                }
            } catch (e: Exception) {
                e.printStackTrace()
                launch(Dispatchers.Main) {
                    callback(Result.success(ResponseParam(ResponseCode.FAIL, e.message)))
                }
            }
        }
    }

    override fun disconnect(param: RequestParam): ResponseParam {
        return try {
            WSPushManager.disConnect(param.data!!["appId"].toString())
            ResponseParam(ResponseCode.SUCCESS)
        } catch (e: Exception) {
            ResponseParam(ResponseCode.FAIL, e.message)
        }
    }

    private val connStatusObservers = mutableMapOf<String, ConnStatusObserverHandle>()

    override fun addConnStatusObserver(param: ObserverRequestParam): ResponseParam {
        return try {
            val callbackKey = param.data.callbackKey
            if (!connStatusObservers.contains(callbackKey)) {
                val observer = object : ConnStatusObserverHandle.Stub() {
                    override fun onConnStatus(appId: String?, bundle: Bundle?) {
                        val info = ConnInfo.getConnInfo(bundle)
                        info?.let {
                            val connStatus = when (info.connStatus) {
                                ConnStatus.CONNECTED -> ConnectStatus.CONNECTED
                                ConnStatus.CONNECTING -> ConnectStatus.CONNECTING
                                ConnStatus.DISCONNECT -> ConnectStatus.DISCONNECT
                                else -> ConnectStatus.DISCONNECT
                            }
                            val transInfo = ConnectInfo(
                                info.errorCode.toLong(), info.errorMessage,
                                connStatus
                            )
                            flutterPushBridge.onConnStatusObserverCall(
                                ConnStatusObserverCallParam(
                                    "ConnStatusObserver_onConnStatus",
                                    ConnStatusCall(callbackKey, param.data.appId, transInfo)
                                )
                            ) {
                                //do nothing
                            }
                        }
                    }
                }
                connStatusObservers[callbackKey] = observer
                WSPushManager.addConnStatusObserver(param.data.appId, observer)
            }
            ResponseParam(ResponseCode.SUCCESS)
        } catch (e: Exception) {
            ResponseParam(ResponseCode.FAIL, e.message)
        }
    }

    override fun removeConnStatusObserver(param: ObserverRequestParam): ResponseParam {
        val callbackKey = param.data.callbackKey
        connStatusObservers.remove(callbackKey)?.let {
            WSPushManager.removeConnStatusObserver(param.data.appId, it)
        }
        return ResponseParam(ResponseCode.SUCCESS)
    }

    private val pushObservers = mutableMapOf<String, PushObserverHandle>()
    override fun addPushObserver(param: ObserverRequestParam): ResponseParam {
        return try {
            val callbackKey = param.data.callbackKey
            if (!pushObservers.contains(callbackKey)) {
                val observer = object : PushObserverHandle.Stub() {
                    override fun onPush(appId: String?, bundle: Bundle?) {
                        val data = PushData.getPushData(bundle)
                        data?.let {
                            val transferData = data.data?.run {
                                TransferData(
                                    seq = seq,
                                    payloadId = payloadId,
                                    payload = payload?.run { String(this) },
                                    timestamp = timestamp,
                                    deviceId = deviceId,
                                    alias = alias,
                                    topic = topic,
                                )
                            }
                            val pushData = PushMessageData(data.type, transferData)
                            flutterPushBridge.onPushObserverCall(
                                PushObserverCallParam(
                                    "PushObserver_onPush",
                                    PushCall(callbackKey, param.data.appId, pushData)
                                )
                            ) {
                                //do nothing
                            }
                        }
                    }
                }
                pushObservers[callbackKey] = observer
                WSPushManager.addPushObserver(param.data.appId, observer)
            }
            ResponseParam(ResponseCode.SUCCESS)
        } catch (e: Exception) {
            ResponseParam(ResponseCode.FAIL, e.message)
        }
    }

    override fun removePushObserver(param: ObserverRequestParam): ResponseParam {
        val callbackKey = param.data.callbackKey
        pushObservers.remove(callbackKey)?.let {
            WSPushManager.removePushObserver(param.data.appId, it)
        }
        return ResponseParam(ResponseCode.SUCCESS)
    }

    override fun setAlias(param: SetAliasRequestParam, callback: (Result<ResponseParam>) -> Unit) {
        val alias2 = param.data.alias.run {
            val list = ArrayList<String>()
            forEach {
                if (!it.isNullOrEmpty()) {
                    list.add(it)
                }
            }
            return@run list
        }
        WSPushManager.setAlias(
            ApplicationUtils.context,
            param.data.appId,
            alias2,
            object : CallbackHandle.Stub() {
                override fun onSuccess(p0: String?) {
                    coroutineScope.launch(Dispatchers.Main) {
                        callback(Result.success(ResponseParam(ResponseCode.SUCCESS)))
                    }
                }

                override fun onFail(appId: String?, code: Int, msg: String?) {
                    coroutineScope.launch(Dispatchers.Main) {
                        callback(Result.success(ResponseParam(ResponseCode.FAIL, "${code}_${msg}")))
                    }
                }

            })
    }

    override fun clearAlias(param: RequestParam, callback: (Result<ResponseParam>) -> Unit) {
        WSPushManager.clearAlias(ApplicationUtils.context, param.data!!["appId"].toString(), object : CallbackHandle.Stub() {
            override fun onSuccess(p0: String?) {
                coroutineScope.launch(Dispatchers.Main) {
                    callback(Result.success(ResponseParam(ResponseCode.SUCCESS)))
                }
            }

            override fun onFail(appId: String?, code: Int, msg: String?) {
                coroutineScope.launch(Dispatchers.Main) {
                    callback(Result.success(ResponseParam(ResponseCode.FAIL, "${code}_${msg}")))
                }
            }
        })
    }

    override fun subscribeTopic(param: RequestParam): ResponseParam {
        val topic = param.data?.get("topic")?.toString() ?: ""
        val appId = param.data?.get("appId")?.toString() ?: ""
        WSPushManager.subscribeTopic(appId, topic)
        return ResponseParam(ResponseCode.SUCCESS)
    }

    override fun unsubscribeTopic(param: RequestParam): ResponseParam {
        val topic = param.data?.get("topic")?.toString() ?: ""
        val appId = param.data?.get("appId")?.toString() ?: ""
        WSPushManager.unsubscribeTopic(appId, topic)
        return ResponseParam(ResponseCode.SUCCESS)
    }


    val topicObservers = mutableMapOf<String, ITopicsObserver>()
    override fun addTopicsObserver(param: ObserverRequestParam): ResponseParam {
        return try {
            val callbackKey = param.data.callbackKey
            if (!topicObservers.contains(callbackKey)) {
                val observer = object : ITopicsObserver.Stub() {
                    override fun onSubscribe(
                        appId: String?,
                        topic: String?,
                        resultBundle: Bundle?
                    ) {
                        resultBundle?.let {
                            val result = SubscribeResult.bundleToBean(resultBundle)?.run {
                                TopicSubscribeResult(
                                    status = when (status) {
                                        TopicStatus.AVAILABLE -> TopicResultStatus.AVAILABLE
                                        TopicStatus.PROCESSING -> TopicResultStatus.PROCESSING
                                        TopicStatus.INVALID -> TopicResultStatus.INVALID
                                        else -> TopicResultStatus.INVALID
                                    }, code = code.toLong(), msg = msg
                                )
                            }
                            result?.let {
                                flutterPushBridge.onTopicObserverCall(
                                    TopicObserverCallParam(
                                        "TopicsObserver_onSubscribe",
                                        TopicCall(callbackKey, param.data.appId, TopicSubscribeData(topic ?: "", result))
                                    )
                                ) {
                                    //do nothing
                                }
                            }
                        }
                    }

                }
                topicObservers[callbackKey] = observer
                WSPushManager.addTopicsObserver(param.data.appId, observer)
            }
            ResponseParam(ResponseCode.SUCCESS)
        } catch (e: Exception) {
            ResponseParam(ResponseCode.FAIL, e.message)
        }
    }

    override fun removeTopicsObserver(param: ObserverRequestParam): ResponseParam {
        val callbackKey = param.data.callbackKey
        topicObservers.remove(callbackKey)?.let {
            WSPushManager.removeTopicsObserver(param.data.appId, it)
        }
        return ResponseParam(ResponseCode.SUCCESS)
    }
}