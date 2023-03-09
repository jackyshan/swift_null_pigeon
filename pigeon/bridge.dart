import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  // copyrightHeader: 'pigeon/copyright.txt',
  input: 'pigeon/bridge.dart',
  dartOut: 'lib/bridge.dart',
  kotlinOptions: KotlinOptions(package: 'com.lizhi.flutter_pigeon'),
  kotlinOut: 'android/src/main/kotlin/com/lizhi/flutter_pigeon/Bridge.kt',
  swiftOut: 'ios/Classes/bridge.swift',
))

enum ResponseCode {
  success,
  fail,
}

class RequestParam {
  late String key;
  Map<String?, Object?>? data;
}
class ResponseParam {
  late ResponseCode code;
  String? message;
  Map<String?, Object?>? data;
}

// init
class InitRequestParam {
  late String key;
  late PushConfig data;
}

class ObserverData {
  late String callbackKey;
}

class ObserverRequestParam {
  late String key;
  late ObserverData data;
}

class ObserverCallRequestParam {
  late String key;
  late ObserverData data;
}

class SetAliasRequestParam {
  late String key;
  late List<String?> alias;
}

class PushConfig {
  late String hostApp;
  late String appId;
  late String deviceId;
  List<String?>? defaultHosts;
}

@HostApi()
abstract class NativePushBridge {

  ///
  /// 连接
  /// */
  @async
  ResponseParam connect(InitRequestParam param);

  ///
  /// 断开连接
  /// */
  ResponseParam disconnect();

  ///
  /// 添加连接状态监听
  /// */
  ResponseParam addConnStatusObserver(ObserverRequestParam param);

  ///
  /// 移除连接状态监听
  /// */
  ResponseParam removeConnStatusObserver(ObserverRequestParam param);

  ///
  /// 添加推送消息监听
  /// */
  ResponseParam addPushObserver(ObserverRequestParam param);

  ///
  /// 移除连接状态监听
  /// */
  ResponseParam removePushObserver(ObserverRequestParam param);

  ///
  /// 设置别名
  /// */
  @async
  ResponseParam setAlias(SetAliasRequestParam param);

  ///
  /// 清除别名
  /// */
  @async
  ResponseParam clearAlias();

  ///
  /// 订阅主题
  /// */
  ResponseParam subscribeTopic(RequestParam param);

  ///
  /// 取消订阅主题
  /// */
  ResponseParam unsubscribeTopic(RequestParam param);

  ///
  /// 添加主题订阅监听
  /// */
  ResponseParam addTopicsObserver(ObserverRequestParam param);

  ///
  /// 移除主题订阅监听
  /// */
  ResponseParam removeTopicsObserver(ObserverRequestParam param);
}

///
/// 连接信息
/// */
class ConnInfo {
  //todo
}

class ConnStatusObserverCallParam {
  late String key;
  late ConnInfo data;
}

///
/// 推送消息
/// */
class PushData {
  //todo
}

class PushObserverCallParam {
  late String key;
  late PushData data;
}

///
/// 订阅结果
/// */
class SubscribeResult {
  //todo
}

class TopicData {
  late String topic;
  late SubscribeResult result;
}

class TopicObserverCallParam {
  late String key;
  late TopicData data;
}

@FlutterApi()
abstract class FlutterPushBridge {
  ResponseParam onConnStatusObserverCall(ConnStatusObserverCallParam param);
  ResponseParam onPushObserverCall(PushObserverCallParam param);
  ResponseParam onTopicObserverCall(TopicObserverCallParam param);
}