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

#import "TAPMediaDetailViewController.h"

@interface TAPProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate, TAPImageCollectionViewCellDelegate, TAPMediaDetailViewControllerDelegate>

@property (strong, nonatomic) TAPProfileView *profileView;
@property (strong, nonatomic) TAPUserModel *updatedUser;
@property (strong, nonatomic) NSMutableArray *mediaMessageDataArray;
@property (strong, nonatomic) NSMutableDictionary *mediaMessageDataDictionary;
@property (nonatomic) BOOL isFullNameChanged;
@property (nonatomic) BOOL isUserProfileURLChanged;
@property (nonatomic) BOOL isMediaLastPage;

@property (weak, nonatomic) id openedBubbleCell;

- (void)getUserProfileDataWithUserID:(NSString *)userID;
- (void)fetchImageDataWithMessage:(TAPMessageModel *)message;
- (void)fetchVideoDataWithMessage:(TAPMessageModel *)message;

- (void)fileDownloadManagerProgressNotification:(NSNotification *)notification;
- (void)fileDownloadManagerStartNotification:(NSNotification *)notification;
- (void)fileDownloadManagerFinishNotification:(NSNotification *)notification;
- (void)fileDownloadManagerFailureNotification:(NSNotification *)notification;

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
    
    [self.profileView.profileImageView setImageWithURLString:self.room.imageURL.fullsize];
    
    self.profileView.nameLabel.text = self.room.name;
    self.profileView.navigationNameLabel.text = self.room.name;
    
    [self getUserProfileDataWithUserID:self.userID];
    
    _mediaMessageDataArray = [[NSMutableArray alloc] init];
    _mediaMessageDataDictionary = [[NSMutableDictionary alloc] init];
    
    [TAPDataManager getDatabaseMediaMessagesInRoomWithRoomID:self.room.roomID lastTimestamp:@"" numberOfItem:50 success:^(NSArray *mediaMessages) {
        _mediaMessageDataArray = [mediaMessages mutableCopy];
        for (TAPMessageModel *message in self.mediaMessageDataArray) {
            [self.mediaMessageDataDictionary setObject:message forKey:message.localID];
        }
        [self.profileView.collectionView reloadData];
    } failure:^(NSError *error) {
        
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileDownloadManagerProgressNotification:) name:TAP_NOTIFICATION_DOWNLOAD_FILE_PROGRESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileDownloadManagerStartNotification:) name:TAP_NOTIFICATION_DOWNLOAD_FILE_START object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileDownloadManagerFinishNotification:) name:TAP_NOTIFICATION_DOWNLOAD_FILE_FINISH object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileDownloadManagerFailureNotification:) name:TAP_NOTIFICATION_DOWNLOAD_FILE_FAILURE object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_DOWNLOAD_FILE_PROGRESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_DOWNLOAD_FILE_START object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_DOWNLOAD_FILE_FINISH object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_DOWNLOAD_FILE_FAILURE object:nil];
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
        //DV Note
        //Temporary Hidden For V1 because features is not complete (25 Mar 2019)
//        return 4;
        //END DV Note
        
        return 0;
    }
    else if (section == 1) {
        return [self.mediaMessageDataArray count]; //DV Temp
    }
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        //DV Note
        //Temporary Hidden For V1 because features is not complete (25 Mar 2019)
