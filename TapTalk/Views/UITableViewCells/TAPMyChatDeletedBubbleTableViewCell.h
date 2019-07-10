//
//  TAPMyChatDeletedBubbleTableViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 28/05/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseMyBubbleTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TAPMyChatDeletedBubbleTableViewCellDelegate <NSObject>

- (void)myChatDeletedBubbleViewDidTapped:(TAPMessageModel *)tappedMessage;

@end

@interface TAPMyChatDeletedBubbleTableViewCell : TAPBaseMyBubbleTableViewCell

@property (weak, nonatomic) id<TAPMyChatDeletedBubbleTableViewCellDelegate> delegate;
@property (strong, nonatomic) TAPMessageModel *message;

- (void)setMessage:(TAPMessageModel *)message;
- (void)receiveSentEvent;
- (void)receiveDeliveredEvent;
- (void)receiveReadEvent;
- (void)showStatusLabel:(BOOL)isShowed animated:(BOOL)animated updateStatusIcon:(BOOL)updateStatusIcon message:(TAPMessageModel *)message;

@end

NS_ASSUME_NONNULL_END
