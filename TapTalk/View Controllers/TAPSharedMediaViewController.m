//
//  TAPSharedMediaViewController.m
//  TapTalk
//
//  Created by TapTalk.io on 16/08/22.
//

#import "TAPSharedMediaViewController.h"
#import "TAPLinksShareMediaTableViewCell.h"
#import "TAPWebViewViewController.h"
#import "TAPDocumentShareMediaTableViewCell.h"
#import "TAPImageCollectionViewCell.h"
#import "TAPMediaDetailViewController.h"

@import QuickLook;

@interface TAPSharedMediaViewController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate,  QLPreviewControllerDelegate, QLPreviewControllerDataSource, TAPDocumentShareManagerCellDelegate, TAPLinkShareManagerCellDelegate, TAPImageCollectionViewCellDelegate, TAPMediaDetailViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *mediaIndicatorView;
@property (weak, nonatomic) IBOutlet UIView *linksIndicatorView;
@property (weak, nonatomic) IBOutlet UIView *documentsIndicatorView;

@property (weak, nonatomic) IBOutlet UILabel *mediaLabel;
@property (weak, nonatomic) IBOutlet UILabel *linksLabel;
@property (weak, nonatomic) IBOutlet UILabel *documentsLabel;

@property (weak, nonatomic) IBOutlet UILabel *emptyStateTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *emptyStateBodyLabel;

@property (weak, nonatomic) IBOutlet UIView *tabButtonsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabButtonsViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *mediaTabButtonView;
@property (weak, nonatomic) IBOutlet UIView *linksTabButtonView;
@property (weak, nonatomic) IBOutlet UIView *documentsTabButtonView;
@property (weak, nonatomic) IBOutlet UIButton *mediaTabButton;
@property (weak, nonatomic) IBOutlet UIButton *linksTabButton;
@property (weak, nonatomic) IBOutlet UIButton *documentsTabButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediaTabButtonViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *linksTabButtonViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *documentsTabButtonViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *linksTabButtonViewLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *linksTabButtonViewRightConstraint;

@property (weak, nonatomic) IBOutlet UIView *mediaTabView;
@property (weak, nonatomic) IBOutlet UIView *linksTabView;
@property (weak, nonatomic) IBOutlet UIView *documentsTabView;

@property (weak, nonatomic) IBOutlet UITableView *linksTableView;
@property (weak, nonatomic) IBOutlet UITableView *documentsTableView;
@property (weak, nonatomic) IBOutlet UICollectionView *mediaCollectionView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediaTabWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *linksTabWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *documentsTabWidthConstraint;

@property (weak, nonatomic) IBOutlet UIView *emptyStateView;

@property (weak, nonatomic) IBOutlet UIView *tabSeperatorView;

@property (strong, nonatomic) NSURL *currentSelectedFileURL;

@property (nonatomic) CGFloat screenSizeWidth;

@property (strong, atomic) NSMutableArray *mediaArray;
@property (strong, atomic) NSMutableArray *linksMessageArray;
@property (strong, atomic) NSMutableArray *documentsMessageArray;

@property (strong, nonatomic) NSMutableArray *mediaMessageArray;
@property (strong, nonatomic) NSMutableDictionary *messageDataDictionary;

@property (strong, nonatomic) NSMutableArray *mediaMessageWithSectionArray;
@property (strong, nonatomic) NSMutableArray *linkMessageWithSectionArray;
@property (strong, nonatomic) NSMutableArray *documentMessageWithSectionArray;

@property (strong, atomic) NSMutableArray *remoteMediaArray;
@property (strong, atomic) NSMutableArray *remoteLinksMessageArray;
@property (strong, atomic) NSMutableArray *remoteDocumentsMessageArray;

@property (nonatomic) BOOL isMediaLastPage;
@property (nonatomic) TAPShareMediaTabType shareMediaTabType;
@property (weak, nonatomic) id openedBubbleCell;

@property (nonatomic) BOOL allLocalMediasLoaded;
@property (nonatomic) BOOL allLocalLinksLoaded;
@property (nonatomic) BOOL allLocalDocumentsLoaded;

@property (nonatomic) BOOL isRemoteContentFetched;

@property (nonatomic) BOOL isMediaLoadMore;
@property (nonatomic) BOOL isLinkLoadMore;
@property (nonatomic) BOOL isDocumentLoadMore;

@property (nonatomic, strong) NSString *mediaLastCreated;
@property (nonatomic, strong) NSString *linkLastCreated;
@property (nonatomic, strong) NSString *documentLastCreated;

@end

