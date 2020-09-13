#line 1 "Tweak.x"
#import <Cephei/HBPreferences.h>
#import <objc/runtime.h>
#import <MRYIPCCenter.h>
#include "Tweak.h"

#define TWEAK_NAME @"ExplosiveIcons"
#define BUNDLE [NSString stringWithFormat:@"com.wrp1002.%@", TWEAK_NAME]


@interface UIWindow ()
- (void)_setSecure:(BOOL)arg1;
@end

@class ExplosiveIcons;




bool enabled;



int startupDelay = 5;
HBPreferences *preferences;
static MRYIPCCenter* center;
ExplosiveIcons *explosiveIcons;



@interface Debug : NSObject
	+(UIWindow*)GetKeyWindow;
	+(void)ShowAlert:(NSString *)msg;
	+(void)Log:(NSString *)msg;
	+(void)LogException:(NSException *)e;
	+(void)SpringBoardReady;
@end

@implementation Debug
	static bool springboardReady = false;

	+(UIWindow*)GetKeyWindow {
		UIWindow        *foundWindow = nil;
		NSArray         *windows = [[UIApplication sharedApplication]windows];
		for (UIWindow   *window in windows) {
			if (window.isKeyWindow) {
				foundWindow = window;
				break;
			}
		}
		return foundWindow;
	}

	
	+(void)ShowAlert:(NSString *)msg {
		if (!springboardReady) return;

		UIAlertController * alert = [UIAlertController
									alertControllerWithTitle:@"Alert"
									message:msg
									preferredStyle:UIAlertControllerStyleAlert];

		
		UIAlertAction* dismissButton = [UIAlertAction
									actionWithTitle:@"Cool!"
									style:UIAlertActionStyleDefault
									handler:^(UIAlertAction * action) {
										
										
									}];

		
		[alert addAction:dismissButton];

		[[self GetKeyWindow].rootViewController presentViewController:alert animated:YES completion:nil];
	}

	
	+(void)Log:(NSString *)msg {
		NSLog(@"%@: %@", TWEAK_NAME, msg);
	}

	
	+(void)LogException:(NSException *)e {
		NSLog(@"%@: NSException caught", TWEAK_NAME);
		NSLog(@"%@: Name:%@", TWEAK_NAME, e.name);
		NSLog(@"%@: Reason:%@", TWEAK_NAME, e.reason);
	}

	+(void)SpringBoardReady {
		springboardReady = true;
	}
@end




@interface ExplosionParticleView : UIView
	-(id)initAtPos:(CGPoint)pos;
@end

@implementation ExplosionParticleView
	-(id)initAtPos:(CGPoint)pos {
		id obj = [super initWithFrame:CGRectMake(pos.x - 10, pos.y - 10, 20, 20)];

		[UIView animateWithDuration:1.0f
			delay:0.0f
			options:UIViewAnimationOptionCurveLinear
			animations:^{
				
				self.alpha = 0.0;

			} completion:^(BOOL finished) {
				[super removeFromSuperview];
				[Debug Log:@"Done"];
			}
		];

		return obj;
	}
@end

@interface ExplosiveIcons : NSObject { }
@property (nonatomic, retain) UIWindow *springboardWindow;
@end

@implementation ExplosiveIcons
	- (id)init {
		[Debug Log:@"ExplosiveIcons init()"];
		if (self = [super init]) {
			_springboardWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
			_springboardWindow.windowLevel = UIWindowLevelAlert;
			[_springboardWindow setHidden:NO];
			[_springboardWindow _setSecure:YES];
			[_springboardWindow setUserInteractionEnabled:NO];
			_springboardWindow.backgroundColor = [UIColor clearColor];
			
			
			
		}
		return self;
	}

	-(void)addParticleWithColor:(UIColor *)color at:(CGPoint)pos {
		ExplosionParticleView *newView = [[ExplosionParticleView alloc] initAtPos:pos];
		newView.backgroundColor = color;
		[_springboardWindow addSubview:newView];
	}
@end





#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class SBIconView; @class SBIconListView; @class SpringBoard; 

