#import <Carousel.h>
#import <Comment.h>
#import <Post.h>
#import <ToggleImageTableViewCell.h>
#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <objc/runtime.h>
#import "Preferences.h"
#import "fishhook/fishhook.h"

@interface UIImage ()
+ (UIImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;
@end

static NSMutableArray *assetBundles;

extern "C" UIImage *iconWithName(NSString *iconName) {
  NSArray *commonIconSizes = @[
    @"24",
    @"20",
    @"16",
  ];
  UIImage *iconImage;
  for (NSBundle *bundle in assetBundles) {
    for (NSString *iconSize in commonIconSizes) {
      if (iconImage) break;
      iconImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_%@", iconName, iconSize]
                             inBundle:bundle];
    }
  }
  return iconImage;
}

extern "C" NSString *localizedString(NSString *key, NSString *table) {
  for (NSBundle *bundle in assetBundles) {
    NSString *localizedString = [bundle localizedStringForKey:key value:nil table:table];
    if (![localizedString isEqualToString:key]) return localizedString;
  }
  return nil;
}

extern "C" Class CoreClass(NSString *name) {
  Class cls = NSClassFromString(name);
  NSArray *prefixes = @[
    @"Reddit.",
    @"RedditCore.",
    @"RedditCoreModels.",
    @"RedditCore_RedditCoreModels.",
    @"RedditUI.",
  ];
  for (NSString *prefix in prefixes) {
    if (cls) break;
    cls = NSClassFromString([prefix stringByAppendingString:name]);
  }
  return cls;
}

static BOOL shouldFilterObject(id object) {
  NSString *className = NSStringFromClass(object_getClass(object));
  BOOL isAdPost = [className hasSuffix:@"AdPost"] ||
                  ([object respondsToSelector:@selector(isAdPost)] && ((Post *)object).isAdPost) ||
                  ([object respondsToSelector:@selector(isPromotedUserPostAd)] &&
                   [(Post *)object isPromotedUserPostAd]) ||
                  ([object respondsToSelector:@selector(isPromotedCommunityPostAd)] &&
                   [(Post *)object isPromotedCommunityPostAd]);
  BOOL isRecommendation = [className containsString:@"Recommend"];
  BOOL isLivestream = [className containsString:@"Stream"];
  BOOL isNSFW = [object respondsToSelector:@selector(isNSFW)] && ((Post *)object).isNSFW;
  if ([NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterPromoted] && isAdPost)
    return YES;
  if ([NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterRecommended] && isRecommendation)
    return YES;
  if ([NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterLivestreams] && isLivestream)
    return YES;
  if ([NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterNSFW] && isNSFW) return YES;
  return NO;
}

static NSArray *filteredObjects(NSArray *objects) {
  return [objects filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(
                                                               id object, NSDictionary *bindings) {
                    return !shouldFilterObject(object);
                  }]];
}

%hook NSJSONSerialization
+ (id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError * _Nullable *)error {
  id result = %orig;
  if (![NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterPromoted]) return result;
  if ([result isKindOfClass:NSMutableDictionary.class]) {
    NSDictionary *json = result;
    if (json[@"data"] && [json[@"data"] isKindOfClass:NSDictionary.class]) {
      NSDictionary *data = json[@"data"];
      if (data[@"homeV3"] || data[@"newsV3"] || data[@"popularV3"]) {
        NSDictionary *elements = data[data.allKeys[0]][@"elements"];
        NSMutableArray *edges = elements[@"edges"];
        for (NSDictionary *edge in edges)
          if ([edge[@"node"][@"cells"][0][@"__typename"] isEqualToString:@"AdMetadataCell"])
            edge[@"node"][@"cells"] = @[ @{} ];
      }
    }
  }
  return result;
}
%end

%hook Listing
- (void)fetchNextPage:(id (^)(NSArray *, id))completionHandler {
  id (^newCompletionHandler)(NSArray *, id) = ^(NSArray *objects, id _) {
    return completionHandler(filteredObjects(objects), _);
  };
  return %orig(newCompletionHandler);
}
%end

%hook FeedNetworkSource
- (NSArray *)postsAndCommentsFromData:(id)data {
  return filteredObjects(%orig);
}
%end

%hook PostDetailPresenter
- (BOOL)shouldFetchCommentAdPost {
  return [NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterPromoted] ? NO
                                                                                : %orig;
}
- (BOOL)shouldFetchAdditionalCommentAdPosts {
  return [NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterPromoted] ? NO
                                                                                : %orig;
}
%end

%hook StreamManager
- (instancetype)initWithAccountContext:(id)accountContext
                                source:(NSInteger)source
                 deeplinkSubredditName:(id)deeplinkSubredditName
                       streamingConfig:(id)streamingConfig {
  if ([NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterLivestreams]) return nil;
  return %orig;
}
- (instancetype)initWithService:(id)service
                         source:(NSInteger)source
          deeplinkSubredditName:(id)deeplinkSubredditName
                streamingConfig:(id)streamingConfig {
  if ([NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterLivestreams]) return nil;
  return %orig;
}
%end

