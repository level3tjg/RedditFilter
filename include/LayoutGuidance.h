#import <Foundation/Foundation.h>

@interface LayoutGuidance : NSObject
@property(class, nonatomic, readonly) LayoutGuidance *currentGuidance;
@property(nonatomic, readonly, assign) CGFloat gridPadding;
@property(nonatomic, readonly, assign) CGFloat maxContentWidth;
@property(nonatomic, readonly, assign) CGFloat gridPaddingDouble;
@end