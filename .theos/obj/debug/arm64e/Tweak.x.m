#line 1 "Tweak.x"
#import <Cephei/HBPreferences.h>
#import <objc/runtime.h>
#import <MRYIPCCenter.h>
#include "Tweak.h"

#define TWEAK_NAME @"ExplosiveIcons"
#define BUNDLE [NSString stringWithFormat:@"com.wrp1002.%@", [TWEAK_NAME lowercaseString]]


@interface UIWindow ()
- (void)_setSecure:(BOOL)arg1;
@end

@interface SBIconListView : UIView
	@property (nonatomic, retain)UIDynamicAnimator *ExplosiveIcons_DynamicAnimator;
@end

@interface UIDynamicItem
@end




bool enabled;
bool gravity;
bool randomColors;
NSInteger colorCount = 30;
NSInteger ballSize = 15;
NSInteger amount = 100;
CGFloat fadeTime = 1.5f;
CGFloat bounce = 0.8;
CGFloat explosionForce = 0.05;



int startupDelay = 5;
HBPreferences *preferences;
static MRYIPCCenter* center;



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
		
		int size = ballSize * drand48() + 1;
		float life = 0.5 + fadeTime * drand48();

		id obj = [super initWithFrame:CGRectMake(pos.x - size / 2, pos.y - size / 2, size, size)];
		self.layer.cornerRadius = size / 2;

		[UIView animateWithDuration:life / 2
			delay:life / 2
			options:UIViewAnimationOptionCurveLinear
			animations:^{
				self.alpha = 0.0;

			} completion:^(BOOL finished) {
				
				[super removeFromSuperview];
			}
		];

		return obj;
	}
@end

NSArray* getColorsFromImage(UIImage* image, int count) {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:count];

    CGImageRef imageRef = [image CGImage];
    unsigned long width = CGImageGetWidth(imageRef);
    unsigned long height = CGImageGetHeight(imageRef);

	unsigned long size = width * height;

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height,
													bitsPerComponent, bytesPerRow, colorSpace,
													kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);

    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);

    for (int i = 0 ; i < count ; i++) {
		unsigned long byteIndex = arc4random_uniform(size / 4) * 4;

        CGFloat alpha = 1.0f;
        CGFloat red   = ((CGFloat) rawData[byteIndex]     ) / 255.0f;
        CGFloat green = ((CGFloat) rawData[byteIndex + 1] ) / 255.0f;
        CGFloat blue  = ((CGFloat) rawData[byteIndex + 2] ) / 255.0f;

        UIColor *acolor = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
        [result addObject:acolor];
    }

  free(rawData);
  return result;
}





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
#line 180 "Tweak.x"
static SBIconListView* (*_logos_orig$DelayedHooks$SBIconListView$initWithModel$layoutProvider$iconLocation$orientation$iconViewProvider$)(_LOGOS_SELF_TYPE_INIT SBIconListView*, SEL, id, id, id, long long, id) _LOGOS_RETURN_RETAINED; static SBIconListView* _logos_method$DelayedHooks$SBIconListView$initWithModel$layoutProvider$iconLocation$orientation$iconViewProvider$(_LOGOS_SELF_TYPE_INIT SBIconListView*, SEL, id, id, id, long long, id) _LOGOS_RETURN_RETAINED; static void (*_logos_orig$DelayedHooks$SBIconListView$iconList$didRemoveIcon$)(_LOGOS_SELF_TYPE_NORMAL SBIconListView* _LOGOS_SELF_CONST, SEL, id, id); static void _logos_method$DelayedHooks$SBIconListView$iconList$didRemoveIcon$(_LOGOS_SELF_TYPE_NORMAL SBIconListView* _LOGOS_SELF_CONST, SEL, id, id); 
	
		__attribute__((used)) static UIDynamicAnimator * _logos_method$DelayedHooks$SBIconListView$ExplosiveIcons_DynamicAnimator(SBIconListView * __unused self, SEL __unused _cmd) { return (UIDynamicAnimator *)objc_getAssociatedObject(self, (void *)_logos_method$DelayedHooks$SBIconListView$ExplosiveIcons_DynamicAnimator); }; __attribute__((used)) static void _logos_method$DelayedHooks$SBIconListView$setExplosiveIcons_DynamicAnimator(SBIconListView * __unused self, SEL __unused _cmd, UIDynamicAnimator * rawValue) { objc_setAssociatedObject(self, (void *)_logos_method$DelayedHooks$SBIconListView$ExplosiveIcons_DynamicAnimator, rawValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC); }

		static SBIconListView* _logos_method$DelayedHooks$SBIconListView$initWithModel$layoutProvider$iconLocation$orientation$iconViewProvider$(_LOGOS_SELF_TYPE_INIT SBIconListView* __unused self, SEL __unused _cmd, id arg1, id arg2, id arg3, long long arg4, id arg5) _LOGOS_RETURN_RETAINED {
			id obj = _logos_orig$DelayedHooks$SBIconListView$initWithModel$layoutProvider$iconLocation$orientation$iconViewProvider$(self, _cmd, arg1, arg2, arg3, arg4, arg5);

			[Debug Log:@"SBIconListView init()"];

			

			return obj;
		}

		static void _logos_method$DelayedHooks$SBIconListView$iconList$didRemoveIcon$(_LOGOS_SELF_TYPE_NORMAL SBIconListView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1, id arg2) {
			_logos_orig$DelayedHooks$SBIconListView$iconList$didRemoveIcon$(self, _cmd, arg1, arg2);

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
						

						
						CGPoint pos = iconView.frame.origin;

						
						pos.x += iconView.frame.size.width / 2; 
						pos.y += iconView.frame.size.height / 2;

						[Debug Log:[NSString stringWithFormat:@"X:%f  Y:%f", pos.x, pos.y]];

						
						NSArray *colors = @[];
						if (!randomColors)
							colors = getColorsFromImage(image, colorCount);

						
						self.ExplosiveIcons_DynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self];

						UIGravityBehavior *gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[]];
						gravityBehavior.gravityDirection = CGVectorMake(0, 5);

						UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[]];
						collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
						collisionBehavior.collisionMode = UICollisionBehaviorModeEverything;

						UIDynamicItemBehavior *dynamicItemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[]];
						dynamicItemBehavior.elasticity = bounce;

						
						for (int i = 0; i < amount; i++) {
							
							CGPoint adjustedPos = pos;
							adjustedPos.x += (1 - drand48() * 2);
							adjustedPos.y += (1 - drand48() * 2);

							ExplosionParticleView *newView = [[ExplosionParticleView alloc] initAtPos:adjustedPos];

							
							UIColor *color;
							if (randomColors) {
								color = [UIColor colorWithRed:drand48() green:drand48() blue:drand48() alpha:1.0f];
							}
							else 
								color = colors[arc4random_uniform([colors count] - 1)];

							newView.backgroundColor = color;
							[self addSubview:newView];

							
							[gravityBehavior addItem:newView];
							[collisionBehavior addItem:newView];
							[dynamicItemBehavior addItem:newView];

							
							UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[newView] mode:UIPushBehaviorModeInstantaneous];
							pushBehavior.angle = M_PI * 2 * drand48();
							pushBehavior.magnitude = explosionForce * drand48();
							[self.ExplosiveIcons_DynamicAnimator addBehavior:pushBehavior];
						}
						
						
						if (gravity) [self.ExplosiveIcons_DynamicAnimator addBehavior:gravityBehavior];
						[self.ExplosiveIcons_DynamicAnimator addBehavior:collisionBehavior];
						[self.ExplosiveIcons_DynamicAnimator addBehavior:dynamicItemBehavior];
					}
				}
				else {
					
					[Debug Log:[NSString stringWithFormat:@"Not SBIconView :("]];
				}
				
			}
		}
	


