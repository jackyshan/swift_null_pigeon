import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'push_lzflutter_method_channel.dart';

abstract class PushLzflutterPlatform extends PlatformInterface {
  /// Constructs a PushLzflutterPlatform.
  PushLzflutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static PushLzflutterPlatform _instance = MethodChannelPushLzflutter();

  /// The default instance of [PushLzflutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelPushLzflutter].
  static PushLzflutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PushLzflutterPlatform] when
  /// they register themselves.
  static set instance(PushLzflutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
