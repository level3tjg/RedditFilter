#import <AppSettingsViewController.h>
#import "FilterSettingsViewController.h"

extern UIImage *iconWithName(NSString *iconName);

%hook AppSettingsViewController
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSInteger result = %orig;
  if (section == 2) result++;
  return result;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 2 &&
      indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
    UIImage *iconImage = iconWithName(@"icon_filter");
    UIImage *accessoryIconImage = iconWithName(@"icon_forward");
    ImageLabelTableViewCell *cell = [self dequeueSettingsCellForTableView:tableView
                                                                indexPath:indexPath
                                                             leadingImage:iconImage
                                                                     text:@"Feed filter"];
    [cell setCustomAccessoryImage:accessoryIconImage];
    return cell;
  }
  return %orig;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 2 &&
      indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
    [self.navigationController pushViewController:[(FilterSettingsViewController *)[objc_getClass(
                                                      "FilterSettingsViewController") alloc]
                                                      initWithStyle:UITableViewStyleGrouped]
                                         animated:YES];
    return;
  }
  %orig;
}
%end
