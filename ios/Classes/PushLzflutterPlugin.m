#import "PushLzflutterPlugin.h"
#if __has_include(<push_lzflutter/push_lzflutter-Swift.h>)
#import <push_lzflutter/push_lzflutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "push_lzflutter-Swift.h"
#endif

@implementation PushLzflutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPushLzflutterPlugin registerWithRegistrar:registrar];
}
@end
