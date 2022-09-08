//
//  TAPStarredMessageViewController.m
//  TapTalk
//
//  Created by TapTalk.io on 21/03/22.
//

#import "TAPStarredMessageViewController.h"
#import "TAPMyChatBubbleTableViewCell.h"
#import "TAPYourChatBubbleTableViewCell.h"
#import "TAPMyFileBubbleTableViewCell.h"
#import "TAPYourFileBubbleTableViewCell.h"
#import "TAPMyImageBubbleTableViewCell.h"
#import "TAPYourImageBubbleTableViewCell.h"
#import "TAPMyLocationBubbleTableViewCell.h"
#import "TAPYourLocationBubbleTableViewCell.h"
#import "TAPMyVideoBubbleTableViewCell.h"
#import "TAPYourVideoBubbleTableViewCell.h"
#import "TAPMyVoiceNoteBubbleTableViewCell.h"
#import "TAPYourVoiceNoteBubbleTableViewCell.h"
#import "TAPMyChatDeletedBubbleTableViewCell.h"
#import "TAPYourChatDeletedBubbleTableViewCell.h"
#import "TAPMentionListXIBTableViewCell.h"
@interface TAPStarredMessageViewController ()<UITableViewDataSource, UITableViewDataSource,TAPMyChatBubbleTableViewCellDelegate, TAPYourChatBubbleTableViewCellDelegate, TAPMyImageBubbleTableViewCellDelegate, TAPYourImageBubbleTableViewCellDelegate, TAPMyLocationBubbleTableViewCellDelegate, TAPYourLocationBubbleTableViewCellDelegate, TAPMyFileBubbleTableViewCellDelegate, TAPYourFileBubbleTableViewCellDelegate, TAPMyVideoBubbleTableViewCellDelegate, TAPYourVideoBubbleTableViewCellDelegate, TAPMyVoiceNoteBubbleTableViewCellDelegate, TAPYourVoiceNoteBubbleTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, atomic) NSMutableDictionary *messageDictionary;
@property (weak, nonatomic) IBOutlet UIView *loadMoreMessageLoadingView;
@property (weak, nonatomic) IBOutlet UILabel *loadMoreMessageLoadingLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loadMoreMessageLoadingHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *loadMoreMessageLoadingViewImageView;
@property (weak, nonatomic) IBOutlet UIView *emptyStateView;
@property (weak, nonatomic) IBOutlet UILabel *emptyStateTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *emptyStateDescpLabel;

//pin message
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *unpinViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *unpinAllLabel;
@property (weak, nonatomic) IBOutlet UIImageView *unpinAllImageView;
@property (weak, nonatomic) IBOutlet UIButton *unpinAllButton;

//loading view
@property (weak, nonatomic) IBOutlet UIView *loadingBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIImageView *loadingImageView;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;



@property (nonatomic) CGFloat loadMoreMessageViewHeight;

- (void)fileDownloadManagerFinishNotification:(NSNotification *)notification;
- (void)addIncomingMessageToArrayAndDictionaryWithMessage:(TAPMessageModel *)message atIndex:(NSInteger)index;

@end

@implementation TAPStarredMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _messageDictionary = [NSMutableDictionary dictionary];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, 58.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - 10.0f);
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    [UIView commitAnimations];
    
    self.tableView.contentInset = UIEdgeInsetsMake(20.0f, 0.0f, 0.0f, 0.0f);
    self.tableView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorChatRoomBackground];
    
    UIFont *emptyTitleLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontInfoLabelSubtitle];
    UIColor *emptyTitleLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorInfoLabelSubtitle];
    UIFont *emptyTitleLabelBoldFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontInfoLabelSubtitleBold];
    UIColor *emptyTitleLabelBoldColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorInfoLabelSubtitleBold];
    
    self.emptyStateTitleLabel.font = emptyTitleLabelBoldFont;
    self.emptyStateTitleLabel.textColor = emptyTitleLabelBoldColor;
    self.emptyStateDescpLabel.font = emptyTitleLabelFont;
    self.emptyStateDescpLabel.textColor = emptyTitleLabelColor;
    
    self.loadingView.backgroundColor = [UIColor whiteColor];
    self.loadingView.layer.shadowRadius = 5.0f;
    self.loadingView.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f].CGColor;
    self.loadingView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.loadingView.layer.shadowOpacity = 1.0f;
    self.loadingView.layer.masksToBounds = NO;
    self.loadingView.layer.cornerRadius = 6.0f;
    self.loadingView.clipsToBounds = YES;
    
    
    [self setupNavigationView];
    if(self.messageListType == TAPUIMessageListTypeStar){
        [self showLoadMoreMessageLoadingView:YES];
        
        NSString *roomID = self.currentRoom.roomID;
        
        [TAPDataManager callAPIGetStarredMessages:roomID pageNumber:1 numberOfItems:50 success:^(NSArray *starredMessages, BOOL hasMore) {
            self.messageArray = starredMessages;
            for (TAPMessageModel *message in starredMessages){
                [self.messageDictionary setObject:message forKey:message.localID];
            }
            
            if(starredMessages.count == 0){
                self.emptyStateView.alpha = 1.0f;
            }
            
            [self.tableView reloadData];
            [self showLoadMoreMessageLoadingView:NO];
        } failure:^(NSError *error) {
            NSString *errorMessage = [error.userInfo objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            [self showLoadMoreMessageLoadingView:NO];
            [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Update Bio" title:NSLocalizedStringFromTableInBundle(@"Failed", nil, [TAPUtil currentBundle], @"") detailInformation:errorMessage leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
        }];
    }
    else if(self.messageListType == TAPUIMessageListTypePin){
        for (TAPMessageModel *message in self.messageArray){
            [self.messageDictionary setObject:message forKey:message.localID];
        }
        
        self.unpinAllLabel.textColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorChatRoomPinTitleLabel];
        self.unpinAllLabel.font = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontNavigationBarButtonLabel];
        
        self.unpinAllLabel.alpha = 1.0f;
        self.unpinAllImageView.alpha = 1.0f;
        self.unpinViewHeightConstraint.constant = 56.0f;
        
        [self.tableView setTransform:CGAffineTransformMakeRotation(-M_PI)];
        
        [self.unpinAllButton addTarget:self action:@selector(unPinAllButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileDownloadManagerFinishNotification:) name:TAP_NOTIFICATION_DOWNLOAD_FILE_FINISH object:nil];
}

