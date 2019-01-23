//
//  TAPImageSelectViewController.m
//  TapTalk
//
//  Created by Dominic Vedericho on 30/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPImageSelectViewController.h"
#import "TAPImageSelectView.h"
#import "TAPImageSelectCollectionViewCell.h"
#import "TAPImagePreviewViewController.h"

@interface TAPImageSelectViewController () <UICollectionViewDelegate, UICollectionViewDataSource, PHPhotoLibraryChangeObserver, TAPImagePreviewViewControllerDelegate>

@property (strong, nonatomic) TAPImageSelectView *imageSelectView;
@property (strong, nonatomic) UIBarButtonItem *leftBarButton;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) NSMutableArray *galleryImageDataArray;
@property (strong, nonatomic) NSMutableArray *tempGalleryImageDataArray;

@property (strong, nonatomic) NSMutableDictionary *loadedImageThumbnailDictionary;

@property (strong, nonatomic) PHFetchResult *assetsFetchResults;
@property (strong, nonatomic) PHCachingImageManager *imageManager;

@property (nonatomic) BOOL isLastPage;
@property (nonatomic) BOOL isSelectedCleared;

//Get Camera Roll Image
@property (strong, nonatomic) PHFetchResult<PHAsset *> *allPhotos;
@property (strong, nonatomic) PHFetchResult<PHAssetCollection *> *smartAlbums;
@property (strong, nonatomic) PHFetchResult<PHCollection *> *userCollections;
@property (strong, nonatomic) PHFetchResult<PHAsset *> *cameraRollPhotos;

@property (nonatomic) NSInteger indexImageCount;

- (void)backButtonDidTapped;
- (void)cancelButtonDidTapped;
- (void)clearButtonDidTapped;
- (void)continueButtonDidTapped;
- (void)getAllPhotosFromCamera;
- (void)fetchGalleryData;
- (void)isShowLoadingIndicatorView:(BOOL)isShow;
- (void)processPhotos;
- (void)fetchCameraRollData;

@end

@implementation TAPImageSelectViewController

