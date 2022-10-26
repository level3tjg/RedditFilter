#import "ImageLabelContentView.h"
#import "ViewLabelTableViewCell.h"

@interface ImageLabelTableViewCell : ViewLabelTableViewCell
@property(nonatomic, strong) ImageLabelContentView *imageLabelView;
@property UIImage *displayImage;
- (void)setCustomAccessoryImage:(UIImage *)customAccessoryImage;
@end