- (void)setupNavigationView {
    //This method is used to setup the title view of navigation bar, and also bar button view
    
    //Title View
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - 56.0f - 56.0f, 43.0f)];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(titleView.frame), CGRectGetHeight(titleView.frame))];
    
    UIFont *chatRoomNameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontChatRoomNameLabel];
    UIColor *chatRoomNameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorChatRoomNameLabel];
    
    if(self.messageListType == TAPUIMessageListTypeStar){
        nameLabel.text = NSLocalizedStringFromTableInBundle(@"Starred Messages", nil, [TAPUtil currentBundle], @"");
    }
    else if(self.messageListType == TAPUIMessageListTypePin){
        nameLabel.text = NSLocalizedStringFromTableInBundle(@"Pinned Messages", nil, [TAPUtil currentBundle], @"");
    }
   // self.nameLabel.text = [NSString stringWithFormat:@"%ld Members", [self.room.participants count]];
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
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
}

#pragma mark - Data Source
#pragma mark UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    /**
    TAPMessageModel *currentMessage = [self.messageArray objectAtIndex:indexPath.row];
    if (currentMessage != nil) {
        BOOL isHidden = currentMessage.isHidden;
        if (isHidden) {
            //Set height = 0 for hidden message
            return 0.0f;
        }
    }
     */
    tableView.estimatedRowHeight = 70.0f;
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return FLT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TAPMessageModel *message = [self.messageArray objectAtIndex:indexPath.row];
    
    BOOL isSavedMessageRoom = [TAPUtil isSaveMessageRoom:self.currentRoom.roomID];
    BOOL isForwardedSavedMessage = NO;
    
    if((![message.forwardFrom.localID isEqualToString:@""] && message.forwardFrom != nil) && isSavedMessageRoom){
        isForwardedSavedMessage = YES;
    }
    
    if ([message.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID] && !isForwardedSavedMessage) {
        if (message.type == TAPChatMessageTypeText || message.type == TAPChatMessageTypeLink) {
            [tableView registerNib:[TAPMyChatBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPMyChatBubbleTableViewCell description]];
            TAPMyChatBubbleTableViewCell *cell = (TAPMyChatBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPMyChatBubbleTableViewCell description] forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.tag = indexPath.row;
            cell.contentView.tag = indexPath.row;
            cell.userInteractionEnabled = YES;
            cell.contentView.userInteractionEnabled = YES;
            cell.delegate = self;
            if(self.messageListType == TAPUIMessageListTypeStar){
                [cell setRotaionToDefault];
                [cell showStarMessageIconView];
                [cell showSeperator];
            }
            else if(self.messageListType == TAPUIMessageListTypePin){
                [cell showPinIcon:YES];
                [cell setSwipeGestureEnable:NO];
            }
            cell.isSwipeGestureOff = YES;
            
            cell.message = message;
            
            if (!message.isHidden) {
                [cell setMessage:message];
            }
            
            return cell;
            
        }
        else if (message.type == TAPChatMessageTypeImage) {
            //My Chat Image Message
            [tableView registerNib:[TAPMyImageBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPMyImageBubbleTableViewCell description]];
            TAPMyImageBubbleTableViewCell *cell = (TAPMyImageBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPMyImageBubbleTableViewCell description] forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.tag = indexPath.row;
            cell.contentView.tag = indexPath.row;
            cell.userInteractionEnabled = YES;
            cell.contentView.userInteractionEnabled = YES;
            cell.delegate = self;
            if(self.messageListType == TAPUIMessageListTypeStar){
                [cell setRotaionToDefault];
                [cell showStarMessageView];
                [cell showSeperatorView];
            }
            else if(self.messageListType == TAPUIMessageListTypePin){
                [cell showPinIcon:YES];
                [cell setSwipeGestureEnable:NO];
            }
            
            cell.message = message;
            
            [cell showStatusLabel:YES];
            
            if (!message.isHidden) {
                [cell setMessage:message];
            }
            
            if (message.isFailedSend) {
                //Update view to failed send
                
                // Fetch image data, get from cache or download if needed
                [self fetchImageDataWithMessage:message];
                [cell setInitialAnimateUploadingImageWithType:TAPMyImageBubbleTableViewCellStateTypeFailed];
            }
            else {
                NSInteger status = [[TAPFileUploadManager sharedManager] obtainUploadStatusWithMessage:message];
                // 0 is not found
                // 1 is uploading
                // 2 is waiting for upload
                if (status != 0) {
                    //Set current progress
                    NSDictionary *uploadProgressDictionary = [[TAPFileUploadManager sharedManager] getUploadProgressWithLocalID:message.localID];
                    [cell setInitialAnimateUploadingImageWithType:TAPMyImageBubbleTableViewCellStateTypeUploading];
                    if (uploadProgressDictionary == nil) {
                        CGFloat progress = [[uploadProgressDictionary objectForKey:@"progress"] floatValue];
                        CGFloat total = [[uploadProgressDictionary objectForKey:@"total"] floatValue];
                        
                        [cell animateProgressUploadingImageWithProgress:progress total:total];
                    }
                }
                else {
                    // Fetch image data, get from cache or download if needed
                    [self fetchImageDataWithMessage:message];
                }
            }
            
            return cell;
        }
        else if (message.type == TAPChatMessageTypeVideo) {
            //My Chat Video Message
            [tableView registerNib:[TAPMyVideoBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPMyVideoBubbleTableViewCell description]];
            TAPMyVideoBubbleTableViewCell *cell = (TAPMyVideoBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPMyVideoBubbleTableViewCell description] forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.tag = indexPath.row;
            cell.contentView.tag = indexPath.row;
            cell.userInteractionEnabled = YES;
            cell.contentView.userInteractionEnabled = YES;
            cell.delegate = self;
            cell.message = message;
            if(self.messageListType == TAPUIMessageListTypeStar){
                [cell setRotaionToDefault];
                [cell showStarMessageView];
                [cell showSeperator];
            }
            else if(self.messageListType == TAPUIMessageListTypePin){
                [cell showPinIcon:YES];
                [cell setSwipeGestureEnable:NO];
            }
            
            if (!message.isHidden) {
                [cell setMessage:message];
            }
            
            if (message != nil) {
                NSDictionary *dataDictionary = message.data;
                NSString *localID = message.localID;
                NSString *roomID = message.room.roomID;
                
                if (message.isFailedSend) {
                    //Update view to failed send
                    [cell animateFailedUploadVideo];
                }
                else {
                    NSInteger status = [[TAPFileUploadManager sharedManager] obtainUploadStatusWithMessage:message];
                    // 0 is not found
                    // 1 is uploading
                    // 2 is waiting for upload
                    if (status != 0) {
                        //Set current progress
                        NSDictionary *uploadProgressDictionary = [[TAPFileUploadManager sharedManager] getUploadProgressWithLocalID:message.localID];
                        [cell showVideoBubbleStatusWithType:TAPMyFileBubbleTableViewCellStateTypeUploading];
                        if (uploadProgressDictionary == nil) {
                            CGFloat progress = [[uploadProgressDictionary objectForKey:@"progress"] floatValue];
                            CGFloat total = [[uploadProgressDictionary objectForKey:@"total"] floatValue];
                            
                            [cell animateProgressUploadingVideoWithProgress:progress total:total];
                        }
                    }
                    else {
                        //Check video is done downloaded or not
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
                                
                                [cell showVideoBubbleStatusWithType:TAPMyVideoBubbleTableViewCellStateTypeDownloading];
                                [cell animateProgressDownloadingVideoWithProgress:progress total:total];
                            }
                            else if ([[TAPFileDownloadManager sharedManager] checkFailedDownloadWithLocalID:message.localID]) {
                                //previous download fail, show retry
                                [cell showVideoBubbleStatusWithType:TAPMyFileBubbleTableViewCellStateTypeRetryDownload];
                            }
                            else {
                                //show download
                                [cell showDownloadedState:NO];
                                [cell setVideoDurationAndSizeProgressViewWithMessage:message progress:nil stateType:TAPMyVideoBubbleTableViewCellStateTypeNotDownloaded];
                            }
                        }
                        else {
                            //File exist, show downloaded file
                            [cell showDownloadedState:YES];
                            [cell setVideoDurationAndSizeProgressViewWithMessage:message progress:nil stateType:TAPMyVideoBubbleTableViewCellStateTypeDoneDownloadedUploaded];
                        }
                    }
                }
                
            }
            return cell;
        }
        else if (message.type == TAPChatMessageTypeVoice) {
            //My Chat File Message
            [tableView registerNib:[TAPMyVoiceNoteBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPMyVoiceNoteBubbleTableViewCell description]];
            TAPMyVoiceNoteBubbleTableViewCell *cell = (TAPMyVoiceNoteBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPMyVoiceNoteBubbleTableViewCell description] forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.tag = indexPath.row;
            cell.contentView.tag = indexPath.row;
            cell.userInteractionEnabled = YES;
            cell.contentView.userInteractionEnabled = YES;
            cell.delegate = self;
            cell.message = message;
            if(self.messageListType == TAPUIMessageListTypeStar){
                [cell setRotaionToDefault];
                [cell showStarMessageView];
                [cell showSeperator];
            }
            else if(self.messageListType == TAPUIMessageListTypePin){
                [cell showPinIcon:YES];
                [cell setSwipeGestureEnable:NO];
            }
            [cell setAudioSliderValue:0.0f];
            
            if (!message.isHidden) {
                [cell setMessage:message];
            }
            
            [cell showDownloadedState:YES];
            
            return cell;
        }
        else if (message.type == TAPChatMessageTypeFile) {
            //My Chat File Message
            [tableView registerNib:[TAPMyFileBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPMyFileBubbleTableViewCell description]];
            TAPMyFileBubbleTableViewCell *cell = (TAPMyFileBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPMyFileBubbleTableViewCell description] forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.tag = indexPath.row;
            cell.contentView.tag = indexPath.row;
            cell.userInteractionEnabled = YES;
            cell.contentView.userInteractionEnabled = YES;
            cell.delegate = self;
            cell.message = message;
            if(self.messageListType == TAPUIMessageListTypeStar){
                [cell setRotaionToDefault];
                [cell showStarMessageView];
                [cell showSeperator];
            }
            else if(self.messageListType == TAPUIMessageListTypePin){
                [cell showPinIcon:YES];
                [cell setSwipeGestureEnable:NO];
            }
            
            if (!message.isHidden) {
                [cell setMessage:message];
            }
            
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
                        [cell showFileBubbleStatusWithType:TAPMyFileBubbleTableViewCellStateTypeUploading];
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
                                
                                [cell showFileBubbleStatusWithType:TAPMyFileBubbleTableViewCellStateTypeDownloading];
                                [cell animateProgressDownloadingFileWithProgress:progress total:total];
                            }
                            else if ([[TAPFileDownloadManager sharedManager] checkFailedDownloadWithLocalID:message.localID]) {
                                //previous download fail, show retry
                                [cell showFileBubbleStatusWithType:TAPMyFileBubbleTableViewCellStateTypeRetryDownload];
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
            return cell;
        }
        else if (message.type == TAPChatMessageTypeLocation) {
            //My Chat Location Message
            [tableView registerNib:[TAPMyLocationBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPMyLocationBubbleTableViewCell description]];
            TAPMyLocationBubbleTableViewCell *cell = (TAPMyLocationBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPMyLocationBubbleTableViewCell description] forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
            cell.message = message;
            
            if(self.messageListType == TAPUIMessageListTypeStar){
                [cell setRotaionToDefault];
                [cell showStarMessageView];
                [cell showSeperator];
            }
            else if(self.messageListType == TAPUIMessageListTypePin){
                [cell showPinIcon:YES];
                [cell setSwipeGestureEnable:NO];
            }
            
            if (!message.isHidden) {
                [cell setMessage:message];
            }
            
            if (message.isFailedSend) {
                [cell showStatusLabel:NO animated:NO updateStatusIcon:NO message:message];
            }
            else {
                [cell showStatusLabel:YES animated:NO updateStatusIcon:NO message:message];
            }
            
            return cell;
        }
        
    }
    else{
        if (message.type == TAPChatMessageTypeText || message.type == TAPChatMessageTypeLink) {
            
            //Their Chat Message
            [tableView registerNib:[TAPYourChatBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPYourChatBubbleTableViewCell description]];
            TAPYourChatBubbleTableViewCell *cell = (TAPYourChatBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPYourChatBubbleTableViewCell description] forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.tag = indexPath.row;
            cell.contentView.tag = indexPath.row;
            cell.userInteractionEnabled = YES;
            cell.contentView.userInteractionEnabled = YES;
            cell.delegate = self;
            if(self.messageListType == TAPUIMessageListTypeStar){
                [cell setRotaionToDefault];
                [cell showStarMessageView];
                [cell showSeperator];
            }
            else if(self.messageListType == TAPUIMessageListTypePin){
                [cell showPinIcon:YES];
                [cell setSwipeGestureEnable:NO];
            }
            
            
            cell.message = message;
            
            if (!message.isHidden) {
                
                [cell setMessage:message];
            }
            
            
            return cell;
        }
        else if (message.type == TAPChatMessageTypeImage) {
            //Their Image Message
            [tableView registerNib:[TAPYourImageBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPYourImageBubbleTableViewCell description]];
            TAPYourImageBubbleTableViewCell *cell = (TAPYourImageBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPYourImageBubbleTableViewCell description] forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.tag = indexPath.row;
            cell.contentView.tag = indexPath.row;
            cell.userInteractionEnabled = YES;
            cell.contentView.userInteractionEnabled = YES;
            cell.delegate = self;
            if(self.messageListType == TAPUIMessageListTypeStar){
                [cell setRotaionToDefault];
                [cell showStarMessageView];
                [cell showSeperator];
            }
            else if(self.messageListType == TAPUIMessageListTypePin){
                [cell showPinIcon:YES];
                [cell setSwipeGestureEnable:NO];
            }
            
            cell.message = message;
            
            if (!message.isHidden) {
                [cell setMessage:message];
            }
            [cell showStatusLabel:YES animated:NO];
            
            NSDictionary *progressDictionary = [[TAPFileDownloadManager sharedManager] getDownloadProgressWithLocalID:message.localID];
            if (progressDictionary != nil) {
                CGFloat progress = [[progressDictionary objectForKey:@"progress"] floatValue];
                CGFloat total = [[progressDictionary objectForKey:@"total"] floatValue];
                [cell setInitialAnimateDownloadingImage];
                [cell animateProgressDownloadingImageWithProgress:progress total:total];
            }
            else {
                //Fetch image data, get from cache or download if needed
                [self fetchImageDataWithMessage:message];
            }
            
            return cell;
        }
        else if (message.type == TAPChatMessageTypeVideo) {
            //Their Video Message
            [tableView registerNib:[TAPYourVideoBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPYourVideoBubbleTableViewCell description]];
            TAPYourVideoBubbleTableViewCell *cell = (TAPYourVideoBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPYourVideoBubbleTableViewCell description] forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.tag = indexPath.row;
            cell.contentView.tag = indexPath.row;
            cell.userInteractionEnabled = YES;
            cell.contentView.userInteractionEnabled = YES;
            cell.delegate = self;
            if(self.messageListType == TAPUIMessageListTypeStar){
                [cell setRotaionToDefault];
                [cell showStarMessageView];
                [cell showSeperator];
            }
            else if(self.messageListType == TAPUIMessageListTypePin){
                [cell showPinIcon:YES];
                [cell setSwipeGestureEnable:NO];
            }
            cell.message = message;
            
            if (!message.isHidden) {
                [cell setMessage:message];
            }
            
            if (message != nil) {
                NSDictionary *dataDictionary = message.data;
                dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];
                NSString *localID = message.localID;
                NSString *roomID = message.room.roomID;
                
                //Check video is done downloaded or not
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
                        
                        [cell showVideoBubbleStatusWithType:TAPYourVideoBubbleTableViewCellStateTypeDownloading];
                        [cell animateProgressDownloadingVideoWithProgress:progress total:total];
                    }
                    else if ([[TAPFileDownloadManager sharedManager] checkFailedDownloadWithLocalID:message.localID]) {
                        //previous download fail, show retry
                        [cell showVideoBubbleStatusWithType:TAPYourFileBubbleTableViewCellStateTypeRetry];
                    }
                    else {
                        //show download
                        [cell showDownloadedState:NO];
                        [cell setVideoDurationAndSizeProgressViewWithMessage:message progress:nil stateType:TAPYourVideoBubbleTableViewCellStateTypeNotDownloaded];
                    }
                }
                else {
                    //File exist, show downloaded file
                    [cell showDownloadedState:YES];
                    [cell setVideoDurationAndSizeProgressViewWithMessage:message progress:nil stateType:TAPYourVideoBubbleTableViewCellStateTypeDoneDownloaded];
                }
            }
            return cell;
        }
        else if (message.type == TAPChatMessageTypeVoice) {
            //Their File Message
            [tableView registerNib:[TAPYourVoiceNoteBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPYourVoiceNoteBubbleTableViewCell description]];
            TAPYourVoiceNoteBubbleTableViewCell *cell = (TAPYourVoiceNoteBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPYourVoiceNoteBubbleTableViewCell description] forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.tag = indexPath.row;
            cell.contentView.tag = indexPath.row;
            cell.userInteractionEnabled = YES;
            cell.contentView.userInteractionEnabled = YES;
            cell.delegate = self;
            cell.message = message;
            if(self.messageListType == TAPUIMessageListTypeStar){
                [cell setRotaionToDefault];
                [cell showStarMessageView];
                [cell showSeperator];
            }
            else if(self.messageListType == TAPUIMessageListTypePin){
                [cell showPinIcon:YES];
                [cell setSwipeGestureEnable:NO];
            }
            [cell setAudioSliderValue:0.0f];
            
            if (!message.isHidden) {
                [cell setMessage:message];
            }
            
            [cell showDownloadedState:YES];
            
            return cell;
        }
        else if (message.type == TAPChatMessageTypeFile) {
            //Their File Message
            [tableView registerNib:[TAPYourFileBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPYourFileBubbleTableViewCell description]];
            TAPYourFileBubbleTableViewCell *cell = (TAPYourFileBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPYourFileBubbleTableViewCell description] forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.tag = indexPath.row;
            cell.contentView.tag = indexPath.row;
            cell.userInteractionEnabled = YES;
            cell.contentView.userInteractionEnabled = YES;
            cell.delegate = self;
            cell.message = message;
            if(self.messageListType == TAPUIMessageListTypeStar){
                [cell setRotaionToDefault];
                [cell showStarMessageView];
                [cell showSeperator];
            }
            else if(self.messageListType == TAPUIMessageListTypePin){
                [cell showPinIcon:YES];
                [cell setSwipeGestureEnable:NO];
            }
            
            if (!message.isHidden) {
                [cell setMessage:message];
            }
            
            if (message != nil) {
                NSDictionary *dataDictionary = message.data;
                dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];
                NSString *localID = message.localID;
                NSString *roomID = message.room.roomID;
                
                //Check file is done downloaded or not
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
                        
                        [cell showFileBubbleStatusWithType:TAPYourFileBubbleTableViewCellStateTypeDownloading];
                        [cell animateProgressDownloadingFileWithProgress:progress total:total];
                    }
                    else if ([[TAPFileDownloadManager sharedManager] checkFailedDownloadWithLocalID:message.localID]) {
                        //previous download fail, show retry
                        [cell showFileBubbleStatusWithType:TAPYourFileBubbleTableViewCellStateTypeRetry];
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
            return cell;
        }
        else if (message.type == TAPChatMessageTypeLocation) {
            //Their Location Message
            [tableView registerNib:[TAPYourLocationBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPYourLocationBubbleTableViewCell description]];
            TAPYourLocationBubbleTableViewCell *cell = (TAPYourLocationBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPYourLocationBubbleTableViewCell description] forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.delegate = self;
            cell.message = message;
            if(self.messageListType == TAPUIMessageListTypeStar){
                [cell setRotaionToDefault];
                [cell showStarMessageView];
                [cell showSeperator];
            }
            else if(self.messageListType == TAPUIMessageListTypePin){
                [cell showPinIcon:YES];
                [cell setSwipeGestureEnable:NO];
            }
            
            if (!message.isHidden) {
                [cell setMessage:message];
            }
            
            [cell showStatusLabel:YES animated:NO];
            
            return cell;
        }
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    return cell;
}