//        NSString *cellID = @"TAPProfileCollectionViewCell";
//        [collectionView registerClass:[TAPProfileCollectionViewCell class] forCellWithReuseIdentifier:cellID];
//        TAPProfileCollectionViewCell *cell = (TAPProfileCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
//
//        if (indexPath.item == 0) {
//            [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeNotification];
//            [cell showSeparatorView:YES];
//        }
//        else if (indexPath.item == 1) {
//            [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeConversationColor];
//            [cell showSeparatorView:YES];
//        }
//        else if (indexPath.item == 2) {
//            [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeBlock];
//            [cell showSeparatorView:YES];
//        }
//        else if (indexPath.item == 3) {
//            [cell setProfileCollectionViewCellType:profileCollectionViewCellTypeClearChat];
//            [cell showSeparatorView:NO];
//        }
//
//        return cell;
        //END DV Note
    }
    else if (indexPath.section == 1) {
        NSString *cellID = @"TAPImageCollectionViewCell";
        [collectionView registerClass:[TAPImageCollectionViewCell class] forCellWithReuseIdentifier:cellID];

        TAPImageCollectionViewCell *cell = (TAPImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
        cell.delegate = self;
        
        TAPMessageModel *message = [self.mediaMessageDataArray objectAtIndex:indexPath.row];
        [cell setImageCollectionViewCellWithMessage:message];
        
        if (message.type == TAPChatMessageTypeImage) {
            NSString *roomID = message.room.roomID;
            NSDictionary *dataDictionary = message.data;
            NSString *fileID = [dataDictionary objectForKey:@"fileID"];
            fileID = [TAPUtil nullToEmptyString:fileID];
            
            [TAPImageView imageFromCacheWithKey:fileID message:message success:^(UIImage *savedImage, TAPMessageModel *resultMessage) {
                NSString *currentRoomID = resultMessage.room.roomID;
                NSString *currentLocalID = resultMessage.localID;
                NSDictionary *currentDataDictionary = resultMessage.data;
                NSString *currentFileID = [currentDataDictionary objectForKey:@"fileID"];
                currentFileID = [TAPUtil nullToEmptyString:currentFileID];
                
                NSDictionary *progressDictionary = [[TAPFileDownloadManager sharedManager] getDownloadProgressWithLocalID:message.localID];
         
                //Check image exist in cache
                if (savedImage != nil) {
                    //Image exist
                    //set as downloaded
                    //set image
                    [cell setImageCollectionViewCellImageWithImage:savedImage];
                    [cell setAsDownloaded];
                    [cell setInfoLabelWithString:@""];
                }
                //Check image is downloading
                else if (progressDictionary != nil) {
                    
                    CGFloat progress = [[progressDictionary objectForKey:@"progress"] floatValue];
                    CGFloat total = [[progressDictionary objectForKey:@"total"] floatValue];
                    [cell setInitialAnimateDownloadingMedia];
                    
                    NSString *fileSize = [NSByteCountFormatter stringFromByteCount:[[message.data objectForKey:@"size"] integerValue] countStyle:NSByteCountFormatterCountStyleBinary];
                    [cell setInfoLabelWithString:fileSize];
                    
                    [cell animateProgressDownloadingMediaWithProgress:progress total:total];
                }
                else {
                    //Image not exist in cache
                    //if not show download button
                    NSString *fileSize = [NSByteCountFormatter stringFromByteCount:[[message.data objectForKey:@"size"] integerValue] countStyle:NSByteCountFormatterCountStyleBinary];
                    [cell setInfoLabelWithString:fileSize];
                    [cell setAsNotDownloaded];
                }
            }];
        }
        else if (message.type == TAPChatMessageTypeVideo) {
            
            NSNumber *duration = [message.data objectForKey:@"duration"];
            NSTimeInterval durationTimeInterval = [duration integerValue] / 1000; //convert to second
            NSString *videoDurationString = [TAPUtil stringFromTimeInterval:ceil(durationTimeInterval)];
            
            NSString *fileSize = [NSByteCountFormatter stringFromByteCount:[[message.data objectForKey:@"size"] integerValue] countStyle:NSByteCountFormatterCountStyleBinary];
            
            //Check video exist in cache
            NSDictionary *dataDictionary = message.data;
            NSString *fileID = [dataDictionary objectForKey:@"fileID"];
            NSString *localID = message.localID;
            NSString *roomID = message.room.roomID;
            
            //Check video is done downloaded or not
            NSString *filePath = [[TAPFileDownloadManager sharedManager] getDownloadedFilePathWithRoomID:roomID fileID:fileID];
            
            NSDictionary *progressDictionary = [[TAPFileDownloadManager sharedManager] getDownloadProgressWithLocalID:message.localID];
       
            
            if ([filePath isEqualToString:@""] || filePath == nil) {
                //File not exist, download file
                [cell setAsNotDownloaded];
                [cell setInfoLabelWithString:fileSize];
            }
            else if (progressDictionary != nil) {
                //File is in downloading progress
                CGFloat progress = [[progressDictionary objectForKey:@"progress"] floatValue];
                CGFloat total = [[progressDictionary objectForKey:@"total"] floatValue];
                [cell setInitialAnimateDownloadingMedia];
                [cell setInfoLabelWithString:fileSize];
                [cell animateProgressDownloadingMediaWithProgress:progress total:total];
            }
            else {
                //File exist, show downloaded file
                [cell setInfoLabelWithString:videoDurationString];
                [cell setAsDownloaded];
                [cell setThumbnailImageForVideoWithMessage:message];
            }
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
            titleLabel.textColor = [TAPUtil getColor:TAP_COLOR_PRIMARY_COLOR_1];
            titleLabel.font = [UIFont fontWithName:TAP_FONT_NAME_BOLD size:11.0f];
            
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
    if (indexPath.section == 1) {
        TAPMessageModel *selectedMessage = [self.mediaMessageDataArray objectAtIndex:indexPath.row];
        
        NSArray *messageArray = [self.mediaMessageDataArray copy];
        NSInteger currentRowIndex = [messageArray indexOfObject:selectedMessage];
        
        TAPImageCollectionViewCell *cell = (TAPImageCollectionViewCell *)[self.profileView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currentRowIndex inSection:1]];

        
        if (selectedMessage.type == TAPChatMessageTypeImage) {
            CGFloat bubbleImageViewMinY = 0.0f;
            
            TAPMediaDetailViewController *mediaDetailViewController = [[TAPMediaDetailViewController alloc] init];
            [mediaDetailViewController setMediaDetailViewControllerType:TAPMediaDetailViewControllerTypeImage];
            mediaDetailViewController.delegate = self;
            mediaDetailViewController.message = cell.currentMessage;
            
            UIImage *cellImage = cell.imageView.image;
            NSArray *imageSliderImage = [NSArray array];
            if(cellImage != nil) {
                imageSliderImage = @[cellImage];
                TAPMessageModel *currentMessage = cell.currentMessage;
                NSString *cellImageURLString = [TAPUtil nullToEmptyString:[cell.currentMessage.data objectForKey:@"fileID"]];
                
                NSString *fileID = [cell.currentMessage.data objectForKey:@"fileID"];
                fileID = [TAPUtil nullToEmptyString:fileID];
                
                [mediaDetailViewController setThumbnailImageArray:imageSliderImage];
                [mediaDetailViewController setImageArray:@[cellImage]];
                
                [mediaDetailViewController setActiveIndex:0];
                
                NSInteger selectedRow = [self.mediaMessageDataArray indexOfObject:cell.currentMessage];
                NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForItem:selectedRow inSection:1];
                
                UICollectionViewLayoutAttributes *attributes = [self.profileView.collectionView layoutAttributesForItemAtIndexPath:indexPath];

                CGRect cellRectInCollectionView = attributes.frame;
                
                CGRect cellRectInView = [self.profileView.collectionView convertRect:cellRectInCollectionView toView:self.profileView];
//                CGRect imageRectInView = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 16.0f - (CGRectGetWidth([UIScreen mainScreen].bounds)-3.0f)/3, CGRectGetMinY(cellRectInView) + bubbleImageViewMinY + [TAPUtil currentDeviceNavigationBarHeightWithStatusBar:YES iPhoneXLargeLayout:NO], (CGRectGetWidth([UIScreen mainScreen].bounds)-3.0f)/3, (CGRectGetWidth([UIScreen mainScreen].bounds)-3.0f)/3);

                [mediaDetailViewController showToViewController:self.navigationController thumbnailImage:cellImage thumbnailFrame:cellRectInView];
                cell.imageView.alpha = 0.0f;
                cell.thumbnailImageView.alpha = 0.0f;
                _openedBubbleCell = cell;
            }

        }
        if (selectedMessage.type == TAPChatMessageTypeVideo) {
            NSDictionary *dataDictionary = selectedMessage.data;
            NSString *fileID = [dataDictionary objectForKey:@"fileID"];
            fileID = [TAPUtil nullToEmptyString:fileID];
            
            NSString *filePath = [[TAPFileDownloadManager sharedManager] getDownloadedFilePathWithRoomID:selectedMessage.room.roomID fileID:fileID];
            
            if (![fileID isEqualToString:@""] && filePath != nil) {
                NSURL *url = [NSURL fileURLWithPath:filePath];
                AVAsset *asset = [AVAsset assetWithURL:url];
                
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
                
                //        AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
                AVPlayerItem *item = [[AVPlayerItem alloc] initWithAsset:asset];
                AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:item];
                
                AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
                controller.delegate = self;
                controller.showsPlaybackControls = YES;
                [self presentViewController:controller animated:YES completion:nil];
                controller.player = player;
                [player play];
            }
        }
        
    }
   
    
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == [self.mediaMessageDataArray count] - 10 && !self.isMediaLastPage) {
        TAPMessageModel *lastMessage = (TAPMessageModel *)[self.mediaMessageDataArray lastObject];
        [TAPDataManager getDatabaseMediaMessagesInRoomWithRoomID:self.room.roomID lastTimestamp:[lastMessage.created stringValue] numberOfItem:50 success:^(NSArray *mediaMessages) {
            [self.mediaMessageDataArray addObjectsFromArray:mediaMessages];
            
            for (TAPMessageModel *message in mediaMessages) {
                [self.mediaMessageDataDictionary setObject:message forKey:message.localID];
            }
            
            [self.profileView.collectionView reloadData];
            
            if ([mediaMessages count] < 50) {
                _isMediaLastPage = YES;
            }
        } failure:^(NSError *error) {
            
        }];
    }
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

