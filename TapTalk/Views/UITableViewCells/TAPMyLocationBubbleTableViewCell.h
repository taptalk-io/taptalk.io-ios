//
//  TAPMyLocationBubbleTableViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 21/02/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseMyBubbleTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TAPMyLocationBubbleTableViewCellDelegate <NSObject>

- (void)myLocationBubbleViewDidTapped:(TAPMessageModel *)tappedMessage;
- (void)myLocationQuoteViewDidTapped:(TAPMessageModel *)tappedMessage;
- (void)myLocationReplyDidTapped:(TAPMessageModel *)tappedMessage;
- (void)myLocationBubbleLongPressedWithMessage:(TAPMessageModel *)longPressedMessage;

@end

@interface TAPMyLocationBubbleTableViewCell : TAPBaseMyBubbleTableViewCell

@property (weak, nonatomic) id<TAPMyLocationBubbleTableViewCellDelegate> delegate;
@property (weak, nonatomic) TAPMessageModel *message;

- (void)setMessage:(TAPMessageModel *)message;
- (void)receiveSentEvent;
- (void)receiveDeliveredEvent;
- (void)receiveReadEvent;
- (void)showStatusLabel:(BOOL)isShowed animated:(BOOL)animated updateStatusIcon:(BOOL)updateStatusIcon message:(TAPMessageModel *)message;

@end

NS_ASSUME_NONNULL_END
