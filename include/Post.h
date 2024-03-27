#import <Foundation/Foundation.h>

@interface Post : NSObject
@property(nonatomic, assign) BOOL isAdPost;
@property(nonatomic, assign) BOOL isNSFW;
- (BOOL)isPromotedUserPostAd;
- (BOOL)isPromotedCommunityPostAd;
@end