#pragma mark TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TAPMessageModel *message = [self.messageArray objectAtIndex:indexPath.row];
    [self goBackToMessage:message];
}

- (void)myChatBubbleViewDidTapped:(TAPMessageModel *)tappedMessage {
    [self goBackToMessage:tappedMessage];
}

- (void)myImageQuoteDidTappedWithMessage:(TAPMessageModel *)message {
    [self goBackToMessage:message];
}
- (void)myImageRetryDidTappedWithMessage:(TAPMessageModel *)message {
    [self goBackToMessage:message];
}

- (void)myImageDidTapped:(TAPMyImageBubbleTableViewCell *)myImageBubbleCell{
    [self goBackToMessage:myImageBubbleCell.message];
}

- (void)myVideoRetryUploadDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage{
    [self goBackToMessage:tappedMessage];
}

- (void)myFileQuoteViewDidTapped:(TAPMessageModel *)tappedMessage {
    [self goBackToMessage:tappedMessage];
}
- (void)myFileOpenFileButtonDidTapped:(TAPMessageModel *)tappedMessage{
    [self goBackToMessage:tappedMessage];
}

- (void)myFileDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage{
    [self goBackToMessage:tappedMessage];
}

- (void)myLocationBubbleViewDidTapped:(TAPMessageModel *)tappedMessage{
    [self goBackToMessage:tappedMessage];
}