#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    
    _imageSelectView = [[TAPImageSelectView alloc] initWithFrame:[TAPBaseView frameWithNavigationBar]];
    [self.view addSubview:self.imageSelectView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(self.imageSelectViewControllerNavigateType == ImageSelectViewControllerNavigateTypePresent) {
        _leftBarButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"TAPIconCloseGreen" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonDidTapped)];
        [self.navigationItem setLeftBarButtonItem:self.leftBarButton];
    }
    else if(self.imageSelectViewControllerNavigateType == ImageSelectViewControllerNavigateTypePush) {
        _leftBarButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"TAPIconBackArrow" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonDidTapped)];
        [self.navigationItem setLeftBarButtonItem:self.leftBarButton];
    }
    
    self.imageSelectView.collectionView.delegate = self;
    self.imageSelectView.collectionView.dataSource = self;
    
    [self.imageSelectView.clearButton addTarget:self action:@selector(clearButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.imageSelectView.continueButton addTarget:self action:@selector(continueButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    
    _galleryImageDataArray = [NSMutableArray array];
    _tempGalleryImageDataArray = [NSMutableArray array];
    _loadedImageThumbnailDictionary = [NSMutableDictionary dictionary];
    
    if(self.imageSelectViewControllerType == ImageSelectViewControllerTypeGallery) {
        _selectedImageDataArray = [NSMutableArray array];

        self.title = NSLocalizedString(@"Photo Gallery", @"");
        // Fetch all assets, sorted by date created.
        [self getAllPhotosFromCamera];
        [self fetchCameraRollData];
    }
    else if(self.imageSelectViewControllerType == ImageSelectViewControllerTypeGalleryAlbum) {
        if(self.cameraRollCollection != nil) {
            
            self.title = self.cameraRollCollection.localizedTitle;

            [self getAllPhotosFromCamera];
            [self fetchFromCameraRollCollection];
        }
    }
    
    if([self.selectedImageDataArray count] > 0) {
        self.imageSelectView.itemNumberView.alpha = 1.0f;
        self.imageSelectView.continueButton.userInteractionEnabled = YES;
        self.imageSelectView.continueButton.alpha = 1.0f;
    }
    else {
        self.imageSelectView.itemNumberView.alpha = 0.0f;
        self.imageSelectView.continueButton.userInteractionEnabled = NO;
        self.imageSelectView.continueButton.alpha = 0.6f;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView
#pragma mark Data Source
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat size = (CGRectGetWidth([UIScreen mainScreen].bounds) - 1.0f - 1.0f - 1.0f - 1.0f) / 3.0f;
    return CGSizeMake(size, size);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(1.0f, 1.0f, 8.0f, 1.0f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0f;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [self.cameraRollPhotos count];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeZero;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"TAPImageSelectCollectionViewCell";
    
    [collectionView registerClass:[TAPImageSelectCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    
    TAPImageSelectCollectionViewCell *cell = (TAPImageSelectCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];

    [cell setCellWithImage:(UIImage *)[self.loadedImageThumbnailDictionary objectForKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]]];

    if(self.imageSelectViewControllerType == ImageSelectViewControllerTypeGalleryAlbum) {
        
        if(self.isSelectedCleared) {
            [cell setCellAsSelected:NO];
        }
        else {
            NSString *currentKeyString = [NSString stringWithFormat:@"%ld-%ld-%ld", (long)self.albumIndexSection ,(long)self.albumIndexRow, (long)indexPath.row];
            if([self.selectedImagePositionDictionary objectForKey:currentKeyString]) {
                //selected
                [cell setCellAsSelected:YES];
            }
            else {
                //not selected
                [cell setCellAsSelected:NO];
            }
        }
    }
    else {
        if([self.galleryImageDataArray count] != 0) {
            if([self.selectedImageDataArray containsObject:[self.galleryImageDataArray objectAtIndex:indexPath.row]]) {
                //selected
                [cell setCellAsSelected:YES];
            }
            else {
                //not selected
                [cell setCellAsSelected:NO];
            }
        }
    }
    
    return cell;
}

#pragma mark Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    _isSelectedCleared = NO;
    TAPImageSelectCollectionViewCell *currentSelectedCell = (TAPImageSelectCollectionViewCell *) [collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    
    id imageObject = [self.cameraRollPhotos objectAtIndex:indexPath.row];
    
    if(self.imageSelectViewControllerType == ImageSelectViewControllerTypeGalleryAlbum) {
        //check selected from gallery album
        NSString *selectedKeyString = [NSString stringWithFormat:@"%ld-%ld-%ld", (long)self.albumIndexSection , (long)self.albumIndexRow, (long)indexPath.row];
        
        if(![self.selectedImagePositionDictionary objectForKey:selectedKeyString]) {
            //image not selected
            if(self.isFromAddService) {
                
                NSInteger currentItemSelected = [self.selectedImageDataArray count];
                NSInteger totalItemSelected = self.currentTotalImageData + currentItemSelected;
                
//                //user choose maximum limit of image choosen (5 images)
//                if(totalItemSelected >= 5) {
//                    //            if([self.selectedImageDataArray count] == 5) {
//                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Failed", @"") message:NSLocalizedString(@"Uploaded images have exceeds the maximum limit (up to 5 images only)", @"") preferredStyle:UIAlertControllerStyleAlert];
//
//                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                    }];
//
//                    [alertController addAction:okAction];
//                    [self presentViewController:alertController animated:YES completion:nil];
//                    return;
//                }
            }
            else {
                //user choose maximum limit of image choosen (10 images)
//                if([self.selectedImageDataArray count] == 10) {
//                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Failed", @"") message:NSLocalizedString(@"You can only choose maximum 10 images", @"") preferredStyle:UIAlertControllerStyleAlert];
//
//                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                    }];
//
//                    [alertController addAction:okAction];
//                    [self presentViewController:alertController animated:YES completion:nil];
//                    return;
//                }
            }
            
            //not selected, change to selected
            [self.selectedImageDataArray addObject:imageObject];
            [self.selectedImagePositionDictionary setObject:imageObject forKey:selectedKeyString];
            
            if([self.delegate respondsToSelector:@selector(imageSelectViewControllerDidAddSelectedImage:selectedDictionary:)]) {
                [self.delegate imageSelectViewControllerDidAddSelectedImage:self.selectedImageDataArray selectedDictionary:self.selectedImagePositionDictionary];
            }
            
            [currentSelectedCell setCellAsSelected:YES];
        }
        else {
            //image selected
            //already selected, change to not selected
            [self.selectedImageDataArray removeObject:imageObject];
            [self.selectedImagePositionDictionary removeObjectForKey:selectedKeyString];
            
            if([self.delegate respondsToSelector:@selector(imageSelectViewControllerDidAddSelectedImage:selectedDictionary:)]) {
                [self.delegate imageSelectViewControllerDidAddSelectedImage:self.selectedImageDataArray selectedDictionary:self.selectedImagePositionDictionary];
            }
            
            [currentSelectedCell setCellAsSelected:NO];
            
        }
        
    }
    else {
        //check selected
        if(![self.selectedImageDataArray containsObject:imageObject]) {
            
            if(self.isFromAddService) {
                
                NSInteger currentItemSelected = [self.selectedImageDataArray count];
                NSInteger totalItemSelected = self.currentTotalImageData + currentItemSelected;
                
                //user choose maximum limit of image choosen (5 images)
                if(totalItemSelected >= 5) {
                    //            if([self.selectedImageDataArray count] == 5) {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Failed", @"") message:NSLocalizedString(@"Uploaded images have exceeds the maximum limit (up to 5 images only)", @"") preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    }];
                    
                    [alertController addAction:okAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                    return;
                }
            }
            else {
                //user choose maximum limit of image choosen (10 images)
                if([self.selectedImageDataArray count] == 10) {
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Failed", @"") message:NSLocalizedString(@"You can only choose maximum 10 images", @"") preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    }];
                    
                    [alertController addAction:okAction];
                    [self presentViewController:alertController animated:YES completion:nil];
                    return;
                }
            }
            
            //not selected, change to selected
            [self.selectedImageDataArray addObject:imageObject];
            [currentSelectedCell setCellAsSelected:YES];
        }
        else {
            //already selected, change to not selected
            [self.selectedImageDataArray removeObject:imageObject];
            [currentSelectedCell setCellAsSelected:NO];
        }
    }
    
    NSInteger totalSelectedCount = [self.selectedImageDataArray count];
    self.imageSelectView.itemNumberLabel.text = [NSString stringWithFormat:@"%ld", (long)totalSelectedCount];
    
    if(totalSelectedCount > 0) {
        [UIView animateWithDuration:0.2f animations:^{
            self.imageSelectView.itemNumberView.alpha = 1.0f;
            self.imageSelectView.continueButton.userInteractionEnabled = YES;
            self.imageSelectView.continueButton.alpha = 1.0f;
        }];
    }
    else {
        [UIView animateWithDuration:0.2f animations:^{
            self.imageSelectView.itemNumberView.alpha = 0.0f;
            self.imageSelectView.continueButton.userInteractionEnabled = NO;
            self.imageSelectView.continueButton.alpha = 0.6f;
        }];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
 
}

#pragma mark - Delegate
//#pragma mark ImagePreviewViewController
//- (void)imagePreviewViewControllerDidTappedContinueButtonWithDataArray:(NSArray *)dataArray {
//    if(self.imageSelectViewControllerType == ImageSelectViewControllerTypeGalleryAlbum) {
//        if([self.delegate respondsToSelector:@selector(imageSelectViewControllerDidTappedContinueButtonWithDataArray:)]) {
//            [self.delegate imageSelectViewControllerDidTappedContinueButtonWithDataArray:dataArray];
//        }
//    }
//    else {
//        if([self.delegate respondsToSelector:@selector(imageSelectViewControllerDidTappedContinueButtonWithDataArray:firstLoginInstagram:)]) {
//            [self.delegate imageSelectViewControllerDidTappedContinueButtonWithDataArray:dataArray firstLoginInstagram:self.isFirstLoginInstagram];
//        }
//    }
//}
//
//- (void)imagePreviewViewControllerDidTappedBackButton {
//    if([self.delegate respondsToSelector:@selector(imageSelectViewControllerDidTappedBackButton)]) {
//        [self.delegate imageSelectViewControllerDidTappedBackButton];
//    }
//}

#pragma mark PHPhotoGalleryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance {

}

#pragma mark TAPImagePreviewViewController
- (void)imagePreviewDidTapSendButtonWithData:(NSArray *)dataArray {    
    if ([self.delegate respondsToSelector:@selector(imageSelectViewControllerDidSendWithDataArray:)]) {
        [self.delegate imageSelectViewControllerDidSendWithDataArray:dataArray];
    }
}

#pragma mark - Custom Method
- (void)backButtonDidTapped {
    if([self.delegate respondsToSelector:@selector(imageSelectViewControllerDidTappedBackButton)]) {
        [self.delegate imageSelectViewControllerDidTappedBackButton];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelButtonDidTapped {
    if([self.delegate respondsToSelector:@selector(imageSelectViewControllerDidTappedBackButton)]) {
        [self.delegate imageSelectViewControllerDidTappedBackButton];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)clearButtonDidTapped {
    dispatch_async(dispatch_get_main_queue(), ^(void){
    _isSelectedCleared = YES;
    _selectedImageDataArray = [NSMutableArray array];
    _selectedImagePositionDictionary = [NSMutableDictionary dictionary];

    if(self.imageSelectViewControllerType == ImageSelectViewControllerTypeGalleryAlbum) {
        if([self.delegate respondsToSelector:@selector(imageSelectViewControllerDidAddSelectedImage:selectedDictionary:)]) {
            [self.delegate imageSelectViewControllerDidAddSelectedImage:[NSMutableArray array] selectedDictionary:[NSMutableDictionary dictionary]];
        }
    }
    
        //Run UI Updates
        [self.imageSelectView.collectionView reloadData];
    
        NSInteger totalSelectedCount = [self.selectedImageDataArray count];
        self.imageSelectView.itemNumberLabel.text = [NSString stringWithFormat:@"%ld", (long)totalSelectedCount];
        
        //Clear itemNumber
        [UIView animateWithDuration:0.2f animations:^{
            self.imageSelectView.itemNumberView.alpha = 0.0f;
            self.imageSelectView.continueButton.alpha = 0.6f;
            self.imageSelectView.continueButton.userInteractionEnabled = NO;
        }];
  
    });
}

- (void)continueButtonDidTapped {
    
    if (self.imageSelectViewControllerContinueType == ImageSelectViewControllerContinueTypeAddMore) {
        
        NSMutableArray *selectedResultArray = [NSMutableArray array];
        PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
        requestOptions.synchronous = NO;
        requestOptions.networkAccessAllowed = YES;
        requestOptions.resizeMode   = PHImageRequestOptionsResizeModeNone;
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
        PHImageManager *manager = [PHImageManager defaultManager];
        
        self.imageSelectView.continueButton.enabled = NO;
        self.imageSelectView.clearButton.enabled = NO;
        self.imageSelectView.collectionView.userInteractionEnabled = NO;
        self.imageSelectView.itemNumberView.alpha = 0.0f;
        self.imageSelectView.continueButton.alpha = 0.0f;
        self.imageSelectView.activityIndicatorView.alpha = 1.0f;
        [self.imageSelectView.activityIndicatorView startAnimating];
        
        NSInteger __block count = 0;
        for (PHAsset *currentAsset in self.selectedImageDataArray) {
            __block UIImage *imageResult;
            [manager requestImageDataForAsset:currentAsset
                                      options:requestOptions
                                resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     imageResult = [UIImage imageWithData:imageData];
                     if(imageResult != nil) {
                         TAPImagePreviewModel *imagePreview = [TAPImagePreviewModel new];
                         imagePreview.image = imageResult;
                         [selectedResultArray addObject:imagePreview];
                     }
                     
                     count++;
                     if(count == [self.selectedImageDataArray count]) {
                         self.imageSelectView.continueButton.enabled = YES;
                         self.imageSelectView.clearButton.enabled = YES;
                         self.imageSelectView.collectionView.userInteractionEnabled = YES;
                         self.imageSelectView.itemNumberView.alpha = 1.0f;
                         self.imageSelectView.continueButton.alpha = 1.0f;
                         self.imageSelectView.activityIndicatorView.alpha = 0.0f;
                         [self.imageSelectView.activityIndicatorView stopAnimating];
                         if(!(self.selectedImageDataArray == nil) && ([self.selectedImageDataArray count] > 0)) {
                             if([self.delegate respondsToSelector:@selector(imageSelectViewControllerDidTappedContinueButtonWithDataArray:)]) {
                                 [self.delegate imageSelectViewControllerDidTappedContinueButtonWithDataArray:selectedResultArray];
                             }
                         }
                     }
                 });
             }];
        }
    }
    else {
        TAPImagePreviewViewController *imagePreviewViewController  = [[TAPImagePreviewViewController alloc] init];
        imagePreviewViewController.delegate = self;
        
        NSMutableArray *selectedResultArray = [NSMutableArray array];
        PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
        requestOptions.synchronous = NO;
        requestOptions.networkAccessAllowed = YES;
        requestOptions.resizeMode   = PHImageRequestOptionsResizeModeNone;
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
        PHImageManager *manager = [PHImageManager defaultManager];
        
        self.imageSelectView.continueButton.enabled = NO;
        self.imageSelectView.clearButton.enabled = NO;
        self.imageSelectView.collectionView.userInteractionEnabled = NO;
        self.imageSelectView.itemNumberView.alpha = 0.0f;
        self.imageSelectView.continueButton.alpha = 0.0f;
        self.imageSelectView.activityIndicatorView.alpha = 1.0f;
        [self.imageSelectView.activityIndicatorView startAnimating];
        
        NSInteger __block count = 0;
        for (PHAsset *currentAsset in self.selectedImageDataArray) {
            __block UIImage *imageResult;
            [manager requestImageDataForAsset:currentAsset
                                      options:requestOptions
                                resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     imageResult = [UIImage imageWithData:imageData];
                     if(imageResult != nil) {
                         TAPImagePreviewModel *imagePreview = [TAPImagePreviewModel new];
                         imagePreview.image = imageResult;
                         [selectedResultArray addObject:imagePreview];
                     }
                     
                     [imagePreviewViewController setImagePreviewData:selectedResultArray];
                     
                     count++;
                     if(count == [self.selectedImageDataArray count]) {
                         self.imageSelectView.continueButton.enabled = YES;
                         self.imageSelectView.clearButton.enabled = YES;
                         self.imageSelectView.collectionView.userInteractionEnabled = YES;
                         self.imageSelectView.itemNumberView.alpha = 1.0f;
                         self.imageSelectView.continueButton.alpha = 1.0f;
                         self.imageSelectView.activityIndicatorView.alpha = 0.0f;
                         [self.imageSelectView.activityIndicatorView stopAnimating];
                         if(!(self.selectedImageDataArray == nil) && ([self.selectedImageDataArray count] > 0)) {
                             
    //                         imagePreviewViewController.delegate = self;
                             [self.navigationController pushViewController:imagePreviewViewController animated:YES];
                         }
                     }
                 });
             }];
        }
    }
}
- (void)setImageSelectViewControllerNavigateType:(ImageSelectViewControllerNavigateType)imageSelectViewControllerNavigateType {
    _imageSelectViewControllerNavigateType = imageSelectViewControllerNavigateType;
}

- (void)setImageSelectViewControllerType:(ImageSelectViewControllerType)imageSelectViewControllerType {
    _imageSelectViewControllerType = imageSelectViewControllerType;
}

- (void)setImageSelectViewControllerContinueType:(ImageSelectViewControllerContinueType)imageSelectViewControllerContinueType {
    _imageSelectViewControllerContinueType = imageSelectViewControllerContinueType;
}

//OLD FETCH IMAGE METHOD
- (void)getAllPhotosFromCamera {
    [self.imageSelectView startLoadingAnimation];
}

- (void)fetchGalleryData {
    //We have permission. Do whatever is needed
//    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
//    requestOptions.synchronous = NO;
//    requestOptions.networkAccessAllowed = YES;
//    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeNone;
//    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
    
    NSLog(@"total photos: %d",(int)result.count);
    
    for(PHAsset *asset in result) {
        [self.tempGalleryImageDataArray addObject:asset];
        [self.galleryImageDataArray addObject:asset];
    }
    self.indexImageCount = 0;
    [self processPhotos];
}

- (void)isShowLoadingIndicatorView:(BOOL)isShow {
    if(isShow) {
        [UIView animateWithDuration:0.2f animations:^{
            self.activityIndicator.alpha = 1.0f;
        }];
    }
    else {
        [UIView animateWithDuration:0.2f animations:^{
            self.activityIndicator.alpha = 0.0f;
        }];
    }
}

- (void)processPhotos {
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.synchronous = NO;
    requestOptions.networkAccessAllowed = YES;
    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeFast;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    
    PHImageManager *manager = [PHImageManager defaultManager];
    
    if([self.tempGalleryImageDataArray count] > 0) {
        // assets contains PHAsset objects.
        PHAsset *currentAsset = [self.tempGalleryImageDataArray objectAtIndex:0];
        __block UIImage *imageResult;
        
        @autoreleasepool {
            [manager requestImageDataForAsset:currentAsset
                                      options:requestOptions
                                resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     @autoreleasepool {
                         imageResult = [UIImage imageWithData:imageData];
                         
                         NSError *error = [info objectForKey:PHImageErrorKey];
                         if (self.tempGalleryImageDataArray.count > 0) {
                             [self.tempGalleryImageDataArray removeObjectAtIndex:0];
                         }
                         if (error) {
                             NSLog(@"[CameraRoll] Image request error: %@",error);
                         } else {
                             if (imageResult != nil) {
                                 [self scaleImageWithImage:imageResult width:CGRectGetWidth([UIScreen mainScreen].bounds)/2 success:^(UIImage *scaledImage) {
                                     [self.loadedImageThumbnailDictionary setObject:scaledImage forKey:[NSString stringWithFormat:@"%ld", (long)self.indexImageCount]];
                                     [self.imageSelectView.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.indexImageCount inSection:0]]];
                                     [self.imageSelectView endLoadingAnimation];
                                     if (self.tempGalleryImageDataArray.count > 0) {
                                         // Recurring loop
                                         self.indexImageCount = self.indexImageCount + 1;
                                         [self processPhotos];
                                     }
                                 }];
                             }
                         }
                     }
                     
                 });
                 
             }];
        }
    }
    else {
        [self.imageSelectView endLoadingAnimation];
    }
}

