#import "FilterSettingsViewController.h"

extern UIImage *iconWithName(NSString *iconName);

%subclass FilterSettingsViewController : BaseTableViewController
%new
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 4;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  ToggleImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kToggleCellID
                                                                   forIndexPath:indexPath];
  NSString *labelText;
  NSString *iconName;
  switch (indexPath.row) {
    case 0:
      labelText = @"Promoted";
      iconName = @"icon_tag_16";
      cell.accessorySwitch.on =
          ![NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterPromoted];
      [cell.accessorySwitch addTarget:self
                               action:@selector(didTogglePromotedSwitch:)
                     forControlEvents:UIControlEventValueChanged];
      break;
    case 1:
      labelText = @"Recommended";
      iconName = @"icon_spam_20";
      cell.accessorySwitch.on =
          ![NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterRecommended];
      [cell.accessorySwitch addTarget:self
                               action:@selector(didToggleRecommendeddSwitch:)
                     forControlEvents:UIControlEventValueChanged];
      break;
    case 2:
      labelText = @"Livestreams";
      iconName = @"icon_video_camera_20";
      if (!iconWithName(iconName)) iconName = @"icon_videocamera_24";
      cell.accessorySwitch.on =
          ![NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterLivestreams];
      [cell.accessorySwitch addTarget:self
                               action:@selector(didToggleLivestreamsSwitch:)
                     forControlEvents:UIControlEventValueChanged];
      break;
    case 3:
      labelText = @"NSFW";
      iconName = @"icon_nsfw_16";
      cell.accessorySwitch.on = ![NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterNSFW];
      [cell.accessorySwitch addTarget:self
                               action:@selector(didToggleNsfwSwitch:)
                     forControlEvents:UIControlEventValueChanged];
      break;
  }

  ([cell respondsToSelector:@selector(mainLabel)] ? cell.mainLabel : cell.imageLabelView.mainLabel)
      .text = labelText;

  UIImage *iconImage = [[iconWithName(iconName) imageScaledToSize:CGSizeMake(16, 16)]
      imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
  if (iconImage) {
    if ([cell respondsToSelector:@selector(setDisplayImage:)]) {
      cell.displayImage = iconImage;
    } else {
      cell.imageLabelView.imageView.image = iconImage;
    }
  }
  return cell;
}
%new
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  BaseLabel *label = [%c(BaseLabel) labelWithSubheaderFont];
  LayoutGuidance *layoutGuidance = [%c(LayoutGuidance) currentGuidance];
  label.frame = CGRectMake(layoutGuidance.gridPadding, 0,
                           layoutGuidance.maxContentWidth - layoutGuidance.gridPaddingDouble, 40.0);
  [label associatePropertySetter:@selector(setTextColor:)
         withThemePropertyGetter:@selector(metaTextColor)];
  BaseTableReusableView *headerView = [[%c(BaseTableReusableView) alloc]
      initWithFrame:CGRectMake(0, 0, tableView.frameWidth, 40.0)];
  [headerView.contentView addSubview:label];
  [headerView associatePropertySetter:@selector(setBackgroundColor:)
              withThemePropertyGetter:@selector(canvasColor)];
  label.text = [@"Filters" uppercaseString];
  return headerView;
}
%new
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 40.0;
}
%new
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
  BaseLabel *label = [%c(BaseLabel) labelWithSubheaderFont];
  LayoutGuidance *layoutGuidance = [%c(LayoutGuidance) currentGuidance];
  label.frame = CGRectMake(layoutGuidance.gridPadding, 0,
                           layoutGuidance.maxContentWidth - layoutGuidance.gridPaddingDouble, 40.0);
  [label associatePropertySetter:@selector(setTextColor:)
         withThemePropertyGetter:@selector(metaTextColor)];
  BaseTableReusableView *footerView = [[%c(BaseTableReusableView) alloc]
      initWithFrame:CGRectMake(0, 0, tableView.frameWidth, 40.0)];
  [footerView.contentView addSubview:label];
  [footerView associatePropertySetter:@selector(setBackgroundColor:)
              withThemePropertyGetter:@selector(canvasColor)];
  label.text = @"Filter specific types of posts from your feed.";
  return footerView;
}
%new
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  return 40.0;
}
- (void)viewDidLoad {
  %orig;
  self.title = @"Feed filter";
  Class toggleCellClass = objc_getClass("ToggleImageTableViewCell");
  if (!toggleCellClass) toggleCellClass = objc_getClass("Reddit.ToggleImageTableViewCell");
  if (!toggleCellClass) toggleCellClass = objc_getClass("RedditUI.ToggleImageTableViewCell");
  [self.tableView registerClass:toggleCellClass forCellReuseIdentifier:kToggleCellID];
}
%new
- (void)didTogglePromotedSwitch:(UISwitch *)sender {
  [NSUserDefaults.standardUserDefaults setBool:!sender.on forKey:kRedditFilterPromoted];
}
%new
- (void)didToggleRecommendeddSwitch:(UISwitch *)sender {
  [NSUserDefaults.standardUserDefaults setBool:!sender.on forKey:kRedditFilterRecommended];
}
%new
- (void)didToggleLivestreamsSwitch:(UISwitch *)sender {
  [NSUserDefaults.standardUserDefaults setBool:!sender.on forKey:kRedditFilterLivestreams];
}
%new
- (void)didToggleNsfwSwitch:(UISwitch *)sender {
  [NSUserDefaults.standardUserDefaults setBool:!sender.on forKey:kRedditFilterNSFW];
}
%end
