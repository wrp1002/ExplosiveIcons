#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#include "Tweak.h"

#define TWEAK_NAME @"ExplosiveIcons"
#define BUNDLE [NSString stringWithFormat:@"com.wrp1002.%@", [TWEAK_NAME lowercaseString]]
#define BUNDLE_NOTIFY (CFStringRef)[NSString stringWithFormat:@"%@/ReloadPrefs", BUNDLE]


//	=========================== Other vars ===========================

UIDynamicAnimator *ExplosiveIcons_DynamicAnimator;
UIGravityBehavior *gravityBehavior;
UICollisionBehavior *collisionBehavior;
UIDynamicItemBehavior *dynamicItemBehavior;

//	=========================== Preference vars ===========================

BOOL enabled;
BOOL gravity;
BOOL randomColors;
NSInteger colorCount;
NSInteger ballSize;
NSInteger amount;
CGFloat fadeTime;
CGFloat bounce;
CGFloat explosionForce;

NSUserDefaults *prefs = nil;

static void InitPrefs(void) {
	if (!prefs) {
		NSDictionary *defaultPrefs = @{
			@"kEnabled": @YES,
			@"kGravity": @YES,
			@"kRandomColors": @NO,
			@"kColorCount": @20,
			@"kBallSize": @15,
			@"kAmount": @100,
			@"kFadeTime": @1.5f,
			@"kBounce": @0.8f,
			@"kExplosionForce": @0.05,
		};
		prefs = [[NSUserDefaults alloc] initWithSuiteName:BUNDLE];
		[prefs registerDefaults:defaultPrefs];
	}
}

static void UpdatePrefs() {
	//[Debug Log:@"updateprsfs"];
	enabled = [prefs boolForKey:@"kEnabled"];
	gravity = [prefs boolForKey:@"kGravity"];
	randomColors = [prefs boolForKey:@"kRandomColors"];

	colorCount =[prefs integerForKey:@"kColorCount"];
	ballSize =[prefs integerForKey:@"kBallSize"];
	amount =[prefs integerForKey:@"kAmount"];

	fadeTime = [prefs floatForKey:@"kFadeTime"];
	bounce = [prefs floatForKey:@"kBounce"];
	explosionForce = [prefs floatForKey:@"kExplosionForce"];

	if (gravity)
		gravityBehavior.gravityDirection = CGVectorMake(0, 5);
	else
		gravityBehavior.gravityDirection = CGVectorMake(0, 0);

	dynamicItemBehavior.elasticity = bounce;
}

static void PrefsChangeCallback(CFNotificationCenterRef center, void *observer, CFNotificationName name, const void *object, CFDictionaryRef userInfo) {
	UpdatePrefs();
}

//	=========================== Classes / Functions ===========================

//	Custom view that acts as explosion particle
@interface ExplosionParticleView : UIView
	@property (nonatomic, strong) UIPushBehavior *pushBehavior;
	-(id)initAtPos:(CGPoint)pos;
@end

