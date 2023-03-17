import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:push_lzflutter/PushManager.dart';
import 'package:push_lzflutter/bridge.dart';
import 'package:push_lzflutter/observers.dart';
import 'package:push_lzflutter/push_lzflutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with ConnectStatusObserver, PushObserver, TopicObserver {
  String _platformVersion = 'Unknown';
  final _pushLzflutterPlugin = PushLzflutter();
  late PushBridge pushBridge;

  @override
  void initState() {
    super.initState();
    initPlatformState();

    pushBridge = _pushLzflutterPlugin.getPushManager().createPushBridge(
        PushConfig(
            hostApp: "",
            appId: "22631490",
            deviceId: "ASD",
            defaultHosts: [
              'ws://172.17.32.53:39999/push'
            ]));
    pushBridge.addConnStatusObserver(this);
    pushBridge.addPushObserver(this);
    pushBridge.addTopicsObserver(this);
  }

  @override
  void dispose() {
    pushBridge.removeConnStatusObserver(this);
    pushBridge.removePushObserver(this);
    pushBridge.removeTopicsObserver(this);
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _pushLzflutterPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  List<PushMessageData> messages = [];

  ConnectInfo? info;

  TopicSubscribeResult? topicResult;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
          child: Column(
            children: [
              Row(
                children: [
                  TextButton(onPressed: () {
                    pushBridge.connect();
                  }, child: const Text('建立连接')),
                  TextButton(onPressed: () {
                    pushBridge.disconnect();
                  }, child: const Text('断开连接')),
                  TextButton(onPressed: () {
                    pushBridge.setAlias(["5116305868660409516"]);
                  }, child: const Text('设置别名')),
                  TextButton(onPressed: () {
                    pushBridge.clearAlias();
                  }, child: const Text('清除别名')),
                ],
              ),
              Row(
                children: [
                  TextButton(onPressed: () {
                    pushBridge.subscribeTopic('LAMP_LIVE_5116305868660409516');
                  }, child: const Text('订阅topic')),
                  TextButton(onPressed: () {
                    pushBridge.unsubscribeTopic('LAMP_LIVE_5116305868660409516');
                  }, child: const Text('取消订阅topic')),
                ],
              ),
              Column(
                children: [
                  Text('连接状态:${info?.connStatus ?? ''}'),
                  Text('订阅状态${topicResult?.status.name ?? ''}'),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: messages
                    .map((e) => 'msg:${e.data?.payload}')
                    .map((e) => Text(e))
                    .toList(),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onConnectStatusChanged(String appId, ConnectInfo info) {
    this.info = info;
    setState(() {
      info;
    });
  }

  @override
  void onPush(String appId, PushMessageData pushData) {
    messages.add(pushData);
    setState(() {
      messages;
    });
  }

  @override
  void onSubscribe(String appId, String topic, TopicSubscribeResult result) {
    topicResult = result;
    setState(() {
      topicResult;
    });
  }
}