@implementation TAPSharedMediaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationView];
    
    _mediaArray = [[NSMutableArray alloc] init];
    _linksMessageArray = [[NSMutableArray alloc] init];
    _documentsMessageArray = [[NSMutableArray alloc] init];
    
    _mediaMessageArray = [[NSMutableArray alloc] init];
    _messageDataDictionary = [[NSMutableDictionary alloc] init];
    
    _mediaMessageWithSectionArray = [[NSMutableArray alloc] init];
    _linkMessageWithSectionArray = [[NSMutableArray alloc] init];
    _documentMessageWithSectionArray = [[NSMutableArray alloc] init];
    
    _remoteMediaArray = [[NSMutableArray alloc] init];
    _remoteLinksMessageArray = [[NSMutableArray alloc] init];
    _remoteDocumentsMessageArray = [[NSMutableArray alloc] init];
    
    _shareMediaTabType = TAPShareMediaTabTypeMedia;
    
    _mediaLastCreated = @"";
    _linkLastCreated = @"";
    _documentLastCreated = @"";
    
    self.linksTableView.dataSource = self;
    self.linksTableView.delegate = self;
    self.linksTableView.delaysContentTouches = NO;
    
    self.documentsTableView.dataSource = self;
    self.documentsTableView.delegate = self;
    self.documentsTableView.delaysContentTouches = NO;
    
    self.mediaCollectionView.dataSource = self;
    self.mediaCollectionView.delegate = self;
    
    self.mediaIndicatorView.layer.cornerRadius = 8.0f;
    self.linksIndicatorView.layer.cornerRadius = 8.0f;
    self.documentsIndicatorView.layer.cornerRadius = 8.0f;
    
    self.screenSizeWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    
    self.mediaTabWidthConstraint.constant = self.screenSizeWidth;
    
    UIColor *tabLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorChatProfileDetailTitleLabel];
    UIFont *tabLabelFontInActive = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontTableViewSectionHeaderLabel];
    
    UIColor *emptyLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorTitleLabel];
    UIFont *emptyLabelTitleFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontChatProfileSharedMediaEmptyTitleLabel];
    UIFont *emptyLabelBodyFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontChatProfileSharedMediaEmptyBodyLabel];
    
    self.emptyStateBodyLabel.textColor = emptyLabelColor;
    self.emptyStateBodyLabel.font = emptyLabelBodyFont;
    
    self.emptyStateTitleLabel.font = emptyLabelTitleFont;
    self.emptyStateTitleLabel.textColor = emptyLabelColor;
    
    float spacing = 3.0f;
    NSString *media = @"MEDIA";
    NSMutableAttributedString *attributedMediaString = [[NSMutableAttributedString alloc] initWithString:media];
    [attributedMediaString addAttribute:NSKernAttributeName
                value:@(spacing)
                range:NSMakeRange(0, [media length])];
    
    NSString *linkString = @"LINKS";
    NSMutableAttributedString *attributedLinkString = [[NSMutableAttributedString alloc] initWithString:linkString];
    [attributedLinkString addAttribute:NSKernAttributeName
                value:@(spacing)
                range:NSMakeRange(0, [linkString length])];
    
    NSString *documentString = @"DOCUMENTS";
    NSMutableAttributedString *attributedDocumentString = [[NSMutableAttributedString alloc] initWithString:documentString];
    [attributedDocumentString addAttribute:NSKernAttributeName
                value:@(spacing)
                range:NSMakeRange(0, [documentString length])];
    
    self.mediaLabel.textColor = tabLabelColor;
    self.mediaLabel.font = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontChatProfileSharedMediaTabActiveLabel];
    self.mediaLabel.attributedText = attributedMediaString;
    
    
    self.linksLabel.textColor = tabLabelColor;
    self.linksLabel.font = tabLabelFontInActive;
    self.linksLabel.attributedText = attributedLinkString;
    
    self.documentsLabel.textColor = tabLabelColor;
    self.documentsLabel.font = tabLabelFontInActive;
    self.documentsLabel.attributedText = attributedDocumentString;
    
    [self.mediaTabButton addTarget:self action:@selector(mediaTabButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.linksTabButton addTarget:self action:@selector(linksTabButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.documentsTabButton addTarget:self action:@selector(documentsTabButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    
    NSInteger hiddenTabs = 0;
    if (![[TapUI sharedInstance] isSharedMediaMediasTabVisible]) {
        self.mediaTabButtonView.alpha = 0.0f;
        self.mediaTabButtonViewWidthConstraint.constant = 0.0f;
        self.linksTabButtonViewLeftConstraint.constant = 0.0f;
        hiddenTabs++;
        [self linksTabButtonDidTapped];
    }
    if (![[TapUI sharedInstance] isSharedMediaLinksTabVisible]) {
        self.linksTabButtonView.alpha = 0.0f;
        self.linksTabButtonViewWidthConstraint.constant = 0.0f;
        self.linksTabButtonViewRightConstraint.constant = 0.0f;
        hiddenTabs++;
        if (![[TapUI sharedInstance] isSharedMediaMediasTabVisible]) {
            [self documentsTabButtonDidTapped];
        }
    }
    if (![[TapUI sharedInstance] isSharedMediaDocumentsTabVisible]) {
        self.documentsTabButtonView.alpha = 0.0f;
        self.documentsTabButtonViewWidthConstraint.constant = 0.0f;
        self.linksTabButtonViewRightConstraint.constant = 0.0f;
        hiddenTabs++;
        
    }
    if (hiddenTabs > 1) {
        self.tabButtonsView.alpha = 0.0f;
        self.tabButtonsViewHeightConstraint.constant = 0.0f;
    }
    
    [TAPDataManager getDatabaseMediaMessagesInRoomWithRoomID:self.room.roomID lastTimestamp:self.mediaLastCreated numberOfItem:50 success:^(NSArray *mediaMessages) {
        _mediaMessageArray = [mediaMessages mutableCopy];
        [self insertMediaSectionArray:self.mediaMessageArray];
        [self.mediaCollectionView reloadData];
        TAPMessageModel *lastLocalMediaMessage = [mediaMessages lastObject];
        self.mediaLastCreated = [lastLocalMediaMessage.created stringValue];
        if (mediaMessages.count < 50) {
            self.allLocalMediasLoaded = YES;
            [self callApiLoad];
        }
        
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

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
   
    UIEdgeInsets cellInsets = UIEdgeInsetsMake(0.0f, 8.0f, 5.0f, 8.0f);
    return cellInsets;
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 4.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout{
    return 1.0f;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.mediaMessageWithSectionArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    NSMutableArray *sectionArray = [self.mediaMessageWithSectionArray objectAtIndex:section];
    return [sectionArray count];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {

    if (self.shareMediaTabType == TAPShareMediaTabTypeMedia && indexPath.row == [self.mediaMessageArray count] - 25 && !self.allLocalMediasLoaded) {
        TAPMessageModel *lastMessage = (TAPMessageModel *)[self.mediaMessageArray lastObject];
        [TAPDataManager getDatabaseMediaMessagesInRoomWithRoomID:self.room.roomID lastTimestamp:self.mediaLastCreated numberOfItem:50 success:^(NSArray *mediaMessages) {
            [self.mediaMessageArray addObjectsFromArray:mediaMessages];
            [self insertMediaSectionArray:self.mediaMessageArray];
            [self.mediaCollectionView reloadData];
            TAPMessageModel *lastLocalMediaMessage = [mediaMessages lastObject];
            self.mediaLastCreated = [lastLocalMediaMessage.created stringValue];
            if (mediaMessages.count < 50) {
                self.allLocalMediasLoaded = YES;
            }
            
        } failure:^(NSError *error) {
            
        }];
    }
    else if (self.shareMediaTabType == TAPShareMediaTabTypeLink && indexPath.row == [self.linksMessageArray count] - 25 && !self.allLocalLinksLoaded) {
        TAPMessageModel *lastMessage = (TAPMessageModel *)[self.linksMessageArray lastObject];
        [TAPDataManager getDatabaseLinkMessagesInRoomWithRoomID:self.room.roomID lastTimestamp:self.linkLastCreated numberOfItem:50 success:^(NSArray *linkMessages) {
            [self.linksMessageArray addObjectsFromArray:linkMessages];
            [self insertLinkSectionArray:self.linksMessageArray];
            [self.linksTableView reloadData];
            TAPMessageModel *lastLocalLinkMessage = [linkMessages lastObject];
            self.linkLastCreated = [lastLocalLinkMessage.created stringValue];
            if (linkMessages.count < 50) {
                self.allLocalLinksLoaded = YES;
            }
            
        } failure:^(NSError *error) {
            
        }];
    }
    else if (self.shareMediaTabType == TAPShareMediaTabTypeDocument && indexPath.row == [self.documentsMessageArray count] - 25 && !self.allLocalDocumentsLoaded) {
        TAPMessageModel *lastMessage = (TAPMessageModel *)[self.documentsMessageArray lastObject];
        [TAPDataManager getDatabaseFileMessagesInRoomWithRoomID:self.room.roomID lastTimestamp:self.documentLastCreated numberOfItem:50 success:^(NSArray *documentMessages) {
            [self.documentsMessageArray addObjectsFromArray:documentMessages];
            [self insertDocumentSectionArray:self.documentsMessageArray];
            [self.documentsTableView reloadData];
            TAPMessageModel *lastLocalDocumentMessage = [documentMessages lastObject];
            self.documentLastCreated = [lastLocalDocumentMessage.created stringValue];
            if (documentMessages.count < 50) {
                self.allLocalDocumentsLoaded = YES;
            }
            
        } failure:^(NSError *error) {
            
        }];
    }
    
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = @"TAPImageCollectionViewCell";
    [collectionView registerClass:[TAPImageCollectionViewCell class] forCellWithReuseIdentifier:cellID];

    TAPImageCollectionViewCell *cell = (TAPImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.delegate = self;
    
    NSMutableArray *sectionArray = [self.mediaMessageWithSectionArray objectAtIndex:indexPath.section];
    TAPMessageModel *message = [sectionArray objectAtIndex:indexPath.row];
    [cell setImageCollectionViewCellWithMessage:message];
    
    NSString *roomID = message.room.roomID;
    NSString *localID = message.localID;
    NSDictionary *dataDictionary = message.data;
    NSString *fileID = [dataDictionary objectForKey:@"fileID"];
    fileID = [TAPUtil nullToEmptyString:fileID];
    
    NSString *urlKey = [dataDictionary objectForKey:@"url"];
    if (urlKey == nil || [urlKey isEqualToString:@""]) {
        urlKey = [dataDictionary objectForKey:@"fileURL"];
    }
    urlKey = [TAPUtil nullToEmptyString:urlKey];
    
    if (![urlKey isEqualToString:@""]) {
        urlKey = [[urlKey componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
    }
    urlKey = [TAPUtil nullToEmptyString:urlKey];
    
    if (message.type == TAPChatMessageTypeImage) {
        [TAPImageView imageFromCacheWithMessage:message
        start:^(TAPMessageModel *receivedMessage) {
            
        }
        progress:^(CGFloat progress, CGFloat total, TAPMessageModel *receivedMessage) {
            
        }
        success:^(UIImage *fullImage, TAPMessageModel *receivedMessage) {
            [self setImageCollectionViewCell:cell image:fullImage message:receivedMessage];
        }
        failure:^(NSError *error, TAPMessageModel *receivedMessage) {
            [self setImageCollectionViewCell:cell image:nil message:receivedMessage];
        }];
        NSNumber *size = [message.data objectForKey:@"size"];
        if (size == nil || size.longValue <= 0) {
            [cell setInfoLabelWithString:@""];
        }
        else {
            NSString *fileSize = [NSByteCountFormatter stringFromByteCount:size.longValue countStyle:NSByteCountFormatterCountStyleBinary];
            [cell setInfoLabelWithString:fileSize];
        }
    }
    else if (message.type == TAPChatMessageTypeVideo) {
        NSNumber *duration = [message.data objectForKey:@"duration"];
        NSString *videoDurationString;
        if ([duration integerValue] > 0) {
            NSTimeInterval durationTimeInterval = [duration integerValue] / 1000; //convert to second
            videoDurationString = [TAPUtil stringFromTimeInterval:ceil(durationTimeInterval)];
        }
        else {
            videoDurationString = @"";
        }
        
        NSString *fileSize;
        NSNumber *size = [message.data objectForKey:@"size"];
        if (size == nil || size.longValue <= 0) {
            fileSize = @"";
        }
        else {
            fileSize = [NSByteCountFormatter stringFromByteCount:size.longValue countStyle:NSByteCountFormatterCountStyleBinary];
        }
        
        //Check video exist in cache
        
        //Check video is done downloaded or not
        NSString *filePath = [[TAPFileDownloadManager sharedManager] getDownloadedFilePathWithRoomID:roomID fileID:urlKey];
        if ([filePath isEqualToString:@""] || filePath == nil) {
            filePath = [[TAPFileDownloadManager sharedManager] getDownloadedFilePathWithRoomID:message.room.roomID fileID:fileID];
        }
        
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    CGSize headerSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 40.0f);
    return headerSize;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize cellSize = CGSizeMake((CGRectGetWidth([UIScreen mainScreen].bounds) - 24.0f) / 3.0f, (CGRectGetWidth([UIScreen mainScreen].bounds) - 24.0f) / 3.0f);
    return cellSize;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableArray *sectionArray = [self.mediaMessageWithSectionArray objectAtIndex:indexPath.section];
    TAPMessageModel *message = [sectionArray objectAtIndex:0];
    
    NSInteger monthInt = [self getMonthWithCreatedTime:message.created];
    NSDateFormatter *formate = [NSDateFormatter new];
    NSArray *monthNames = [formate standaloneMonthSymbols];
    NSString *monthName = [monthNames objectAtIndex:(monthInt - 1)];
    
    NSInteger yearInt = [self getYearWithCreatedTime:message.created];
    
    NSString *headerID = monthName;
    [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:kind withReuseIdentifier:headerID];
    
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerID forIndexPath:indexPath];
    
    [headerView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    if (indexPath.row == 0) {
        UICollectionViewLayoutAttributes *attributes = [collectionView layoutAttributesForItemAtIndexPath:indexPath];
        [headerView preferredLayoutAttributesFittingAttributes:attributes];
        
        headerView.backgroundColor = [UIColor whiteColor];
        
        UIView *seperatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(headerView.frame) - 8.0f, CGRectGetWidth(headerView.frame), 1.0f)];
        seperatorView.backgroundColor = [[TAPUtil getColor:@"191919"] colorWithAlphaComponent:0.1f];
        [headerView addSubview:seperatorView];
        
        if (indexPath.section != 0) {
            UIView *seperatorViewTop = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(headerView.frame), 1.0f)];
            seperatorViewTop.backgroundColor = [[TAPUtil getColor:@"191919"] colorWithAlphaComponent:0.1f];
            [headerView addSubview:seperatorViewTop];
        }
    
        UILabel *monthLabel = [[UILabel alloc]initWithFrame:CGRectMake(24.0f, 0.0f, 200, 32)];
        monthLabel.text = [NSString stringWithFormat:@"%@ %ld", monthName, yearInt];
        monthLabel.textColor = [UIColor blackColor];
        monthLabel.textColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorSharedMediaSectionHeaderLabel];
        monthLabel.font = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontChatProfileSharedMediaSectionLabel];
        
        [headerView addSubview:monthLabel];
    }
    
    return headerView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *sectionArray = [self.mediaMessageWithSectionArray objectAtIndex:indexPath.section];
    TAPMessageModel *selectedMessage = [sectionArray objectAtIndex:indexPath.row];
    
    NSArray *messageArray = [sectionArray copy];
    NSInteger currentRowIndex = [messageArray indexOfObject:selectedMessage];
    
    TAPImageCollectionViewCell *cell = (TAPImageCollectionViewCell *)[self.mediaCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currentRowIndex inSection:indexPath.section]];

    
    if (selectedMessage.type == TAPChatMessageTypeImage) {
        CGFloat bubbleImageViewMinY = 0.0f;
        
        TAPMediaDetailViewController *mediaDetailViewController = [[TAPMediaDetailViewController alloc] init];
        [mediaDetailViewController setMediaDetailViewControllerType:TAPMediaDetailViewControllerTypeImage];
        mediaDetailViewController.delegate = self;
        mediaDetailViewController.message = cell.currentMessage;
        
        UIImage *cellImage = cell.imageView.image;
        NSArray *imageSliderImage = [NSArray array];
        if (cellImage != nil) {
            imageSliderImage = @[cellImage];
            TAPMessageModel *currentMessage = cell.currentMessage;
            NSString *cellImageURLString = [TAPUtil nullToEmptyString:[cell.currentMessage.data objectForKey:@"fileID"]];
            
            NSString *fileID = [cell.currentMessage.data objectForKey:@"fileID"];
            fileID = [TAPUtil nullToEmptyString:fileID];
            
            [mediaDetailViewController setThumbnailImageArray:imageSliderImage];
            [mediaDetailViewController setImageArray:@[cellImage]];
            
            [mediaDetailViewController setActiveIndex:0];
            
            NSInteger selectedRow = [sectionArray indexOfObject:cell.currentMessage];
            NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForItem:selectedRow inSection:1];
            
            UICollectionViewLayoutAttributes *attributes = [self.mediaCollectionView layoutAttributesForItemAtIndexPath:indexPath];

            CGRect cellRectInCollectionView = attributes.frame;
            
            CGRect cellRectInView = [self.mediaCollectionView convertRect:cellRectInCollectionView toView:self.view];

            [mediaDetailViewController showToViewController:self.navigationController thumbnailImage:cellImage thumbnailFrame:cellRectInView];
            cell.imageView.alpha = 0.0f;
            cell.thumbnailImageView.alpha = 0.0f;
            _openedBubbleCell = cell;
        }

    }
    if (selectedMessage.type == TAPChatMessageTypeVideo) {
        NSDictionary *dataDictionary = selectedMessage.data;
        dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];
        
        NSString *key = [dataDictionary objectForKey:@"fileID"];
        key = [TAPUtil nullToEmptyString:key];
        
        NSString *filePath = [[TAPFileDownloadManager sharedManager] getDownloadedFilePathWithRoomID:selectedMessage.room.roomID fileID:key];
        
        if (filePath == nil || [filePath isEqualToString:@""]) {
            NSString *fileURL = [dataDictionary objectForKey:@"url"];
            if (fileURL == nil || [fileURL isEqualToString:@""]) {
                fileURL = [dataDictionary objectForKey:@"fileURL"];
            }
            fileURL = [TAPUtil nullToEmptyString:fileURL];
            
            if (![fileURL isEqualToString:@""]) {
                key = fileURL;
                key = [[key componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
            }
            
            filePath = [[TAPFileDownloadManager sharedManager] getDownloadedFilePathWithRoomID:selectedMessage.room.roomID fileID:key];
        }
        
        if (filePath == nil || [filePath isEqualToString:@""]) {
            return;
        }
        
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


#pragma mark TableView
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.linksTableView) {
        NSMutableArray *sectionArray = [self.linkMessageWithSectionArray objectAtIndex:section];
        return sectionArray.count;
    }
    else if (tableView == self.documentsTableView) {
        NSMutableArray *sectionArray = [self.documentMessageWithSectionArray objectAtIndex:section];
        return sectionArray.count;
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.linksTableView) {
        return [self.linkMessageWithSectionArray count];
    }
    else if (tableView == self.documentsTableView) {
        return [self.documentMessageWithSectionArray count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    return 32.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    
    UILabel *monthLabel = [[UILabel alloc]initWithFrame:CGRectMake(24.0f, 0.0f, 200, 32)];
    monthLabel.textColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorSharedMediaSectionHeaderLabel];
    monthLabel.font = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontChatProfileSharedMediaSectionLabel];
    [view addSubview:monthLabel];
    
    NSMutableArray *sectionArray = nil;
    
    if (tableView == self.linksTableView) {
        sectionArray = [self.linkMessageWithSectionArray objectAtIndex:section];
    }
    else if (tableView == self.documentsTableView) {
        sectionArray = [self.documentMessageWithSectionArray objectAtIndex:section];
    }
    else{
        return view;
    }
    
    TAPMessageModel *message = [sectionArray objectAtIndex:0];
    NSInteger monthInt = [self getMonthWithCreatedTime:message.created];
    NSDateFormatter *formate = [NSDateFormatter new];
    NSArray *monthNames = [formate standaloneMonthSymbols];
    NSString *monthName = [monthNames objectAtIndex:(monthInt - 1)];
    
    NSInteger yearInt = [self getYearWithCreatedTime:message.created];
    
    monthLabel.text = [NSString stringWithFormat:@"%@ %ld", monthName, yearInt];
    return view;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (tableView == self.linksTableView) {
        [tableView registerNib:[TAPLinksShareMediaTableViewCell cellNib] forCellReuseIdentifier:[TAPLinksShareMediaTableViewCell description]];
        TAPLinksShareMediaTableViewCell *cell = (TAPLinksShareMediaTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPLinksShareMediaTableViewCell description] forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = YES;
        cell.contentView.userInteractionEnabled = YES;
        cell.delegate = self;
        
        NSMutableArray *sectionArray = [self.linkMessageWithSectionArray objectAtIndex:indexPath.section];
        
        TAPMessageModel *message = [sectionArray objectAtIndex:indexPath.row];
        NSArray<NSString *> *urls = [message.data objectForKey:@"urls"];
        NSString *urlString = [message.data objectForKey:@"url"];
        NSString *text = @"";
        if (![TAPUtil isEmptyArray:urls]) {
            for (NSString * url in urls) {
                if (![TAPUtil isEmptyString:text]) {
                    text = [NSString stringWithFormat:@"%@\n", text];
                }
                text = [NSString stringWithFormat:@"%@%@", text, url];
            }
        }
        else {
            text = [TAPUtil nullToEmptyString:urlString];
        }
        [cell setLinkLabelWithString:text];
        cell.message = message;
        [cell setGrayHighlightColor];
        
        return cell;
    }
    else if (tableView == self.documentsTableView) {
        [tableView registerNib:[TAPDocumentShareMediaTableViewCell cellNib] forCellReuseIdentifier:[TAPDocumentShareMediaTableViewCell description]];
        TAPDocumentShareMediaTableViewCell *cell = (TAPDocumentShareMediaTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPDocumentShareMediaTableViewCell description] forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = YES;
        cell.contentView.userInteractionEnabled = YES;
        cell.delegate = self;
        
        NSMutableArray *sectionArray = [self.documentMessageWithSectionArray objectAtIndex:indexPath.section];
        
        TAPMessageModel *message = [sectionArray objectAtIndex:indexPath.row];
        [cell setDocumentTitleInfoWithMessage:message];
        cell.message = message;
        
        
        if (message != nil) {
            NSDictionary *dataDictionary = message.data;
            NSString *localID = message.localID;
            NSString *roomID = message.room.roomID;
            
            if (message.isFailedSend) {
                //Update view to failed send
                [cell animateFailedUploadFile];
            }
            else {
                NSInteger status = [[TAPFileUploadManager sharedManager] obtainUploadStatusWithMessage:message];
                // 0 is not found
                // 1 is uploading
                // 2 is waiting for upload
                if (status != 0) {
                    //Set current progress
                    NSDictionary *uploadProgressDictionary = [[TAPFileUploadManager sharedManager] getUploadProgressWithLocalID:message.localID];
                    [cell showFileBubbleStatusWithType:TAPDocumentShareManagerStateTypeUploading];
                    if (uploadProgressDictionary == nil) {
                        CGFloat progress = [[uploadProgressDictionary objectForKey:@"progress"] floatValue];
                        CGFloat total = [[uploadProgressDictionary objectForKey:@"total"] floatValue];
                        
                        [cell animateProgressUploadingFileWithProgress:progress total:total];
                    }
                }
                else {
                    //Check file is done downloaded or not
                    NSDictionary *dataDictionary = message.data;
                    dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];
                    
                    NSString *key = [dataDictionary objectForKey:@"fileID"];
                    key = [TAPUtil nullToEmptyString:key];
                    
                    NSString *filePath = [[TAPFileDownloadManager sharedManager] getDownloadedFilePathWithRoomID:message.room.roomID fileID:key];
                    
                    if (filePath == nil || [filePath isEqualToString:@""]) {
                        NSString *fileURL = [dataDictionary objectForKey:@"url"];
                        if (fileURL == nil || [fileURL isEqualToString:@""]) {
                            fileURL = [dataDictionary objectForKey:@"fileURL"];
                        }
                        fileURL = [TAPUtil nullToEmptyString:fileURL];
                        
                        if (![fileURL isEqualToString:@""]) {
                            key = fileURL;
                            key = [[key componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
                        }
                        
                        filePath = [[TAPFileDownloadManager sharedManager] getDownloadedFilePathWithRoomID:message.room.roomID fileID:key];
                    }
                    
                    if (filePath == nil || [filePath isEqualToString:@""]) {
                        NSDictionary *downloadProgressDictionary = [[TAPFileDownloadManager sharedManager] getDownloadProgressWithLocalID:message.localID];
                        if (downloadProgressDictionary != nil) {
                            // Show downloading in progress
                            CGFloat progress = [[downloadProgressDictionary objectForKey:@"progress"] floatValue];
                            CGFloat total = [[downloadProgressDictionary objectForKey:@"total"] floatValue];
                            
                            [cell showFileBubbleStatusWithType:TAPDocumentShareManagerStateTypeDownloading];
                            [cell animateProgressDownloadingFileWithProgress:progress total:total];
                        }
                        else if ([[TAPFileDownloadManager sharedManager] checkFailedDownloadWithLocalID:message.localID]) {
                            //previous download fail, show retry
                            [cell showFileBubbleStatusWithType:TAPDocumentShareManagerStateTypeRetryDownload];
                        }
                        else {
                            //show download
                            [cell showDownloadedState:NO];
                        }
                    }
                    else {
                        //File exist, show downloaded file
                        [cell showDownloadedState:YES];
                    }
                }
            }
        }
        [cell setGrayHighlightColor];
        
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.documentsTableView) {
        return 56.0f;
    }
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (tableView == self.documentsTableView) {
        if (section == [self.documentMessageWithSectionArray count] - 1) {
            return FLT_MIN;
        }
        else{
            return 4.0f;
        }
    }
    else if (tableView == self.linksTableView) {
        if (section == [self.linkMessageWithSectionArray count] - 1) {
            return FLT_MIN;
        }
        else{
            return 4.0f;
        }
    }
    return 4.0f;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
   
    view.backgroundColor = [TAPUtil getColor:@"F3F3F3"];
   
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == self.linksTableView) {
        // present in app web view, the app is not installed
        NSMutableArray *sectionArray = [self.linkMessageWithSectionArray objectAtIndex:indexPath.section];
        TAPMessageModel *message = [sectionArray objectAtIndex:indexPath.row];
        if (message == nil) {
            return;
        }
        NSString *urlString = [message.data objectForKey:@"url"];
        if ([TAPUtil isEmptyString:urlString]) {
            NSArray<NSString *> *urls = [message.data objectForKey:@"urls"];
            if (![TAPUtil isEmptyArray:urls]) {
                urlString = [urls objectAtIndex:0];
            }
        }
        if ([TAPUtil isEmptyString:urlString]) {
            return;
        }
        NSURL *url = [NSURL URLWithString:urlString];
        [self openUrl:url];
    }
    else if (tableView == self.documentsTableView) {
        
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.shareMediaTabType == TAPShareMediaTabTypeLink && indexPath.row == [self.linksMessageArray count] - 25 && !self.allLocalLinksLoaded) {
        TAPMessageModel *lastMessage = (TAPMessageModel *)[self.linksMessageArray lastObject];
        [TAPDataManager getDatabaseLinkMessagesInRoomWithRoomID:self.room.roomID lastTimestamp:self.linkLastCreated numberOfItem:50 success:^(NSArray *linkMessages) {
            [self.linksMessageArray addObjectsFromArray:linkMessages];
            [self insertLinkSectionArray:self.linksMessageArray];
            [self.linksTableView reloadData];
            TAPMessageModel *lastLocalLinkMessage = [linkMessages lastObject];
            self.linkLastCreated = [lastLocalLinkMessage.created stringValue];
            if (linkMessages.count < 50) {
                self.allLocalLinksLoaded = YES;
            }
            
        } failure:^(NSError *error) {
            
        }];
    }
    else if (self.shareMediaTabType == TAPShareMediaTabTypeDocument && indexPath.row == [self.documentsMessageArray count] - 25 && !self.allLocalDocumentsLoaded) {
        TAPMessageModel *lastMessage = (TAPMessageModel *)[self.documentsMessageArray lastObject];
        [TAPDataManager getDatabaseFileMessagesInRoomWithRoomID:self.room.roomID lastTimestamp:self.documentLastCreated numberOfItem:50 success:^(NSArray *documentMessages) {
            [self.documentsMessageArray addObjectsFromArray:documentMessages];
            [self insertDocumentSectionArray:self.documentsMessageArray];
            [self.documentsTableView reloadData];
            TAPMessageModel *lastLocalDocumentMessage = [documentMessages lastObject];
            self.documentLastCreated = [lastLocalDocumentMessage.created stringValue];
            if (documentMessages.count < 50) {
                self.allLocalDocumentsLoaded = YES;
            }
            
        } failure:^(NSError *error) {
            
        }];
    }
}

#pragma mark TAPLinkShareManagerCellDelegate

- (void)linkShareManagerLongPressedWithMessage:(TAPMessageModel *)longPressedMessage {
    [self handleLongPressWithMessage:longPressedMessage];
}

- (void)sharedLinkUrlDidTappedWithMessage:(TAPMessageModel *)message url:(NSURL *)url {
    [self openUrl:url];
}

- (void)sharedLinkUrlDidLongPressedWithMessage:(TAPMessageModel *)message url:(NSURL *)url {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:url.absoluteString];
    [self showSnackBar:TapTalkSnackBarTypeToast
               message:NSLocalizedStringFromTableInBundle(@"Link copied.", nil, [TAPUtil currentBundle], @"")
              iconName:@""];
}

#pragma mark TAPDocumentShareManagerCellDelegate
- (void)documentShareManagerOpenFileButtonDidTapped:(TAPMessageModel *)tappedMessage {
    [self openFilePreviewViewControllerWithMessage:tappedMessage];
}

- (void)documentShareManagerLongPressedWithMessage:(TAPMessageModel *)longPressedMessage {
    [self handleLongPressWithMessage:longPressedMessage];
}

- (void)documentShareManagerDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage {
    [self fetchFileDataWithMessage:tappedMessage];
}

#pragma mark QLPreviewController
- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller {
    return 1;
}

- (id <QLPreviewItem>) previewController:(QLPreviewController *)controller previewItemAtIndex: (NSInteger) index {
    return self.currentSelectedFileURL;
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
    TAPMessageModel *currentMessage = [self.messageDataDictionary objectForKey:message.localID];
    NSInteger section = [self getSectionWithArray:self.mediaMessageWithSectionArray message:currentMessage];
    NSMutableArray *sectionArray = [self.mediaMessageWithSectionArray objectAtIndex:section];
    NSInteger currentRowIndex = [sectionArray indexOfObject:currentMessage];
    
    TAPImageCollectionViewCell *cell = (TAPImageCollectionViewCell *)[self.mediaCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currentRowIndex inSection:section]];
    [cell animateFailedDownloadingMedia];
}

- (void)imageCollectionViewCellLongPressedWithMessage:(TAPMessageModel *)longPressedMessage {
    [self handleLongPressWithMessage:longPressedMessage];
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
        
        TAPMessageModel *currentMessage = [self.messageDataDictionary objectForKey:localID];
        TAPChatMessageType type = currentMessage.type;
        
        if (type == TAPChatMessageTypeFile) {
            NSInteger section = [self getSectionWithArray:self.documentMessageWithSectionArray message:currentMessage];
            
            NSMutableArray *messageArray = [self.documentMessageWithSectionArray objectAtIndex:section];
            NSInteger currentRowIndex = [messageArray indexOfObject:currentMessage];
            
            TAPDocumentShareMediaTableViewCell *cell = (TAPDocumentShareMediaTableViewCell *)[self.documentsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:section]];
            [cell animateProgressDownloadingFileWithProgress:progress total:total];
        }
        else{
            NSInteger section = [self getSectionWithArray:self.mediaMessageWithSectionArray message:currentMessage];
            
            NSMutableArray *messageArray = [self.mediaMessageWithSectionArray objectAtIndex:section];
            NSInteger currentRowIndex = [messageArray indexOfObject:currentMessage];
            
            TAPImageCollectionViewCell *cell = (TAPImageCollectionViewCell *)[self.mediaCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currentRowIndex inSection:section]];
            if (type == TAPChatMessageTypeImage) {
                [cell animateProgressDownloadingMediaWithProgress:progress total:total];
            }
            else if (type == TAPChatMessageTypeVideo) {
                [cell animateProgressDownloadingMediaWithProgress:progress total:total];
            }
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
        
        TAPMessageModel *currentMessage = [self.messageDataDictionary objectForKey:localID];
        TAPChatMessageType type = currentMessage.type;
        
        if (type == TAPChatMessageTypeFile) {
            NSInteger section = [self getSectionWithArray:self.documentMessageWithSectionArray message:currentMessage];
            NSMutableArray *messageArray = [self.documentMessageWithSectionArray objectAtIndex:section];
            NSInteger currentRowIndex = [messageArray indexOfObject:currentMessage];
            
            TAPDocumentShareMediaTableViewCell *cell = (TAPDocumentShareMediaTableViewCell *)[self.documentsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:section]];
            [cell showFileBubbleStatusWithType:TAPDocumentShareManagerStateTypeUploading];
        }
        else{
            NSInteger section = [self getSectionWithArray:self.mediaMessageWithSectionArray message:currentMessage];
            NSMutableArray *messageArray = [self.mediaMessageWithSectionArray objectAtIndex:section];
            NSInteger currentRowIndex = [messageArray indexOfObject:currentMessage];
            
            TAPImageCollectionViewCell *cell = (TAPImageCollectionViewCell *)[self.mediaCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currentRowIndex inSection:section]];

            if (type == TAPChatMessageTypeImage) {
                [cell setInitialAnimateDownloadingMedia];
            }
            else if (type == TAPChatMessageTypeVideo) {
                [cell setInitialAnimateDownloadingMedia];
            }
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
        
        TAPMessageModel *currentMessage = [self.messageDataDictionary objectForKey:localID];
        TAPChatMessageType type = currentMessage.type;
        
        if (type == TAPChatMessageTypeFile) {
            NSInteger section = [self getSectionWithArray:self.documentMessageWithSectionArray message:currentMessage];
            NSMutableArray *messageArray = [self.documentMessageWithSectionArray objectAtIndex:section];
            NSInteger currentRowIndex = [messageArray indexOfObject:currentMessage];
            TAPDocumentShareMediaTableViewCell *cell = (TAPDocumentShareMediaTableViewCell *)[self.documentsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:section]];
            
            if (!currentMessage.isFailedSend) {
                [cell animateFinishedDownloadFile];
            }
            else {
                [cell animateFailedUploadFile];
            }
        }
        else{
            NSInteger section = [self getSectionWithArray:self.mediaMessageWithSectionArray message:currentMessage];
            NSMutableArray *messageArray = [self.mediaMessageWithSectionArray objectAtIndex:section];
            NSInteger currentRowIndex = [messageArray indexOfObject:currentMessage];
            
            TAPImageCollectionViewCell *cell = (TAPImageCollectionViewCell *)[self.mediaCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currentRowIndex inSection:section]];
            
            if (type == TAPChatMessageTypeImage) {
                UIImage *fullImage = [notificationParameterDictionary objectForKey:@"fullImage"];

                if (fullImage != nil) {
                    [cell setImageCollectionViewCellImageWithImage:fullImage];
                }
                [cell animateFinishedDownloadingMedia];
                [cell setAsDownloaded];
            }
            else if (type == TAPChatMessageTypeVideo) {
                [cell animateFinishedDownloadingMedia];
                [cell setAsDownloaded];
                NSNumber *duration = [currentMessage.data objectForKey:@"duration"];
                NSString *videoDurationString;
                if ([duration integerValue] > 0) {
                    NSTimeInterval durationTimeInterval = [duration integerValue] / 1000; //convert to second
                    videoDurationString = [TAPUtil stringFromTimeInterval:ceil(durationTimeInterval)];
                }
                else {
                    videoDurationString = @"";
                }
                [cell setInfoLabelWithString:videoDurationString];
                [cell setThumbnailImageForVideoWithMessage:currentMessage];
            }
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
        
        TAPMessageModel *currentMessage = [self.messageDataDictionary objectForKey:localID];
        
        TAPChatMessageType type = currentMessage.type;
        
        if (type == TAPChatMessageTypeFile) {
            NSInteger section = [self getSectionWithArray:self.documentMessageWithSectionArray message:currentMessage];
            NSMutableArray *messageArray = [self.documentMessageWithSectionArray objectAtIndex:section];
            NSInteger currentRowIndex = [messageArray indexOfObject:currentMessage];
            if (error.code == NSURLErrorCancelled) {
                    //My Chat
                TAPDocumentShareMediaTableViewCell *cell = (TAPDocumentShareMediaTableViewCell *)[self.documentsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:section]];
                    [self.documentsTableView performBatchUpdates:^{
                        //changing beginUpdates and endUpdates with this because of deprecation
                        [cell animateCancelDownloadFile];
                    } completion:^(BOOL finished) {
                    }];
                
               
            } else {
                TAPDocumentShareMediaTableViewCell *cell = (TAPDocumentShareMediaTableViewCell *)[self.documentsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:section]];
                    [cell animateFailedDownloadFile];
            }
        }
        else{
            NSInteger section = [self getSectionWithArray:self.mediaMessageWithSectionArray message:currentMessage];
            NSMutableArray *messageArray = [self.mediaMessageWithSectionArray objectAtIndex:section];
            NSInteger currentRowIndex = [messageArray indexOfObject:currentMessage];
            
            TAPImageCollectionViewCell *cell = (TAPImageCollectionViewCell *)[self.mediaCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currentRowIndex inSection:section]];
            
            NSString *fileSize;
            NSNumber *size = [currentMessage.data objectForKey:@"size"];
            if (size == nil || size.longValue <= 0) {
                fileSize = @"";
            }
            else {
                fileSize = [NSByteCountFormatter stringFromByteCount:size.longValue countStyle:NSByteCountFormatterCountStyleBinary];
            }
            
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
        }
        
        
    });
}

