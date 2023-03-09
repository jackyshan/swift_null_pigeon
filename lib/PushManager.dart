
import 'package:flutter/services.dart';
import 'package:push_lzflutter/bridge.dart';
import 'package:push_lzflutter/bridge/FlutterPushBridge.dart';
import 'package:uuid/uuid.dart';

import 'observers.dart';

class PushManager {

  late final MethodChannel _methodChannel;
  late final NativePushBridge _nativePushBridge;

  PushManager._() {
    _methodChannel = const MethodChannel('push_lzflutter');
    _nativePushBridge = NativePushBridge(binaryMessenger: _methodChannel.binaryMessenger);
    FlutterPushBridge.setup(FlutterPushBridgeImpl(pushManager: this), binaryMessenger: _methodChannel.binaryMessenger);
  }



  Map<String, TopicObserver> topicObservers = {};
  Map<String, PushObserver> pushObservers = {};
  Map<String, ConnectStatusObserver> connObservers = {};

  void callConnStatusObserver(String key, ConnInfo connInfo) {
    connObservers[key]?.onConnectStatusChanged(connInfo);
  }

  void callPushObserver(String key, PushData pushData) {
    pushObservers[key]?.onPush(pushData);
  }

  void callTopicObserverCall(String key, TopicData topicData) {
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
  void disconnect() async {
    await _nativePushBridge.disconnect();
  }

  ///
  /// 添加连接状态监听
  /// */
  void addConnStatusObserver(ConnectStatusObserver observer) async {
    var contain = connObservers.values.contains(observer);
    if (!contain) {
      var callbackKey = 'conn_status_${const Uuid().v1()}';
      connObservers[callbackKey] = observer;
      await _nativePushBridge.addConnStatusObserver(ObserverRequestParam(
          key: 'push_addConnStatusObserver',
          data: ObserverData(callbackKey: callbackKey)));
    }
  }

  ///
  /// 移除连接状态监听
  /// */
  void removeConnStatusObserver(ConnectStatusObserver observer) async {
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
          data: ObserverData(callbackKey: callbackKey)));
    }
  }

  ///
  /// 添加推送消息监听
  /// */
  void addPushObserver(PushObserver observer) async {
    var contain = pushObservers.containsValue(observer);
    if (!contain) {
      var callbackKey = 'push_${const Uuid().v1()}';
      pushObservers[callbackKey] = observer;
      await _nativePushBridge.addPushObserver(ObserverRequestParam(
          key: 'push_addPushObserver',
          data: ObserverData(callbackKey: callbackKey)));
    }
  }

  ///
  /// 移除连接状态监听
  /// */
  void removePushObserver(PushObserver observer) async {
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
          data: ObserverData(callbackKey: callbackKey)));
    }
  }

  ///
  /// 设置别名
  /// */
  Future<ResponseParam> setAlias(List<String> alias) async {
    return await _nativePushBridge.setAlias(SetAliasRequestParam(key: 'push_setAlias', alias: alias));
  }

  ///
  /// 清除别名
  /// */
  Future<ResponseParam> clearAlias() async {
    return await _nativePushBridge.clearAlias();
  }

  ///
  /// 订阅主题
  /// */
  void subscribeTopic(String topic) async {
    await _nativePushBridge.subscribeTopic(RequestParam(key: 'push_subscribeTopic', data: {'topic': topic}));
  }

  ///
  /// 取消订阅主题
  /// */
  void unsubscribeTopic(String topic) async {
    await _nativePushBridge.unsubscribeTopic(RequestParam(key: 'push_unsubscribeTopic', data: {'topic': topic}));
  }

  ///
  /// 添加主题订阅监听
  /// */
  void addTopicsObserver(TopicObserver observer) async {
    var contain = topicObservers.containsValue(observer);
    if (!contain) {
      var callbackKey = 'topic_${const Uuid().v1()}';
      topicObservers[callbackKey] = observer;
      await _nativePushBridge.addTopicsObserver(ObserverRequestParam(
          key: 'push_addTopicsObserver',
          data: ObserverData(callbackKey: callbackKey)));
    }
  }

  ///
  /// 移除主题订阅监听
  /// */
  void removeTopicsObserver(TopicObserver observer) async {
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
          data: ObserverData(callbackKey: callbackKey)));
    }
  }
}