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
  late String appId;
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

class SetAliasParam {
  late String appId;
  late List<String?> alias;
}

class SetAliasRequestParam {
  late String key;
  late SetAliasParam data;
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
  /// 初始化
  ///
  ResponseParam init(InitRequestParam param);

  ///
  /// 连接
  /// 
  @async
  ResponseParam connect(InitRequestParam param);

  ///
  /// 断开连接
  /// param: appId
  /// 
  ResponseParam disconnect(RequestParam param);

  ///
  /// 添加连接状态监听
  /// 
  ResponseParam addConnStatusObserver(ObserverRequestParam param);

  ///
  /// 移除连接状态监听
  /// 
  ResponseParam removeConnStatusObserver(ObserverRequestParam param);

  ///
  /// 添加推送消息监听
  /// 
  ResponseParam addPushObserver(ObserverRequestParam param);

  ///
  /// 移除连接状态监听
  /// 
  ResponseParam removePushObserver(ObserverRequestParam param);

  ///
  /// 设置别名
  /// 
  @async
  ResponseParam setAlias(SetAliasRequestParam param);

  ///
  /// 清除别名
  /// param: appId
  /// 
  @async
  ResponseParam clearAlias(RequestParam param);

  ///
  /// 订阅主题
  /// param: appId, topic
  /// 
  ResponseParam subscribeTopic(RequestParam param);

  ///
  /// 取消订阅主题
  /// param: appId, topic
  /// 
  ResponseParam unsubscribeTopic(RequestParam param);

  ///
  /// 添加主题订阅监听
  /// 
  ResponseParam addTopicsObserver(ObserverRequestParam param);

  ///
  /// 移除主题订阅监听
  /// 
  ResponseParam removeTopicsObserver(ObserverRequestParam param);
}


enum ConnectStatus {
  connecting,  //连接中 1
  connected,  //连接成功 2
  disconnect //连接断开 3
}
///
/// 连接信息
/// 
class ConnectInfo {
  late int errorCode;
  String? errorMessage;
  ConnectStatus? connStatus;
}

class ConnStatusCall {
  late String callbackKey;
  late String appId;
  late ConnectInfo data;
}
class ConnStatusObserverCallParam {
  late String key;
  late ConnStatusCall data;
}

class TransferData {
  String? seq;
  String? payloadId;
  String? payload;
  late int timestamp; //后段发送来的时间搓
  String? deviceId;
  String? alias;
  String? topic;
}
///
/// 推送消息
/// 
class PushMessageData {
  String? type;
  TransferData? data;
}

class PushCall {
  late String callbackKey;
  late String appId;
  late PushMessageData data;
}
class PushObserverCallParam {
  late String key;
  late PushCall data;
}


enum TopicResultStatus {
  invalid,
  processing,
  available;
}
///
/// 订阅结果
/// 
class TopicSubscribeResult {
  late TopicResultStatus status;
  late int code;
  String? msg;
}

class TopicSubscribeData {
  late String topic;
  late TopicSubscribeResult result;
}

class TopicCall {
  late String callbackKey;
  late String appId;
  late TopicSubscribeData data;
}
class TopicObserverCallParam {
  late String key;
  late TopicCall data;
}

@FlutterApi()
abstract class FlutterPushBridge {
  ResponseParam onConnStatusObserverCall(ConnStatusObserverCallParam param);
  ResponseParam onPushObserverCall(PushObserverCallParam param);
  ResponseParam onTopicObserverCall(TopicObserverCallParam param);
}