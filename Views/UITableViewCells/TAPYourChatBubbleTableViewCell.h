//
//  TAPYourChatBubbleTableViewCell.h
//  TapTalk
//
//  Created by Welly Kencana on 1/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseXIBRotatedTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TAPYourChatBubbleTableViewCellDelegate <NSObject>

- (void)yourChatBubbleViewDidTapped:(TAPMessageModel *)tappedMessage;
- (void)yourChatReplyDidTapped;

@end

@interface TAPYourChatBubbleTableViewCell : TAPBaseXIBRotatedTableViewCell

@property (weak, nonatomic) id<TAPYourChatBubbleTableViewCellDelegate> delegate;
@property (weak, nonatomic) TAPMessageModel *message;

- (void)setMessage:(TAPMessageModel *)message;
- (void)showStatusLabel:(BOOL)isShowed animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
