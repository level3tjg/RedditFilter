#import "AttributedLabelRegular.h"
#import "BaseTableViewCell.h"

@interface ViewLabelTableViewCell : BaseTableViewCell
@property(nonatomic, readonly, strong) AttributedLabelRegular *mainLabel;
@end