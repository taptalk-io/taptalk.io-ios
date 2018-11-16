//
//  TAPProfileViewController.m
//  TapTalk
//
//  Created by Welly Kencana on 30/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPProfileViewController.h"
#import "TAPProfileView.h"

#import "TAPProfileCollectionViewCell.h"
#import "TAPImageCollectionViewCell.h"

@interface TAPProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) TAPProfileView *profileView;

@end

@implementation TAPProfileViewController

#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    
    _profileView = [[TAPProfileView alloc] initWithFrame:[TAPBaseView frameWithoutNavigationBar]];
    [self.view addSubview:self.profileView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.profileView.collectionView.delegate = self;
    self.profileView.collectionView.dataSource = self;
    
    [self.profileView.navigationBackButton addTarget:self action:@selector(backButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.profileView.backButton addTarget:self action:@selector(backButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self.profileView.profileImageView setImageWithURLString:TAP_DUMMY_IMAGE_URL]; //WK Temp - Dummy image url
    
    self.profileView.nameLabel.text = self.room.name;
    self.profileView.navigationNameLabel.text = self.room.name;
}

#pragma mark - Data Source
#pragma mark CollectionView
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        CGSize cellSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 56.0f);
        return cellSize;
    }
    else if (indexPath.section == 1) {
        CGSize cellSize = CGSizeMake((CGRectGetWidth([UIScreen mainScreen].bounds) - 3.0f) / 3.0f, (CGRectGetWidth([UIScreen mainScreen].bounds) - 3.0f) / 3.0f);
        return cellSize;
    }
    
    CGSize size = CGSizeZero;
    return size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    if (section == 1) {
        UIEdgeInsets cellInsets = UIEdgeInsetsMake(0.0f, 0.5f, 0.0f, 0.5f);
        return cellInsets;
    }
    
    return UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if (section == 1) {
        return 1.0f;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (section == 1) {
        return 1.0f;
    }
    
    return 0.0f;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    }
    else if (section == 1) {
        return 40; //WK Temp
    }
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSString *cellID = @"TAPProfileCollectionViewCell";
        [collectionView registerClass:[TAPProfileCollectionViewCell class] forCellWithReuseIdentifier:cellID];
        TAPProfileCollectionViewCell *cell = (TAPProfileCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
        
        if (indexPath.item == 0) {
            [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeNotification];
            [cell showSeparatorView:YES];
        }
        else if (indexPath.item == 1) {
            [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeConversationColor];
            [cell showSeparatorView:YES];
        }
        else if (indexPath.item == 2) {
            [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeBlock];
            [cell showSeparatorView:YES];
        }
        else if (indexPath.item == 3) {
            [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeClearChat];
            [cell showSeparatorView:NO];
        }
        
        return cell;
    }
    else if (indexPath.section == 1) {
        NSString *cellID = @"TAPImageCollectionViewCell";
        [collectionView registerClass:[TAPImageCollectionViewCell class] forCellWithReuseIdentifier:cellID];

        TAPImageCollectionViewCell *cell = (TAPImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
        if (cell == nil) {
            NSLog(@"===>");
        }
        
        [cell setImageCollectionViewCellWithURL:TAP_DUMMY_IMAGE_URL]; //WK Temp - Dummy image URL
        
        return cell;
    }
    
    static NSString *cellID = @"UICollectionViewCell";
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellID];
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.backgroundColor = [UIColor blueColor];
    
    return cell;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attributesInRect = [NSArray array];
    return attributesInRect;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        CGSize headerSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 30.0f);
        return headerSize;
    }
    
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (kind == UICollectionElementKindSectionHeader) {
        if (indexPath.section == 1) {
            NSString *headerID = @"ShareMediaHeaderView";
            [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:kind withReuseIdentifier:headerID];
            
            UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerID forIndexPath:indexPath];
            
            UICollectionViewLayoutAttributes *attributes = [collectionView layoutAttributesForItemAtIndexPath:indexPath];
            [headerView preferredLayoutAttributesFittingAttributes:attributes];
            
            headerView.backgroundColor = [TAPUtil getColor:TAP_COLOR_WHITE_F3];
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - 16.0f - 16.0f, CGRectGetHeight(headerView.frame))];
            titleLabel.text = @"SHARED MEDIA";
            titleLabel.textColor = [TAPUtil getColor:TAP_COLOR_MOSELO_PURPLE];
            titleLabel.font = [UIFont fontWithName:TAP_FONT_LATO_BOLD size:11.0f];
            
            [headerView addSubview:titleLabel];
            
            return headerView;
        }
        
        NSString *headerID = @"headerView";
        [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:kind withReuseIdentifier:headerID];
        
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerID forIndexPath:indexPath];
        
        UICollectionViewLayoutAttributes *attributes = [collectionView layoutAttributesForItemAtIndexPath:indexPath];
        [headerView preferredLayoutAttributesFittingAttributes:attributes];
        
        if (headerView == nil) {
            headerView = [[UICollectionReusableView alloc] initWithFrame:CGRectZero];
        }
        
        return headerView;
    }
    else if (kind == UICollectionElementKindSectionFooter) {
        NSString *footerID = @"footerView";
        [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:kind withReuseIdentifier:footerID];
        
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerID forIndexPath:indexPath];
        
        UICollectionViewLayoutAttributes *attributes = [collectionView layoutAttributesForItemAtIndexPath:indexPath];
        [footerView preferredLayoutAttributesFittingAttributes:attributes];
        
        if (footerView == nil) {
            footerView = [[UICollectionReusableView alloc] initWithFrame:CGRectZero];
        }
        
        return footerView;
    }
    
    return nil;
}

