//
//  TAPProductListBubbleTableViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 05/11/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPProductListBubbleTableViewCell.h"
#import "TAPProductListCollectionViewCell.h"

@interface TAPProductListBubbleTableViewCell () <UICollectionViewDelegate, UICollectionViewDataSource, TAPProductListCollectionViewCellDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *productDataArray;

@end

@implementation TAPProductListBubbleTableViewCell

#pragma mark - Lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
    _productDataArray = [[NSMutableArray alloc] init];
    
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


#pragma mark - Data Source
#pragma mark UICollectionView
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (IS_IPHONE_4_7_INCH_AND_ABOVE) {
        return CGSizeMake(270.0f, 347.0f);
    }
    else {
        return CGSizeMake(230.0f, 347.0f);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0.0f, 16.0f, 0.0f, 16.0f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 8.0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [self.productDataArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"TAPProductListCollectionViewCell";
    
    [collectionView registerNib:[UINib nibWithNibName:@"TAPProductListCollectionViewCell" bundle:[TAPUtil currentBundle]] forCellWithReuseIdentifier:cellIdentifier];
    
    TAPProductListCollectionViewCell *cell = (TAPProductListCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    cell.delegate = self;
    cell.selectedIndexPath = indexPath;
    
    BOOL isSingleOption = NO;
    if (self.productListBubbleTableViewCellType == TAPProductListBubbleTableViewCellTypeSingleOption) {
        isSingleOption = YES;
    }
    
    [cell setAsSingleButtonView:isSingleOption];
    
    if ([self.productDataArray count] != 0) {
        NSDictionary *productData = [self.productDataArray objectAtIndex:indexPath.row];
        [cell setProductCellWithData:productData];
    }
    
    return cell;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attributesInRect = [NSArray array];
    
    return attributesInRect;
}

#pragma mark - Delegate
#pragma mark UICollectionView
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - TAPProductListCollectionViewCell
- (void)leftOrSingleOptionButtonDidTappedWithIndexPath:(NSIndexPath *)indexPath isSingleOptionView:(BOOL)isSingleOption {
    
//    if ([self.delegate respondsToSelector:@selector(productListBubbleDidTappedLeftOrSingleOptionWithData:isSingleOptionView:)]) {
//        [self.delegate productListBubbleDidTappedLeftOrSingleOptionWithData:<#(nonnull TAPMessageModel *)#> isSingleOptionView:isSingleOption];
//    }
}

- (void)rightOptionButtonDidTappedWithIndexPath:(NSIndexPath *)indexPath isSingleOptionView:(BOOL)isSingleOption {
    
}

#pragma mark - Custom Method
- (void)setProductListBubbleCellWithData:(NSArray *)productDataArray {
    _productDataArray = productDataArray;
    [self.collectionView reloadData];
}

- (void)setProductListBubbleTableViewCellType:(TAPProductListBubbleTableViewCellType)productListBubbleTableViewCellType {
    _productListBubbleTableViewCellType = productListBubbleTableViewCellType;
}

@end
