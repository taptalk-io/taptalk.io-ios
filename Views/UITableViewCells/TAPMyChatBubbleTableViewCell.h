//
//  TAPMyChatBubbleTableViewCell.h
//  TapTalk
//
//  Created by Welly Kencana on 25/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseXIBRotatedTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TAPMyChatBubbleTableViewCellDelegate <NSObject>

- (void)myChatBubbleViewDidTapped:(TAPMessageModel *)tappedMessage;
- (void)myChatReplyDidTapped;

@end

@interface TAPMyChatBubbleTableViewCell : TAPBaseXIBRotatedTableViewCell

@property (weak, nonatomic) id<TAPMyChatBubbleTableViewCellDelegate> delegate;
@property (weak, nonatomic) TAPMessageModel *message;

- (void)setMessage:(TAPMessageModel *)message;
- (void)animateSendingIcon;
- (void)setAsDelivered;
- (void)setAsRead;
- (void)showStatusLabel:(BOOL)isShowed animated:(BOOL)animated updateStatusIcon:(BOOL)updateStatusIcon;

@end

NS_ASSUME_NONNULL_END
