
import 'package:push_lzflutter/bridge.dart';

mixin TopicObserver {
  void onSubscribe(String topic, SubscribeResult result);
}

mixin PushObserver {
  void onPush(PushData pushData);
}

mixin ConnectStatusObserver {
  void onConnectStatusChanged(ConnInfo info);
}