- (void)myVoiceNotePlayPauseButtonDidTapped:(TAPMessageModel *)tappedMessage{
    [self goBackToMessage:tappedMessage];
  
}

- (void)myVoiceNoteQuoteViewDidTapped:(TAPMessageModel *)tappedMessage {
    [self goBackToMessage:tappedMessage];
}


- (void)myVoiceNoteDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage {
    [self.navigationController popViewControllerAnimated:YES];
    if ([self.delegate respondsToSelector:@selector(starMessageBubbleCliked:)]) {
        [self.delegate starMessageBubbleCliked:tappedMessage];
    }
}

- (void)yourVoiceNoteOpenFileButtonDidTapped:(TAPMessageModel *)tappedMessage{
    [self goBackToMessage:tappedMessage];
  
}

- (void)yourVoiceNoteQuoteViewDidTapped:(TAPMessageModel *)tappedMessage {
    [self goBackToMessage:tappedMessage];
}


- (void)yourVoiceNoteDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage {
    [self goBackToMessage:tappedMessage];
}


- (void)yourChatBubbleViewDidTapped:(TAPMessageModel *)tappedMessage{
    [self goBackToMessage:tappedMessage];
}

- (void)yourImageDidTapped:(TAPYourImageBubbleTableViewCell *)yourImageBubbleCell {
    [self goBackToMessage:yourImageBubbleCell.message];
}