- (void)scaleImageWithImage:(UIImage *)sourceImage
                      width:(CGFloat)targetWidth
                    success:(void (^)(UIImage *scaledImage))success {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        float oldWidth = sourceImage.size.width;
        float scaleFactor = targetWidth / oldWidth;
        
        float newHeight = sourceImage.size.height * scaleFactor;
        float newWidth = oldWidth * scaleFactor;
        
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
        [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
        success(newImage);
        });
    });
}

//NEW GET IMAGE METHOD
- (void)fetchCameraRollData {
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    self.allPhotos = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:allPhotosOptions];
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    
    self.smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    self.userCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    for(PHAssetCollection *collection in self.smartAlbums) {
        PHFetchResult *assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
#ifdef DEBUG
        NSLog(@"sub album title is %@, count is %ld", collection.localizedTitle, assetsFetchResult.count);
#endif
        if ([[collection.localizedTitle lowercaseString] isEqualToString:@"camera roll"] || [[collection.localizedTitle lowercaseString] isEqualToString:@"all photos"]) {
#ifdef DEBUG
            NSLog(@"Collection id %@", collection.localIdentifier);
#endif
            _cameraRollCollection = collection;
        }
    }
    
    [self fetchFromCameraRollCollection];
}

- (void)fetchFromCameraRollCollection {
    _tempGalleryImageDataArray = [NSMutableArray array];
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    
    _cameraRollPhotos = [PHAsset fetchAssetsInAssetCollection:self.cameraRollCollection options:options];
    for(PHAsset *asset in self.cameraRollPhotos) {
        [self.tempGalleryImageDataArray addObject:asset];
    }

    self.indexImageCount = 0;
    [self processCameraRollPhotos];
}

