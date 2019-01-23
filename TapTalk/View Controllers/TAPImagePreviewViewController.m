//
//  TAPImagePreviewViewController.m
//  TapTalk
//
//  Created by Dominic Vedericho on 18/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPImagePreviewViewController.h"
#import "TAPImagePreviewView.h"
#import <Photos/Photos.h>

#import "TAPPhotoAlbumListViewController.h"
#import "TAPCustomGrowingTextView.h"

#import "TapThumbnailImagePreviewCollectionViewCell.h"
#import "TAPImagePreviewCollectionViewCell.h"

#import "TAPImagePreviewModel.h"

#define kLimitOfCaptionCharacters 100

@interface TAPImagePreviewViewController () <UICollectionViewDelegate, UICollectionViewDataSource, TAPCustomGrowingTextViewDelegate, TAPPhotoAlbumListViewControllerDelegate>

@property (strong, nonatomic) TAPImagePreviewView *imagePreviewView;

@property (strong, nonatomic) NSMutableArray *imageDataArray;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic) CGFloat captionTextViewHeight;
@property (nonatomic) BOOL isScrolledFromThumbnailImageTapped;

- (void)cancelButtonDidTapped;
- (void)morePictureButtonDidTapped;
- (void)sendButtonDidTapped;
- (void)openGallery;

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
    
    [self.imagePreviewView.captionTextView resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.imagePreviewView.imagePreviewCollectionView.delegate = self;
    self.imagePreviewView.imagePreviewCollectionView.dataSource = self;
    
    self.imagePreviewView.thumbnailCollectionView.delegate = self;
    self.imagePreviewView.thumbnailCollectionView.dataSource = self;
    
    [self.imagePreviewView.cancelButton addTarget:self action:@selector(cancelButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.imagePreviewView.morePictureButton addTarget:self action:@selector(morePictureButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.imagePreviewView.sendButton addTarget:self action:@selector(sendButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    
    _selectedIndex = 0;
    
    self.captionTextViewHeight = 22.0f;
    self.imagePreviewView.captionTextView.delegate = self;
    self.imagePreviewView.captionTextView.minimumHeight = 22.0f;
    self.imagePreviewView.captionTextView.maximumHeight = 60.0f;
    [self.imagePreviewView.captionTextView setFont:[UIFont fontWithName:TAP_FONT_LATO_REGULAR size:15.0f]];
    [self.imagePreviewView.captionTextView setTextColor:[UIColor whiteColor]];
    self.imagePreviewView.captionTextView.tintColor = [UIColor whiteColor];
    [self.imagePreviewView.captionTextView setPlaceholderColor:[UIColor whiteColor]];
    [self.imagePreviewView.captionTextView setPlaceholderText:NSLocalizedString(@"Add a caption", @"")];
    
    self.imagePreviewView.wordLeftLabel.text = [NSString stringWithFormat:@"%ld/%ld", kLimitOfCaptionCharacters, kLimitOfCaptionCharacters];
    [self.imagePreviewView isShowCounterCharLeft:NO];
    
    if ([self.imageDataArray count] != 0 && [self.imageDataArray count] > 1) {
        [self.imagePreviewView isShowAsSingleImagePreview:NO animated:NO];
    }
    else {
        [self.imagePreviewView isShowAsSingleImagePreview:YES animated:NO];
    }
    
    [self.imagePreviewView setItemNumberWithCurrentNumber:1 ofTotalNumber:[self.imageDataArray count]];
    [self.imagePreviewView.imagePreviewCollectionView reloadData];
    [self.imagePreviewView.thumbnailCollectionView reloadData];
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
    return [self.imageDataArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.imagePreviewView.imagePreviewCollectionView) {
        NSString *cellID = @"TAPImagePreviewCollectionViewCell";
        [collectionView registerClass:[TAPImagePreviewCollectionViewCell class] forCellWithReuseIdentifier:cellID];
        TAPImagePreviewCollectionViewCell *cell = (TAPImagePreviewCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
        
        if ([self.imageDataArray count] != 0 && self.imageDataArray != nil) {
            TAPImagePreviewModel *currentImagePreview = [self.imageDataArray objectAtIndex:indexPath.item];
            UIImage *currentImage = currentImagePreview.image;
            [cell setImagePreviewImage:currentImage];
        }
        
        return cell;
    }
    else if (collectionView == self.imagePreviewView.thumbnailCollectionView) {
        NSString *cellID = @"TapThumbnailImagePreviewCollectionViewCell";
        [collectionView registerClass:[TapThumbnailImagePreviewCollectionViewCell class] forCellWithReuseIdentifier:cellID];
        TapThumbnailImagePreviewCollectionViewCell *cell = (TapThumbnailImagePreviewCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];

        if ([self.imageDataArray count] != 0 && self.imageDataArray != nil) {
            TAPImagePreviewModel *currentImagePreview = [self.imageDataArray objectAtIndex:indexPath.item];
            UIImage *currentImage = currentImagePreview.image;
            [cell setThumbnailImageView:currentImage];
        }
        
        if (indexPath.item == self.selectedIndex) {
            [cell setAsSelected:YES];
        }
        else {
            [cell setAsSelected:NO];
        }
        
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

    [self.imagePreviewView.captionTextView resignFirstResponder];

    if (collectionView == self.imagePreviewView.imagePreviewCollectionView) {
        if (indexPath.item != self.selectedIndex) {
            TAPImagePreviewModel *currentImagePreview = [self.imageDataArray objectAtIndex:self.selectedIndex];
            NSString *savedCaptionString = currentImagePreview.caption;
            savedCaptionString = [TAPUtil nullToEmptyString:savedCaptionString];
            
            if (![savedCaptionString isEqualToString:@""] && savedCaptionString != nil) {
                //contain previous saved caption
                [self.imagePreviewView.captionTextView setInitialText:@""];
                [self.imagePreviewView.captionTextView setInitialText:savedCaptionString];
                self.imagePreviewView.wordLeftLabel.text = [NSString stringWithFormat:@"%ld/%ld", kLimitOfCaptionCharacters - [savedCaptionString length], kLimitOfCaptionCharacters];
                [self.imagePreviewView isShowCounterCharLeft:YES];
            }
            else {
                [self.imagePreviewView.captionTextView setInitialText:@""];
                self.imagePreviewView.wordLeftLabel.text = [NSString stringWithFormat:@"%ld/%ld", kLimitOfCaptionCharacters, kLimitOfCaptionCharacters];
                [self.imagePreviewView isShowCounterCharLeft:NO];
            }
        }
    }
    else if (collectionView == self.imagePreviewView.thumbnailCollectionView) {
        
        _isScrolledFromThumbnailImageTapped = YES;
        
        if(indexPath.item == self.selectedIndex) {
            //Remove image
            
            [self.imagePreviewView.captionTextView setInitialText:@""];
            [self.imagePreviewView isShowCounterCharLeft:NO];
            self.imagePreviewView.wordLeftLabel.text = [NSString stringWithFormat:@"%ld/%ld", kLimitOfCaptionCharacters, kLimitOfCaptionCharacters];

            //Remove from data array
            NSLog(@"indexpath item: %ld", indexPath.item);
            
            if (indexPath.item == [self.imageDataArray count] - 1) {
                //Move index to -1 when delete last index
                _selectedIndex = self.selectedIndex - 1;
            }
            
            [self.imageDataArray removeObjectAtIndex:indexPath.item];
            
            [self.imagePreviewView.imagePreviewCollectionView reloadData];
            [self.imagePreviewView.thumbnailCollectionView reloadData];
            
            [self.imagePreviewView setItemNumberWithCurrentNumber:indexPath.item + 1 ofTotalNumber:[self.imageDataArray count]];
            
            if ([self.imageDataArray count] > 0 && [self.imageDataArray count] < 2) {
                [self.imagePreviewView isShowAsSingleImagePreview:YES animated:YES];
            }
        }
        else {
            TapThumbnailImagePreviewCollectionViewCell *previousCell = [self.imagePreviewView.thumbnailCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedIndex inSection:0]];
            [previousCell setAsSelected:NO];
            
            _selectedIndex = indexPath.item;
            
            TapThumbnailImagePreviewCollectionViewCell *currentSelectedCell = [self.imagePreviewView.thumbnailCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:0]];
            [currentSelectedCell setAsSelected:YES];
            
            [self.imagePreviewView.imagePreviewCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
            
            TAPImagePreviewModel *currentImagePreview = [self.imageDataArray objectAtIndex:self.selectedIndex];
            NSString *savedCaptionString = currentImagePreview.caption;
            savedCaptionString = [TAPUtil nullToEmptyString:savedCaptionString];
            
            if (![savedCaptionString isEqualToString:@""] && savedCaptionString != nil) {
                //contain previous saved caption
                [self.imagePreviewView.captionTextView setInitialText:@""];
                [self.imagePreviewView.captionTextView setInitialText:savedCaptionString];
                self.imagePreviewView.wordLeftLabel.text = [NSString stringWithFormat:@"%ld/%ld", kLimitOfCaptionCharacters - [savedCaptionString length], kLimitOfCaptionCharacters];
                [self.imagePreviewView isShowCounterCharLeft:YES];
            }
            else {
                [self.imagePreviewView.captionTextView setInitialText:@""];
                self.imagePreviewView.wordLeftLabel.text = [NSString stringWithFormat:@"%ld/%ld", kLimitOfCaptionCharacters, kLimitOfCaptionCharacters];
                [self.imagePreviewView isShowCounterCharLeft:NO];
            }
        }
    }
}

#pragma mark UIScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self.imagePreviewView.captionTextView resignFirstResponder];
    
    if (scrollView == self.imagePreviewView.imagePreviewCollectionView) {
        NSInteger currentIndex = roundf(scrollView.contentOffset.x / CGRectGetWidth([UIScreen mainScreen].bounds));
        
        if(currentIndex < 0) {
            currentIndex = 0;
        }
        else if(currentIndex > [self.imageDataArray count] - 1) {
            currentIndex = [self.imageDataArray count] - 1;
        }
        
        if (currentIndex != self.selectedIndex) {
            _selectedIndex = currentIndex;
            
            if (currentIndex == 0) {
                //First index
                [self.imagePreviewView.thumbnailCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
            
                [self.imagePreviewView.thumbnailCollectionView setContentOffset:CGPointMake(-self.imagePreviewView.thumbnailCollectionView.contentInset.left, self.imagePreviewView.thumbnailCollectionView.contentOffset.y) animated:YES];
            }
            else if (currentIndex == [self.imageDataArray count] - 1) {
                //Last index
                [self.imagePreviewView.thumbnailCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
                
                if (self.imagePreviewView.thumbnailCollectionView.contentSize.width > CGRectGetWidth(self.imagePreviewView.thumbnailCollectionView.frame)) {
                    [self.imagePreviewView.thumbnailCollectionView setContentOffset:CGPointMake(self.imagePreviewView.thumbnailCollectionView.contentSize.width - CGRectGetWidth(self.imagePreviewView.thumbnailCollectionView.frame) + self.imagePreviewView.thumbnailCollectionView.contentInset.right, self.imagePreviewView.thumbnailCollectionView.contentOffset.y) animated:YES];
                }
            }
            else {
                [self.imagePreviewView.thumbnailCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
            }
            
            if (!self.isScrolledFromThumbnailImageTapped) {
                [self.imagePreviewView.thumbnailCollectionView reloadData];
            }
            
        }
        
        [self.imagePreviewView setItemNumberWithCurrentNumber:currentIndex + 1 ofTotalNumber:[self.imageDataArray count]];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.imagePreviewView.imagePreviewCollectionView) {
        if (self.isScrolledFromThumbnailImageTapped) {
            _isScrolledFromThumbnailImageTapped = NO;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.isScrolledFromThumbnailImageTapped) {
        _isScrolledFromThumbnailImageTapped = NO;
    }
    
    if (scrollView == self.imagePreviewView.imagePreviewCollectionView) {        
        TAPImagePreviewModel *currentImagePreview = [self.imageDataArray objectAtIndex:self.selectedIndex];
        NSString *savedCaptionString = currentImagePreview.caption;
        savedCaptionString = [TAPUtil nullToEmptyString:savedCaptionString];
        
        if (![savedCaptionString isEqualToString:@""] && savedCaptionString != nil) {
            //contain previous saved caption
            [self.imagePreviewView.captionTextView setInitialText:@""];
            [self.imagePreviewView.captionTextView setInitialText:savedCaptionString];
            self.imagePreviewView.wordLeftLabel.text = [NSString stringWithFormat:@"%ld/%ld", kLimitOfCaptionCharacters - [savedCaptionString length], kLimitOfCaptionCharacters];
            [self.imagePreviewView isShowCounterCharLeft:YES];
        }
        else {
            [self.imagePreviewView.captionTextView setInitialText:@""];
            self.imagePreviewView.wordLeftLabel.text = [NSString stringWithFormat:@"%ld/%ld", kLimitOfCaptionCharacters, kLimitOfCaptionCharacters];
            [self.imagePreviewView isShowCounterCharLeft:NO];
        }
    }
}

#pragma mark TAPCustomGrowingTextView
- (BOOL)customGrowingTextView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    NSInteger textLength = [newString length];
    
    if (textLength > kLimitOfCaptionCharacters) {
        return NO;
    }
    
    NSInteger charCountLeft = kLimitOfCaptionCharacters - textLength;
    [self.imagePreviewView setCurrentWordLeftWithCurrentCharCount:charCountLeft];
    
    return YES;
}

- (void)customGrowingTextView:(UITextView *)textView shouldChangeHeight:(CGFloat)height {
    [UIView animateWithDuration:0.1f animations:^{
        
        self.captionTextViewHeight = height;
        
        CGFloat captionTextViewWidth = CGRectGetWidth(self.imagePreviewView.captionView.frame) - 16.0f - 16.0f - 8.0f - CGRectGetWidth(self.imagePreviewView.wordLeftLabel.frame);
        self.imagePreviewView.captionTextView.frame = CGRectMake(CGRectGetMinX(self.imagePreviewView.captionTextView.frame), CGRectGetMinY(self.imagePreviewView.captionTextView.frame), captionTextViewWidth, self.captionTextViewHeight);
        
        self.imagePreviewView.captionSeparatorView.frame = CGRectMake(CGRectGetMinX(self.imagePreviewView.captionSeparatorView.frame), CGRectGetMaxY(self.imagePreviewView.captionTextView.frame) + 12.0f, CGRectGetWidth(self.imagePreviewView.captionSeparatorView.frame), CGRectGetHeight(self.imagePreviewView.captionSeparatorView.frame));
        
        self.imagePreviewView.wordLeftLabel.frame = CGRectMake(CGRectGetMinX(self.imagePreviewView.wordLeftLabel.frame), CGRectGetMinY(self.imagePreviewView.captionSeparatorView.frame) - 15.0f - 13.0f, CGRectGetWidth(self.imagePreviewView.wordLeftLabel.frame), CGRectGetHeight(self.imagePreviewView.wordLeftLabel.frame));
        
        CGFloat captionViewHeight = CGRectGetMaxY(self.imagePreviewView.captionSeparatorView.frame) + 10.0f;
        self.imagePreviewView.captionView.frame = CGRectMake(CGRectGetMinX(self.imagePreviewView.captionView.frame), CGRectGetMinY(self.imagePreviewView.bottomMenuView.frame) - captionViewHeight, CGRectGetWidth(self.imagePreviewView.captionView.frame), captionViewHeight);
    }];
}

- (void)customGrowingTextViewDidBeginEditing:(UITextView *)textView {
    [self.imagePreviewView isShowCounterCharLeft:YES];
}

- (void)customGrowingTextViewDidEndEditing:(UITextView *)textView {
    
    NSString *captionString = textView.text;
    NSString *trimmedCaptionString = [captionString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([trimmedCaptionString isEqualToString:@""]) {
        //remove saved caption
        TAPImagePreviewModel *currentImagePreview = [self.imageDataArray objectAtIndex:self.selectedIndex];
        currentImagePreview.caption = @"";
    }
    else {
        TAPImagePreviewModel *currentImagePreview = [self.imageDataArray objectAtIndex:self.selectedIndex];
        currentImagePreview.caption = captionString;
    }
}

#pragma mark TAPPhotoAlbumListViewController
- (void)photoAlbumListViewControllerSelectImageWithDataArray:(NSArray *)dataArray {
    [self addMoreImagePreviewData:dataArray];
    self.imagePreviewView.wordLeftLabel.text = [NSString stringWithFormat:@"%ld/%ld", kLimitOfCaptionCharacters, kLimitOfCaptionCharacters];
    [self.imagePreviewView isShowCounterCharLeft:NO];
    
    if ([self.imageDataArray count] != 0 && [self.imageDataArray count] > 1) {
        [self.imagePreviewView isShowAsSingleImagePreview:NO animated:NO];
    }
    else {
        [self.imagePreviewView isShowAsSingleImagePreview:YES animated:NO];
    }
    
    self.selectedIndex = 0;
    
    [self.imagePreviewView.thumbnailCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    [self.imagePreviewView.imagePreviewCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    
    [self.imagePreviewView setItemNumberWithCurrentNumber:1 ofTotalNumber:[self.imageDataArray count]];
    [self.imagePreviewView.imagePreviewCollectionView reloadData];
    [self.imagePreviewView.thumbnailCollectionView reloadData];
}

#pragma mark - Custom Method
- (void)keyboardWillShowWithHeight:(CGFloat)keyboardHeight {
    
    CGFloat bottomMenuViewHeight = 48.0f;
    CGFloat bottomMenuYPosition = CGRectGetHeight(self.view.frame) - bottomMenuViewHeight;
    
    self.imagePreviewView.bottomMenuView.frame = CGRectMake(CGRectGetMinX(self.imagePreviewView.bottomMenuView.frame), bottomMenuYPosition - keyboardHeight, CGRectGetWidth(self.imagePreviewView.bottomMenuView.frame), CGRectGetHeight(self.imagePreviewView.bottomMenuView.frame));
   
    self.imagePreviewView.captionView.frame = CGRectMake(CGRectGetMinX(self.imagePreviewView.captionView.frame), CGRectGetMinY(self.imagePreviewView.bottomMenuView.frame) - CGRectGetHeight(self.imagePreviewView.captionView.frame), CGRectGetWidth(self.imagePreviewView.captionView.frame), CGRectGetHeight(self.imagePreviewView.captionView.frame));
}

- (void)keyboardWillHideWithHeight:(CGFloat)keyboardHeight {
    
    CGFloat bottomMenuViewHeight = 48.0f;
    CGFloat bottomMenuYPosition = CGRectGetHeight(self.view.frame) - bottomMenuViewHeight;
    if (IS_IPHONE_X_FAMILY) {
        bottomMenuYPosition = bottomMenuYPosition - [TAPUtil safeAreaBottomPadding];
    }
    
    self.imagePreviewView.bottomMenuView.frame = CGRectMake(CGRectGetMinX(self.imagePreviewView.bottomMenuView.frame), bottomMenuYPosition, CGRectGetWidth(self.imagePreviewView.bottomMenuView.frame), CGRectGetHeight(self.imagePreviewView.bottomMenuView.frame));
    
    self.imagePreviewView.captionView.frame = CGRectMake(CGRectGetMinX(self.imagePreviewView.captionView.frame), CGRectGetMinY(self.imagePreviewView.bottomMenuView.frame) - CGRectGetHeight(self.imagePreviewView.captionView.frame), CGRectGetWidth(self.imagePreviewView.captionView.frame), CGRectGetHeight(self.imagePreviewView.captionView.frame));
}

- (void)setImagePreviewData:(NSArray *)array {
    self.imageDataArray = [[NSMutableArray alloc] init];
    self.imageDataArray = [array mutableCopy];
}

- (void)addMoreImagePreviewData:(NSArray *)array {
    [self.imageDataArray addObjectsFromArray:[array mutableCopy]];
}

- (void)cancelButtonDidTapped {
    [self dismissViewControllerAnimated:YES completion:nil]; //DV Temp
}

- (void)morePictureButtonDidTapped {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusAuthorized) {
        TAPPhotoAlbumListViewController *photoAlbumListViewController = [[TAPPhotoAlbumListViewController alloc] init];
        photoAlbumListViewController.delegate = self;
        [photoAlbumListViewController setPhotoAlbumListViewControllerType:TAPPhotoAlbumListViewControllerTypeAddMore];
        UINavigationController *photoAlbumListNavigationController = [[UINavigationController alloc] initWithRootViewController:photoAlbumListViewController];
        [self presentViewController:photoAlbumListNavigationController animated:YES completion:nil];
    }
    else if (status == PHAuthorizationStatusNotDetermined) {
        //request
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            [self openGallery];
        }];
    }
    else {
        //No permission. Trying to normally request it
        NSString *accessDescription = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSPhotoLibraryUsageDescription"];
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:accessDescription message:@"To give permissions tap on 'Change Settings' button" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Change Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (IS_IOS_10_OR_ABOVE) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:[NSDictionary dictionary] completionHandler:nil];
            }
            else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }];
        [alertController addAction:settingsAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)openGallery {
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusAuthorized) {
        TAPPhotoAlbumListViewController *photoAlbumListViewController = [[TAPPhotoAlbumListViewController alloc] init];
        [photoAlbumListViewController setPhotoAlbumListViewControllerType:TAPPhotoAlbumListViewControllerTypeAddMore];
        photoAlbumListViewController.delegate = self;
        UINavigationController *photoAlbumListNavigationController = [[UINavigationController alloc] initWithRootViewController:photoAlbumListViewController];
        [self presentViewController:photoAlbumListNavigationController animated:YES completion:nil];
    }
    else if (status == PHAuthorizationStatusNotDetermined) {
        //request
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            [self openGallery];
        }];
    }
    else {
        //No permission. Trying to normally request it
        NSString *accessDescription = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSPhotoLibraryUsageDescription"];
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:accessDescription message:@"To give permissions tap on 'Change Settings' button" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Change Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (IS_IOS_10_OR_ABOVE) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:[NSDictionary dictionary] completionHandler:nil];
            }
            else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }];
        [alertController addAction:settingsAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)sendButtonDidTapped {
    [self.view endEditing:YES];
    
    if ([self.delegate respondsToSelector:@selector(imagePreviewDidTapSendButtonWithData:)]) {
        [self.delegate imagePreviewDidTapSendButtonWithData:self.imageDataArray];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
