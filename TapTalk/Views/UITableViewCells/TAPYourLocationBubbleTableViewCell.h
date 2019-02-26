//
//  TAPYourLocationBubbleTableViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 21/02/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseXIBRotatedTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TAPYourLocationBubbleTableViewCellDelegate <NSObject>

- (void)yourLocationBubbleViewDidTapped:(TAPMessageModel *)tappedMessage;
- (void)yourLocationQuoteViewDidTapped:(TAPMessageModel *)tappedMessage;
- (void)yourLocationReplyDidTapped:(TAPMessageModel *)tappedMessage;

@end

@interface TAPYourLocationBubbleTableViewCell : TAPBaseXIBRotatedTableViewCell

@property (weak, nonatomic) id<TAPYourLocationBubbleTableViewCellDelegate> delegate;

@property (weak, nonatomic) TAPMessageModel *message;

- (void)setMessage:(TAPMessageModel *)message;
- (void)showStatusLabel:(BOOL)isShowed animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
