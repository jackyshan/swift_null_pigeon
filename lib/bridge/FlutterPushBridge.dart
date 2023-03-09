
import 'package:push_lzflutter/bridge.dart';
import 'package:push_lzflutter/PushManager.dart';
class FlutterPushBridgeImpl extends FlutterPushBridge {

  FlutterPushBridgeImpl({required this.pushManager});

  PushManager pushManager;

  @override
  ResponseParam onConnStatusObserverCall(ConnStatusObserverCallParam param) {
    pushManager.callConnStatusObserver(param.key, param.data);
    return ResponseParam(code : ResponseCode.success);
  }

  @override
  ResponseParam onPushObserverCall(PushObserverCallParam param) {
    pushManager.callPushObserver(param.key, param.data);
    return ResponseParam(code : ResponseCode.success);
  }

  @override
  ResponseParam onTopicObserverCall(TopicObserverCallParam param) {
    pushManager.callTopicObserverCall(param.key, param.data);
    return ResponseParam(code : ResponseCode.success);
  }


}