#import <AppSettingsViewController.h>
#import "FeedFilterSettingsViewController.h"

NSBundle *redditFilterBundle;

extern UIImage *iconWithName(NSString *iconName);
extern NSString *localizedString(NSString *key, NSString *table);

@interface AppSettingsViewController ()
@property(nonatomic, assign) NSInteger feedFilterSectionIndex;
@end

%hook AppSettingsViewController
%property(nonatomic, assign) NSInteger feedFilterSectionIndex;
- (void)viewDidLoad {
  %orig;
  for (int section = 0; section < [self numberOfSectionsInTableView:self.tableView]; section++) {
    BaseTableReusableView *headerView = (BaseTableReusableView *)[self tableView:self.tableView
                                                          viewForHeaderInSection:section];
    if (!headerView) continue;
    BaseLabel *label = headerView.contentView.subviews[0];
    for (NSString *key in @[ @"drawer.settings.feedOptions", @"drawer.settings.viewOptions" ]) {
      if ([label.text isEqualToString:[localizedString(key, @"user") uppercaseString]]) {
        self.feedFilterSectionIndex = section;
        return;
      }
    }
  }
  self.feedFilterSectionIndex = 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  NSInteger result = %orig;
  if (section == self.feedFilterSectionIndex) result++;
  return result;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == self.feedFilterSectionIndex &&
      indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
    UIImage *iconImage = [iconWithName(@"icon_filter") ?: iconWithName(@"icon-filter-outline") imageScaledToSize:CGSizeMake(20, 20)];
    UIImage *accessoryIconImage =
        [iconWithName(@"icon_forward") imageScaledToSize:CGSizeMake(20, 20)];
    ImageLabelTableViewCell *cell = [self
        dequeueSettingsCellForTableView:tableView
                              indexPath:indexPath
                           leadingImage:iconImage
                                   text:[redditFilterBundle localizedStringForKey:@"filter.settings.title"
                                                                            value:@"Feed filter"
                                                                            table:nil]];
    [cell setCustomAccessoryImage:accessoryIconImage];
    return cell;
  }
  return %orig;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == self.feedFilterSectionIndex &&
      indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1) {
    [self.navigationController
        pushViewController:[(FeedFilterSettingsViewController *)[objc_getClass(
                               "FeedFilterSettingsViewController") alloc]
                               initWithStyle:UITableViewStyleGrouped]
                  animated:YES];
    return;
  }
  %orig;
}
%end

%ctor {
  redditFilterBundle = [NSBundle bundleWithPath:[NSBundle.mainBundle pathForResource:@"RedditFilter"
                                                                              ofType:@"bundle"]];
  if (!redditFilterBundle)
    redditFilterBundle = [NSBundle bundleWithPath:@THEOS_PACKAGE_INSTALL_PREFIX
                                   @"/Library/Application Support/RedditFilter.bundle"];
}
