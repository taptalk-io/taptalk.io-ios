//
//  TAPLinksShareMediaTableViewCell.h
//  TapTalk-TapTalk
//
//  Created by TapTalk.io on 18/08/22.
//

#import "TAPBaseXIBTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TAPLinkShareManagerCellDelegate <NSObject>

- (void)linkShareManagerLongPressedWithMessage:(TAPMessageModel *)longPressedMessage;
- (void)sharedLinkUrlDidTappedWithMessage:(TAPMessageModel *)message url:(NSURL *)url;
- (void)sharedLinkUrlDidLongPressedWithMessage:(TAPMessageModel *)message url:(NSURL *)url;

@end

@interface TAPLinksShareMediaTableViewCell : TAPBaseXIBTableViewCell
@property (weak, nonatomic) id<TAPLinkShareManagerCellDelegate> delegate;
- (void)setLinkLabelWithString:(NSString *)linkUrlString;
@property (weak, nonatomic) TAPMessageModel *message;

@end

NS_ASSUME_NONNULL_END
