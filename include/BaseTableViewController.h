#import "DeprecatedBaseViewController.h"

@interface BaseTableViewController
    : DeprecatedBaseViewController <UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, strong) UITableView *tableView;
- (instancetype)initWithStyle:(UITableViewStyle)style;
@end