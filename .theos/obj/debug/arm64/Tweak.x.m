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

@interface SBIconListView : UIView
	@property (nonatomic, retain)UIDynamicAnimator *ExplosiveIcons_DynamicAnimator;
	@property (nonatomic, retain)UIGravityBehavior *ExplosiveIcons_GravityBehavior;
	@property (nonatomic, retain)UICollisionBehavior *ExplosiveIcons_CollisionBehavior;
	@property (nonatomic, retain)UIDynamicItemBehavior *ExplosiveIcons_UIDynamicItemBehavior;
@end

@interface UIDynamicItem
@end




bool enabled;
int colorCount = 30;
int ballSize = 10;
int amount = 100;
float fadeTime = 1.5f;
float bounce = 0.7;



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
		id obj = [super initWithFrame:CGRectMake(pos.x - ballSize / 2, pos.y - ballSize / 2, ballSize, ballSize)];
		self.layer.cornerRadius = 5;

		float life = 0.5 + fadeTime * drand48();

		[UIView animateWithDuration:life
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

NSArray* getRGBAsFromImage(UIImage* image, int count) {
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

	for (UIColor *color in result)
		[Debug Log:[NSString stringWithFormat:@"results: %@", color]];

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

@class SBIconListView; @class SpringBoard; @class SBIconView; 

static __inline__ __attribute__((always_inline)) __attribute__((unused)) Class _logos_static_class_lookup$SBIconView(void) { static Class _klass; if(!_klass) { _klass = objc_getClass("SBIconView"); } return _klass; }
#line 184 "Tweak.x"
static SBIconListView* (*_logos_orig$DelayedHooks$SBIconListView$initWithModel$layoutProvider$iconLocation$orientation$iconViewProvider$)(_LOGOS_SELF_TYPE_INIT SBIconListView*, SEL, id, id, id, long long, id) _LOGOS_RETURN_RETAINED; static SBIconListView* _logos_method$DelayedHooks$SBIconListView$initWithModel$layoutProvider$iconLocation$orientation$iconViewProvider$(_LOGOS_SELF_TYPE_INIT SBIconListView*, SEL, id, id, id, long long, id) _LOGOS_RETURN_RETAINED; static void (*_logos_orig$DelayedHooks$SBIconListView$iconList$didRemoveIcon$)(_LOGOS_SELF_TYPE_NORMAL SBIconListView* _LOGOS_SELF_CONST, SEL, id, id); static void _logos_method$DelayedHooks$SBIconListView$iconList$didRemoveIcon$(_LOGOS_SELF_TYPE_NORMAL SBIconListView* _LOGOS_SELF_CONST, SEL, id, id); 
	
		__attribute__((used)) static UIDynamicAnimator * _logos_method$DelayedHooks$SBIconListView$ExplosiveIcons_DynamicAnimator(SBIconListView * __unused self, SEL __unused _cmd) { return (UIDynamicAnimator *)objc_getAssociatedObject(self, (void *)_logos_method$DelayedHooks$SBIconListView$ExplosiveIcons_DynamicAnimator); }; __attribute__((used)) static void _logos_method$DelayedHooks$SBIconListView$setExplosiveIcons_DynamicAnimator(SBIconListView * __unused self, SEL __unused _cmd, UIDynamicAnimator * rawValue) { objc_setAssociatedObject(self, (void *)_logos_method$DelayedHooks$SBIconListView$ExplosiveIcons_DynamicAnimator, rawValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC); }
		__attribute__((used)) static UIGravityBehavior * _logos_method$DelayedHooks$SBIconListView$ExplosiveIcons_GravityBehavior(SBIconListView * __unused self, SEL __unused _cmd) { return (UIGravityBehavior *)objc_getAssociatedObject(self, (void *)_logos_method$DelayedHooks$SBIconListView$ExplosiveIcons_GravityBehavior); }; __attribute__((used)) static void _logos_method$DelayedHooks$SBIconListView$setExplosiveIcons_GravityBehavior(SBIconListView * __unused self, SEL __unused _cmd, UIGravityBehavior * rawValue) { objc_setAssociatedObject(self, (void *)_logos_method$DelayedHooks$SBIconListView$ExplosiveIcons_GravityBehavior, rawValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC); }
		__attribute__((used)) static UICollisionBehavior * _logos_method$DelayedHooks$SBIconListView$ExplosiveIcons_CollisionBehavior(SBIconListView * __unused self, SEL __unused _cmd) { return (UICollisionBehavior *)objc_getAssociatedObject(self, (void *)_logos_method$DelayedHooks$SBIconListView$ExplosiveIcons_CollisionBehavior); }; __attribute__((used)) static void _logos_method$DelayedHooks$SBIconListView$setExplosiveIcons_CollisionBehavior(SBIconListView * __unused self, SEL __unused _cmd, UICollisionBehavior * rawValue) { objc_setAssociatedObject(self, (void *)_logos_method$DelayedHooks$SBIconListView$ExplosiveIcons_CollisionBehavior, rawValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC); }
		__attribute__((used)) static UIDynamicItemBehavior * _logos_method$DelayedHooks$SBIconListView$ExplosiveIcons_UIDynamicItemBehavior(SBIconListView * __unused self, SEL __unused _cmd) { return (UIDynamicItemBehavior *)objc_getAssociatedObject(self, (void *)_logos_method$DelayedHooks$SBIconListView$ExplosiveIcons_UIDynamicItemBehavior); }; __attribute__((used)) static void _logos_method$DelayedHooks$SBIconListView$setExplosiveIcons_UIDynamicItemBehavior(SBIconListView * __unused self, SEL __unused _cmd, UIDynamicItemBehavior * rawValue) { objc_setAssociatedObject(self, (void *)_logos_method$DelayedHooks$SBIconListView$ExplosiveIcons_UIDynamicItemBehavior, rawValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC); }

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
						UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);

						
						
						

						
						CGPoint pos = iconView.frame.origin;

						
						pos.x += iconView.frame.size.width / 2; 
						pos.y += iconView.frame.size.height / 2;

						[Debug Log:[NSString stringWithFormat:@"X:%f  Y:%f", pos.x, pos.y]];

						NSArray *colors = getRGBAsFromImage(image, colorCount);


						self.ExplosiveIcons_DynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self];

						self.ExplosiveIcons_GravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[]];
						self.ExplosiveIcons_GravityBehavior.gravityDirection = CGVectorMake(0, 5);

						self.ExplosiveIcons_CollisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[]];
						self.ExplosiveIcons_CollisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
						self.ExplosiveIcons_CollisionBehavior.collisionMode = UICollisionBehaviorModeEverything;

						self.ExplosiveIcons_UIDynamicItemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[]];
						self.ExplosiveIcons_UIDynamicItemBehavior.elasticity = bounce;

						for (int i = 0; i < amount; i++) {
							ExplosionParticleView *newView = [[ExplosionParticleView alloc] initAtPos:pos];
							UIColor *color = colors[arc4random_uniform([colors count] - 1)];
							[Debug Log:[NSString stringWithFormat:@"COlor: %@", color]];
							newView.backgroundColor = color;
							[self addSubview:newView];

							[self.ExplosiveIcons_GravityBehavior addItem:newView];
							[self.ExplosiveIcons_CollisionBehavior addItem:newView];
							[self.ExplosiveIcons_UIDynamicItemBehavior addItem:newView];

							UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[newView] mode:UIPushBehaviorModeInstantaneous];
							pushBehavior.angle = M_PI * 2 * drand48();
							pushBehavior.magnitude = 0.25 * drand48();
							[self.ExplosiveIcons_DynamicAnimator addBehavior:pushBehavior];
						}
						

						[self.ExplosiveIcons_DynamicAnimator addBehavior:self.ExplosiveIcons_GravityBehavior];
						[self.ExplosiveIcons_DynamicAnimator addBehavior:self.ExplosiveIcons_CollisionBehavior];
						[self.ExplosiveIcons_DynamicAnimator addBehavior:self.ExplosiveIcons_UIDynamicItemBehavior];
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
			{Class _logos_class$DelayedHooks$SBIconListView = objc_getClass("SBIconListView"); { MSHookMessageEx(_logos_class$DelayedHooks$SBIconListView, @selector(initWithModel:layoutProvider:iconLocation:orientation:iconViewProvider:), (IMP)&_logos_method$DelayedHooks$SBIconListView$initWithModel$layoutProvider$iconLocation$orientation$iconViewProvider$, (IMP*)&_logos_orig$DelayedHooks$SBIconListView$initWithModel$layoutProvider$iconLocation$orientation$iconViewProvider$);}{ MSHookMessageEx(_logos_class$DelayedHooks$SBIconListView, @selector(iconList:didRemoveIcon:), (IMP)&_logos_method$DelayedHooks$SBIconListView$iconList$didRemoveIcon$, (IMP*)&_logos_orig$DelayedHooks$SBIconListView$iconList$didRemoveIcon$);}{ char _typeEncoding[1024]; sprintf(_typeEncoding, "%s@:", @encode(UIDynamicAnimator *)); class_addMethod(_logos_class$DelayedHooks$SBIconListView, @selector(ExplosiveIcons_DynamicAnimator), (IMP)&_logos_method$DelayedHooks$SBIconListView$ExplosiveIcons_DynamicAnimator, _typeEncoding); sprintf(_typeEncoding, "v@:%s", @encode(UIDynamicAnimator *)); class_addMethod(_logos_class$DelayedHooks$SBIconListView, @selector(setExplosiveIcons_DynamicAnimator:), (IMP)&_logos_method$DelayedHooks$SBIconListView$setExplosiveIcons_DynamicAnimator, _typeEncoding); } { char _typeEncoding[1024]; sprintf(_typeEncoding, "%s@:", @encode(UIGravityBehavior *)); class_addMethod(_logos_class$DelayedHooks$SBIconListView, @selector(ExplosiveIcons_GravityBehavior), (IMP)&_logos_method$DelayedHooks$SBIconListView$ExplosiveIcons_GravityBehavior, _typeEncoding); sprintf(_typeEncoding, "v@:%s", @encode(UIGravityBehavior *)); class_addMethod(_logos_class$DelayedHooks$SBIconListView, @selector(setExplosiveIcons_GravityBehavior:), (IMP)&_logos_method$DelayedHooks$SBIconListView$setExplosiveIcons_GravityBehavior, _typeEncoding); } { char _typeEncoding[1024]; sprintf(_typeEncoding, "%s@:", @encode(UICollisionBehavior *)); class_addMethod(_logos_class$DelayedHooks$SBIconListView, @selector(ExplosiveIcons_CollisionBehavior), (IMP)&_logos_method$DelayedHooks$SBIconListView$ExplosiveIcons_CollisionBehavior, _typeEncoding); sprintf(_typeEncoding, "v@:%s", @encode(UICollisionBehavior *)); class_addMethod(_logos_class$DelayedHooks$SBIconListView, @selector(setExplosiveIcons_CollisionBehavior:), (IMP)&_logos_method$DelayedHooks$SBIconListView$setExplosiveIcons_CollisionBehavior, _typeEncoding); } { char _typeEncoding[1024]; sprintf(_typeEncoding, "%s@:", @encode(UIDynamicItemBehavior *)); class_addMethod(_logos_class$DelayedHooks$SBIconListView, @selector(ExplosiveIcons_UIDynamicItemBehavior), (IMP)&_logos_method$DelayedHooks$SBIconListView$ExplosiveIcons_UIDynamicItemBehavior, _typeEncoding); sprintf(_typeEncoding, "v@:%s", @encode(UIDynamicItemBehavior *)); class_addMethod(_logos_class$DelayedHooks$SBIconListView, @selector(setExplosiveIcons_UIDynamicItemBehavior:), (IMP)&_logos_method$DelayedHooks$SBIconListView$setExplosiveIcons_UIDynamicItemBehavior, _typeEncoding); } }
		}

	





static __attribute__((constructor)) void _logosLocalCtor_5c40de68(int __unused argc, char __unused **argv, char __unused **envp) {
	srand48(time(0));

	[Debug Log:[NSString stringWithFormat:@"============== %@ started ==============", TWEAK_NAME]];

	preferences = [[HBPreferences alloc] initWithIdentifier:BUNDLE];

	[preferences registerBool:&enabled default:true forKey:@"kEnabled"];

	NSString *bundleID = NSBundle.mainBundle.bundleIdentifier;
	if ([bundleID isEqualToString:@"com.apple.springboard"]) {}

	{Class _logos_class$Hooks$SpringBoard = objc_getClass("SpringBoard"); { MSHookMessageEx(_logos_class$Hooks$SpringBoard, @selector(applicationDidFinishLaunching:), (IMP)&_logos_method$Hooks$SpringBoard$applicationDidFinishLaunching$, (IMP*)&_logos_orig$Hooks$SpringBoard$applicationDidFinishLaunching$);}}
}
