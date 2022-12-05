#import <AppSettingsViewController.h>
#import "FilterSettingsViewController.h"

extern UIImage *iconWithName(NSString *iconName);

%hook AppSettingsViewController
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSInteger result = %orig;
  if (section == (%orig(tableView, 0) == 0 ? 3 : 2)) result++;
  return result;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == ([self tableView:tableView numberOfRowsInSection:0] == 0 ? 3 : 2) &&
      indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
    UIImage *iconImage = [iconWithName(@"icon_filter") imageScaledToSize:CGSizeMake(20, 20)];
    UIImage *accessoryIconImage =
        [iconWithName(@"icon_forward") imageScaledToSize:CGSizeMake(20, 20)];
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
  if (indexPath.section == ([self tableView:tableView numberOfRowsInSection:0] == 0 ? 3 : 2) &&
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
