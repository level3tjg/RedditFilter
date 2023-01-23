#import "Preferences.h"
#import <BaseLabel.h>
#import <BaseTableReusableView.h>
#import <BaseTableViewController.h>
#import <LayoutGuidance.h>
#import <ToggleImageTableViewCell.h>

@interface UIView ()
@property(nonatomic, readonly, assign) CGFloat frameWidth;
- (void)associatePropertySetter:(SEL)propertySetter
        withThemePropertyGetter:(SEL)themePropertyGetter;
@end

@interface UIImage ()
- (UIImage *)imageScaledToSize:(CGSize)size;
@end

@interface FeedFilterSettingsViewController : BaseTableViewController
@end