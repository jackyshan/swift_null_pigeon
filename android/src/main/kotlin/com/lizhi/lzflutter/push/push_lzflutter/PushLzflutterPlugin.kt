package com.lizhi.lzflutter.push.push_lzflutter

import androidx.annotation.NonNull
import com.lizhi.flutter_pigeon.FlutterPushBridge
import com.lizhi.flutter_pigeon.NativePushBridge

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodChannel

/** PushLzflutterPlugin */
class PushLzflutterPlugin: FlutterPlugin {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  private var nativePushManager: NativePushManager? = null
  private var flutterPushBridge: FlutterPushBridge? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    flutterPushBridge = FlutterPushBridge(flutterPluginBinding.binaryMessenger)
    nativePushManager = NativePushManager(flutterPushBridge!!)
    NativePushBridge.setUp(flutterPluginBinding.binaryMessenger, nativePushManager)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    NativePushBridge.setUp(binding.binaryMessenger, null)
    flutterPushBridge = null
    nativePushManager = null
    channel.setMethodCallHandler(null)
  }
}
