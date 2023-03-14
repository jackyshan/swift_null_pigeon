
import 'package:push_lzflutter/bridge.dart';

mixin TopicObserver {
  void onSubscribe(String appId, String topic, TopicSubscribeResult result);
}

mixin PushObserver {
  void onPush(String appId, PushMessageData pushData);
}

mixin ConnectStatusObserver {
  void onConnectStatusChanged(String appId, ConnectInfo info);
}