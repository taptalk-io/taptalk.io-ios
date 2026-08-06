//
//  TAPProductListCollectionViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 05/11/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TAPProductListCollectionViewCellDelegate <NSObject>

@optional

- (void)leftOrSingleOptionButtonDidTappedWithIndexPath:(NSIndexPath *)indexPath isSingleOptionView:(BOOL)isSingleOption;
- (void)rightOptionButtonDidTappedWithIndexPath:(NSIndexPath *)indexPath isSingleOptionView:(BOOL)isSingleOption;

@end

@interface TAPProductListCollectionViewCell : TAPBaseCollectionViewCell

@property (strong, nonatomic) IBOutlet UIButton *leftOptionButton;
@property (strong, nonatomic) IBOutlet UIButton *rightOptionButton;
@property (strong, nonatomic) IBOutlet UIButton *singleOptionButton;

@property (weak, nonatomic) id<TAPProductListCollectionViewCellDelegate> delegate;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (nonatomic) BOOL isSetAsSingleButtonView;

- (void)setProductCellWithData:(NSDictionary *)dataDictionary;
- (void)setAsSingleButtonView:(BOOL)isSetAsSingleButtonView;
- (void)setCellCornerRadiusPositionWithCurrentActiveUserProduct:(BOOL)isCurrentActiveUserProduct;
@end

NS_ASSUME_NONNULL_END