- (void)processCameraRollPhotos {
    @autoreleasepool {
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.synchronous = NO;
    requestOptions.networkAccessAllowed = YES;
    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    PHImageManager *manager = [PHImageManager defaultManager];
    
    if([self.tempGalleryImageDataArray count] > 0) {
        // assets contains PHAsset objects.
        PHAsset *currentAsset = [self.tempGalleryImageDataArray objectAtIndex:0];
        __block UIImage *imageResult;
//        @autoreleasepool {
            [manager requestImageForAsset:currentAsset targetSize:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds)/2, CGRectGetWidth([UIScreen mainScreen].bounds)/2) contentMode:PHImageContentModeAspectFill options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    @autoreleasepool {
                        imageResult = result;
                        NSError *error = [info objectForKey:PHImageErrorKey];
                        if (self.tempGalleryImageDataArray.count > 0) {
                            [self.tempGalleryImageDataArray removeObjectAtIndex:0];
                        }
                        if (error) {
#ifdef DEBUG
                            NSLog(@"[CameraRoll] Image request error: %@",error);
#endif
                        } else {
                            if (imageResult != nil) {
                                [self.loadedImageThumbnailDictionary setObject:imageResult forKey:[NSString stringWithFormat:@"%ld", (long)self.indexImageCount]];
                                [self.imageSelectView.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:self.indexImageCount inSection:0]]];
                                [self.imageSelectView endLoadingAnimation];
                                if (self.tempGalleryImageDataArray.count > 0) {
                                    // Recurring loop
                                    self.indexImageCount = self.indexImageCount + 1;
                                    [self processCameraRollPhotos];
                                }
                            }
                        }
                    }
                });
            }];
            
//        }
    }
    
    else {
        [self.imageSelectView endLoadingAnimation];
    }
    }
}

@end
