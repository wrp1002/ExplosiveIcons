#import <Cephei/HBPreferences.h>
#import <objc/runtime.h>
#import <MRYIPCCenter.h>
#include "Tweak.h"

#define TWEAK_NAME @"ExplosiveIcons"
#define BUNDLE [NSString stringWithFormat:@"com.wrp1002.%@", TWEAK_NAME]


@interface UIWindow ()
- (void)_setSecure:(BOOL)arg1;
@end

@interface SBIconListView : UIView
	@property (nonatomic, retain)UIDynamicAnimator *ExplosiveIcons_DynamicAnimator;
	@property (nonatomic, retain)UIGravityBehavior *ExplosiveIcons_GravityBehavior;
	@property (nonatomic, retain)UICollisionBehavior *ExplosiveIcons_CollisionBehavior;
	@property (nonatomic, retain)UIDynamicItemBehavior *ExplosiveIcons_UIDynamicItemBehavior;
@end

@interface UIDynamicItem
@end


//	=========================== Preference vars ===========================

bool enabled;

//	=========================== Other vars ===========================

int startupDelay = 5;
HBPreferences *preferences;
static MRYIPCCenter* center;

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
		self.layer.cornerRadius = 10;

		[UIView animateWithDuration:2.0f
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


//	=========================== Hooks ===========================

%group DelayedHooks
	%hook SBIconListView
		%property (nonatomic, retain)UIDynamicAnimator *ExplosiveIcons_DynamicAnimator;
		%property (nonatomic, retain)UIGravityBehavior *ExplosiveIcons_GravityBehavior;
		%property (nonatomic, retain)UICollisionBehavior *ExplosiveIcons_CollisionBehavior;
		%property (nonatomic, retain)UIDynamicItemBehavior *ExplosiveIcons_UIDynamicItemBehavior;

		-(id)initWithModel:(id)arg1 layoutProvider:(id)arg2 iconLocation:(id)arg3 orientation:(long long)arg4 iconViewProvider:(id)arg5 {
			id obj = %orig;

			[Debug Log:@"SBIconListView init()"];

			

			return obj;
		}

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

						SBIconImageView *iconImage = [iconView _iconImageView];
						UIImage *image = [iconImage displayedImage];
						UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);

						//CGFloat x = iconView.frame.origin.x + iconView.frame.size.width / 2;
						//CGFloat y = iconView.frame.origin.y + iconView.frame.size.height / 2;
						//CGPoint pos = [self convertPoint:iconView.frame.origin toView:[explosiveIcons springboardWindow]];

						//	Position of the deleted icon
						CGPoint pos = iconView.frame.origin;

						//	Move point to center of icon
						pos.x += iconView.frame.size.width / 2; 
						pos.y += iconView.frame.size.height / 2;

						[Debug Log:[NSString stringWithFormat:@"X:%f  Y:%f", pos.x, pos.y]];
						//[explosiveIcons addParticleWithColor:[UIColor redColor] at:pos];
						


						self.ExplosiveIcons_DynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self];

						self.ExplosiveIcons_GravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[]];
						self.ExplosiveIcons_GravityBehavior.gravityDirection = CGVectorMake(0, 5);

						self.ExplosiveIcons_CollisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[]];
						self.ExplosiveIcons_CollisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
						self.ExplosiveIcons_CollisionBehavior.collisionMode = UICollisionBehaviorModeEverything;

						self.ExplosiveIcons_UIDynamicItemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[]];
						self.ExplosiveIcons_UIDynamicItemBehavior.elasticity = 0.7;

						for (int i = 0; i < 10; i++) {
							ExplosionParticleView *newView = [[ExplosionParticleView alloc] initAtPos:pos];
							newView.backgroundColor = [UIColor redColor];
							[self addSubview:newView];
							[self.ExplosiveIcons_GravityBehavior addItem:newView];
							[self.ExplosiveIcons_CollisionBehavior addItem:newView];
							[self.ExplosiveIcons_UIDynamicItemBehavior addItem:newView];
						}
						

						[self.ExplosiveIcons_DynamicAnimator addBehavior:self.ExplosiveIcons_GravityBehavior];
						[self.ExplosiveIcons_DynamicAnimator addBehavior:self.ExplosiveIcons_CollisionBehavior];
						[self.ExplosiveIcons_DynamicAnimator addBehavior:self.ExplosiveIcons_UIDynamicItemBehavior];

						for (UIView *item in self.ExplosiveIcons_UIDynamicItemBehavior.items) {
							[self.ExplosiveIcons_UIDynamicItemBehavior addLinearVelocity:CGPointMake(20, 0) forItem:item];						}
					}
				}
				else {
					[Debug Log:[NSString stringWithFormat:@"Not SBIconView :("]];
				}
				
			}
		}
	%end
%end


%group Hooks
	%hook SpringBoard
		//	Called when springboard is finished launching
		-(void)applicationDidFinishLaunching:(id)application {
			%orig;
			[Debug SpringBoardReady];
			%init(DelayedHooks);
		}

	%end
%end


//	=========================== Constructor stuff ===========================

%ctor {
	[Debug Log:[NSString stringWithFormat:@"============== %@ started ==============", TWEAK_NAME]];

	preferences = [[HBPreferences alloc] initWithIdentifier:BUNDLE];

	[preferences registerBool:&enabled default:true forKey:@"kEnabled"];

	NSString *bundleID = NSBundle.mainBundle.bundleIdentifier;
	if ([bundleID isEqualToString:@"com.apple.springboard"]) {}

	%init(Hooks);
}
