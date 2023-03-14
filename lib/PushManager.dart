
import 'package:flutter/services.dart';
import 'package:push_lzflutter/bridge.dart';
import 'package:push_lzflutter/bridge/FlutterPushBridge.dart';
import 'package:uuid/uuid.dart';

import 'observers.dart';

class PushManager {

  late final MethodChannel _methodChannel;
  late final NativePushBridge _nativePushBridge;

  PushManager() {
    _methodChannel = const MethodChannel('push_lzflutter');
    _nativePushBridge = NativePushBridge(binaryMessenger: _methodChannel.binaryMessenger);
    FlutterPushBridge.setup(FlutterPushBridgeImpl(pushManager: this), binaryMessenger: _methodChannel.binaryMessenger);
  }



  Map<String, TopicObserver> topicObservers = {};
  Map<String, PushObserver> pushObservers = {};
  Map<String, ConnectStatusObserver> connObservers = {};

  void callConnStatusObserver(String key, String? appId, ConnectInfo connInfo) {
    connObservers[key]?.onConnectStatusChanged(connInfo);
  }

  void callPushObserver(String key, String? appId, PushMessageData pushData) {
    pushObservers[key]?.onPush(pushData);
  }

  void callTopicObserverCall(String key, String? appId, TopicSubscribeData topicData) {
    topicObservers[key]?.onSubscribe(topicData.topic, topicData.result);
  }

  ///
  /// 连接
  /// */
  void connect(PushConfig config) async {
    await _nativePushBridge.connect(InitRequestParam(key: "push_init", data: config));
  }

  ///
  /// 断开连接
  /// */
  void disconnect(String appId) async {
    await _nativePushBridge.disconnect(RequestParam(key: "push_disconnect", data: {'appId' : appId}));
  }

  ///
  /// 添加连接状态监听
  /// */
  void addConnStatusObserver(String appId, ConnectStatusObserver observer) async {
    var contain = connObservers.values.contains(observer);
    if (!contain) {
      var callbackKey = 'conn_status_${const Uuid().v1()}';
      connObservers[callbackKey] = observer;
      await _nativePushBridge.addConnStatusObserver(ObserverRequestParam(
          key: 'push_addConnStatusObserver',
          data: ObserverData(appId: appId, callbackKey: callbackKey)));
    }
  }

  ///
  /// 移除连接状态监听
  /// */
  void removeConnStatusObserver(String appId, ConnectStatusObserver observer) async {
    String? callbackKey;
    for (MapEntry<String, ConnectStatusObserver> entry
        in connObservers.entries) {
      if (entry.value == observer) {
        callbackKey = entry.key;
        break;
      }
    }
    if (callbackKey != null) {
      connObservers.remove(callbackKey);
      await _nativePushBridge.removeConnStatusObserver(ObserverRequestParam(
          key: 'push_removeConnStatusObserver',
          data: ObserverData(appId: appId, callbackKey: callbackKey)));
    }
  }

  ///
  /// 添加推送消息监听
  /// */
  void addPushObserver(String appId, PushObserver observer) async {
    var contain = pushObservers.containsValue(observer);
    if (!contain) {
      var callbackKey = 'push_${const Uuid().v1()}';
      pushObservers[callbackKey] = observer;
      await _nativePushBridge.addPushObserver(ObserverRequestParam(
          key: 'push_addPushObserver',
          data: ObserverData(appId: appId, callbackKey: callbackKey)));
    }
  }

  ///
  /// 移除连接状态监听
  /// */
  void removePushObserver(String appId, PushObserver observer) async {
    String? callbackKey;
    for (MapEntry<String, PushObserver> entry in pushObservers.entries) {
      if (entry.value == observer) {
        callbackKey = entry.key;
        break;
      }
    }
    if (callbackKey != null) {
      pushObservers.remove(callbackKey);
      await _nativePushBridge.removePushObserver(ObserverRequestParam(
          key: 'push_removePushObserver',
          data: ObserverData(appId: appId, callbackKey: callbackKey)));
    }
  }

  ///
  /// 设置别名
  /// */
  Future<ResponseParam> setAlias(String appId, List<String> alias) async {
    return await _nativePushBridge.setAlias(SetAliasRequestParam(key: 'push_setAlias', data: SetAliasParam(appId: appId, alias: alias)));
  }

  ///
  /// 清除别名
  /// */
  Future<ResponseParam> clearAlias(String appId) async {
    return await _nativePushBridge.clearAlias(RequestParam(key: "push_clearAlias", data: {'appId' : appId}));
  }

  ///
  /// 订阅主题
  /// */
  void subscribeTopic(String appId, String topic) async {
    await _nativePushBridge.subscribeTopic(RequestParam(key: 'push_subscribeTopic', data: {'topic': topic, 'appId':appId}));
  }

  ///
  /// 取消订阅主题
  /// */
  void unsubscribeTopic(String appId, String topic) async {
    await _nativePushBridge.unsubscribeTopic(RequestParam(key: 'push_unsubscribeTopic', data: {'topic': topic, 'appId':appId}));
  }

  ///
  /// 添加主题订阅监听
  /// */
  void addTopicsObserver(String appId, TopicObserver observer) async {
    var contain = topicObservers.containsValue(observer);
    if (!contain) {
      var callbackKey = 'topic_${const Uuid().v1()}';
      topicObservers[callbackKey] = observer;
      await _nativePushBridge.addTopicsObserver(ObserverRequestParam(
          key: 'push_addTopicsObserver',
          data: ObserverData(appId: appId, callbackKey: callbackKey)));
    }
  }

  ///
  /// 移除主题订阅监听
  /// */
  void removeTopicsObserver(String appId, TopicObserver observer) async {
    String? callbackKey;
    for (MapEntry<String, TopicObserver> entry in topicObservers.entries) {
      if (entry.value == observer) {
        callbackKey = entry.key;
        break;
      }
    }
    if (callbackKey != null) {
      topicObservers.remove(callbackKey);
      await _nativePushBridge.removeTopicsObserver(ObserverRequestParam(
          key: 'push_removeTopicsObserver',
          data: ObserverData(appId: appId, callbackKey: callbackKey)));
    }
  }
}