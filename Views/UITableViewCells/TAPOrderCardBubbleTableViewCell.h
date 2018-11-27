//
//  TAPOrderCardBubbleTableViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 07/11/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseXIBRotatedTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, OrderCardSenderType) {
    OrderCardSenderTypeMy = 0,
    OrderCardSenderTypeYour = 1
};

@protocol OrderCardBubbleTableViewCellDelegate <NSObject>

- (void)orderCardBubbleDidTappedHeaderButtonDidTapped;
- (void)orderCardBubbleDidTappedOrderStatusButtonDidTapped;
- (void)orderCardBubbleDidTappedReviewConfirmActionButtonDidTapped;
- (void)orderCardBubbleDidTappedUpdateCostActionButtonDidTapped;
- (void)orderCardBubbleDidTappedConfirmPaymentActionButtonDidTapped;
- (void)orderCardBubbleDidTappedReviewOrderActionButtonDidTapped;
- (void)orderCardBubbleDidTappedMarkFinishedActionButtonDidTapped;
- (void)orderCardBubbleDidTappedExpertMarkFinishedButtonDidTapped;
- (void)orderCardBubbleDidTappedCurrentStatusButton;

@end

@interface TAPOrderCardBubbleTableViewCell : TAPBaseXIBRotatedTableViewCell

@property (weak, nonatomic) id<OrderCardBubbleTableViewCellDelegate> delegate;

@property (nonatomic) OrderCardSenderType *orderCardSenderType;

@end

NS_ASSUME_NONNULL_END
