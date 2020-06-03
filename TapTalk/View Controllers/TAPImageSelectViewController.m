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
- (void)loopFetchThumbnailImageWithIndexCounter:(NSInteger)indexCount selectedResultArray:(NSMutableArray *)array;

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
        UIImage *closeImage = [UIImage imageNamed:@"TAPIconClose" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        closeImage = [closeImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconNavigationBarCloseButton]];
        _leftBarButton = [[UIBarButtonItem alloc] initWithImage:closeImage style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonDidTapped)];
        self.leftBarButton.tintColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconNavigationBarCloseButton];
        [self.navigationItem setLeftBarButtonItem:self.leftBarButton];
    }
    else if(self.imageSelectViewControllerNavigateType == ImageSelectViewControllerNavigateTypePush) {
        UIImage *buttonImage = [UIImage imageNamed:@"TAPIconBackArrow" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        buttonImage = [buttonImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconNavigationBarBackButton]];
        _leftBarButton = [[UIBarButtonItem alloc] initWithImage:buttonImage style:UIBarButtonItemStylePlain target:self action:@selector(backButtonDidTapped)];
        self.leftBarButton.tintColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconNavigationBarBackButton];
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
        _selectedMediaDataArray = [NSMutableArray array];
        
        self.title = NSLocalizedStringFromTableInBundle(@"Photo Gallery", nil, [TAPUtil currentBundle], @"");
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
    
    if([self.selectedMediaDataArray count] > 0) {
        self.imageSelectView.itemNumberView.alpha = 1.0f;
        self.imageSelectView.continueButton.userInteractionEnabled = YES;
        self.imageSelectView.continueButton.alpha = 1.0f;
        
        self.imageSelectView.itemNumberLabel.text = [NSString stringWithFormat:@"%ld", (long)[self.selectedMediaDataArray count]];
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
    
    UIImage *selectedImage = (UIImage *)[self.loadedImageThumbnailDictionary objectForKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
    PHAsset *asset = [self.galleryImageDataArray objectAtIndex:indexPath.row];
    
    [cell setCellWithImage:selectedImage andMediaAsset:asset];
    
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
            if([self.selectedMediaDataArray containsObject:[self.galleryImageDataArray objectAtIndex:indexPath.row]]) {
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
            
            NSInteger currentItemSelected = [self.selectedMediaDataArray count];
            NSInteger totalItemSelected = self.currentTotalImageData + currentItemSelected;
            
            //not selected, change to selected
            [self.selectedMediaDataArray addObject:imageObject];
            [self.selectedImagePositionDictionary setObject:imageObject forKey:selectedKeyString];
            
            if([self.delegate respondsToSelector:@selector(imageSelectViewControllerDidAddSelectedImage:selectedDictionary:)]) {
                [self.delegate imageSelectViewControllerDidAddSelectedImage:self.selectedMediaDataArray selectedDictionary:self.selectedImagePositionDictionary];
            }
            
            [currentSelectedCell setCellAsSelected:YES];
        }
        else {
            //image selected
            //already selected, change to not selected
            [self.selectedMediaDataArray removeObject:imageObject];
            [self.selectedImagePositionDictionary removeObjectForKey:selectedKeyString];
            
            if([self.delegate respondsToSelector:@selector(imageSelectViewControllerDidAddSelectedImage:selectedDictionary:)]) {
                [self.delegate imageSelectViewControllerDidAddSelectedImage:self.selectedMediaDataArray selectedDictionary:self.selectedImagePositionDictionary];
            }
            
            [currentSelectedCell setCellAsSelected:NO];
            
        }
        
    }
    else {
        //check selected
        if(![self.selectedMediaDataArray containsObject:imageObject]) {
            //not selected, change to selected
            [self.selectedMediaDataArray addObject:imageObject];
            [currentSelectedCell setCellAsSelected:YES];
        }
        else {
            //already selected, change to not selected
            [self.selectedMediaDataArray removeObject:imageObject];
            [currentSelectedCell setCellAsSelected:NO];
        }
    }
    
    NSInteger totalSelectedCount = [self.selectedMediaDataArray count];
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
        _selectedMediaDataArray = [NSMutableArray array];
        _selectedImagePositionDictionary = [NSMutableDictionary dictionary];
        
        if(self.imageSelectViewControllerType == ImageSelectViewControllerTypeGalleryAlbum) {
            if([self.delegate respondsToSelector:@selector(imageSelectViewControllerDidAddSelectedImage:selectedDictionary:)]) {
                [self.delegate imageSelectViewControllerDidAddSelectedImage:[NSMutableArray array] selectedDictionary:[NSMutableDictionary dictionary]];
            }
        }
        
        //Run UI Updates
        [self.imageSelectView.collectionView reloadData];
        
        NSInteger totalSelectedCount = [self.selectedMediaDataArray count];
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
    NSMutableArray *selectedResultArray = [NSMutableArray array];
    [self loopFetchThumbnailImageWithIndexCounter:0 selectedResultArray:selectedResultArray];
}