static void (*_logos_orig$Hooks$SpringBoard$applicationDidFinishLaunching$)(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$Hooks$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); 
	
		
		static void _logos_method$Hooks$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id application) {
			_logos_orig$Hooks$SpringBoard$applicationDidFinishLaunching$(self, _cmd, application);
			[Debug SpringBoardReady];

			
			{Class _logos_class$DelayedHooks$SBIconListView = objc_getClass("SBIconListView"); { MSHookMessageEx(_logos_class$DelayedHooks$SBIconListView, @selector(initWithModel:layoutProvider:iconLocation:orientation:iconViewProvider:), (IMP)&_logos_method$DelayedHooks$SBIconListView$initWithModel$layoutProvider$iconLocation$orientation$iconViewProvider$, (IMP*)&_logos_orig$DelayedHooks$SBIconListView$initWithModel$layoutProvider$iconLocation$orientation$iconViewProvider$);}{ MSHookMessageEx(_logos_class$DelayedHooks$SBIconListView, @selector(iconList:didRemoveIcon:), (IMP)&_logos_method$DelayedHooks$SBIconListView$iconList$didRemoveIcon$, (IMP*)&_logos_orig$DelayedHooks$SBIconListView$iconList$didRemoveIcon$);}{ char _typeEncoding[1024]; sprintf(_typeEncoding, "%s@:", @encode(UIDynamicAnimator *)); class_addMethod(_logos_class$DelayedHooks$SBIconListView, @selector(ExplosiveIcons_DynamicAnimator), (IMP)&_logos_method$DelayedHooks$SBIconListView$ExplosiveIcons_DynamicAnimator, _typeEncoding); sprintf(_typeEncoding, "v@:%s", @encode(UIDynamicAnimator *)); class_addMethod(_logos_class$DelayedHooks$SBIconListView, @selector(setExplosiveIcons_DynamicAnimator:), (IMP)&_logos_method$DelayedHooks$SBIconListView$setExplosiveIcons_DynamicAnimator, _typeEncoding); } }
		}

	





static __attribute__((constructor)) void _logosLocalCtor_c97e8588(int __unused argc, char __unused **argv, char __unused **envp) {
	srand48(time(0));

	[Debug Log:[NSString stringWithFormat:@"============== %@ started ==============", TWEAK_NAME]];


	preferences = [[HBPreferences alloc] initWithIdentifier:BUNDLE];

	[preferences registerBool:&enabled default:true forKey:@"kEnabled"];
	[preferences registerBool:&gravity default:true forKey:@"kGravity"];
	[preferences registerBool:&randomColors default:false forKey:@"kRandomColors"];

	[preferences registerInteger:&colorCount default:20 forKey:@"kColorCount"];
	[preferences registerInteger:&ballSize default:15 forKey:@"kBallSize"];
	[preferences registerInteger:&amount default:100 forKey:@"kAmount"];

	[preferences registerFloat:&fadeTime default:1.5f forKey:@"kFadeTime"];
	[preferences registerFloat:&bounce default:0.8f forKey:@"kBounce"];
	[preferences registerFloat:&explosionForce default:0.05 forKey:@"kExplosionForce"];

	{Class _logos_class$Hooks$SpringBoard = objc_getClass("SpringBoard"); { MSHookMessageEx(_logos_class$Hooks$SpringBoard, @selector(applicationDidFinishLaunching:), (IMP)&_logos_method$Hooks$SpringBoard$applicationDidFinishLaunching$, (IMP*)&_logos_orig$Hooks$SpringBoard$applicationDidFinishLaunching$);}}
}