- (void)yourImageQuoteDidTappedWithMessage:(TAPMessageModel *)message{
    [self goBackToMessage:message];
}

- (void)yourFileBubbleViewDidTapped:(TAPMessageModel *)tappedMessage {
    [self goBackToMessage:tappedMessage];
}

- (void)yourFileQuoteViewDidTapped:(TAPMessageModel *)tappedMessage {
    [self goBackToMessage:tappedMessage];
}

- (void)yourFileOpenFileButtonDidTapped:(TAPMessageModel *)tappedMessage{
    [self goBackToMessage:tappedMessage];
}

- (void)yourLocationBubbleViewDidTapped:(TAPMessageModel *)tappedMessage{
    [self goBackToMessage:tappedMessage];
}

#pragma mark Custom Method

-(void)goBackToMessage:(TAPMessageModel *)message {
    if(self.messageListType == TAPUIMessageListTypeStar){
        [self.navigationController popViewControllerAnimated:NO];
        if ([self.delegate respondsToSelector:@selector(starMessageBubbleCliked:)]) {
            [self.delegate starMessageBubbleCliked:message];
        }
    }
    else if(self.messageListType == TAPUIMessageListTypePin){
        [self.navigationController popViewControllerAnimated:YES];
        if ([self.delegate respondsToSelector:@selector(starMessageBubbleCliked:)]) {
            [self.delegate starMessageBubbleCliked:message];
        }
        
    }
}

