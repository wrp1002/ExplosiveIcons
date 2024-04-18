
// Needs commented out for GitHub to compile
//int __isOSVersionAtLeast(int major, int minor, int patch) { NSOperatingSystemVersion version; version.majorVersion = major; version.minorVersion = minor; version.patchVersion = patch; return [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:version]; }


@interface SBIcon
	-(NSString *)displayName;
	-(BOOL)isUninstalled;
	-(BOOL)isLaunchEnabled;
	-(id)applicationBundleID;
@end

@interface SBIconView : UIView
	-(SBIcon *)icon;
	-(UIImage *)iconImageSnapshot;
	-(id)_iconImageView;
@end

@interface SBIconImageView : UIView
	// iOS >= 13
	-(UIImage *)displayedImage;

	// iOS <= 12
	-(id)squareContentsImage;
	-(id)squareDarkeningOverlayImage;
	-(id)_currentOverlayImage;
	-(id)_iconBasicOverlayImage;
	-(id)_iconSquareOverlayImage;
	-(id)snapshot;
@end

@interface SBApplication : NSObject
	-(NSString *)bundleIdentifier;
@end

@interface SBLeafIcon
@end

@interface SBApplicationIcon : SBLeafIcon
	-(id)application;
@end

@interface UIWindow ()
- (void)_setSecure:(BOOL)arg1;
@end

@interface SBIconListView : UIView
	@property (nonatomic, retain)UIDynamicAnimator *ExplosiveIcons_DynamicAnimator;
	-(id)icons;
	-(BOOL)isEditing;
	-(id)iconViewForIcon:(id)arg1;
	-(void)iconList:(id)arg1 didRemoveIcon:(id)arg2;
	-(id)viewMap;

	// Added with %new
	-(void)explodeIcon:(id)iconView image:(id)arg2;
@end


@interface SBIconViewMap
	-(id)iconViewForIcon:(id)arg1;
@end