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
	-(UIImage *)displayedImage;
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
	-(BOOL)isEditing;
@end