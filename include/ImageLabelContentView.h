#import "AttributedLabelRegular.h"
#import "BaseView.h"

@interface ImageLabelContentView : BaseView
@property(nonatomic, readonly, strong) UIImageView *imageView;
@property(nonatomic, readonly, strong) AttributedLabelRegular *mainLabel;
@end