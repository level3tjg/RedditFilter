#import "BaseTableViewController.h"
#import "ImageLabelTableViewCell.h"

@interface AppSettingsViewController : BaseTableViewController
- (ImageLabelTableViewCell *)
    dequeueSettingsCellForTableView:(UITableView *)tableView
                          indexPath:(NSIndexPath *)indexPath
                       leadingImage:(UIImage *)leadingImage
                               text:(NSString *)text;
@end