#pragma mark - Custom Method

- (void)mediaTabButtonDidTapped {
    self.shareMediaTabType = TAPShareMediaTabTypeMedia;
    if (!self.allLocalMediasLoaded) {
        [TAPDataManager getDatabaseMediaMessagesInRoomWithRoomID:self.room.roomID lastTimestamp:@"" numberOfItem:50 success:^(NSArray *mediaMessages) {
            _mediaMessageArray = [mediaMessages mutableCopy];
            [self insertMediaSectionArray:mediaMessages];
            [self.mediaCollectionView reloadData];
            TAPMessageModel *lastLocalMediaMessage = [mediaMessages lastObject];
            self.mediaLastCreated = [lastLocalMediaMessage.created stringValue];
            if (mediaMessages.count < 50) {
                self.allLocalMediasLoaded = YES;
                [self callApiLoad];
            }
        } failure:^(NSError *error) {
            
        }];
    }
    else{
        if (self.isRemoteContentFetched) {
            [self insertLoadMoreData];
            
            if (self.mediaMessageArray.count == 0) {
                self.emptyStateView.alpha = 1.0f;
            }
            else{
                self.emptyStateView.alpha = 0.0f;
            }
        }
    }

    self.mediaIndicatorView.alpha = 1.0f;
    self.linksIndicatorView.alpha = 0.0f;
    self.documentsIndicatorView.alpha = 0.0f;
    
    self.mediaLabel.font = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontChatProfileSharedMediaTabActiveLabel];
    self.linksLabel.font = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontTableViewSectionHeaderLabel];
    self.documentsLabel.font = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontTableViewSectionHeaderLabel];
    
    self.mediaTabWidthConstraint.constant = self.screenSizeWidth;
    self.linksTabWidthConstraint.constant = 0.0f;
    self.documentsTabWidthConstraint.constant = 0.0f;
    
    [TAPUtil performBlock:^{
        [self.mediaCollectionView reloadData];
    } afterDelay:0.5f];
    
}

