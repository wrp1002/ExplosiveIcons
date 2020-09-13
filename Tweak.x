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


//	=========================== Preference vars ===========================

bool enabled;

//	=========================== Other vars ===========================

int startupDelay = 5;
HBPreferences *preferences;
static MRYIPCCenter* center;
ExplosiveIcons *explosiveIcons;

//	=========================== Debugging stuff ===========================

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

	//	Shows an alert box. Used for debugging 
	+(void)ShowAlert:(NSString *)msg {
		if (!springboardReady) return;

		UIAlertController * alert = [UIAlertController
									alertControllerWithTitle:@"Alert"
									message:msg
									preferredStyle:UIAlertControllerStyleAlert];

		//Add Buttons
		UIAlertAction* dismissButton = [UIAlertAction
									actionWithTitle:@"Cool!"
									style:UIAlertActionStyleDefault
									handler:^(UIAlertAction * action) {
										//Handle dismiss button action here
										
									}];

		//Add your buttons to alert controller
		[alert addAction:dismissButton];

		[[self GetKeyWindow].rootViewController presentViewController:alert animated:YES completion:nil];
	}

	//	Show log with tweak name as prefix for easy grep
	+(void)Log:(NSString *)msg {
		NSLog(@"%@: %@", TWEAK_NAME, msg);
	}

	//	Log exception info
	+(void)LogException:(NSException *)e {
		NSLog(@"%@: NSException caught", TWEAK_NAME);
		NSLog(@"%@: Name:%@", TWEAK_NAME, e.name);
		NSLog(@"%@: Reason:%@", TWEAK_NAME, e.reason);
	}

	+(void)SpringBoardReady {
		springboardReady = true;
	}
@end


//	=========================== Classes / Functions ===========================

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
				//	First part of animation
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
			//[_springboardWindow makeKeyAndVisible];
			
			
		}
		return self;
	}

	-(void)addParticleWithColor:(UIColor *)color at:(CGPoint)pos {
		ExplosionParticleView *newView = [[ExplosionParticleView alloc] initAtPos:pos];
		newView.backgroundColor = color;
		[_springboardWindow addSubview:newView];
	}
@end


//	=========================== Hooks ===========================

%group Hooks

	%hook SpringBoard

		//	Called when springboard is finished launching
		-(void)applicationDidFinishLaunching:(id)application {
			%orig;
			[Debug SpringBoardReady];
			explosiveIcons = [[ExplosiveIcons alloc] init];
		}

	%end
		
		/*
	%hook SBIcon
		- (void)setUninstalled {
			%orig;
			[Debug Log:[NSString stringWithFormat:@"setUninstalled: %@", [self displayName]]];
		}
		- (void)completeUninstall {
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
				%orig;
			});
			[Debug Log:[NSString stringWithFormat:@"completeUninstall: %@", [self displayName]]];
		}
	%end

	*/

	%hook SBIconListView
		-(void)iconList:(id)arg1 didRemoveIcon:(id)arg2 {
			%orig;

			//[Debug Log:[NSString stringWithFormat:@"didRemoveIcon arg1:%@   arg2:%@", arg1, arg2]];
			[Debug Log:[NSString stringWithFormat:@"didRemoveIcon"]];

			SBApplicationIcon *appIcon = arg2;
			SBApplication *app = [appIcon application];
			NSString *bundleID = [app bundleIdentifier];

			if (!bundleID) {
				[Debug Log:[NSString stringWithFormat:@"No bundle ID"]];
				return;
			}

			[Debug Log:[NSString stringWithFormat:@"bundleID:%@", bundleID]];

			// Get the subviews of the view
			NSArray *subviews = [self subviews];

			for (id view in subviews) {
				if ([view isMemberOfClass:[%c(SBIconView) class]]) {
					SBIconView *iconView = view;

					SBIcon *icon = [iconView icon];
					NSString *checkID = [icon applicationBundleID];

					if ([checkID isEqualToString:bundleID]) {
						[Debug Log:[NSString stringWithFormat:@"Uninstalled: %@", bundleID]];

						// do this
						SBIconImageView *iconImage = [iconView _iconImageView];
						UIImage *image = [iconImage displayedImage];
						UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);

						//CGFloat x = iconView.frame.origin.x + iconView.frame.size.width / 2;
						//CGFloat y = iconView.frame.origin.y + iconView.frame.size.height / 2;

						//CGPoint pos = [self convertPoint:iconView.frame.origin toView:[explosiveIcons springboardWindow]];
						CGPoint pos = [self convertPoint:iconView.frame.origin toView:self];
						pos.x += iconView.frame.size.width / 2;
						pos.y += iconView.frame.size.height / 2;

						[Debug Log:[NSString stringWithFormat:@"X:%f  Y:%f", pos.x, pos.y]];
						//[explosiveIcons addParticleWithColor:[UIColor redColor] at:pos];
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
	%end

	/*
	%hook SBApplicationController
		-(void)uninstallApplication:(id)arg1 {
			[Debug Log:[NSString stringWithFormat:@"uninstallApplication: arg1:%@", arg1]];

			@try {
				SBApplication *app = arg1;
				NSString *bundleID = [app bundleIdentifier];
				[Debug Log:[NSString stringWithFormat:@"uninstallApplication  bundleID:%@", bundleID]];
				lastDeletedID = bundleID;
			}
			@catch (NSException *e) {
				[Debug LogException:e];
			}

			%orig;
		}
	%end*/


	/*%hook SBIconView
	 	- (void)prepareForReuse {
			[Debug Log:@"- (void)prepareForReuse;"];

			@try {
				SBIcon *icon = [self icon];
				NSString *bundleID = [icon applicationBundleID];

				[Debug Log:[NSString stringWithFormat:@"bundleID:%@   lastDeletedID:%@", bundleID, lastDeletedID]];

				if ([bundleID isEqualToString:lastDeletedID]) {
					[Debug Log:@"Uninstalled"];
					SBIconImageView *iconImage = [self _iconImageView];
					UIImage *image = [iconImage displayedImage];

					UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);

					CGFloat x = self.frame.origin.x + self.frame.size.width / 2;
					CGFloat y = self.frame.origin.y + self.frame.size.height / 2;

					CGPoint pos = [self convertPoint:self.frame.origin toView:[explosiveIcons springboardWindow]];

					[Debug Log:[NSString stringWithFormat:@"X:%f  Y:%f", pos.x, pos.y]];
					[explosiveIcons addColor:[UIColor redColor] atX:x atY:y];
				}
			}
			@catch (NSException *e) {
				[Debug LogException:e];
			}

			%orig;
		 }
	%end*/


%end



%group DelayedHooks

%end


//	=========================== Constructor stuff ===========================

%ctor {
	[Debug Log:[NSString stringWithFormat:@"============== %@ started ==============", TWEAK_NAME]];

	preferences = [[HBPreferences alloc] initWithIdentifier:BUNDLE];

	[preferences registerBool:&enabled default:true forKey:@"kEnabled"];

	NSString *bundleID = NSBundle.mainBundle.bundleIdentifier;
	if ([bundleID isEqualToString:@"com.apple.springboard"]) {}

	%init(Hooks);

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, startupDelay * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		%init(DelayedHooks);
	});
}
