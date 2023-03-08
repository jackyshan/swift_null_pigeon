import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:push_lzflutter/push_lzflutter_method_channel.dart';

void main() {
  MethodChannelPushLzflutter platform = MethodChannelPushLzflutter();
  const MethodChannel channel = MethodChannel('push_lzflutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