#pragma mark - Delegate
#pragma mark CollectionView
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark ScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat topPadding = 0.0f;
    if (IS_IPHONE_X_FAMILY) {
        topPadding = [TAPUtil currentDeviceStatusBarHeight];
    }
    
    CGFloat meetingPoint = 44.0f + [TAPUtil currentDeviceStatusBarHeight];
    if (IS_IPHONE_X_FAMILY) {
        meetingPoint = 44.0f; //WK Note - Because the image Y position is max Y of status bar for iphone X.
    }
    
    CGFloat scrollProgress = 1 + ((scrollView.contentOffset.y + meetingPoint) / (CGRectGetHeight(self.profileView.profileImageView.frame) - meetingPoint));
    if (scrollProgress < 0.0f) {
        scrollProgress = 0.0f;
    }
    else if (scrollProgress > 1.0f) {
        scrollProgress = 1.0f;
    }
    
    //CHANGE FRAME nameLabel
    CGRect nameLabelFrame = self.profileView.nameLabel.frame;
    CGFloat nameLabelYPosition = self.profileView.nameLabelYPosition - (CGRectGetHeight(self.profileView.profileImageView.frame) - meetingPoint) * scrollProgress;
    nameLabelFrame.origin.y = nameLabelYPosition;
    self.profileView.nameLabel.frame = nameLabelFrame;
    
    //CHANGE FRAME navigationBarView
    CGRect navigationBarViewFrame = self.profileView.navigationBarView.frame;
    CGFloat navigationBarViewYPosition = -self.profileView.navigationBarHeight + topPadding + ((self.profileView.navigationBarHeight - topPadding) * scrollProgress);
    navigationBarViewFrame.origin.y = navigationBarViewYPosition;
    self.profileView.navigationBarView.frame = navigationBarViewFrame;
    
    //CHANGE FRAME navigationNameLabel
    CGRect navigationNameLabelFrame = self.profileView.navigationNameLabel.frame;
    CGFloat navigationNameLabelYPosition = self.profileView.navigationNameLabelYPosition - CGRectGetHeight(self.profileView.profileImageView.frame) * scrollProgress;
    navigationNameLabelFrame.origin.y = navigationNameLabelYPosition;
    self.profileView.navigationNameLabel.frame = navigationNameLabelFrame;
    
    self.profileView.navigationBackButton.alpha = scrollProgress;
    self.profileView.backButton.alpha = 1 - scrollProgress;
    
    self.profileView.collectionView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:scrollProgress];
}

#pragma mark - Custom Method
- (void)backButtonDidTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