- (void)linksTabButtonDidTapped {
    self.shareMediaTabType = TAPShareMediaTabTypeLink;
    if (!self.allLocalLinksLoaded) {
        [TAPDataManager getDatabaseLinkMessagesInRoomWithRoomID:self.room.roomID lastTimestamp:@"" numberOfItem:50 success:^(NSArray *linkMessages) {
            _linksMessageArray = [linkMessages mutableCopy];
            [self insertLinkSectionArray:linkMessages];
            [self.linksTableView reloadData];
            TAPMessageModel *lastLocalLinkMessage = [linkMessages lastObject];
            self.linkLastCreated = [lastLocalLinkMessage.created stringValue];
            if (linkMessages.count < 50) {
                self.allLocalLinksLoaded = YES;
                [self callApiLoad];
            }
            
        } failure:^(NSError *error) {
                
        }];
    }
    else{
        if (self.isRemoteContentFetched) {
            [self insertLoadMoreData];
            
            if (self.linksMessageArray.count == 0) {
                self.emptyStateView.alpha = 1.0f;
            }
            else{
                self.emptyStateView.alpha = 0.0f;
            }
        }
    }
    
    
    
    self.mediaIndicatorView.alpha = 0.0f;
    self.linksIndicatorView.alpha = 1.0f;
    self.documentsIndicatorView.alpha = 0.0f;
    
    self.mediaLabel.font = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontTableViewSectionHeaderLabel];
    self.linksLabel.font = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontChatProfileSharedMediaTabActiveLabel];
    self.documentsLabel.font = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontTableViewSectionHeaderLabel];
    
    self.mediaTabWidthConstraint.constant = 0.0f;
    self.linksTabWidthConstraint.constant = self.screenSizeWidth;
    self.documentsTabWidthConstraint.constant = 0.0f;
    
}

