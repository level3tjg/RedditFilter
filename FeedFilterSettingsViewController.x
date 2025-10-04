#import "FeedFilterSettingsViewController.h"

extern NSBundle *redditFilterBundle;
extern UIImage *iconWithName(NSString *iconName);
extern Class CoreClass(NSString *name);

#define LOC(x, d) [redditFilterBundle localizedStringForKey:x value:d table:nil]

%subclass FeedFilterSettingsViewController : BaseTableViewController
%new
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  switch (section) {
    case 0:
      return 6;
    default:
      return 0;
  }
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *mainLabelText;
  NSString *detailLabelText;
  NSArray *iconNames;
  ToggleImageTableViewCell *toggleCell;
  ImageLabelTableViewCell *cell;
  switch (indexPath.section) {
    case 0: {
      toggleCell = [tableView dequeueReusableCellWithIdentifier:kToggleCellID
                                                   forIndexPath:indexPath];

      switch (indexPath.row) {
        case 0:
          mainLabelText = LOC(@"filter.settings.promoted.title", @"Promoted");
          iconNames = @[ @"rpl3/tag", @"icon_tag" ];
          toggleCell.accessorySwitch.on =
              ![NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterPromoted];
          [toggleCell.accessorySwitch addTarget:self
                                         action:@selector(didTogglePromotedSwitch:)
                               forControlEvents:UIControlEventValueChanged];
          break;
        case 1:
          mainLabelText = LOC(@"filter.settings.recommended.title", @"Recommended");
          iconNames = @[ @"rpl3/spam", @"icon_spam" ];
          toggleCell.accessorySwitch.on =
              ![NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterRecommended];
          [toggleCell.accessorySwitch addTarget:self
                                         action:@selector(didToggleRecommendedSwitch:)
                               forControlEvents:UIControlEventValueChanged];
          break;
        case 2:
          mainLabelText = LOC(@"filter.settings.nsfw.title", @"NSFW");
          iconNames = @[ @"rpl3/nsfw", @"icon_nsfw_outline", @"icon_nsfw" ];
          toggleCell.accessorySwitch.on =
              ![NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterNSFW];
          [toggleCell.accessorySwitch addTarget:self
                                         action:@selector(didToggleNsfwSwitch:)
                               forControlEvents:UIControlEventValueChanged];
          break;
        case 3:
          mainLabelText = LOC(@"filter.settings.awards.title", @"Awards");
          detailLabelText =
              LOC(@"filter.settings.awards.subtitle", @"Show awards on posts and comments");
          iconNames = @[ @"rpl3/award",  @"icon_gift_fill", @"icon_award", @"icon-award-outline" ];
          toggleCell.accessorySwitch.on =
              ![NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterAwards];
          [toggleCell.accessorySwitch addTarget:self
                                         action:@selector(didToggleAwardsSwitch:)
                               forControlEvents:UIControlEventValueChanged];
          break;
        case 4:
          mainLabelText = LOC(@"filter.settings.scores.title", @"Scores");
          detailLabelText =
              LOC(@"filter.settings.scores.subtitle", @"Show vote count on posts and comments");
          iconNames = @[ @"rpl3/upvote", @"icon_upvote" ];
          toggleCell.accessorySwitch.on =
              ![NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterScores];
          [toggleCell.accessorySwitch addTarget:self
                                         action:@selector(didToggleScoresSwitch:)
                               forControlEvents:UIControlEventValueChanged];
          break;
        case 5:
          mainLabelText = LOC(@"filter.settings.automod.title", @"AutoMod");
          detailLabelText =
              LOC(@"filter.settings.automod.subtitle", @"Auto collapse AutoMod comments");
          iconNames = @[ @"rpl3/mod", @"icon_mod" ];
          toggleCell.accessorySwitch.on =
              [NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterAutoCollapseAutoMod];
          [toggleCell.accessorySwitch addTarget:self
                                         action:@selector(didToggleAutoCollapseAutoModSwitch:)
                               forControlEvents:UIControlEventValueChanged];
          break;
        default:
          return nil;
      }

      cell = toggleCell;
      break;
    }
    default:
      return nil;
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
  switch (section) {
    case 0:
      label.text = [LOC(@"filter.settings.header", @"Filters") uppercaseString];
      break;
    default:
      return nil;
  }
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
  switch (section) {
    case 0:
      label.text = LOC(@"filter.settings.footer", @"Filter specific types of posts from your feed");
      break;
    default:
      return nil;
  }
  return footerView;
}
%new
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
  return 40.0;
}
- (void)viewDidLoad {
  %orig;
  self.title = @"RedditFilter";
  [self.tableView registerClass:CoreClass(@"ToggleImageTableViewCell")
         forCellReuseIdentifier:kToggleCellID];
  [self.tableView registerClass:CoreClass(@"ImageLabelTableViewCell")
         forCellReuseIdentifier:kLabelCellID];
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
