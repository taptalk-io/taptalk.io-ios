//
//  TAPYourChatDeletedBubbleTableViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 29/05/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseXIBRotatedTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPYourChatDeletedBubbleTableViewCellType) {
    TAPYourChatDeletedBubbleTableViewCellTypeDefault = 0,
    TAPYourChatDeletedBubbleTableViewCellTypeUnsupported = 1,
};

@protocol TAPYourChatDeletedBubbleTableViewCellDelegate <NSObject>

- (void)yourChatDeletedBubbleViewDidTapped:(TAPMessageModel *)tappedMessage;
- (void)yourChatDeletedBubbleDidTappedProfilePictureWithMessage:(TAPMessageModel *)tappedMessage;

@end

@interface TAPYourChatDeletedBubbleTableViewCell : TAPBaseXIBRotatedTableViewCell

@property (weak, nonatomic) id<TAPYourChatDeletedBubbleTableViewCellDelegate> delegate;
@property (weak, nonatomic) TAPMessageModel *message;
@property (nonatomic) TAPYourChatDeletedBubbleTableViewCellType type;

- (void)setMessage:(TAPMessageModel *)message;
- (void)showStatusLabel:(BOOL)isShowed animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