#pragma mark - TAPImageCollectionViewCellDelegate
- (void)imageCollectionViewCellDidTappedDownloadWithMessage:(TAPMessageModel *)message {
    if (message.type == TAPChatMessageTypeImage) {
        [self fetchImageDataWithMessage:message];
    }
    else if (message.type == TAPChatMessageTypeVideo) {
        [self fetchVideoDataWithMessage:message];
    }
}

- (void)imageCollectionViewCellDidTappedCancelWithMessage:(TAPMessageModel *)message {
    [[TAPFileDownloadManager sharedManager] cancelDownloadWithMessage:message];
    TAPMessageModel *currentMessage = [self.mediaMessageDataDictionary objectForKey:message.localID];
    NSArray *messageArray = [self.mediaMessageDataArray copy];
    NSInteger currentRowIndex = [messageArray indexOfObject:currentMessage];
    
    TAPImageCollectionViewCell *cell = (TAPImageCollectionViewCell *)[self.profileView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currentRowIndex inSection:1]];
    [cell animateFailedDownloadingMedia];
}

#pragma mark TAPMediaDetailViewController
- (void)mediaDetailViewControllerWillStartClosingAnimation {
    
}

- (void)mediaDetailViewControllerDidFinishClosingAnimation {
    if ([self.openedBubbleCell isKindOfClass:[TAPImageCollectionViewCell class]]) {
        TAPImageCollectionViewCell *cell = (TAPImageCollectionViewCell *)self.openedBubbleCell;
        cell.imageView.alpha = 1.0f;
        cell.thumbnailImageView.alpha = 1.0f;
    }
}

