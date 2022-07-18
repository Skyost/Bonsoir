#import "BonsoirPlugin.h"
#if __has_include(<bonsoir_darwin/bonsoir_darwin-Swift.h>)
#import <bonsoir_darwin/bonsoir_darwin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "bonsoir_darwin-Swift.h"
#endif

@implementation BonsoirPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftBonsoirPlugin registerWithRegistrar:registrar];
}
@end
