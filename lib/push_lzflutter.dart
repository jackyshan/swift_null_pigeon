
import 'push_lzflutter_platform_interface.dart';

class PushLzflutter {
  Future<String?> getPlatformVersion() {
    return PushLzflutterPlatform.instance.getPlatformVersion();
  }
}