- (void)documentsTabButtonDidTapped {
    self.shareMediaTabType = TAPShareMediaTabTypeDocument;
    if (!self.allLocalDocumentsLoaded) {
        [TAPDataManager getDatabaseFileMessagesInRoomWithRoomID:self.room.roomID lastTimestamp:@"" numberOfItem:50 success:^(NSArray *fileMessages) {
            _documentsMessageArray = [fileMessages mutableCopy];
            [self insertDocumentSectionArray:fileMessages];
            [self.documentsTableView reloadData];
            TAPMessageModel *lastLocalFileMessage = [fileMessages lastObject];
            self.documentLastCreated = [lastLocalFileMessage.created stringValue];
            if (fileMessages.count < 50) {
                self.allLocalDocumentsLoaded = YES;
                [self callApiLoad];
            }
            
        } failure:^(NSError *error) {
            
        }];
    }
    else {
        if (self.isRemoteContentFetched) {
            [self insertLoadMoreData];
            
            if (self.documentsMessageArray.count == 0) {
                self.emptyStateView.alpha = 1.0f;
            }
            else{
                self.emptyStateView.alpha = 0.0f;
            }
        }
    }
    
   
    
    self.mediaIndicatorView.alpha = 0.0f;
    self.linksIndicatorView.alpha = 0.0f;
    self.documentsIndicatorView.alpha = 1.0f;
    
    self.mediaLabel.font = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontTableViewSectionHeaderLabel];
    self.linksLabel.font = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontTableViewSectionHeaderLabel];
    self.documentsLabel.font = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontChatProfileSharedMediaTabActiveLabel];
    
    self.mediaTabWidthConstraint.constant = 0.0f;
    self.linksTabWidthConstraint.constant = 0.0f;
    self.documentsTabWidthConstraint.constant = self.screenSizeWidth;
}

