//
//  TAPOrderCardBubbleTableViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 07/11/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseXIBRotatedTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPOrderCardSenderType) {
    TAPOrderCardSenderTypeMy = 0,
    TAPOrderCardSenderTypeYour = 1
};

@protocol TAPOrderCardBubbleTableViewCellDelegate <NSObject>

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

@property (weak, nonatomic) id<TAPOrderCardBubbleTableViewCellDelegate> delegate;

@property (nonatomic) TAPOrderCardSenderType *orderCardSenderType;

- (void)setOrderCardWithType:(NSInteger)type; //CS TEMP - Dummy Set Data

@end

NS_ASSUME_NONNULL_END
