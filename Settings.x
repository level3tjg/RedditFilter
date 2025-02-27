#import <AppSettingsViewController.h>
#import "FeedFilterSettingsViewController.h"

NSBundle *redditFilterBundle;

extern UIImage *iconWithName(NSString *iconName);
extern NSString *localizedString(NSString *key, NSString *table);

@interface AppSettingsViewController ()
@property(nonatomic, assign) NSInteger feedFilterSectionIndex;
@end

%hook NSURLSession
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(void (^)(NSData *data, NSURLResponse *response,
                                                        NSError *error))completionHandler {
  if (![request.URL.host hasPrefix:@"gql"] || !request.HTTPBody) return %orig;
  NSError *error;
  NSDictionary *json = [NSJSONSerialization JSONObjectWithData:request.HTTPBody
                                                       options:0
                                                         error:&error];
  if (error || ![json[@"operationName"] isEqualToString:@"GetAllExperimentVariants"])
    return %orig;
  void (^newCompletionHandler)(NSData *, NSURLResponse *, NSError *) =
      ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || !data) return completionHandler(data, response, error);
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                             options:NSJSONReadingMutableContainers
                                                               error:&error];
        if (error || !json) return completionHandler(data, response, error);
        for (NSMutableDictionary *experimentVariant in json[@"data"][@"experimentVariants"])
          if ([experimentVariant[@"experimentName"] isEqualToString:@"ios_swiftui_app_settings"])
            experimentVariant[@"name"] = @"disabled";
        data = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
        completionHandler(data, response, error);
      };
  return %orig(request, newCompletionHandler);
}
%end

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
    UIImage *iconImage = [iconWithName(@"icon_filter") ?: iconWithName(@"icon-filter-outline")
        imageScaledToSize:CGSizeMake(20, 20)];
    UIImage *accessoryIconImage =
        [iconWithName(@"icon_forward") imageScaledToSize:CGSizeMake(20, 20)];
    ImageLabelTableViewCell *cell =
        [self dequeueSettingsCellForTableView:tableView
                                    indexPath:indexPath
                                 leadingImage:iconImage
                                         text:[redditFilterBundle
                                                  localizedStringForKey:@"filter.settings.title"
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
