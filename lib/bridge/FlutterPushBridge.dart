
import 'package:push_lzflutter/bridge.dart';
import 'package:push_lzflutter/PushManager.dart';
class FlutterPushBridgeImpl extends FlutterPushBridge {

  FlutterPushBridgeImpl({required this.pushManager});

  PushManager pushManager;

  @override
  ResponseParam onConnStatusObserverCall(ConnStatusObserverCallParam param) {
    pushManager.callConnStatusObserver(param.data.callbackKey, param.data.appId, param.data.data);
    return ResponseParam(code : ResponseCode.success);
  }

  @override
  ResponseParam onPushObserverCall(PushObserverCallParam param) {
    pushManager.callPushObserver(param.data.callbackKey, param.data.appId, param.data.data);
    return ResponseParam(code : ResponseCode.success);
  }

  @override
  ResponseParam onTopicObserverCall(TopicObserverCallParam param) {
    pushManager.callTopicObserverCall(param.data.callbackKey, param.data.appId, param.data.data);
    return ResponseParam(code : ResponseCode.success);
  }


}