- (void)showLoadMoreMessageLoadingView:(BOOL)show {
    self.loadMoreMessageLoadingLabel.alpha = 0.0f;
    
    if (show) {
        self.loadMoreMessageViewHeight = 40.0f;
        
        
        [UIView animateWithDuration:0.2f animations:^{
            //change frame
            self.loadMoreMessageLoadingHeightConstraint.constant = self.loadMoreMessageViewHeight;
            [self.view layoutIfNeeded];
        }];
        
        if ([self.loadMoreMessageLoadingViewImageView.layer animationForKey:@"SpinAnimation"] == nil) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            animation.fromValue = [NSNumber numberWithFloat:0.0f];
            animation.toValue = [NSNumber numberWithFloat: 2*M_PI];
            animation.duration = 1.5f;
            animation.repeatCount = INFINITY;
            animation.removedOnCompletion = NO;
            [self.loadMoreMessageLoadingViewImageView.layer addAnimation:animation forKey:@"SpinAnimation"];
        }
    }
    else {
        self.loadMoreMessageViewHeight = 0.0f;
        
        [UIView animateWithDuration:0.2f animations:^{
            //change frame
            self.loadMoreMessageLoadingHeightConstraint.constant = self.loadMoreMessageViewHeight;
            [self.view layoutIfNeeded];
        }];
        
        //Remove Animation
        if ([self.loadMoreMessageLoadingViewImageView.layer animationForKey:@"SpinAnimation"] != nil) {
            [self.loadMoreMessageLoadingViewImageView.layer removeAnimationForKey:@"SpinAnimation"];
        }
    }
    /**
    CGFloat currentHeight = self.loadMoreMessageViewHeight;
    if (self.connectionStatusHeight == 0.0f && self.loadMoreMessageViewHeight== 0.0f) {
        currentHeight = 0.0f;
    }
    else if (self.connectionStatusHeight > 0.0f) {
        currentHeight = self.connectionStatusHeight;
    }
    else if (self.loadMoreMessageViewHeight > 0.0f) {
        currentHeight = self.loadMoreMessageViewHeight;
    }
    */
    /**
    [UIView animateWithDuration:0.2f animations:^{
        //change frame
        self.tableViewTopConstraint.constant = currentHeight - 50.0f;
        [self.view layoutIfNeeded];
    }];
    */
}