//- (void)continueButtonDidTapped {
//
//    if (self.imageSelectViewControllerContinueType == ImageSelectViewControllerContinueTypeAddMore) {
//
//        NSMutableArray *selectedResultArray = [NSMutableArray array];
//        PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
//        requestOptions.synchronous = NO;
//        requestOptions.networkAccessAllowed = YES;
//        requestOptions.resizeMode   = PHImageRequestOptionsResizeModeNone;
//        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
//
//        PHImageManager *manager = [PHImageManager defaultManager];
//
//        self.imageSelectView.continueButton.enabled = NO;
//        self.imageSelectView.clearButton.enabled = NO;
//        self.imageSelectView.collectionView.userInteractionEnabled = NO;
//        self.imageSelectView.itemNumberView.alpha = 0.0f;
//        self.imageSelectView.continueButton.alpha = 0.0f;
//        self.imageSelectView.activityIndicatorView.alpha = 1.0f;
//        [self.imageSelectView.activityIndicatorView startAnimating];
//
//        NSInteger __block count = 0;
//        for (PHAsset *currentAsset in self.selectedMediaDataArray) {
//            __block UIImage *imageResult;
//            [manager requestImageDataForAsset:currentAsset
//                                      options:requestOptions
//                                resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info)
//             {
//                 dispatch_async(dispatch_get_main_queue(), ^{
//
//                     imageResult = [UIImage imageWithData:imageData];
//
//                     if (currentAsset.mediaType == PHAssetMediaTypeImage) {
//                         if(imageResult != nil) {
//                             TAPMediaPreviewModel *mediaPreview = [TAPMediaPreviewModel new];
//                             mediaPreview.image = imageResult;
//                             mediaPreview.mediaType = @"image";
//                             [selectedResultArray addObject:mediaPreview];
//                         }
//
//                         count++;
//                         if(count == [self.selectedMediaDataArray count]) {
//                             self.imageSelectView.continueButton.enabled = YES;
//                             self.imageSelectView.clearButton.enabled = YES;
//                             self.imageSelectView.collectionView.userInteractionEnabled = YES;
//                             self.imageSelectView.itemNumberView.alpha = 1.0f;
//                             self.imageSelectView.continueButton.alpha = 1.0f;
//                             self.imageSelectView.activityIndicatorView.alpha = 0.0f;
//                             [self.imageSelectView.activityIndicatorView stopAnimating];
//                             if(!(self.selectedMediaDataArray == nil) && ([self.selectedMediaDataArray count] > 0)) {
//                                 if([self.delegate respondsToSelector:@selector(imageSelectViewControllerDidTappedContinueButtonWithDataArray:)]) {
//                                     [self.delegate imageSelectViewControllerDidTappedContinueButtonWithDataArray:selectedResultArray];
//                                 }
//                             }
//                         }
//                     }
//                     else if (currentAsset.mediaType == PHAssetMediaTypeVideo) {
//                         //Handle for video
//                         PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
//                         options.version = PHVideoRequestOptionsVersionOriginal;
//                         options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
//                         options.networkAccessAllowed = YES;
//                         options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info){
//                             NSLog(@"====== PROGRESS DOWNLOAD %f", progress);
//
//                         };
//                         [manager requestAVAssetForVideo:currentAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
//
//                             if (asset != nil) {
//                                 TAPMediaPreviewModel *mediaPreview = [TAPMediaPreviewModel new];
//                                 mediaPreview.videoAsset = asset;
//                                 mediaPreview.image = imageResult;
//                                 mediaPreview.mediaType = @"video";
//                                 [selectedResultArray addObject:mediaPreview];
//                             }
//
//                             dispatch_async(dispatch_get_main_queue(), ^{
//
//                                 count++;
//                                 if(count == [self.selectedMediaDataArray count]) {
//                                     self.imageSelectView.continueButton.enabled = YES;
//                                     self.imageSelectView.clearButton.enabled = YES;
//                                     self.imageSelectView.collectionView.userInteractionEnabled = YES;
//                                     self.imageSelectView.itemNumberView.alpha = 1.0f;
//                                     self.imageSelectView.continueButton.alpha = 1.0f;
//                                     self.imageSelectView.activityIndicatorView.alpha = 0.0f;
//                                     [self.imageSelectView.activityIndicatorView stopAnimating];
//                                     if(!(self.selectedMediaDataArray == nil) && ([self.selectedMediaDataArray count] > 0)) {
//                                         if([self.delegate respondsToSelector:@selector(imageSelectViewControllerDidTappedContinueButtonWithDataArray:)]) {
//                                             [self.delegate imageSelectViewControllerDidTappedContinueButtonWithDataArray:selectedResultArray];
//                                         }
//                                     }
//                                 }
//                             });
//                         }];
//                     }
//                 });
//             }];
//        }
//    }
//    else {
//        TAPImagePreviewViewController *imagePreviewViewController  = [[TAPImagePreviewViewController alloc] init];
//        imagePreviewViewController.delegate = self;
//
//        NSMutableArray *selectedResultArray = [NSMutableArray array];
//        PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
//        requestOptions.synchronous = NO;
//        requestOptions.networkAccessAllowed = YES;
//        requestOptions.resizeMode   = PHImageRequestOptionsResizeModeNone;
//        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
//
//        PHImageManager *manager = [PHImageManager defaultManager];
//
//        self.imageSelectView.continueButton.enabled = NO;
//        self.imageSelectView.clearButton.enabled = NO;
//        self.imageSelectView.collectionView.userInteractionEnabled = NO;
//        self.imageSelectView.itemNumberView.alpha = 0.0f;
//        self.imageSelectView.continueButton.alpha = 0.0f;
//        self.imageSelectView.activityIndicatorView.alpha = 1.0f;
//        [self.imageSelectView.activityIndicatorView startAnimating];
//
//        NSInteger __block count = 0;
//        for (PHAsset *currentAsset in self.selectedMediaDataArray) {
//
//            __block UIImage *imageResult;
//            [manager requestImageDataForAsset:currentAsset
//                                      options:requestOptions
//                                resultHandler:^(NSData *imageData, NSString *dataUTI, UIImageOrientation orientation, NSDictionary *info)
//             {
//                 dispatch_async(dispatch_get_main_queue(), ^{
//                     imageResult = [UIImage imageWithData:imageData];
//                     if (currentAsset.mediaType == PHAssetMediaTypeImage) {
//                         if(imageResult != nil) {
//                             TAPMediaPreviewModel *mediaPreview = [TAPMediaPreviewModel new];
//                             mediaPreview.image = imageResult;
//                             mediaPreview.mediaType = @"image";
//                             [selectedResultArray addObject:mediaPreview];
//                             [imagePreviewViewController setMediaPreviewData:mediaPreview];
//                         }
//
//                         count++;
//                         if(count == [self.selectedMediaDataArray count]) {
//                             self.imageSelectView.continueButton.enabled = YES;
//                             self.imageSelectView.clearButton.enabled = YES;
//                             self.imageSelectView.collectionView.userInteractionEnabled = YES;
//                             self.imageSelectView.itemNumberView.alpha = 1.0f;
//                             self.imageSelectView.continueButton.alpha = 1.0f;
//                             self.imageSelectView.activityIndicatorView.alpha = 0.0f;
//                             [self.imageSelectView.activityIndicatorView stopAnimating];
//                             if(!(self.selectedMediaDataArray == nil) && ([self.selectedMediaDataArray count] > 0)) {
//                                 [self.navigationController pushViewController:imagePreviewViewController animated:YES];
//                             }
//                         }
//                     }
//                     else if (currentAsset.mediaType == PHAssetMediaTypeVideo) {
//                         //Handle for video
//                         PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
//                         options.version = PHVideoRequestOptionsVersionOriginal;
//                         options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
//                         options.networkAccessAllowed = YES;
//                         options.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info){
//                             NSLog(@"====== PROGRESS DOWNLOAD %f", progress);
//                         };
//                         [manager requestAVAssetForVideo:currentAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
//
//                             if (asset != nil) {
//                                 TAPMediaPreviewModel *mediaPreview = [TAPMediaPreviewModel new];
//                                 mediaPreview.videoAsset = asset;
//                                 mediaPreview.image = imageResult;
//                                 mediaPreview.mediaType = @"video";
//                                 [selectedResultArray addObject:mediaPreview];
//                                 [imagePreviewViewController setMediaPreviewData:mediaPreview];
//                             }
//
//                             dispatch_async(dispatch_get_main_queue(), ^{
//
////                                 if (asset != nil) {
////                                     TAPMediaPreviewModel *mediaPreview = [TAPMediaPreviewModel new];
////                                     mediaPreview.videoAsset = asset;
////                                     mediaPreview.image = imageResult;
////                                     mediaPreview.mediaType = @"video";
////                                     [selectedResultArray addObject:mediaPreview];
////                                     [imagePreviewViewController setMediaPreviewData:mediaPreview];
////                                 }
//
//                                 count++;
//                                 if(count == [self.selectedMediaDataArray count]) {
//                                     self.imageSelectView.continueButton.enabled = YES;
//                                     self.imageSelectView.clearButton.enabled = YES;
//                                     self.imageSelectView.collectionView.userInteractionEnabled = YES;
//                                     self.imageSelectView.itemNumberView.alpha = 1.0f;
//                                     self.imageSelectView.continueButton.alpha = 1.0f;
//                                     self.imageSelectView.activityIndicatorView.alpha = 0.0f;
//                                     [self.imageSelectView.activityIndicatorView stopAnimating];
//                                     if(!(self.selectedMediaDataArray == nil) && ([self.selectedMediaDataArray count] > 0)) {
//                                         [self.navigationController pushViewController:imagePreviewViewController animated:YES];
//                                     }
//                                 }
//                             });
//                         }];
//                     }
//                 });
//             }];
//        }
//    }
//}

