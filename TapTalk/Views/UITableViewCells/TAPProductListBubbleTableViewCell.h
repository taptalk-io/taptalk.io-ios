//
//  TAPProductListBubbleTableViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 05/11/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseXIBRotatedTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPProductListBubbleTableViewCellType) {
    TAPProductListBubbleTableViewCellTypeSingleOption = 0,
    TAPProductListBubbleTableViewCellTypeTwoOption = 1
};

@protocol TAPProductListBubbleTableViewCellDelegate <NSObject>

- (void)productListBubbleDidTappedLeftOrSingleOptionWithData:(NSDictionary *)productDictionary isSingleOptionView:(BOOL)isSingleOption;
- (void)productListBubbleDidTappedRightOptionWithData:(NSDictionary *)productDictionary isSingleOptionView:(BOOL)isSingleOption;

@end

@interface TAPProductListBubbleTableViewCell : TAPBaseXIBRotatedTableViewCell

@property (nonatomic) TAPProductListBubbleTableViewCellType productListBubbleTableViewCellType;
@property (weak, nonatomic) id<TAPProductListBubbleTableViewCellDelegate> delegate;
@property (nonatomic) BOOL isCurrentActiveUserProduct; //Indicate whether the product is belong to current active user

- (void)setProductListBubbleCellWithData:(NSArray *)productDataArray;
- (void)setProductListBubbleTableViewCellType:(TAPProductListBubbleTableViewCellType)productListBubbleTableViewCellType;

@end

NS_ASSUME_NONNULL_END
