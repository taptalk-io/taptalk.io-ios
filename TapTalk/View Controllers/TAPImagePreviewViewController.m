//
//  TAPImagePreviewViewController.m
//  TapTalk
//
//  Created by Dominic Vedericho on 18/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPImagePreviewViewController.h"
#import "TAPImagePreviewView.h"
#import "TapThumbnailImagePreviewCollectionViewCell.h"
#import "TAPImagePreviewCollectionViewCell.h"

@interface TAPImagePreviewViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) TAPImagePreviewView *imagePreviewView;

@property (strong, nonatomic) NSMutableDictionary *captionDictionary;

@end

@implementation TAPImagePreviewViewController

#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    
    _imagePreviewView = [[TAPImagePreviewView alloc] initWithFrame:[TAPBaseView frameWithoutNavigationBar]];
    [self.view addSubview:self.imagePreviewView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imagePreviewView.imagePreviewCollectionView.delegate = self;
    self.imagePreviewView.imagePreviewCollectionView.dataSource = self;
    
    self.imagePreviewView.thumbnailCollectionView.delegate = self;
    self.imagePreviewView.thumbnailCollectionView.dataSource = self;
    
    _captionDictionary = [[NSMutableDictionary alloc] init];
    
}

#pragma mark - Data Source
#pragma mark CollectionView
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.imagePreviewView.imagePreviewCollectionView) {
        
        CGFloat imagePreviewCollectionViewHeight = CGRectGetHeight([UIScreen mainScreen].bounds);
        if (IS_IPHONE_X_FAMILY) {
            imagePreviewCollectionViewHeight = imagePreviewCollectionViewHeight - [TAPUtil safeAreaTopPadding] - [TAPUtil safeAreaBottomPadding];
        }
        
        CGSize cellSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), imagePreviewCollectionViewHeight);
        return cellSize;
    }
    else if (collectionView == self.imagePreviewView.thumbnailCollectionView) {
        CGSize cellSize = CGSizeMake(58.0f, 58.0f);
        return cellSize;
    }
    
    CGSize size = CGSizeZero;
    return size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
   
    if (collectionView == self.imagePreviewView.imagePreviewCollectionView) {
        return UIEdgeInsetsZero;
    }
    else if (collectionView == self.imagePreviewView.thumbnailCollectionView) {
        return UIEdgeInsetsMake(0.0f, 16.0f, 0.0f, 16.0f);
    }
    
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    if (collectionView == self.imagePreviewView.imagePreviewCollectionView) {
        return 0.0f;
    }
    else if (collectionView == self.imagePreviewView.thumbnailCollectionView) {
        return 1.0f;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return 3; //DV Temp
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.imagePreviewView.imagePreviewCollectionView) {
        NSString *cellID = @"TAPImagePreviewCollectionViewCell";
        [collectionView registerClass:[TAPImagePreviewCollectionViewCell class] forCellWithReuseIdentifier:cellID];
        TAPImagePreviewCollectionViewCell *cell = (TAPImagePreviewCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
        
        [cell setImagePreviewImage:[UIImage imageNamed:@"dummyImagePreview" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil]]; //DV Temp

        return cell;
    }
    else if (collectionView == self.imagePreviewView.thumbnailCollectionView) {
        NSString *cellID = @"TapThumbnailImagePreviewCollectionViewCell";
        [collectionView registerClass:[TapThumbnailImagePreviewCollectionViewCell class] forCellWithReuseIdentifier:cellID];
        TapThumbnailImagePreviewCollectionViewCell *cell = (TapThumbnailImagePreviewCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];

        [cell setThumbnailImageView:[UIImage imageNamed:@"dummyImagePreview" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil]]; //DV Temp
        
        return cell;
    }
    
    static NSString *cellID = @"UICollectionViewCell";
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellID];
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    
    return cell;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attributesInRect = [NSArray array];
    return attributesInRect;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    return nil;
}

#pragma mark - Delegate
#pragma mark CollectionView
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.imagePreviewView.imagePreviewCollectionView) {
  
    }
    else if (collectionView == self.imagePreviewView.thumbnailCollectionView) {
  
    }
}

#pragma mark - Custom Method

@end