- (void)unPinAllButtonDidTapped {
    [self setAsLoadingState:YES];
    [TAPDataManager callAPIUnPinMessage:self.currentRoom.roomID messageID: self.messageIDs success:^(NSArray *unpinnedMessageIDs) {
        [self setAsLoadingState:NO];
        [self.navigationController popViewControllerAnimated:YES];
        if ([self.delegate respondsToSelector:@selector(unpinAllButtonCliked)]) {
            [self.delegate unpinAllButtonCliked];
        }
        
    } failure:^(NSError *error) {
        [self setAsLoadingState:NO];
        NSString *errorMessage = [error.userInfo objectForKey:@"message"];
        errorMessage = [TAPUtil nullToEmptyString:errorMessage];
        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error" title:NSLocalizedStringFromTableInBundle(@"Failed", nil, [TAPUtil currentBundle], @"") detailInformation:errorMessage leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
    }];
}

- (void)setAsLoadingState:(BOOL)isLoading{
    if (isLoading) {
        self.loadingBackgroundView.alpha = 1.0f;
        [self animateSaveLoading:YES];
        self.loadingImageView.image = [UIImage imageNamed:@"TAPIconLoaderProgress" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.loadingImageView.image = [self.loadingImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconLoadingProgressPrimary]];
        self.loadingLabel.text = @"Loading...";
    }
    else {
        self.loadingBackgroundView.alpha = 0.0f;
        [self animateSaveLoading:NO];
        self.loadingImageView.image = [UIImage imageNamed:@"TAPIconImageSaved" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.loadingImageView.image = [self.loadingImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconLoadingPopupSuccess]];
    }
}

- (void)animateSaveLoading:(BOOL)isAnimate {
    if (isAnimate) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.fromValue = [NSNumber numberWithFloat:0.0f];
        animation.toValue = [NSNumber numberWithFloat: 2 * M_PI];
        animation.duration = 1.5f;
        animation.repeatCount = INFINITY;
        animation.removedOnCompletion = NO;
        [self.loadingImageView.layer addAnimation:animation forKey:@"FirstLoadSpinAnimation"];
    }
    else {
        [self.loadingImageView.layer removeAnimationForKey:@"FirstLoadSpinAnimation"];
    }
}


