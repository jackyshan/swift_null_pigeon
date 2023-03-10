
import 'package:push_lzflutter/bridge.dart';

mixin TopicObserver {
  void onSubscribe(String topic, TopicSubscribeResult result);
}

mixin PushObserver {
  void onPush(PushMessageData pushData);
}

mixin ConnectStatusObserver {
  void onConnectStatusChanged(ConnectInfo info);
}