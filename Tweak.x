#import <Cephei/HBPreferences.h>
#import <objc/runtime.h>
#import <MRYIPCCenter.h>
#include "Tweak.h"

#define TWEAK_NAME @"ExplosiveIcons"
#define BUNDLE [NSString stringWithFormat:@"com.wrp1002.%@", [TWEAK_NAME lowercaseString]]

//	=========================== Preference vars ===========================

bool enabled;
bool gravity;
bool randomColors;
NSInteger colorCount = 30;
NSInteger ballSize = 15;
NSInteger amount = 100;
CGFloat fadeTime = 1.5f;
CGFloat bounce = 0.8;
CGFloat explosionForce = 0.05;

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

//	Custom view that acts as explosion particle
@interface ExplosionParticleView : UIView
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

%group DelayedHooks
	%hook SBIconListView
		%property (nonatomic, retain)UIDynamicAnimator *ExplosiveIcons_DynamicAnimator;

		-(void)iconList:(id)arg1 didRemoveIcon:(id)arg2 {
			%orig;

			[Debug Log:[NSString stringWithFormat:@"didRemoveIcon"]];

			//	Get icon info and bundleID
			SBApplicationIcon *appIcon = arg2;
			SBApplication *app = [appIcon application];
			NSString *bundleID = [app bundleIdentifier];

			//	bundleID is null if the icon is being moved, which is great
			if (!bundleID) {
				[Debug Log:[NSString stringWithFormat:@"No bundle ID"]];
				return;
			}

			[Debug Log:[NSString stringWithFormat:@"bundleID:%@", bundleID]];

			// Get the subviews of the SBIconListView (all icons on screen)
			NSArray *subviews = [self subviews];

			//	If an icon is deleted, it's the only icon on screen, and editing mode isn't enabled, 
			//	then there's no point in doing the animation because the page instantly disapears
			if ([subviews count] <= 1) {
				bool editing = [self isEditing];

				if (!editing)
					return;
			}
			

			for (id view in subviews) {
				//	Make sure the view is actually an icon. I think it always is anyway tho
				if ([view isMemberOfClass:[%c(SBIconView) class]]) {
					SBIconView *iconView = view;

					//	Check if this is the icon that was deleted
					SBIcon *icon = [iconView icon];
					NSString *checkID = [icon applicationBundleID];

					if ([checkID isEqualToString:bundleID]) {
						[Debug Log:[NSString stringWithFormat:@"Uninstalled: %@", bundleID]];

						//	Get the icon's image
						SBIconImageView *iconImage = [iconView _iconImageView];
						UIImage *image = [iconImage displayedImage];
						//UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);

						//	Position of the deleted icon
						CGPoint pos = iconView.frame.origin;

						//	Move point to center of icon
						pos.x += iconView.frame.size.width / 2; 
						pos.y += iconView.frame.size.height / 2;

						[Debug Log:[NSString stringWithFormat:@"X:%f  Y:%f", pos.x, pos.y]];

						//	Only bother figuring out colors if random colors is turned off
						NSArray *colors = @[];
						if (!randomColors)
							colors = getColorsFromImage(image, colorCount);

						// Physics stuff start here
						self.ExplosiveIcons_DynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self];

						UIGravityBehavior *gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[]];
						gravityBehavior.gravityDirection = CGVectorMake(0, 5);

						UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[]];
						collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
						collisionBehavior.collisionMode = UICollisionBehaviorModeEverything;

						UIDynamicItemBehavior *dynamicItemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[]];
						dynamicItemBehavior.elasticity = bounce;

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
							[self.ExplosiveIcons_DynamicAnimator addBehavior:pushBehavior];
						}
						
						//	Add behaviors to DynamicAnimator
						if (gravity) [self.ExplosiveIcons_DynamicAnimator addBehavior:gravityBehavior];
						[self.ExplosiveIcons_DynamicAnimator addBehavior:collisionBehavior];
						[self.ExplosiveIcons_DynamicAnimator addBehavior:dynamicItemBehavior];

						break;
					}
				}
				else {
					//	This prolly never happens
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

			//	Lots of icons are added and removed as SpringBoard starts up, so wait till its finished to init SBIconListView hooks
			%init(DelayedHooks);
		}

	%end
%end


//	=========================== Constructor stuff ===========================

%ctor {
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

	%init(Hooks);
}


