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
#import <AVKit/AVKit.h>

#import "TAPPhotoAlbumListViewController.h"
#import "TAPCustomGrowingTextView.h"

#import "TAPThumbnailImagePreviewCollectionViewCell.h"
#import "TAPImagePreviewCollectionViewCell.h"

#import "TAPMediaPreviewModel.h"

@interface TAPImagePreviewViewController () <UICollectionViewDelegate, UICollectionViewDataSource, TAPCustomGrowingTextViewDelegate, TAPPhotoAlbumListViewControllerDelegate, TAPImagePreviewCollectionViewCellDelegate, AVPlayerViewControllerDelegate>

@property (strong, nonatomic) TAPImagePreviewView *imagePreviewView;

@property (strong, nonatomic) NSMutableArray *mediaDataArray;
@property (strong, nonatomic) NSMutableDictionary *excedeedSizeLimitMediaDictionary;
@property (nonatomic) NSInteger selectedIndex;
@property (nonatomic) CGFloat captionTextViewHeight;
@property (nonatomic) BOOL isScrolledFromThumbnailImageTapped;
@property (nonatomic) BOOL showVideoPlayer;
@property (nonatomic) BOOL isContainExcedeedFileSizeLimit;

- (void)cancelButtonDidTapped;
- (void)morePictureButtonDidTapped;
- (void)sendButtonDidTapped;
- (void)openGallery;
- (BOOL)isAssetSizeExcedeedLimitWithData:(TAPMediaPreviewModel *)mediaPreview;
- (void)filterAssetSizeExcedeedLimitWithArray:(NSArray *)dataArray;

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
    _showVideoPlayer = NO;
    
    self.captionTextViewHeight = 22.0f;
    self.imagePreviewView.captionTextView.delegate = self;
    self.imagePreviewView.captionTextView.minimumHeight = 22.0f;
    self.imagePreviewView.captionTextView.maximumHeight = 60.0f;
    [self.imagePreviewView.captionTextView setPlaceholderText:NSLocalizedString(@"Add a caption", @"")];
    
    self.imagePreviewView.wordCountLabel.text = [NSString stringWithFormat:@"%ld/%ld", 0, (long)TAP_LIMIT_OF_CAPTION_CHARACTER];
    [self.imagePreviewView isShowCounterCharCount:NO];
    
    if ([self.mediaDataArray count] != 0 && [self.mediaDataArray count] > 1) {
        [self.imagePreviewView isShowAsSingleImagePreview:NO animated:NO];
    }
    else {
        [self.imagePreviewView isShowAsSingleImagePreview:YES animated:NO];
    }
    
    [self.imagePreviewView setItemNumberWithCurrentNumber:1 ofTotalNumber:[self.mediaDataArray count]];
    [self.imagePreviewView.imagePreviewCollectionView reloadData];
    [self.imagePreviewView.thumbnailCollectionView reloadData];
    
    if ([self.mediaDataArray count] != 0) {
        //Show excedeed bottom view if needed
        TAPMediaPreviewModel *firstMediaPreview = [self.mediaDataArray firstObject];
        BOOL isExcedeedFileSize = [self isAssetSizeExcedeedLimitWithData:firstMediaPreview];
        [self.imagePreviewView showExcedeedFileSizeAlertView:isExcedeedFileSize animated:YES];
    }
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
    return [self.mediaDataArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.imagePreviewView.imagePreviewCollectionView) {
        NSString *cellID = @"TAPImagePreviewCollectionViewCell";
        [collectionView registerClass:[TAPImagePreviewCollectionViewCell class] forCellWithReuseIdentifier:cellID];
        TAPImagePreviewCollectionViewCell *cell = (TAPImagePreviewCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
        cell.currentIndexPath = indexPath;
        cell.delegate = self;
        
        if ([self.mediaDataArray count] != 0 && self.mediaDataArray != nil) {
            
            TAPMediaPreviewModel *mediaPreview = [self.mediaDataArray objectAtIndex:indexPath.item];
            UIImage *currentImage = mediaPreview.thumbnailImage;
            [cell setImagePreviewImage:currentImage];
            cell.mediaPreviewData = mediaPreview;
            
            BOOL isExceeded = [self isAssetSizeExcedeedLimitWithData:mediaPreview];
            if (isExceeded) {
                cell.isExceededMaxFileSize = YES;
            }
            else {
                cell.isExceededMaxFileSize = NO;
            }
            
            if (mediaPreview.asset == nil) {
                //Data is UIImage from camera
                UIImage *image = mediaPreview.image;
                [cell setImagePreviewImage:image];
                cell.mediaPreviewData = mediaPreview;
            }
            else {
                //Data is PHAsset (video or image)
                if (mediaPreview.asset.mediaType == PHAssetMediaTypeImage) {
                    [cell setImagePreviewCollectionViewCellType:TAPImagePreviewCollectionViewCellTypeImage];
                    [cell setImagePreviewCollectionViewCellStateType:TAPImagePreviewCollectionViewCellStateTypeDefault];
                    [cell showProgressView:NO animated:NO];
                    
                    NSNumber *fetchProgress = [[TAPFetchMediaManager sharedManager] getFetchProgressWithAsset:mediaPreview.asset];
                    if (fetchProgress == nil) {
                        //Download not started
                        [[TAPFetchMediaManager sharedManager] fetchImageDataForAsset:mediaPreview.asset progressHandler:^(double progress, NSError * _Nonnull error, BOOL * _Nonnull stop, NSDictionary * _Nonnull dictionary) {
                            
#ifdef DEBUG
                            NSLog(@"====== PROGRESS DOWNLOAD IMAGE %f", progress);
#endif
                            
                            [cell setImagePreviewCollectionViewCellStateType:TAPImagePreviewCollectionViewCellStateTypeDownloading];
                            [cell animateProgressMediaWithProgress:progress total:1.0f];
                            if (progress == 1.0f) {
                                [TAPUtil delayCallback:^{
                                    [cell animateFinishedDownload];
                                } forTotalSeconds:0.3f];
                            }
                        } resultHandler:^(UIImage * _Nonnull resultImage) {
                            mediaPreview.image = resultImage;
                            [cell setImagePreviewImage:resultImage];
                            cell.mediaPreviewData = mediaPreview;
                        } failureHandler:^{
                            
                        }];
                    }
                    else {
                        //Download is in progress
                        [cell setImagePreviewCollectionViewCellStateType:TAPImagePreviewCollectionViewCellStateTypeDownloading];
                        [cell showProgressView:YES animated:NO];
                        [cell animateProgressMediaWithProgress:[fetchProgress doubleValue] total:1.0f];
                    }
                }
                else if (mediaPreview.asset.mediaType == PHAssetMediaTypeVideo) {
                    [cell setImagePreviewCollectionViewCellType:TAPImagePreviewCollectionViewCellTypeVideo];
                    
                    NSNumber *fetchProgress = [[TAPFetchMediaManager sharedManager] getFetchProgressWithAsset:mediaPreview.asset];
                    if (fetchProgress == nil) {
                        //Download not started
                        [cell setImagePreviewCollectionViewCellStateType:TAPImagePreviewCollectionViewCellStateTypeDefault];
                        [cell showProgressView:NO animated:NO];
                        [cell showPlayButton:YES animated:NO];
                    }
                    else {
                        //Download is in progress
                        [cell setImagePreviewCollectionViewCellStateType:TAPImagePreviewCollectionViewCellStateTypeDownloading];
                        [cell showProgressView:YES animated:NO];
                        [cell animateProgressMediaWithProgress:[fetchProgress doubleValue] total:1.0f];
                    }
                    
                }
            }
        }
        
        return cell;
    }
    else if (collectionView == self.imagePreviewView.thumbnailCollectionView) {
        NSString *cellID = @"TAPThumbnailImagePreviewCollectionViewCell";
        [collectionView registerClass:[TAPThumbnailImagePreviewCollectionViewCell class] forCellWithReuseIdentifier:cellID];
        TAPThumbnailImagePreviewCollectionViewCell *cell = (TAPThumbnailImagePreviewCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];

        if ([self.mediaDataArray count] != 0 && self.mediaDataArray != nil) {
            
            TAPMediaPreviewModel *mediaPreview = [self.mediaDataArray objectAtIndex:indexPath.item];
        
            BOOL isExceeded = [self isAssetSizeExcedeedLimitWithData:mediaPreview];
            if (isExceeded) {
                cell.isExceededMaxFileSize = YES;
                [cell setAsExceededFileSize:YES animated:NO];
            }
            else {
                cell.isExceededMaxFileSize = NO;
                [cell setAsExceededFileSize:NO animated:NO];
            }
            
            if (mediaPreview.asset.mediaType == PHAssetMediaTypeImage || mediaPreview.asset == nil) {
                [cell setThumbnailImagePreviewCollectionViewCellType:TAPThumbnailImagePreviewCollectionViewCellTypeImage];
            }
            else if (mediaPreview.asset.mediaType == PHAssetMediaTypeVideo) {
                [cell setThumbnailImagePreviewCollectionViewCellType:TAPThumbnailImagePreviewCollectionViewCellTypeVideo];
            }
            
            UIImage *thumbnailImage = nil;
            if (mediaPreview.asset == nil) {
                //data is from Camera - UIImage
                thumbnailImage = mediaPreview.image;
            }
            else {
                //data is from PHAsset
                thumbnailImage = mediaPreview.thumbnailImage;
            }
            
            [cell setThumbnailImageView:thumbnailImage];
            cell.mediaPreviewData = mediaPreview;
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
            TAPMediaPreviewModel *currentImagePreview = [self.mediaDataArray objectAtIndex:self.selectedIndex];
            NSString *savedCaptionString = currentImagePreview.caption;
            savedCaptionString = [TAPUtil nullToEmptyString:savedCaptionString];
            
            if (![savedCaptionString isEqualToString:@""] && savedCaptionString != nil) {
                //contain previous saved caption
                [self.imagePreviewView.captionTextView setInitialText:@""];
                [self.imagePreviewView.captionTextView setInitialText:savedCaptionString];
                self.imagePreviewView.wordCountLabel.text = [NSString stringWithFormat:@"%ld/%ld", [savedCaptionString length], TAP_LIMIT_OF_CAPTION_CHARACTER];
                [self.imagePreviewView isShowCounterCharCount:YES];
            }
            else {
                [self.imagePreviewView.captionTextView setInitialText:@""];
                self.imagePreviewView.wordCountLabel.text = [NSString stringWithFormat:@"%ld/%ld", 0, TAP_LIMIT_OF_CAPTION_CHARACTER];
                [self.imagePreviewView isShowCounterCharCount:NO];
            }
        }
    }
    else if (collectionView == self.imagePreviewView.thumbnailCollectionView) {
        
        _showVideoPlayer = NO;
        _isScrolledFromThumbnailImageTapped = YES;
        
        if(indexPath.item == self.selectedIndex) {
            //Remove image
            
            [self.imagePreviewView.captionTextView setInitialText:@""];
            [self.imagePreviewView isShowCounterCharCount:NO];
            self.imagePreviewView.wordCountLabel.text = [NSString stringWithFormat:@"%ld/%ld", 0, TAP_LIMIT_OF_CAPTION_CHARACTER];

            //Remove from data array
            NSLog(@"indexpath item: %ld", indexPath.item);
            
            if (indexPath.item == [self.mediaDataArray count] - 1) {
                //Move index to -1 when delete last index
                _selectedIndex = self.selectedIndex - 1;
            }
            
            TAPMediaPreviewModel *toBeDeletedMediaPreview = [self.mediaDataArray objectAtIndex:indexPath.item];
            PHAsset *toBeDeletedAsset = toBeDeletedMediaPreview.asset;
            
            [self.mediaDataArray removeObjectAtIndex:indexPath.item];
            
            NSString *generatedAssetKey = toBeDeletedAsset.localIdentifier;
            [self.excedeedSizeLimitMediaDictionary removeObjectForKey:generatedAssetKey];
            
            [self filterAssetSizeExcedeedLimitWithArray:self.mediaDataArray];
            
            [self.imagePreviewView.imagePreviewCollectionView reloadData];
            [self.imagePreviewView.thumbnailCollectionView reloadData];
            
            [self.imagePreviewView setItemNumberWithCurrentNumber:indexPath.item + 1 ofTotalNumber:[self.mediaDataArray count]];
            
            if ([self.mediaDataArray count] > 0 && [self.mediaDataArray count] < 2) {
                [self.imagePreviewView isShowAsSingleImagePreview:YES animated:YES];
            }
        
            TAPMediaPreviewModel *nextSelectedMediaPreview = [self.mediaDataArray objectAtIndex:self.selectedIndex];
            BOOL isExcedeedFileSize = [self isAssetSizeExcedeedLimitWithData:nextSelectedMediaPreview];
            [self.imagePreviewView showExcedeedFileSizeAlertView:isExcedeedFileSize animated:YES];
        }
        else {
            TAPThumbnailImagePreviewCollectionViewCell *previousCell = [self.imagePreviewView.thumbnailCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedIndex inSection:0]];
            [previousCell setAsSelected:NO];
            
            _selectedIndex = indexPath.item;
            
            TAPThumbnailImagePreviewCollectionViewCell *currentSelectedCell = [self.imagePreviewView.thumbnailCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:0]];
            [currentSelectedCell setAsSelected:YES];
            
            [self.imagePreviewView.imagePreviewCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
            
            TAPMediaPreviewModel *currentImagePreview = [self.mediaDataArray objectAtIndex:self.selectedIndex];
            NSString *savedCaptionString = currentImagePreview.caption;
            savedCaptionString = [TAPUtil nullToEmptyString:savedCaptionString];
            
            if (![savedCaptionString isEqualToString:@""] && savedCaptionString != nil) {
                //contain previous saved caption
                [self.imagePreviewView.captionTextView setInitialText:@""];
                [self.imagePreviewView.captionTextView setInitialText:savedCaptionString];
                self.imagePreviewView.wordCountLabel.text = [NSString stringWithFormat:@"%ld/%ld", [savedCaptionString length], TAP_LIMIT_OF_CAPTION_CHARACTER];
                [self.imagePreviewView isShowCounterCharCount:YES];
            }
            else {
                [self.imagePreviewView.captionTextView setInitialText:@""];
                self.imagePreviewView.wordCountLabel.text = [NSString stringWithFormat:@"%ld/%ld", 0, TAP_LIMIT_OF_CAPTION_CHARACTER];
                [self.imagePreviewView isShowCounterCharCount:NO];
            }
            
            //Show excedeed bottom view if needed
            BOOL isExcedeedFileSize = [self isAssetSizeExcedeedLimitWithData:currentImagePreview];
            [self.imagePreviewView showExcedeedFileSizeAlertView:isExcedeedFileSize animated:YES];
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
        else if(currentIndex > [self.mediaDataArray count] - 1) {
            currentIndex = [self.mediaDataArray count] - 1;
        }
        
        if (currentIndex != self.selectedIndex) {
            _selectedIndex = currentIndex;
            
            if (currentIndex == 0) {
                //First index
                [self.imagePreviewView.thumbnailCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
            
                [self.imagePreviewView.thumbnailCollectionView setContentOffset:CGPointMake(-self.imagePreviewView.thumbnailCollectionView.contentInset.left, self.imagePreviewView.thumbnailCollectionView.contentOffset.y) animated:YES];
            }
            else if (currentIndex == [self.mediaDataArray count] - 1) {
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
            
            //Show excedeed file limit size if needed
            TAPMediaPreviewModel *currentMediaPreview = [self.mediaDataArray objectAtIndex:currentIndex];
            BOOL isExceeded = [self isAssetSizeExcedeedLimitWithData:currentMediaPreview];
            if (isExceeded) {
                [self.imagePreviewView showExcedeedFileSizeAlertView:YES animated:YES];
            }
            else {
                [self.imagePreviewView showExcedeedFileSizeAlertView:NO animated:YES];
            }
            
        }
        else {
            //currentIndex == self.selectedIndex
            _showVideoPlayer = NO;
        }
        
        [self.imagePreviewView setItemNumberWithCurrentNumber:currentIndex + 1 ofTotalNumber:[self.mediaDataArray count]];
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
        
        TAPMediaPreviewModel *currentImagePreview = [self.mediaDataArray objectAtIndex:self.selectedIndex];
        
        NSString *savedCaptionString = currentImagePreview.caption;
        savedCaptionString = [TAPUtil nullToEmptyString:savedCaptionString];
        
        if (![savedCaptionString isEqualToString:@""] && savedCaptionString != nil) {
            //contain previous saved caption
            [self.imagePreviewView.captionTextView setInitialText:@""];
            [self.imagePreviewView.captionTextView setInitialText:savedCaptionString];
            self.imagePreviewView.wordCountLabel.text = [NSString stringWithFormat:@"%ld/%ld", [savedCaptionString length], TAP_LIMIT_OF_CAPTION_CHARACTER];
            
            [self.imagePreviewView isShowCounterCharCount:YES];
        }
        else {
            [self.imagePreviewView.captionTextView setInitialText:@""];
            self.imagePreviewView.wordCountLabel.text = [NSString stringWithFormat:@"%ld/%ld", 0, TAP_LIMIT_OF_CAPTION_CHARACTER];
            [self.imagePreviewView isShowCounterCharCount:NO];
        }
    }
}

#pragma mark TAPCustomGrowingTextView
- (BOOL)customGrowingTextView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    NSInteger textLength = [newString length];
    
    [self.imagePreviewView setCurrentWordCountWithCurrentCharCount:textLength];
    
    if (textLength > TAP_LIMIT_OF_CAPTION_CHARACTER) {
        return NO;
    }
    
    return YES;
}

- (void)customGrowingTextView:(UITextView *)textView shouldChangeHeight:(CGFloat)height {
    [UIView animateWithDuration:0.1f animations:^{
        
        self.captionTextViewHeight = height;
        
        CGFloat captionTextViewWidth = CGRectGetWidth(self.imagePreviewView.captionView.frame) - 16.0f - 16.0f - 8.0f - CGRectGetWidth(self.imagePreviewView.wordCountLabel.frame);
        self.imagePreviewView.captionTextView.frame = CGRectMake(CGRectGetMinX(self.imagePreviewView.captionTextView.frame), CGRectGetMinY(self.imagePreviewView.captionTextView.frame), captionTextViewWidth, self.captionTextViewHeight);
        
        self.imagePreviewView.captionSeparatorView.frame = CGRectMake(CGRectGetMinX(self.imagePreviewView.captionSeparatorView.frame), CGRectGetMaxY(self.imagePreviewView.captionTextView.frame) + 12.0f, CGRectGetWidth(self.imagePreviewView.captionSeparatorView.frame), CGRectGetHeight(self.imagePreviewView.captionSeparatorView.frame));
        
        self.imagePreviewView.wordCountLabel.frame = CGRectMake(CGRectGetMinX(self.imagePreviewView.wordCountLabel.frame), CGRectGetMinY(self.imagePreviewView.captionSeparatorView.frame) - 15.0f - 13.0f, CGRectGetWidth(self.imagePreviewView.wordCountLabel.frame), CGRectGetHeight(self.imagePreviewView.wordCountLabel.frame));
        
        CGFloat captionViewHeight = CGRectGetMaxY(self.imagePreviewView.captionSeparatorView.frame) + 10.0f;
        self.imagePreviewView.captionView.frame = CGRectMake(CGRectGetMinX(self.imagePreviewView.captionView.frame), CGRectGetMinY(self.imagePreviewView.bottomMenuView.frame) - captionViewHeight, CGRectGetWidth(self.imagePreviewView.captionView.frame), captionViewHeight);
    }];
}

- (void)customGrowingTextViewDidBeginEditing:(UITextView *)textView {
    [self.imagePreviewView isShowCounterCharCount:YES];
}

- (void)customGrowingTextViewDidEndEditing:(UITextView *)textView {
    
    NSString *captionString = textView.text;
    NSString *trimmedCaptionString = [captionString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([trimmedCaptionString isEqualToString:@""]) {
        //remove saved caption
        TAPMediaPreviewModel *currentImagePreview = [self.mediaDataArray objectAtIndex:self.selectedIndex];
        currentImagePreview.caption = @"";
    }
    else {
        TAPMediaPreviewModel *currentImagePreview = [self.mediaDataArray objectAtIndex:self.selectedIndex];
        currentImagePreview.caption = captionString;
    }
}

#pragma mark TAPPhotoAlbumListViewController
- (void)photoAlbumListViewControllerSelectImageWithDataArray:(NSArray *)dataArray {
    
    [self setMediaPreviewDataWithArray:dataArray];
    self.imagePreviewView.wordCountLabel.text = [NSString stringWithFormat:@"%ld/%ld", TAP_LIMIT_OF_CAPTION_CHARACTER, TAP_LIMIT_OF_CAPTION_CHARACTER];
    [self.imagePreviewView isShowCounterCharCount:NO];
    
    if ([self.mediaDataArray count] != 0 && [self.mediaDataArray count] > 1) {
        [self.imagePreviewView isShowAsSingleImagePreview:NO animated:NO];
    }
    else {
        [self.imagePreviewView isShowAsSingleImagePreview:YES animated:NO];
    }
    
    self.selectedIndex = 0;
    
    [self.imagePreviewView.thumbnailCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    [self.imagePreviewView.imagePreviewCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    
    [self.imagePreviewView setItemNumberWithCurrentNumber:1 ofTotalNumber:[self.mediaDataArray count]];
    [self.imagePreviewView.imagePreviewCollectionView reloadData];
    [self.imagePreviewView.thumbnailCollectionView reloadData];
}

#pragma mark TAPImagePreviewCollectionViewCell
- (void)imagePreviewCollectionViewCellDidPlayVideoButtonDidTappedWithMediaPreview:(TAPMediaPreviewModel *)mediaPreview indexPath:(NSIndexPath *)indexPath {
    
    TAPImagePreviewCollectionViewCell *cell = (TAPImagePreviewCollectionViewCell *)[self.imagePreviewView.imagePreviewCollectionView cellForItemAtIndexPath:indexPath];
    [cell setImagePreviewCollectionViewCellStateType:TAPImagePreviewCollectionViewCellStateTypeDownloading];
    [cell showProgressView:YES animated:YES];
    
    _showVideoPlayer = YES;
    [[TAPFetchMediaManager sharedManager] fetchVideoDataForAsset:mediaPreview.asset progressHandler:^(double progress, NSError * _Nonnull error, BOOL * _Nonnull stop, NSDictionary * _Nonnull dictionary) {
        
#ifdef DEBUG
        NSLog(@"====== PROGRESS DOWNLOAD VIDEO %f", progress);
#endif
        
        [cell animateProgressMediaWithProgress:progress total:1.0f];
        if (progress == 1.0f) {
            [TAPUtil delayCallback:^{
                [cell animateFinishedDownload];
            } forTotalSeconds:0.3f];
        }
        
    } resultHandler:^(AVAsset * _Nonnull resultVideoAsset) {
        mediaPreview.videoAsset = resultVideoAsset;
        cell.mediaPreviewData = mediaPreview;
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:resultVideoAsset];
        AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:item];
        
        if (self.showVideoPlayer) {
            AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
            controller.delegate = self;
            controller.showsPlaybackControls = YES;
            [self presentViewController:controller animated:YES completion:nil];
            controller.player = player;
            [player play];
        }
        
        [TAPUtil delayCallback:^{
            [cell setImagePreviewCollectionViewCellStateType:TAPImagePreviewCollectionViewCellStateTypeDefault];
            [cell showProgressView:NO animated:NO];
            [cell showPlayButton:YES animated:NO];
            _showVideoPlayer = NO;
        } forTotalSeconds:0.5f];
    } failureHandler:^{
        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Cannot Fetch Video"  title:NSLocalizedString(@"Error", @"") detailInformation:NSLocalizedString(@"Cannot play video at the moment, please check your connection and try again.",@"") leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];

    }];
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

- (void)setMediaPreviewDataWithData:(TAPMediaPreviewModel *)mediaPreviewData {
    if (self.mediaDataArray == nil || [self.mediaDataArray count] == 0) {
        self.mediaDataArray = [[NSMutableArray alloc] init];
    }
    
    [self.mediaDataArray addObject:mediaPreviewData];
}

- (void)setMediaPreviewDataWithArray:(NSMutableArray *)array {
    if (self.mediaDataArray == nil || [self.mediaDataArray count] == 0) {
        self.mediaDataArray = [[NSMutableArray alloc] init];
    }
    
    [self.mediaDataArray addObjectsFromArray:array];
    
    [self filterAssetSizeExcedeedLimitWithArray:self.mediaDataArray];
}

- (void)cancelButtonDidTapped {
    _showVideoPlayer = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)morePictureButtonDidTapped {
    
    _showVideoPlayer = NO;
    
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
    
    for (TAPMediaPreviewModel *mediaPreview in self.mediaDataArray) {
        BOOL isExceeded = [self isAssetSizeExcedeedLimitWithData:mediaPreview];
        if (isExceeded) {
            _isContainExcedeedFileSizeLimit = YES;
        }
    }
    
    if (self.isContainExcedeedFileSizeLimit) {
        //Show popup warning
        
        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Image Size Excedeed"  title:NSLocalizedString(@"Some files may not send", @"") detailInformation:[NSString stringWithFormat:@"Video thumbnails that are marked with th icon ‘ ! ‘ have exceeded the %ldMB upload limit and won’t be sent.", TAP_MAX_VIDEO_SIZE] leftOptionButtonTitle:@"Cancel" singleOrRightOptionButtonTitle:@"Continue"];
    }
    else {
        if ([self.delegate respondsToSelector:@selector(imagePreviewDidTapSendButtonWithData:)]) {
            [self.delegate imagePreviewDidTapSendButtonWithData:self.mediaDataArray];
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)popUpInfoTappedSingleButtonOrRightButtonWithIdentifier:(NSString *)popupIdentifier {
    [super popUpInfoTappedSingleButtonOrRightButtonWithIdentifier:popupIdentifier];
    
    if ([popupIdentifier isEqualToString:@"Error Image Size Excedeed"]) {
        NSMutableArray *filteredDataArray = [[NSMutableArray alloc] init];
        for (TAPMediaPreviewModel *mediaPreview in self.mediaDataArray) {
            BOOL isExceeded = [self isAssetSizeExcedeedLimitWithData:mediaPreview];
            if (!isExceeded) {
                [filteredDataArray addObject:mediaPreview];
            }
        }
        
        //    if ([self.delegate respondsToSelector:@selector(imagePreviewDidTapSendButtonWithData:)]) {
        //        [self.delegate imagePreviewDidTapSendButtonWithData:filteredDataArray];
        //    }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if ([popupIdentifier isEqualToString:@"Error Cannot Fetch Video"]) {
        //Do nothing because hide popup handled when we press the button
    }
}

- (BOOL)isAssetSizeExcedeedLimitWithData:(TAPMediaPreviewModel *)mediaPreview {

    BOOL isExceededMaxFileSize = NO;
    
    NSInteger fileSizeLimitStatus = mediaPreview.fileSizeLimitStatus;
    if (fileSizeLimitStatus == 1) {
        isExceededMaxFileSize = YES;
    }
    
    return isExceededMaxFileSize;
}

- (void)filterAssetSizeExcedeedLimitWithArray:(NSArray *)dataArray {

    if ([self.excedeedSizeLimitMediaDictionary count] == 0 || self.excedeedSizeLimitMediaDictionary == nil) {
        _excedeedSizeLimitMediaDictionary = [NSMutableDictionary dictionary];
    }
    
    if ([dataArray count] == 0 || dataArray == nil) {
        return;
    }
    
    for (TAPMediaPreviewModel *mediaPreview in dataArray) {
        if (mediaPreview.fileSizeLimitStatus == 0) {
            PHAsset *asset = mediaPreview.asset;
            
            if (asset != nil) {
                NSArray *assetResourceArray = [PHAssetResource assetResourcesForAsset:asset];
                PHAssetResource *assetResource = [assetResourceArray firstObject];
                double fileSize = [[assetResource valueForKey:@"fileSize"] doubleValue];
                double filesizeInMB = fileSize / 1000000; //convert to MB
                
                if (filesizeInMB > TAP_MAX_VIDEO_SIZE && asset.mediaType == PHAssetMediaTypeVideo) {
                    mediaPreview.fileSizeLimitStatus = 1; // exceeded limit
                    //    NSString *generatedAssetKey = [[TAPFetchMediaManager sharedManager] getDictionaryKeyForAsset:asset];
                    NSString *generatedAssetKey = asset.localIdentifier;
                    [self.excedeedSizeLimitMediaDictionary setObject:mediaPreview forKey:generatedAssetKey];
                }
                else {
                    mediaPreview.fileSizeLimitStatus = 2; // not exceeded limit
                }
            }
            else {
                //For mediaPreview with UIImage (Not PHAsset)
                mediaPreview.fileSizeLimitStatus = 2; // not exceeded limit
            }

        }
    }
    
    if ([self.excedeedSizeLimitMediaDictionary count] == [self.mediaDataArray count]) {
        //Disable send button
        [self.imagePreviewView enableSendButton:NO];
    }
    else {
        [self.imagePreviewView enableSendButton:YES];
    }
}

@end