- (void)loopFetchThumbnailImageWithIndexCounter:(NSInteger)indexCount selectedResultArray:(NSMutableArray *)array {
    __block NSInteger indexCounter = indexCount;
    
    @autoreleasepool {
        PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
        requestOptions.synchronous = NO;
        requestOptions.networkAccessAllowed = YES;
        requestOptions.resizeMode   = PHImageRequestOptionsResizeModeNone;
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
        PHImageManager *manager = [PHImageManager defaultManager];
        
        // assets contains PHAsset objects.
        PHAsset *currentAsset = [self.selectedMediaDataArray objectAtIndex:indexCounter];
        __block UIImage *imageResult;
        __block NSMutableArray *selectedResultArray = array;
        
        [manager requestImageForAsset:currentAsset targetSize:CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds)/2, CGRectGetWidth([UIScreen mainScreen].bounds)/2) contentMode:PHImageContentModeAspectFill options:requestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                @autoreleasepool {
                    imageResult = result;
                    NSError *error = [info objectForKey:PHImageErrorKey];
                    if (error) {
#ifdef DEBUG
                        NSLog(@"[CameraRoll] Image request error: %@",error);
#endif
                    } else {
                        if (imageResult != nil) {
                            TAPMediaPreviewModel *mediaPreview = [TAPMediaPreviewModel new];
                            mediaPreview.asset = currentAsset;
                            mediaPreview.thumbnailImage = imageResult;
                            
                            if (currentAsset.mediaType == PHAssetMediaTypeImage) {
                                mediaPreview.mediaType = @"image";
                            }
                            else if (currentAsset.mediaType == PHAssetMediaTypeVideo) {
                                mediaPreview.mediaType = @"video";
                            }
                            
                            [selectedResultArray addObject:mediaPreview];
                            
                            if (indexCounter < [self.selectedMediaDataArray count] - 1) {
                                // Recurring loop
                                indexCounter++;
                                [self loopFetchThumbnailImageWithIndexCounter:indexCounter selectedResultArray:selectedResultArray];
                            }
                            else {
                                //Done loop
                                if (self.imageSelectViewControllerContinueType == ImageSelectViewControllerContinueTypeAddMore) {
                                    if (!(self.selectedMediaDataArray == nil) && ([self.selectedMediaDataArray count] > 0)) {
                                        if ([self.delegate respondsToSelector:@selector(imageSelectViewControllerDidTappedContinueButtonWithDataArray:)]) {
                                            [self.delegate imageSelectViewControllerDidTappedContinueButtonWithDataArray:selectedResultArray];
                                        }
                                    }
                                }
                                else {
                                    TAPImagePreviewViewController *imagePreviewViewController = [[TAPImagePreviewViewController alloc] init];
                                    imagePreviewViewController.delegate = self;
                                    imagePreviewViewController.isNotFromPersonalRoom = self.isNotFromPersonalRoom;
                                    [imagePreviewViewController setParticipantListArray:self.participantListArray];
                                    
                                    if (!(self.selectedMediaDataArray == nil) && ([self.selectedMediaDataArray count] > 0)) {
                                        [imagePreviewViewController setMediaPreviewDataWithArray:selectedResultArray];
                                        [self.navigationController pushViewController:imagePreviewViewController animated:YES];
                                    }
                                }
                            }
                        }
                    }
                }
            });
        }];
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
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    PHFetchResult *imageResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
    PHFetchResult *videoResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:fetchOptions];
    
#ifdef DEBUG
    NSLog(@"total photos: %d total videos: %d",(int)imageResult.count, (int)videoResult.count);
#endif
    
    for(PHAsset *asset in imageResult) {
        [self.tempGalleryImageDataArray addObject:asset];
        [self.galleryImageDataArray addObject:asset];
    }
    
    for(PHAsset *asset in videoResult) {
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
    
    _cameraRollPhotos = [PHAsset fetchAssetsInAssetCollection:self.cameraRollCollection options:options];
    for(PHAsset *asset in self.cameraRollPhotos) {
        [self.tempGalleryImageDataArray addObject:asset];
        [self.galleryImageDataArray addObject:asset];
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
