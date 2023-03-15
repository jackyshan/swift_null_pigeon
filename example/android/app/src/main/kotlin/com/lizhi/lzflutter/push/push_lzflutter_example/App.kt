package com.lizhi.lzflutter.push.push_lzflutter_example

import android.app.Activity
import android.app.Application
import android.util.Log
import androidx.annotation.CallSuper
import com.lizhi.component.basetool.env.AppEnvironment
import com.lizhi.component.basetool.env.Environments
import com.lizhi.itnet.configure.model.Region
import com.yibasan.lizhifm.itnet.conf.ITNetConf
import com.yibasan.lizhifm.itnet.conf.ITNetConfBuilder
import com.yibasan.lizhifm.itnet.conf.ITNetModule
import com.yibasan.lizhifm.sdk.platformtools.ApplicationContext
import com.yibasan.lizhifm.sdk.platformtools.MobileUtils
import io.flutter.app.FlutterApplication
import io.reactivex.plugins.RxJavaPlugins

class App: FlutterApplication() {

    @CallSuper
    override fun onCreate() {
        RxJavaPlugins.setErrorHandler {
            it.printStackTrace()
        }
        initdItNet(this)
        super.onCreate()
    }


    companion object {
        var itNetInit = false
        fun initdItNet(context: Application) {
            ApplicationContext.setApplication(context)
            if (!itNetInit) {
                Environments.changeEnv(context, AppEnvironment.TOWER)
                itNetInit = true
                val itnetConfBuilder = ITNetConfBuilder.Builder()
                    .setAppId(22631490) //设置AppId，通过闪电后台配置生成，通过它来区分不同应用，已有AppId查看这里https://ones.lizhi.fm/wiki#/team/6XRfASKf/share/5jusqjj5/page/TdHc5VaH
                    .setDeviceId(MobileUtils.getDeviceId())//设置设备id，推荐使用大数据部门统一提供的获取方式
//                .setNetStateListener(getNetStateListener())
                    .setRegion(Region.DOMESTIC)
                    .build()
                //网络库内部开始初始化
                try {
                    ITNetConf.init(
                        context,
                        itnetConfBuilder,
                        ITNetModule.Builder().all().build()
                    )
//                ITClient.globalHeaderProvider(getIDLHeader())
//                ITClient.gHttpInterceptor(LoggerInterceptor("LzHttp"))
//                PBHelper.setAppId(Constant.APP_ID)
                } catch (e: Throwable) {
                    Log.e("MainActivity", e.message, e)
                }
            }
        }
    }

}