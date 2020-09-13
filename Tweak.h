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

@interface SBIconListView : UIView
@end