import 'package:flutter_test/flutter_test.dart';
import 'package:push_lzflutter/push_lzflutter.dart';
import 'package:push_lzflutter/push_lzflutter_platform_interface.dart';
import 'package:push_lzflutter/push_lzflutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPushLzflutterPlatform
    with MockPlatformInterfaceMixin
    implements PushLzflutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PushLzflutterPlatform initialPlatform = PushLzflutterPlatform.instance;

  test('$MethodChannelPushLzflutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPushLzflutter>());
  });

  test('getPlatformVersion', () async {
    PushLzflutter pushLzflutterPlugin = PushLzflutter();
    MockPushLzflutterPlatform fakePlatform = MockPushLzflutterPlatform();
    PushLzflutterPlatform.instance = fakePlatform;

    expect(await pushLzflutterPlugin.getPlatformVersion(), '42');
  });
}
