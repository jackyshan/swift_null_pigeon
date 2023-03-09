package com.lizhi.lzflutter.push.push_lzflutter

import com.lizhi.component.net.websocket.WSPushManager
import com.lizhi.component.net.websocket.model.ConnConfige
import com.lizhi.flutter_pigeon.*
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

class NativePushManager(val flutterPushBridge: FlutterPushBridge) : NativePushBridge {

    @OptIn(DelicateCoroutinesApi::class)
    override fun connect(param: InitRequestParam, callback: (Result<ResponseParam>) -> Unit) {
        GlobalScope.launch(Dispatchers.Main) {
            try{
                val configParam = param.data
                val configBuilder = ConnConfige.ConfigBuilder()
                    .setHostApp(configParam.hostApp) //例如：lizhi，tiya，pongpong，组件必填,app可以为空
                    //1：必须：例如荔枝对应的appId 为0，注意appId是否已经开通，如果未开通需要先开通，与服务端对应BusinessEnv
                    //2:如果是组件：app由自己命名即可
                    .setAppId(configParam.appId)
                    .setDeviceId("deviceID_test")//必须
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
            }catch(e:Exception){
                e.printStackTrace()
                launch(Dispatchers.Main) {
                    callback(Result.success(ResponseParam(ResponseCode.FAIL, e.message)))
                }
            }
        }
    }

    override fun disconnect(): ResponseParam {
        TODO("Not yet implemented")
    }

    override fun addConnStatusObserver(param: ObserverRequestParam): ResponseParam {
        TODO("Not yet implemented")
    }

    override fun removeConnStatusObserver(param: ObserverRequestParam): ResponseParam {
        TODO("Not yet implemented")
    }

    override fun addPushObserver(param: ObserverRequestParam): ResponseParam {
        TODO("Not yet implemented")
    }

    override fun removePushObserver(param: ObserverRequestParam): ResponseParam {
        TODO("Not yet implemented")
    }

    override fun setAlias(param: SetAliasRequestParam, callback: (Result<ResponseParam>) -> Unit) {
        TODO("Not yet implemented")
    }

    override fun clearAlias(callback: (Result<ResponseParam>) -> Unit) {
        TODO("Not yet implemented")
    }

    override fun subscribeTopic(param: RequestParam): ResponseParam {
        TODO("Not yet implemented")
    }

    override fun unsubscribeTopic(param: RequestParam): ResponseParam {
        TODO("Not yet implemented")
    }

    override fun addTopicsObserver(param: ObserverRequestParam): ResponseParam {
        TODO("Not yet implemented")
    }

    override fun removeTopicsObserver(param: ObserverRequestParam): ResponseParam {
        TODO("Not yet implemented")
    }
}