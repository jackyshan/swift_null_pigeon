import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:push_lzflutter/bridge.dart';
import 'package:push_lzflutter/push_lzflutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _pushLzflutterPlugin = PushLzflutter();

  @override
  void initState() {
    super.initState();
    initPlatformState();

    _pushLzflutterPlugin.getPushManager().createPushBridge(PushConfig(
        hostApp: "saya",
        appId: "22631490",
        deviceId: "N_399daa7b0ccd5d9a",
        defaultHosts: ['ws://172.17.32.53:39999/push'])).connect();
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

                  }, child: const Text('建立连接')),
                  TextButton(onPressed: () {

                  }, child: const Text('断开连接')),
                  TextButton(onPressed: () {

                  }, child: const Text('设置别名')),
                  TextButton(onPressed: () {

                  }, child: const Text('清除别名')),
                ],
              ),
              Row(children: [
                TextButton(onPressed: () {

                }, child: const Text('订阅topic')),
                TextButton(onPressed: () {

                }, child: const Text('取消订阅topic')),
              ],)
            ],
          ),
        ),
      ),
    );
  }
}