static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$SBIconView(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBIconView"); } return _klass; }
#line 153 "Tweak.x"
static void (*_logos_orig$Hooks$SpringBoard$applicationDidFinishLaunching$)(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$Hooks$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); static void (*_logos_orig$Hooks$SBIconListView$iconList$didRemoveIcon$)(_LOGOS_SELF_TYPE_NORMAL SBIconListView* _LOGOS_SELF_CONST, SEL, id, id); static void _logos_method$Hooks$SBIconListView$iconList$didRemoveIcon$(_LOGOS_SELF_TYPE_NORMAL SBIconListView* _LOGOS_SELF_CONST, SEL, id, id); 

	

		
		static void _logos_method$Hooks$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id application) {
			_logos_orig$Hooks$SpringBoard$applicationDidFinishLaunching$(self, _cmd, application);
			[Debug SpringBoardReady];
			explosiveIcons = [[ExplosiveIcons alloc] init];
		}

	
		
		















	
		static void _logos_method$Hooks$SBIconListView$iconList$didRemoveIcon$(_LOGOS_SELF_TYPE_NORMAL SBIconListView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1, id arg2) {
			_logos_orig$Hooks$SBIconListView$iconList$didRemoveIcon$(self, _cmd, arg1, arg2);

			
			[Debug Log:[NSString stringWithFormat:@"didRemoveIcon"]];

			SBApplicationIcon *appIcon = arg2;
			SBApplication *app = [appIcon application];
			NSString *bundleID = [app bundleIdentifier];

			if (!bundleID) {
				[Debug Log:[NSString stringWithFormat:@"No bundle ID"]];
				return;
			}

			[Debug Log:[NSString stringWithFormat:@"bundleID:%@", bundleID]];

			
			NSArray *subviews = [self subviews];

			for (id view in subviews) {
				if ([view isMemberOfClass:[_logos_static_class_lookup$SBIconView() class]]) {
					SBIconView *iconView = view;

					SBIcon *icon = [iconView icon];
					NSString *checkID = [icon applicationBundleID];

					if ([checkID isEqualToString:bundleID]) {
						[Debug Log:[NSString stringWithFormat:@"Uninstalled: %@", bundleID]];

						
						SBIconImageView *iconImage = [iconView _iconImageView];
						UIImage *image = [iconImage displayedImage];
						UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);

						
						

						
						CGPoint pos = [self convertPoint:iconView.frame.origin toView:self];
						pos.x += iconView.frame.size.width / 2;
						pos.y += iconView.frame.size.height / 2;

						[Debug Log:[NSString stringWithFormat:@"X:%f  Y:%f", pos.x, pos.y]];
						
						ExplosionParticleView *newView = [[ExplosionParticleView alloc] initAtPos:pos];
						newView.backgroundColor = [UIColor redColor];
						[self addSubview:newView];
					}
				}
				else {
					[Debug Log:[NSString stringWithFormat:@"Not SBIconView :("]];
				}
				
			}
		}
	

	



















	













































static __attribute__((constructor)) void _logosLocalCtor_3aaf24e0(int __unused argc, char __unused **argv, char __unused **envp) {
	[Debug Log:[NSString stringWithFormat:@"============== %@ started ==============", TWEAK_NAME]];

	preferences = [[HBPreferences alloc] initWithIdentifier:BUNDLE];

	[preferences registerBool:&enabled default:true forKey:@"kEnabled"];

	NSString *bundleID = NSBundle.mainBundle.bundleIdentifier;
	if ([bundleID isEqualToString:@"com.apple.springboard"]) {}

	{Class _logos_class$Hooks$SpringBoard = objc_getClass("SpringBoard"); { MSHookMessageEx(_logos_class$Hooks$SpringBoard, @selector(applicationDidFinishLaunching:), (IMP)&_logos_method$Hooks$SpringBoard$applicationDidFinishLaunching$, (IMP*)&_logos_orig$Hooks$SpringBoard$applicationDidFinishLaunching$);}Class _logos_class$Hooks$SBIconListView = objc_getClass("SBIconListView"); { MSHookMessageEx(_logos_class$Hooks$SBIconListView, @selector(iconList:didRemoveIcon:), (IMP)&_logos_method$Hooks$SBIconListView$iconList$didRemoveIcon$, (IMP*)&_logos_orig$Hooks$SBIconListView$iconList$didRemoveIcon$);}}

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, startupDelay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		{}
	});
}
