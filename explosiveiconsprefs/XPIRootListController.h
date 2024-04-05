#import <Preferences/PSListController.h>
#import <Cephei/HBPreferences.h>
#import <spawn.h>

#define TWEAK_NAME @"ExplosiveIcons"
#define BUNDLE [NSString stringWithFormat:@"com.wrp1002.%@", [TWEAK_NAME lowercaseString]]
#define BUNDLE_NOTIFY "com.wrp1002.explosiveicons/ReloadPrefs"

@interface XPIRootListController : PSListController

@end
