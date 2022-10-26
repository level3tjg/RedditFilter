#import <Carousel.h>
#import <Post.h>
#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import "Preferences.h"

@interface UIImage ()
+ (UIImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;
@end

@interface NSURLRequest ()
@property(readonly) NSString *graphQLOperationName;
@property(readonly) NSString *graphQLOperationId;
@end

NSMutableArray *assetBundles;

UIImage *iconWithName(NSString *iconName) {
  for (NSBundle *bundle in assetBundles) {
    UIImage *iconImage = [UIImage imageNamed:iconName inBundle:bundle];
    if (iconImage) return iconImage;
  }
  return nil;
}

%hook Listing
- (void)fetchNextPage:(id (^)(NSArray *, id))completion {
  id (^newCompletion)(NSArray *, id) = ^id(NSArray *objects, id arg2) {
    objects = [objects
        filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object,
                                                                          NSDictionary *bindings) {
          NSString *className = NSStringFromClass(object_getClass(object));
          if ([NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterPromoted]) {
            if ([className hasSuffix:@"AdPost"]) return NO;
            if ([className hasSuffix:@"Post"] && [object respondsToSelector:@selector(isAdPost)] &&
                ((Post *)object).isAdPost)
              return NO;
          }
          if ([NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterRecommended]) {
            if ([className containsString:@"Recommendation"]) return NO;
          }
          if ([NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterLivestreams]) {
            if ([className containsString:@"Stream"]) return NO;
          }
          if ([NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterNSFW]) {
            if ([className hasSuffix:@"Post"] && [object respondsToSelector:@selector(isNSFW)] &&
                ((Post *)object).isNSFW)
              return NO;
          }
          return YES;
        }]];
    return completion(objects, arg2);
  };
  %orig(newCompletion);
}
%end

%hook PostDetailPresenter
- (BOOL)shouldFetchCommentAdPost {
  return [NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterPromoted] ? NO
                                                                                : %orig;
}
%end

%hook _TtC6Reddit13StreamManager
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
  return [NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterRecommended] &&
                 ([self.analyticType isEqualToString:@"recommended_posts"] ||
                  [self.analyticType isEqualToString:@"recommended_subreddits"] ||
                  [self.analyticType isEqualToString:@"similar_subreddits"] ||
                  [self.analyticType isEqualToString:@"popular_posts_near_you"])

             ? YES
             : %orig;
}
%end

%hook _TtC6Reddit20QuickActionViewModel
- (void)fetchActions {
  if ([NSUserDefaults.standardUserDefaults boolForKey:kRedditFilterRecommended]) return;
  %orig;
}
%end

static void init() { %init; }

static void add_image(const struct mach_header *mh, intptr_t vmaddr_slide) {
  Dl_info dlinfo;
  if (!dladdr(mh, &dlinfo)) return;
  if (!strstr(dlinfo.dli_fname, "RedditCore")) return;
  if (!%c(Listing))
    NSLog(@"No Listing class?");
  else
    init();
}

%ctor {
  assetBundles = [NSMutableArray new];
  [assetBundles addObject:NSBundle.mainBundle];
  NSBundle *redditAppAssetsBundle =
      [NSBundle bundleWithPath:[NSBundle.mainBundle pathForResource:@"RedditAppAssetsBundle"
                                                             ofType:@"bundle"]];
  if (redditAppAssetsBundle) [assetBundles addObject:redditAppAssetsBundle];
  NSBundle *genericAssetsBundle = [NSBundle
      bundleWithPath:[NSBundle.mainBundle pathForResource:@"GenericAssetsBundle" ofType:@"bundle"]];
  if (genericAssetsBundle) [assetBundles addObject:genericAssetsBundle];
  if (%c(Listing))
    init();
  else
    _dyld_register_func_for_add_image(add_image);
}