- (void)addIncomingMessageToArrayAndDictionaryWithMessage:(TAPMessageModel *)message atIndex:(NSInteger)index {
    
    //Add message to message pointer dictionary
    [self.messageDictionary setObject:message forKey:message.localID];
}

- (void)fetchImageDataWithMessage:(TAPMessageModel *)message {
    [[TAPFileDownloadManager sharedManager] receiveImageDataWithMessage:message start:^(TAPMessageModel * _Nonnull receivedMessage) {
        //Already Handled via Notification
    } progress:^(CGFloat progress, CGFloat total, TAPMessageModel * _Nonnull receivedMessage) {
        //Already Handled via Notification
    } success:^(UIImage * _Nonnull fullImage, TAPMessageModel * _Nonnull receivedMessage, NSString * _Nullable filePath) {
        //Already Handled via Notification
    } failure:^(NSError * _Nonnull error, TAPMessageModel * _Nonnull receivedMessage) {
        //Already Handled via Notification
    }];
}


- (void)fileDownloadManagerFinishNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *notificationParameterDictionary = (NSDictionary *)[notification object];
        
        TAPMessageModel *obtainedMessage = [notificationParameterDictionary objectForKey:@"message"];
        NSString *roomID = obtainedMessage.room.roomID;
        roomID = [TAPUtil nullToEmptyString:roomID];
        
//        TAPRoomModel *currentRoom = [TAPChatManager sharedManager].activeRoom;
        NSString *currentActiveRoomID = self.currentRoom.roomID;
        currentActiveRoomID = [TAPUtil nullToEmptyString:currentActiveRoomID];
        
        if (![roomID isEqualToString:currentActiveRoomID]) {
            return;
        }
        
        NSString *localID = obtainedMessage.localID;
        localID = [TAPUtil nullToEmptyString:localID];
        
        TAPMessageModel *currentMessage = [self.messageDictionary objectForKey:localID];
        NSArray *messageArray = [self.messageArray copy];
        NSInteger currentRowIndex = [messageArray indexOfObject:currentMessage];
        
        BOOL isSavedMessageRoom = [TAPUtil isSaveMessageRoom:roomID];
        BOOL isForwardedSavedMessage = NO;
        
        if((![obtainedMessage.forwardFrom.localID isEqualToString:@""] && obtainedMessage.forwardFrom != nil) && isSavedMessageRoom){
            isForwardedSavedMessage = YES;
        }
        
        TAPChatMessageType type = currentMessage.type;
        if (type == TAPChatMessageTypeImage) {
            
            UIImage *fullImage = [notificationParameterDictionary objectForKey:@"fullImage"];
            
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID] && !isForwardedSavedMessage) {
                //My Chat
                TAPMyImageBubbleTableViewCell *cell = (TAPMyImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                if (fullImage != nil && [fullImage isKindOfClass:[UIImage class]]) {
                    [cell setFullImage:fullImage];
                }
                if (!currentMessage.isFailedSend) {
                    [cell animateFinishedUploadingImage];
                }
                else {
                    [cell animateFailedUploadingImage];
                }
            }
            else {
                //Their Chat
                TAPYourImageBubbleTableViewCell *cell = (TAPYourImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                if (fullImage != nil && [fullImage isKindOfClass:[UIImage class]]) {
                    [cell setFullImage:fullImage];
                }
                [cell animateFinishedDownloadingImage];
            }
        }
        else if (type == TAPChatMessageTypeFile) {
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID] && !isForwardedSavedMessage) {
                //My Chat
                TAPMyFileBubbleTableViewCell *cell = (TAPMyFileBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                if (!currentMessage.isFailedSend) {
                    [cell animateFinishedDownloadFile];
                }
                else {
                    [cell animateFailedUploadFile];
                }
            }
            else {
                //Their Chat
                TAPYourFileBubbleTableViewCell *cell = (TAPYourFileBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                [cell animateFinishedDownloadFile];
            }
        }
        else if (type == TAPChatMessageTypeVideo) {
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID] && !isForwardedSavedMessage) {
                //My Chat
                TAPMyVideoBubbleTableViewCell *cell = (TAPMyVideoBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                if (!currentMessage.isFailedSend) {
                    [cell animateFinishedDownloadVideo];
                }
                else {
                    [cell animateFailedUploadVideo];
                }
                [cell setVideoDurationAndSizeProgressViewWithMessage:currentMessage progress:nil stateType:TAPMyVideoBubbleTableViewCellStateTypeDoneDownloadedUploaded];
                [cell setThumbnailImageForVideoWithMessage:currentMessage];
            }
            else {
                //Their Chat
                TAPYourVideoBubbleTableViewCell *cell = (TAPYourVideoBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                [cell animateFinishedDownloadVideo];
                [cell setVideoDurationAndSizeProgressViewWithMessage:currentMessage progress:nil stateType:TAPYourVideoBubbleTableViewCellStateTypeDoneDownloaded];
                [cell setThumbnailImageForVideoWithMessage:currentMessage];
            }
        }
    });
}
@end
