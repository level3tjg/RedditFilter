#import "ImageLabelContentView.h"
#import "ViewLabelTableViewCell.h"

@interface ImageLabelTableViewCell : ViewLabelTableViewCell
@property(nonatomic, strong) ImageLabelContentView *imageLabelView;
@property(nonatomic, strong) UIImage *displayImage;
- (void)setCustomAccessoryImage:(UIImage *)customAccessoryImage;
@end