#pragma mark - Custom Method
#pragma mark Download Notification
- (void)fileDownloadManagerProgressNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *notificationParameterDictionary = (NSDictionary *)[notification object];
        
        TAPMessageModel *obtainedMessage = [notificationParameterDictionary objectForKey:@"message"];
        
        NSString *roomID = obtainedMessage.room.roomID;
        roomID = [TAPUtil nullToEmptyString:roomID];
        
        TAPRoomModel *currentRoom = [TAPChatManager sharedManager].activeRoom;
        NSString *currentActiveRoomID = currentRoom.roomID;
        currentActiveRoomID = [TAPUtil nullToEmptyString:currentActiveRoomID];
        
        if (![roomID isEqualToString:currentActiveRoomID]) {
            return;
        }
        
        NSString *localID = obtainedMessage.localID;
        localID = [TAPUtil nullToEmptyString:localID];
        
        NSString *progressString = [notificationParameterDictionary objectForKey:@"progress"];
        CGFloat progress = [progressString floatValue];
        
        NSString *totalString = [notificationParameterDictionary objectForKey:@"total"];
        CGFloat total = [totalString floatValue];
        
        TAPMessageModel *currentMessage = [self.mediaMessageDataDictionary objectForKey:localID];
        NSArray *messageArray = [self.mediaMessageDataArray copy];
        NSInteger currentRowIndex = [messageArray indexOfObject:currentMessage];
        
        TAPChatMessageType type = currentMessage.type;
        TAPImageCollectionViewCell *cell = (TAPImageCollectionViewCell *)[self.profileView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currentRowIndex inSection:1]];
        if (type == TAPChatMessageTypeImage) {
            [cell animateProgressDownloadingMediaWithProgress:progress total:total];
        }
        else if (type == TAPChatMessageTypeVideo) {
            [cell animateProgressDownloadingMediaWithProgress:progress total:total];
        }
    });
}

