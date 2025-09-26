#import "BaseTableView.h"
#import "DeprecatedBaseViewController.h"

@interface UserDrawerViewController
    : DeprecatedBaseViewController <UITableViewDataSource, UITableViewDelegate>
@property(nonatomic) BaseTableView *actionsTableView;
@property(nonatomic) NSMutableArray<NSNumber *> *availableUserActions;
- (UINavigationController *)currentNavigationController;
@end