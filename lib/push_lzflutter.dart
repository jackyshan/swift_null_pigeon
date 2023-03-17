
import 'package:push_lzflutter/PushManager.dart';

import 'push_lzflutter_platform_interface.dart';

class PushLzflutter {
  Future<String?> getPlatformVersion() {
    return PushLzflutterPlatform.instance.getPlatformVersion();
  }

  PushManager getPushManager() {
    return PushLzflutterPlatform.instance.getPushManager();
  }
}
