#import "AttributedLabelRegular.h"
#import "BaseTableViewCell.h"

@interface ViewLabelTableViewCell : BaseTableViewCell {
  UIStackView *labelsStackView;
  UIStackView *horizontalStackView;
}
@property(nonatomic, readonly, strong) AttributedLabelRegular *mainLabel;
@property(nonatomic, readonly, strong) BaseLabel *detailLabel;
@end