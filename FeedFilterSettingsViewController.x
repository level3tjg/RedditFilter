#import "FeedFilterSettingsViewController.h"

extern NSBundle *redditFilterBundle;
extern UIImage *iconWithName(NSString *iconName);
extern Class CoreClass(NSString *name);

%subclass FeedFilterSettingsViewController : BaseTableViewController
%new
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 7;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  ToggleImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kToggleCellID
                                                                   forIndexPath:indexPath];

  NSString *mainLabelText;
  NSString *detailLabelText;
  NSArray *iconNames;

  switch (indexPath.row) {
    case 0:
      mainLabelText = [redditFilterBundle localizedStringForKey:@"filter.settings.promoted.title"
                                                          value:@"Promoted"
                                                          table:nil];
      iconNames = @[ @"icon_tag" ];
      cell.accessorySwitch.on =
          ![NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterPromoted];
      [cell.accessorySwitch addTarget:self
                               action:@selector(didTogglePromotedSwitch:)
                     forControlEvents:UIControlEventValueChanged];
      break;
    case 1:
      mainLabelText = [redditFilterBundle localizedStringForKey:@"filter.settings.recommended.title"
                                                          value:@"Recommended"
                                                          table:nil];
      iconNames = @[ @"icon_spam" ];
      cell.accessorySwitch.on =
          ![NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterRecommended];
      [cell.accessorySwitch addTarget:self
                               action:@selector(didToggleRecommendedSwitch:)
                     forControlEvents:UIControlEventValueChanged];
      break;
    case 2:
      mainLabelText = [redditFilterBundle localizedStringForKey:@"filter.settings.livestreams.title"
                                                          value:@"Livestreams"
                                                          table:nil];
      iconNames = @[ @"icon_videocamera", @"icon_video_camera" ];
      cell.accessorySwitch.on =
          ![NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterLivestreams];
      [cell.accessorySwitch addTarget:self
                               action:@selector(didToggleLivestreamsSwitch:)
                     forControlEvents:UIControlEventValueChanged];
      break;
    case 3:
      mainLabelText = [redditFilterBundle localizedStringForKey:@"filter.settings.nsfw.title"
                                                          value:@"NSFW"
                                                          table:nil];
      iconNames = @[ @"icon_nsfw" ];
      cell.accessorySwitch.on = ![NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterNSFW];
      [cell.accessorySwitch addTarget:self
                               action:@selector(didToggleNsfwSwitch:)
                     forControlEvents:UIControlEventValueChanged];
      break;
    case 4:
      mainLabelText = [redditFilterBundle localizedStringForKey:@"filter.settings.awards.title"
                                                          value:@"Awards"
                                                          table:nil];
      detailLabelText =
          [redditFilterBundle localizedStringForKey:@"filter.settings.awards.subtitle"
                                              value:@"Show awards on posts and comments"
                                              table:nil];
      iconNames = @[ @"icon_gift_fill", @"icon_award" ];
      cell.accessorySwitch.on =
          ![NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterAwards];
      [cell.accessorySwitch addTarget:self
                               action:@selector(didToggleAwardsSwitch:)
                     forControlEvents:UIControlEventValueChanged];
      break;
    case 5:
      mainLabelText = [redditFilterBundle localizedStringForKey:@"filter.settings.scores.title"
                                                          value:@"Scores"
                                                          table:nil];
      detailLabelText =
          [redditFilterBundle localizedStringForKey:@"filter.settings.scores.subtitle"
                                              value:@"Show vote count on posts and comments"
                                              table:nil];
      iconNames = @[ @"icon_upvote" ];
      cell.accessorySwitch.on =
          ![NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterScores];
      [cell.accessorySwitch addTarget:self
                               action:@selector(didToggleScoresSwitch:)
                     forControlEvents:UIControlEventValueChanged];
      break;
    case 6:
      mainLabelText = [redditFilterBundle localizedStringForKey:@"filter.settings.automod.title"
                                                          value:@"AutoMod"
                                                          table:nil];
      detailLabelText =
          [redditFilterBundle localizedStringForKey:@"filter.settings.automod.subtitle"
                                              value:@"Auto collapse AutoMod comments"
                                              table:nil];
      iconNames = @[ @"icon_mod" ];
      cell.accessorySwitch.on =
          [NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterAutoCollapseAutoMod];
      [cell.accessorySwitch addTarget:self
                               action:@selector(didToggleAutoCollapseAutoModSwitch:)
                     forControlEvents:UIControlEventValueChanged];
      break;
  }

  ([cell respondsToSelector:@selector(mainLabel)] ? cell.mainLabel : cell.imageLabelView.mainLabel)
      .text = mainLabelText;

  ([cell respondsToSelector:@selector(detailLabel)] ? cell.detailLabel
                                                    : cell.imageLabelView.detailLabel)
      .text = detailLabelText;

  UIImage *iconImage;
  for (NSString *iconName in iconNames) {
    iconImage = iconWithName(iconName);
    if (iconImage) break;
  }

  if (iconImage) {
    UIImage *displayImage = [[iconImage imageScaledToSize:CGSizeMake(20, 20)]
        imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    if ([cell respondsToSelector:@selector(setDisplayImage:)])
      cell.displayImage = displayImage;
    else
      cell.imageLabelView.imageView.image = displayImage;
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
  label.text = [[redditFilterBundle localizedStringForKey:@"filter.settings.header"
                                                    value:@"Filters"
                                                    table:nil] uppercaseString];
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
  label.text =
      [redditFilterBundle localizedStringForKey:@"filter.settings.footer"
                                          value:@"Filter specific types of posts from your feed."
                                          table:nil];
  return footerView;
}
%new
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  return 40.0;
}
- (void)viewDidLoad {
  %orig;
  self.title = [redditFilterBundle localizedStringForKey:@"filter.settings.title"
                                                   value:@"Feed filter"
                                                   table:nil];
  [self.tableView registerClass:CoreClass(@"ToggleImageTableViewCell")
         forCellReuseIdentifier:kToggleCellID];
}
%new
- (void)didTogglePromotedSwitch:(UISwitch *)sender {
  [NSUserDefaults.standardUserDefaults setBool:!sender.on forKey:kRedditFilterPromoted];
}
%new
- (void)didToggleRecommendedSwitch:(UISwitch *)sender {
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
%new
- (void)didToggleAwardsSwitch:(UISwitch *)sender {
  [NSUserDefaults.standardUserDefaults setBool:!sender.on forKey:kRedditFilterAwards];
}
%new
- (void)didToggleScoresSwitch:(UISwitch *)sender {
  [NSUserDefaults.standardUserDefaults setBool:!sender.on forKey:kRedditFilterScores];
}
%new
- (void)didToggleAutoCollapseAutoModSwitch:(UISwitch *)sender {
  [NSUserDefaults.standardUserDefaults setBool:sender.on forKey:kRedditFilterAutoCollapseAutoMod];
}
%end
