#import "AttributedLabelRegular.h"
#import "BaseView.h"

@interface ImageLabelContentView : BaseView
@property(nonatomic, readonly, strong) UIImageView *imageView;
@property(nonatomic, readonly, strong) AttributedLabelRegular *mainLabel;
@property(nonatomic, readonly, strong) BaseLabel *detailLabel;
@property(nonatomic, strong) UIStackView *horizontalStackView;
@end