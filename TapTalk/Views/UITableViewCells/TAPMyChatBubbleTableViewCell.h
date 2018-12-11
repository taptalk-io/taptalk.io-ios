//
//  TAPMyChatBubbleTableViewCell.h
//  TapTalk
//
//  Created by Welly Kencana on 25/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseMyBubbleTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TAPMyChatBubbleTableViewCellDelegate <NSObject>

- (void)myChatBubbleViewDidTapped:(TAPMessageModel *)tappedMessage;
- (void)myChatReplyDidTapped;

@end

@interface TAPMyChatBubbleTableViewCell : TAPBaseMyBubbleTableViewCell

@property (weak, nonatomic) id<TAPMyChatBubbleTableViewCellDelegate> delegate;
@property (weak, nonatomic) TAPMessageModel *message;

- (void)setMessage:(TAPMessageModel *)message;
- (void)receiveSentEvent;
- (void)receiveDeliveredEvent;
- (void)receiveReadEvent;
- (void)showStatusLabel:(BOOL)isShowed animated:(BOOL)animated updateStatusIcon:(BOOL)updateStatusIcon;

@end

NS_ASSUME_NONNULL_END