- (void)callApiLoad {
    if (!self.isRemoteContentFetched) {
        [TAPDataManager getDatabaseOldestCreatedTimeFromRoom:self.room.roomID success:^(NSNumber *createdTime) {
            long oldestCreatedTime = [createdTime longValue];
            [TAPDataManager callAPIGetSharedContent:self.room.roomID maxCreated:oldestCreatedTime  minCreated:0 success:^(NSArray <TAPMessageModel *> *mediaMessagesArray, NSArray <TAPMessageModel *> *linkMessagesArray, NSArray <TAPMessageModel *> *fileMessagesArray) {
                
                self.isRemoteContentFetched = YES;
                
                if (mediaMessagesArray.count > 0) {
                    self.remoteMediaArray = mediaMessagesArray;
                }
                
                if (fileMessagesArray.count > 0) {
                    self.remoteDocumentsMessageArray = fileMessagesArray;
                }
                
                if (linkMessagesArray.count > 0) {
                    self.remoteLinksMessageArray = linkMessagesArray;
                }
                
                [self insertLoadMoreData];
                
            } failure:^(NSError *error) {
                
            }];
            
        }
        failure:^(NSError *error) {
            
        }];
    }
    else {
        [self insertLoadMoreData];
    }
    
}

- (void)insertLoadMoreData {
    if (self.shareMediaTabType == TAPShareMediaTabTypeMedia && !self.isMediaLoadMore) {
        self.isMediaLoadMore = YES;
        [self.mediaMessageArray addObjectsFromArray:self.remoteMediaArray];
        [self insertMediaSectionArray:self.mediaMessageArray];
        [self.mediaCollectionView reloadData];
        
        if (self.mediaMessageArray.count == 0) {
            self.emptyStateView.alpha = 1.0f;
        }
        else{
            self.emptyStateView.alpha = 0.0f;
        }
    }
    else if (self.shareMediaTabType == TAPShareMediaTabTypeLink && !self.isLinkLoadMore) {
        self.isLinkLoadMore = YES;
        [self.linksMessageArray addObjectsFromArray:self.remoteLinksMessageArray];
        [self insertLinkSectionArray:self.linksMessageArray];
        [self.linksTableView reloadData];
        
        if (self.linksMessageArray.count == 0) {
            self.emptyStateView.alpha = 1.0f;
        }
        else{
            self.emptyStateView.alpha = 0.0f;
        }
    }
    else if (self.shareMediaTabType == TAPShareMediaTabTypeDocument && !self.isDocumentLoadMore) {
        self.isDocumentLoadMore = YES;
        [self.documentsMessageArray addObjectsFromArray:self.remoteDocumentsMessageArray];
        [self insertDocumentSectionArray:self.documentsMessageArray];
        [self.documentsTableView reloadData];
        
        if (self.documentsMessageArray.count == 0) {
            self.emptyStateView.alpha = 1.0f;
        }
        else{
            self.emptyStateView.alpha = 0.0f;
        }
    }
}

