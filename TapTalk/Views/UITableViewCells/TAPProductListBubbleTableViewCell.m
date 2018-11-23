//
//  TAPProductListBubbleTableViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 05/11/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPProductListBubbleTableViewCell.h"
#import "TAPProductListCollectionViewCell.h"

@interface TAPProductListBubbleTableViewCell () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation TAPProductListBubbleTableViewCell

#pragma mark - Lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
    
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
    return 6; //DV Temp
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"TAPProductListCollectionViewCell";
    
    [collectionView registerNib:[UINib nibWithNibName:@"TAPProductListCollectionViewCell" bundle:[TAPUtil currentBundle]] forCellWithReuseIdentifier:cellIdentifier];
    
    TAPProductListCollectionViewCell *cell = (TAPProductListCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [cell setProductListWithData];
    
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

#pragma mark - Custom Method

@end