- (void)fileDownloadManagerStartNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *notificationParameterDictionary = (NSDictionary *)[notification object];
        
        TAPMessageModel *obtainedMessage = [notificationParameterDictionary objectForKey:@"message"];
        
        NSString *roomID = obtainedMessage.room.roomID;
        roomID = [TAPUtil nullToEmptyString:roomID];
        
        TAPRoomModel *currentRoom = [TAPChatManager sharedManager].activeRoom;
        NSString *currentActiveRoomID = currentRoom.roomID;
        currentActiveRoomID = [TAPUtil nullToEmptyString:currentActiveRoomID];
        
        if (![roomID isEqualToString:currentActiveRoomID]) {
            return;
        }
        
        NSString *localID = obtainedMessage.localID;
        localID = [TAPUtil nullToEmptyString:localID];
        
        TAPMessageModel *currentMessage = [self.mediaMessageDataDictionary objectForKey:localID];
        NSArray *messageArray = [self.mediaMessageDataArray copy];
        NSInteger currentRowIndex = [messageArray indexOfObject:currentMessage];
        
        TAPChatMessageType type = currentMessage.type;
        TAPImageCollectionViewCell *cell = (TAPImageCollectionViewCell *)[self.profileView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currentRowIndex inSection:1]];

        if (type == TAPChatMessageTypeImage) {
            [cell setInitialAnimateDownloadingMedia];
        }
        else if (type == TAPChatMessageTypeVideo) {
            [cell setInitialAnimateDownloadingMedia];
        }
    });
}

- (void)fileDownloadManagerFinishNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *notificationParameterDictionary = (NSDictionary *)[notification object];
        
        TAPMessageModel *obtainedMessage = [notificationParameterDictionary objectForKey:@"message"];
        
        NSString *roomID = obtainedMessage.room.roomID;
        roomID = [TAPUtil nullToEmptyString:roomID];
        
        TAPRoomModel *currentRoom = [TAPChatManager sharedManager].activeRoom;
        NSString *currentActiveRoomID = currentRoom.roomID;
        currentActiveRoomID = [TAPUtil nullToEmptyString:currentActiveRoomID];
        
        if (![roomID isEqualToString:currentActiveRoomID]) {
            return;
        }
        
        NSString *localID = obtainedMessage.localID;
        localID = [TAPUtil nullToEmptyString:localID];
        
        TAPMessageModel *currentMessage = [self.mediaMessageDataDictionary objectForKey:localID];
        NSArray *messageArray = [self.mediaMessageDataArray copy];
        NSInteger currentRowIndex = [messageArray indexOfObject:currentMessage];
        
        TAPChatMessageType type = currentMessage.type;
        
        TAPImageCollectionViewCell *cell = (TAPImageCollectionViewCell *)[self.profileView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currentRowIndex inSection:1]];
        
        if (type == TAPChatMessageTypeImage) {
            UIImage *fullImage = [notificationParameterDictionary objectForKey:@"fullImage"];

            if (fullImage != nil) {
                [cell setImageCollectionViewCellImageWithImage:fullImage];
            }
            [cell animateFinishedDownloadingMedia];
            [cell setAsDownloaded];
            [cell setInfoLabelWithString:@""];
        }
        else if (type == TAPChatMessageTypeVideo) {
            [cell animateFinishedDownloadingMedia];
            [cell setAsDownloaded];
            NSNumber *duration = [currentMessage.data objectForKey:@"duration"];
            NSTimeInterval durationTimeInterval = [duration integerValue] / 1000; //convert to second
            NSString *videoDurationString = [TAPUtil stringFromTimeInterval:ceil(durationTimeInterval)];
            [cell setInfoLabelWithString:videoDurationString];
            [cell setThumbnailImageForVideoWithMessage:currentMessage];
            
        }
    });
}

- (void)fileDownloadManagerFailureNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *notificationParameterDictionary = (NSDictionary *)[notification object];
        
        TAPMessageModel *obtainedMessage = [notificationParameterDictionary objectForKey:@"message"];
        NSError *error = [notificationParameterDictionary objectForKey:@"error"];
        
        NSString *roomID = obtainedMessage.room.roomID;
        roomID = [TAPUtil nullToEmptyString:roomID];
        
        TAPRoomModel *currentRoom = [TAPChatManager sharedManager].activeRoom;
        NSString *currentActiveRoomID = currentRoom.roomID;
        currentActiveRoomID = [TAPUtil nullToEmptyString:currentActiveRoomID];
        
        if (![roomID isEqualToString:currentActiveRoomID]) {
            return;
        }
        
        NSString *localID = obtainedMessage.localID;
        localID = [TAPUtil nullToEmptyString:localID];
        
        TAPMessageModel *currentMessage = [self.mediaMessageDataDictionary objectForKey:localID];
        NSArray *messageArray = [self.mediaMessageDataArray copy];
        NSInteger currentRowIndex = [messageArray indexOfObject:currentMessage];
        
        TAPChatMessageType type = currentMessage.type;
        
        TAPImageCollectionViewCell *cell = (TAPImageCollectionViewCell *)[self.profileView.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currentRowIndex inSection:1]];
        
        NSString *fileSize = [NSByteCountFormatter stringFromByteCount:[[currentMessage.data objectForKey:@"size"] integerValue] countStyle:NSByteCountFormatterCountStyleBinary];
        
        if (type == TAPChatMessageTypeImage) {
            [cell animateFailedDownloadingMedia];
            //if not show download button
            [cell setInfoLabelWithString:fileSize];
            [cell setAsNotDownloaded];
        }
        else if (type == TAPChatMessageTypeVideo) {
            [cell animateFailedDownloadingMedia];
            //File not exist, download file
            [cell setAsNotDownloaded];
            [cell setInfoLabelWithString:fileSize];
        }
    });
}

#pragma mark Others
- (void)backButtonDidTapped {
    [self.navigationController popViewControllerAnimated:YES];
    
    if (self.room.type == RoomTypePersonal && (self.isFullNameChanged || self.isUserProfileURLChanged)) {
        NSMutableDictionary *objectDictionary = [NSMutableDictionary dictionary];
        [objectDictionary setObject:self.room forKey:@"room"];
        [objectDictionary setObject:self.updatedUser forKey:@"user"];
        [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_USER_PROFILE_CHANGES object:objectDictionary];
    }
}

- (void)getUserProfileDataWithUserID:(NSString *)userID {
    [TAPDataManager callAPIGetUserByUserID:userID success:^(TAPUserModel *user) {
        
        _updatedUser = user;
        
        NSString *existingUserFullName = self.room.name;
        NSString *obtainedUserFullName = user.fullname;
        
        NSString *existingUserProfileURL = self.room.imageURL.fullsize;
        NSString *obtainedUserProfileURL = user.imageURL.fullsize;
        
        _isFullNameChanged = NO;
        _isUserProfileURLChanged = NO;
        
        if (![obtainedUserFullName isEqualToString:existingUserFullName]) {
            //Change when name is different
            _isFullNameChanged = YES;
            self.profileView.nameLabel.text = obtainedUserFullName;
            self.profileView.navigationNameLabel.text = obtainedUserFullName;
        }
        
        if (![obtainedUserProfileURL isEqualToString:existingUserProfileURL]) {
            _isUserProfileURLChanged = YES;
            //Change when profile image is different
            [self.profileView.profileImageView setImageWithURLString:obtainedUserProfileURL];
        }
        
        if (self.room.type == RoomTypePersonal && (self.isFullNameChanged || self.isUserProfileURLChanged)) {
            //Save changes to contact dictionary
            [[TAPContactManager sharedManager] addContactWithUserModel:user saveToDatabase:NO];
        }
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)fetchImageDataWithMessage:(TAPMessageModel *)message {
    [[TAPFileDownloadManager sharedManager] receiveImageDataWithMessage:message start:^(TAPMessageModel * _Nonnull receivedMessage) {
        //Already handled via Notification
    } progress:^(CGFloat progress, CGFloat total, TAPMessageModel * _Nonnull receivedMessage) {
        //Already handled via Notification
    } success:^(UIImage * _Nonnull fullImage, TAPMessageModel * _Nonnull receivedMessage) {
        //Already handled via Notification
    } failure:^(NSError * _Nonnull error, TAPMessageModel * _Nonnull receivedMessage) {
        //Already handled via Notification
    }];
}

- (void)fetchVideoDataWithMessage:(TAPMessageModel *)message {
    [[TAPFileDownloadManager sharedManager] receiveVideoDataWithMessage:message start:^(TAPMessageModel * _Nonnull receivedMessage) {
        //Already handled via Notification
    } progress:^(CGFloat progress, CGFloat total, TAPMessageModel * _Nonnull receivedMessage) {
        //Already handled via Notification
    } success:^(NSData * _Nonnull fileData, TAPMessageModel * _Nonnull receivedMessage) {
        //Already handled via Notification
    } failure:^(NSError * _Nonnull error, TAPMessageModel * _Nonnull receivedMessage) {
        //Already handled via Notification
    }];
}

@end