- (void)insertMediaSectionArray:(NSMutableArray *)messageArray {
    [self.mediaMessageWithSectionArray removeAllObjects];
    NSInteger month = 0;
    NSInteger section = -1;
    NSMutableArray *sectionArray = [[NSMutableArray alloc] init];
    for(TAPMessageModel *message in messageArray) {
        NSInteger createdMonth = [self getMonthWithCreatedTime:message.created];
        [self.messageDataDictionary setObject:message forKey:message.localID];
        
        if (createdMonth == month) {
            NSMutableArray *sectionArray = [self.mediaMessageWithSectionArray objectAtIndex:section];
            [sectionArray addObject:message];
        }
        else{
            month = createdMonth;
            section += 1;
            [self.mediaMessageWithSectionArray addObject:[[NSMutableArray alloc] init]];
            NSMutableArray *sectionArray = [self.mediaMessageWithSectionArray objectAtIndex:section];
            [sectionArray addObject:message];
            
        }
        
    }
}

- (void)insertLinkSectionArray:(NSMutableArray *)messageArray {
    [self.linkMessageWithSectionArray removeAllObjects];
    NSInteger month = 0;
    NSInteger section = -1;
    NSMutableArray *sectionArray = [[NSMutableArray alloc] init];
    for(TAPMessageModel *message in messageArray) {
        NSInteger createdMonth = [self getMonthWithCreatedTime:message.created];
        
        if (createdMonth == month) {
            NSMutableArray *sectionArray = [self.linkMessageWithSectionArray objectAtIndex:section];
            [sectionArray addObject:message];
        }
        else{
            month = createdMonth;
            section += 1;
            [self.linkMessageWithSectionArray addObject:[[NSMutableArray alloc] init]];
            NSMutableArray *sectionArray = [self.linkMessageWithSectionArray objectAtIndex:section];
            [sectionArray addObject:message];
            
        }
        
    }
}

- (void)insertDocumentSectionArray:(NSMutableArray *)messageArray {
    [self.documentMessageWithSectionArray removeAllObjects];
    NSInteger month = 0;
    NSInteger section = -1;
    NSMutableArray *sectionArray = [[NSMutableArray alloc] init];
    for(TAPMessageModel *message in messageArray) {
        NSInteger createdMonth = [self getMonthWithCreatedTime:message.created];
        [self.messageDataDictionary setObject:message forKey:message.localID];
        
        if (createdMonth == month) {
            NSMutableArray *sectionArray = [self.documentMessageWithSectionArray objectAtIndex:section];
            [sectionArray addObject:message];
        }
        else{
            month = createdMonth;
            section += 1;
            [self.documentMessageWithSectionArray addObject:[[NSMutableArray alloc] init]];
            NSMutableArray *sectionArray = [self.documentMessageWithSectionArray objectAtIndex:section];
            [sectionArray addObject:message];
            
        }
        
    }
}