@implementation ExplosionParticleView
	-(id)initAtPos:(CGPoint)pos {
		//	Give particle sizes a bit of randomness
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
				//	Remove the particle view when its faded out
				[super removeFromSuperview];
				// Also remove it from all behaviors
				[gravityBehavior removeItem:self];
				[collisionBehavior removeItem:self];
				[dynamicItemBehavior removeItem:self];
				[ExplosiveIcons_DynamicAnimator removeBehavior:self.pushBehavior];
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


//	=========================== Hooks ===========================


%group iOS13AndUpHooks
	%hook SBIconListView
		-(void)iconList:(id)arg1 didRemoveIcon:(id)arg2 {
			%orig;

			if (!enabled)
				return;

			//[Debug Log:[NSString stringWithFormat:@"didRemoveIcon"]];

			if (![arg2 isKindOfClass:[%c(SBApplicationIcon) class]]) {
				//[Debug Log:[NSString stringWithFormat:@"Not SBApplicationIcon"]];
				return;
			}

			SBApplicationIcon *appIcon = arg2;
			SBApplication *app = [appIcon application];
			NSString *bundleID = [app bundleIdentifier];

			//	bundleID is null if the icon is being moved, which is great
			if (!bundleID) {
				//[Debug Log:[NSString stringWithFormat:@"No bundle ID"]];
				return;
			}

			//[Debug Log:[NSString stringWithFormat:@"bundleID:%@", bundleID]];

			// Get the subviews of the SBIconListView (all icons on screen)
			NSArray *subviews = [self subviews];

			//	If an icon is deleted, it's the only icon on screen, and editing mode isn't enabled,
			//	then there's no point in doing the animation because the page instantly disapears
			if ([subviews count] <= 1 && ![self isEditing]) {
				//[Debug Log:[NSString stringWithFormat:@"not editing and no views. return"]];
				return;
			}

			SBIconView *iconView = [self iconViewForIcon:appIcon];
			if (!iconView)
				return;

			//[Debug Log:[NSString stringWithFormat:@"view class:%@", [iconView class]]];

			//	Check if this is the icon that was deleted
			SBIcon *icon = [iconView icon];
			NSString *checkID = [icon applicationBundleID];
			if (![checkID isEqualToString:bundleID]) {
				//[Debug Log:[NSString stringWithFormat:@"bundleID doesn't match"]];
				return;
			}

			//[Debug Log:[NSString stringWithFormat:@"Uninstalled: %@", bundleID]];

			//	Get the icon's image
			SBIconImageView *iconImageView = [iconView _iconImageView];
			UIImage *image = [iconImageView displayedImage];

			[self explodeIcon:iconView image:image];

		}
	%end
%end

%group iOS12AndBelowHooks
	%hook SBIconListView
		-(void)removeIconAtIndex:(unsigned long long)arg1 {
			if (!enabled) {
				%orig;
				return;
			}

			//[Debug Log:[NSString stringWithFormat:@"removeIconAtIndex: %llu", arg1]];

			id appIconId = [[self icons] objectAtIndex:arg1];

			//[Debug Log:[NSString stringWithFormat:@"appicon: %@", appIconId]];

			if (![appIconId isKindOfClass:[%c(SBApplicationIcon) class]]) {
				//[Debug Log:[NSString stringWithFormat:@"Not SBApplicationIcon"]];
				%orig;
				return;
			}

			SBApplicationIcon *appIcon = appIconId;
			//[Debug Log:[NSString stringWithFormat:@"icon:%@", appIcon]];

			SBApplication *app = [appIcon application];
			NSString *bundleID = [app bundleIdentifier];

			//	bundleID is null if the icon is being moved, which is great
			if (!bundleID) {
				//[Debug Log:[NSString stringWithFormat:@"No bundle ID"]];
				%orig;
				return;
			}

			//[Debug Log:[NSString stringWithFormat:@"bundleID:%@", bundleID]];

			// Get the subviews of the SBIconListView (all icons on screen)
			NSArray *subviews = [self subviews];

			//	If an icon is deleted, it's the only icon on screen, and editing mode isn't enabled,
			//	then there's no point in doing the animation because the page instantly disapears
			if ([subviews count] <= 1 && ![self isEditing]) {
				//[Debug Log:[NSString stringWithFormat:@"not editing and no views. return"]];
				%orig;
				return;
			}

			SBIconViewMap *iconViewMap = [self viewMap];

			SBIconView *iconView = [iconViewMap iconViewForIcon:appIcon];
			if (!iconView) {
				%orig;
				return;
			}

			//[Debug Log:[NSString stringWithFormat:@"view class:%@", [iconView class]]];

			//	Check if this is the icon that was deleted
			SBIcon *icon = [iconView icon];
			NSString *checkID = [icon applicationBundleID];
			if (![checkID isEqualToString:bundleID]) {
				//[Debug Log:[NSString stringWithFormat:@"bundleID doesn't match"]];
				%orig;
				return;
			}

			//	Get the icon's image
			SBIconImageView *iconImageView = [iconView _iconImageView];
			UIImage *image = [iconImageView snapshot];

			//[Debug Log:[NSString stringWithFormat:@"Uninstalled: %@", bundleID]];
			[self explodeIcon:iconView image:image];

			%orig;
		}
	%end
%end


%group AllVersionHooks
	%hook SpringBoard
		//	Called when springboard is finished launching
		-(void)applicationDidFinishLaunching:(id)application {
			%orig;
			//[Debug SpringBoardReady];

			//	Lots of icons are added and removed as SpringBoard starts up, so wait till its finished to init SBIconListView hooks
			if (@available(iOS 13.0, *))
				%init(iOS13AndUpHooks);
			else
				%init(iOS12AndBelowHooks);


			// Setup physics animators
			ExplosiveIcons_DynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:[UIScreen mainScreen]];

			gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[]];
			if (gravity)
				gravityBehavior.gravityDirection = CGVectorMake(0, 5);
			else
				gravityBehavior.gravityDirection = CGVectorMake(0, 0);

			collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[]];
			collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
			collisionBehavior.collisionMode = UICollisionBehaviorModeEverything;

			dynamicItemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[]];
			dynamicItemBehavior.elasticity = bounce;

			[ExplosiveIcons_DynamicAnimator addBehavior:gravityBehavior];
			[ExplosiveIcons_DynamicAnimator addBehavior:collisionBehavior];
			[ExplosiveIcons_DynamicAnimator addBehavior:dynamicItemBehavior];
		}

	%end

	%hook SBIconListView
		%new
		-(void)explodeIcon:(id)arg1 image:(id)arg2 {
			SBIconView *iconView = arg1;
			UIImage *image = arg2;

			//UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);

			//	Position of the deleted icon
			CGPoint pos = iconView.frame.origin;

			//	Move point to center of icon
			pos.x += iconView.frame.size.width / 2;
			pos.y += iconView.frame.size.height / 2;

			//[Debug Log:[NSString stringWithFormat:@"X:%f  Y:%f", pos.x, pos.y]];

			//	Only bother figuring out colors if random colors is turned off
			NSArray *colors = @[];
			if (!randomColors)
				colors = getColorsFromImage(image, colorCount);

			//	Time to make particles
			for (int i = 0; i < amount; i++) {
				//	Add a bit of randomness to the position so that all points aren't stacked
				CGPoint adjustedPos = pos;
				adjustedPos.x += (1 - drand48() * 2);
				adjustedPos.y += (1 - drand48() * 2);

				ExplosionParticleView *newView = [[ExplosionParticleView alloc] initAtPos:adjustedPos];

				//	Figure out color for new particle
				UIColor *color;
				if (randomColors)
					color = [UIColor colorWithRed:drand48() green:drand48() blue:drand48() alpha:1.0f];
				else
					color = colors[arc4random_uniform([colors count] - 1)];

				newView.backgroundColor = color;
				[self addSubview:newView];

				//	Add behaviors to new view
				[gravityBehavior addItem:newView];
				[collisionBehavior addItem:newView];
				[dynamicItemBehavior addItem:newView];

				//	Push each particle in a random direction
				UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[newView] mode:UIPushBehaviorModeInstantaneous];
				pushBehavior.angle = M_PI * 2 * drand48();
				pushBehavior.magnitude = explosionForce * drand48();

				newView.pushBehavior = pushBehavior;
				[ExplosiveIcons_DynamicAnimator addBehavior:pushBehavior];
			}
		}
	%end
%end


//	=========================== Constructor stuff ===========================

%ctor {
	srand48(time(0));

	//[Debug Log:[NSString stringWithFormat:@"============== %@ started ==============", TWEAK_NAME]];

	InitPrefs();
	UpdatePrefs();

	CFNotificationCenterAddObserver(
		CFNotificationCenterGetDarwinNotifyCenter(),
		NULL,
		&PrefsChangeCallback,
		BUNDLE_NOTIFY,
		NULL,
		0
	);

	%init(AllVersionHooks);
}


%dtor {
	[ExplosiveIcons_DynamicAnimator removeAllBehaviors];
	ExplosiveIcons_DynamicAnimator = nil;
	gravityBehavior = nil;
	collisionBehavior = nil;
	dynamicItemBehavior = nil;
}