%hook Carousel
- (BOOL)isHiddenByUserWithAccountSettings:(id)accountSettings {
  return ([NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterRecommended] &&
          ([self.analyticType containsString:@"recommended"] ||
           [self.analyticType containsString:@"similar"] ||
           [self.analyticType containsString:@"popular"])) ||
         %orig;
}
%end

%hook QuickActionViewModel
- (void)fetchActions {
  if ([NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterRecommended]) return;
  %orig;
}
%end

%hook Post
- (NSArray *)awardingTotals {
  return [NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterAwards] ? nil
                                                                              : %orig;
}
- (NSUInteger)totalAwardsReceived {
  return [NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterAwards] ? 0
                                                                              : %orig;
}
- (BOOL)canAward {
  return [NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterAwards] ? NO
                                                                              : %orig;
}
- (BOOL)isScoreHidden {
  return [NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterScores] ? YES
                                                                              : %orig;
}
%end

%hook Comment
- (NSArray *)awardingTotals {
  return [NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterAwards] ? nil
                                                                              : %orig;
}
- (NSUInteger)totalAwardsReceived {
  return [NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterAwards] ? 0
                                                                              : %orig;
}
- (BOOL)canAward {
  return [NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterAwards] ? NO
                                                                              : %orig;
}
- (BOOL)shouldHighlightForHighAward {
  return [NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterAwards] ? NO
                                                                              : %orig;
}
- (BOOL)isScoreHidden {
  return [NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterScores] ? YES
                                                                              : %orig;
}
- (BOOL)shouldAutoCollapse {
  return [NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterAutoCollapseAutoMod] &&
                 [((Comment *)self).authorPk isEqualToString:@"t2_6l4z3"]
             ? YES
             : %orig;
}
%end

%hook ToggleImageTableViewCell
- (void)updateConstraints {
  %orig;
  UIStackView *horizontalStackView =
      [self respondsToSelector:@selector(imageLabelView)]
          ? [self imageLabelView].horizontalStackView
          : object_getIvar(self,
                           class_getInstanceVariable(object_getClass(self), "horizontalStackView"));
  UILabel *detailLabel = [self respondsToSelector:@selector(imageLabelView)]
                             ? [self imageLabelView].detailLabel
                             : [self detailLabel];
  if (!horizontalStackView || !detailLabel) return;
  if (detailLabel.text) {
    UIView *contentView = [self contentView];
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:detailLabel
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:horizontalStackView
                                                            attribute:NSLayoutAttributeHeight
                                                           multiplier:.33
                                                             constant:0]];
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:horizontalStackView
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:contentView
                                                            attribute:NSLayoutAttributeHeight
                                                           multiplier:1
                                                             constant:0]];
    [contentView addConstraint:[NSLayoutConstraint constraintWithItem:horizontalStackView
                                                            attribute:NSLayoutAttributeCenterY
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:contentView
                                                            attribute:NSLayoutAttributeCenterY
                                                           multiplier:1
                                                             constant:0]];
  }
}
%end

static BOOL initialized = NO;

static void add_image(const struct mach_header *mh, intptr_t vmaddr_slide) {
  if (!initialized && %c(Listing)) {
    %init(Comment = CoreClass(@"Comment"), Post = CoreClass(@"Post"),
                     QuickActionViewModel = CoreClass(@"QuickActionViewModel"),
                     StreamManager = CoreClass(@"StreamManager"),
                     ToggleImageTableViewCell = CoreClass(@"ToggleImageTableViewCell"));
    initialized = YES;
  }
}

// static bool (*orig__availability_version_check)(int, int, uint, uint);
// static bool hook__availability_version_check(int Platform, int Major, uint Minor, uint Subminor) {
//   return Major >= 15 ? NO : orig__availability_version_check(Platform, Major, Minor, Subminor);
// }

%ctor {
  assetBundles = [NSMutableArray new];
  [assetBundles addObject:NSBundle.mainBundle];
  for (NSString *file in
       [NSFileManager.defaultManager contentsOfDirectoryAtPath:NSBundle.mainBundle.bundlePath
                                                         error:nil]) {
    if (![file hasSuffix:@"bundle"]) continue;
    NSBundle *bundle = [NSBundle
        bundleWithPath:[NSBundle.mainBundle pathForResource:[file stringByDeletingPathExtension]
                                                     ofType:@"bundle"]];
    if (bundle) [assetBundles addObject:bundle];
  }
  for (NSString *file in [NSFileManager.defaultManager
           contentsOfDirectoryAtPath:[NSBundle.mainBundle.bundlePath
                                         stringByAppendingPathComponent:@"Frameworks"]
                               error:nil]) {
    if (![file hasSuffix:@"framework"]) continue;
    NSBundle *bundle = [NSBundle
        bundleWithPath:[NSBundle.mainBundle pathForResource:[file stringByDeletingPathExtension]
                                                     ofType:@"framework"
                                                inDirectory:@"Frameworks"]];
    if (bundle) [assetBundles addObject:bundle];
  }
  // rebind_symbols(
  //     (struct rebinding[]){
  //         {"_availability_version_check", (void *)hook__availability_version_check,
  //          (void **)&orig__availability_version_check},
  //     },
  //     1);
  _dyld_register_func_for_add_image(add_image);
}