- (void)handleLongPressWithMessage:(TAPMessageModel *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *viewChatAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedStringFromTableInBundle(@"View in Chat", nil, [TAPUtil currentBundle], @"")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
        [self.navigationController popViewControllerAnimated:NO];
        if ([self.delegate respondsToSelector:@selector(scrollToMessageShareMediaWithLocalID:)]) {
            [self.delegate scrollToMessageShareMediaWithLocalID:message.localID];
        }
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
                                       //Do some thing here
                                   }];
    
    UIImage *viewChatActionImage = [UIImage imageNamed:@"TAPIconViewChat" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    viewChatActionImage = [viewChatActionImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconSelectPictureCamera]];
    [viewChatAction setValue:[viewChatActionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    [viewChatAction setValue:@0 forKey:@"titleTextAlignment"];
    
    UIColor *actionSheetDefaultColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorActionSheetDefaultLabel];
    UIColor *actionSheetCancelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorActionSheetCancelButtonLabel];
    [viewChatAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
    [cancelAction setValue:actionSheetCancelColor forKey:@"titleTextColor"];
    
    [alertController addAction:viewChatAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}



- (void)openFilePreviewViewControllerWithMessage:(TAPMessageModel *)tappedMessage {
    NSString *roomID = tappedMessage.room.roomID;
    NSDictionary *dataDictionary = tappedMessage.data;
    dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];
    
    NSString *key = [dataDictionary objectForKey:@"fileID"];
    key = [TAPUtil nullToEmptyString:key];
    
    NSString *filePath = [[TAPFileDownloadManager sharedManager] getDownloadedFilePathWithRoomID:roomID fileID:key];
    
    if (filePath == nil || [filePath isEqualToString:@""]) {
        NSString *fileURL = [dataDictionary objectForKey:@"url"];
        if (fileURL == nil || [fileURL isEqualToString:@""]) {
            fileURL = [dataDictionary objectForKey:@"fileURL"];
        }
        fileURL = [TAPUtil nullToEmptyString:fileURL];
        
        if (![fileURL isEqualToString:@""]) {
            key = fileURL;
            key = [[key componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
        }
        
        filePath = [[TAPFileDownloadManager sharedManager] getDownloadedFilePathWithRoomID:roomID fileID:key];
    }
    
    if (filePath == nil || [filePath isEqualToString:@""]/* || ![[NSFileManager defaultManager] fileExistsAtPath:filePath]*/) {
       // [self showFileNotFoundPopUpWithMessage:tappedMessage];
        return;
    }
    
    self.currentSelectedFileURL = [NSURL fileURLWithPath:filePath];
    
    QLPreviewController *preview = [[QLPreviewController alloc] init];
    preview.dataSource = self;
    preview.delegate = self;
    
    [self presentViewController:preview animated:YES completion:nil];
}

- (void)fetchImageDataWithMessage:(TAPMessageModel *)message {
    [[TAPFileDownloadManager sharedManager] receiveImageDataWithMessage:message start:^(TAPMessageModel * _Nonnull receivedMessage) {
        //Already handled via Notification
    } progress:^(CGFloat progress, CGFloat total, TAPMessageModel * _Nonnull receivedMessage) {
        //Already handled via Notification
    } success:^(UIImage * _Nonnull fullImage, TAPMessageModel * _Nonnull receivedMessage, NSString * _Nullable filePath) {
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
    } success:^(NSData * _Nonnull fileData, TAPMessageModel * _Nonnull receivedMessage, NSString * _Nonnull filePath) {
        //Already handled via Notification
    } failure:^(NSError * _Nonnull error, TAPMessageModel * _Nonnull receivedMessage) {
        //Already handled via Notification
    }];
}

- (void)fetchFileDataWithMessage:(TAPMessageModel *)message {
    [[TAPFileDownloadManager sharedManager] receiveFileDataWithMessage:message start:^(TAPMessageModel * _Nonnull receivedMessage) {
        //Already Handled via Notification
    } progress:^(CGFloat progress, CGFloat total, TAPMessageModel * _Nonnull receivedMessage) {
        //Already Handled via Notification
    } success:^(NSData * _Nonnull fileData, TAPMessageModel * _Nonnull receivedMessage, NSString * _Nonnull filePath) {
        //Already Handled via Notification
    } failure:^(NSError * _Nonnull error, TAPMessageModel * _Nonnull receivedMessage) {
        //Already Handled via Notification
    }];
}

- (void)setImageCollectionViewCell:(TAPImageCollectionViewCell *)cell
                             image:(UIImage *)image
                           message:(TAPMessageModel *)message {
    
    NSString *currentRoomID = message.room.roomID;
    NSString *currentLocalID = message.localID;
    NSDictionary *currentDataDictionary = message.data;
    
    NSDictionary *progressDictionary = [[TAPFileDownloadManager sharedManager] getDownloadProgressWithLocalID:message.localID];

    //Check image exist in cache
    if (image != nil) {
        //Image exist
        //set as downloaded
        //set image
        [cell setImageCollectionViewCellImageWithImage:image];
        [cell setAsDownloaded];
    }
    //Check image is downloading
    else if (progressDictionary != nil) {
        CGFloat progress = [[progressDictionary objectForKey:@"progress"] floatValue];
        CGFloat total = [[progressDictionary objectForKey:@"total"] floatValue];
        [cell setInitialAnimateDownloadingMedia];
        
        NSString *fileSize;
        NSNumber *size = [message.data objectForKey:@"size"];
        if (size == nil || size.longValue <= 0) {
            fileSize = @"";
        }
        else {
            fileSize = [NSByteCountFormatter stringFromByteCount:size.longValue countStyle:NSByteCountFormatterCountStyleBinary];
        }
        [cell setInfoLabelWithString:fileSize];
        
        [cell animateProgressDownloadingMediaWithProgress:progress total:total];
    }
    else {
        //Image not exist in cache
        //if not show download button
        NSString *fileSize;
        NSNumber *size = [message.data objectForKey:@"size"];
        if (size == nil || size.longValue <= 0) {
            fileSize = @"";
        }
        else {
            fileSize = [NSByteCountFormatter stringFromByteCount:size.longValue countStyle:NSByteCountFormatterCountStyleBinary];
        }
        [cell setInfoLabelWithString:fileSize];
        [cell setAsNotDownloaded];
    }
}


- (NSInteger)getMonthWithCreatedTime:(NSNumber *)createdTime {
    NSTimeInterval messageTimeInterval = [createdTime doubleValue] / 1000.0f;
    NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:messageTimeInterval];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:messageDate];
    NSInteger month = [components month];
    
    return month;
}

- (NSInteger)getYearWithCreatedTime:(NSNumber *)createdTime {
    NSTimeInterval messageTimeInterval = [createdTime doubleValue] / 1000.0f;
    NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:messageTimeInterval];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:messageDate];
    NSInteger year = [components year];
    
    return year;
}

- (NSInteger)getSectionWithArray:(NSMutableArray *)array message:(TAPMessageModel *)mediaMessage {
    NSInteger mediaMonth = [self getMonthWithCreatedTime:mediaMessage.created];
    NSInteger mediaYear = [self getYearWithCreatedTime:mediaMessage.created];
    
    NSInteger counter = 0;
    for(NSMutableArray *messageArray in array) {
        TAPMessageModel *message = [messageArray objectAtIndex:0];
        NSInteger month = [self getMonthWithCreatedTime:message.created];
        NSInteger year = [self getYearWithCreatedTime:message.created];
        if (mediaMonth == month && mediaYear == year) {
            return counter;
        }
        counter += 1;
    }
    return 0;
}


- (void)setupNavigationView {
    //This method is used to setup the title view of navigation bar, and also bar button view
    
    //Title View
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - 56.0f - 56.0f, 43.0f)];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(titleView.frame), CGRectGetHeight(titleView.frame))];
    
    UIFont *chatRoomNameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontChatRoomNameLabel];
    UIColor *chatRoomNameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorChatRoomNameLabel];
    nameLabel.text = NSLocalizedStringFromTableInBundle(@"Shared Media", nil, [TAPUtil currentBundle], @"");
    nameLabel.textColor = chatRoomNameLabelColor;
    nameLabel.font = chatRoomNameLabelFont;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [titleView addSubview:nameLabel];
  
    
    [self.navigationItem setTitleView:titleView];
    
    //Back Bar Button
    UIImage *buttonImage = [UIImage imageNamed:@"TAPIconBackArrow" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    buttonImage = [buttonImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconNavigationBarBackButton]];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    TapBarButtonItem *barButtonItem = [[TapBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
}

- (void)openUrl:(NSURL *)url {
    if (url == nil) {
        return;
    }
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        if (IS_IOS_11_OR_ABOVE) {
            [[UIApplication sharedApplication] openURL:url
                                               options:@{UIApplicationOpenURLOptionUniversalLinksOnly: @YES}
                                     completionHandler:^(BOOL success) {
                                         if (!success) {
                                             // present in app web view, the app is not installed
                                             TAPWebViewViewController *webViewController = [[TAPWebViewViewController alloc] init];
                                             webViewController.urlString = url.absoluteString;
                                             //CS NOTE - add resign first responder before every pushVC to handle keyboard height
                                             
                                             [self keyboardWillHideWithHeight:0.0f];
                                             [self.navigationController pushViewController:webViewController animated:YES];
                                         }
                                     }];
        }
        else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

@end
