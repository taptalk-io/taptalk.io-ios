//
//  TAPMessageInfoViewController.m
//  TapTalk
//
//  Created by TapTalk.io on 26/10/22.
//

#import "TAPMessageInfoViewController.h"
#import "TAPContactTableViewCell.h"
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
#import "TAPMyChatDeletedBubbleTableViewCell.h"
#import "TAPYourChatDeletedBubbleTableViewCell.h"
#import "TAPMentionListXIBTableViewCell.h"
#import "TAPMyVoiceNoteBubbleTableViewCell.h"
#import "TAPYourVoiceNoteBubbleTableViewCell.h"
#import "TapMessageRecipientModel.h"
#import "TAPAudioManager.h"
#import "TAPMediaDetailViewController.h"
#import "TAPWebViewViewController.h"

@import QuickLook;

@interface TAPMessageInfoViewController () <UITableViewDelegate, UITableViewDataSource, QLPreviewControllerDelegate, QLPreviewControllerDataSource, TAPMyChatBubbleTableViewCellDelegate, TAPMyImageBubbleTableViewCellDelegate, TAPMyVideoBubbleTableViewCellDelegate, TAPMyFileBubbleTableViewCellDelegate, TAPMyLocationBubbleTableViewCellDelegate, TAPMyVoiceNoteBubbleTableViewCellDelegate, TAPAudioManagerDelegate>

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *deliveredToArray;
@property (strong, nonatomic) NSArray *readByArray;
@property (strong, nonatomic) TAPMessageModel *pendingRedownloadMessage;
@property (strong, nonatomic) TAPMessageModel *currentVoiceNoteMessage;
@property (strong, nonatomic) NSURL *currentSelectedFileURL;
@property (strong, nonatomic) NSTimer *seekBarUpdateTimer;
@property (nonatomic) BOOL isMessageAudioPlaying;
@property (nonatomic) BOOL isPlayerSliding;
@property (weak, nonatomic) id<TAPAudioManagerDelegate> previousAudioManagerDelegate;

@end

@implementation TAPMessageInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource =self;
    
    self.view.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorChatRoomBackground];
    
    [self setupNavigationView];
    
    [TAPDataManager callAPIGetMessageDetails:self.message.messageID success:^(TAPMessageModel *message, NSArray<TapMessageRecipientModel *> *deliveredTo, NSArray<TapMessageRecipientModel *> *readBy) {
        self.readByArray = readBy;
        self.deliveredToArray = deliveredTo;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileDownloadManagerProgressNotification:) name:TAP_NOTIFICATION_DOWNLOAD_FILE_PROGRESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileDownloadManagerStartNotification:) name:TAP_NOTIFICATION_DOWNLOAD_FILE_START object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileDownloadManagerFinishNotification:) name:TAP_NOTIFICATION_DOWNLOAD_FILE_FINISH object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileDownloadManagerFailureNotification:) name:TAP_NOTIFICATION_DOWNLOAD_FILE_FAILURE object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.message != nil && self.message.type == TAPChatMessageTypeVoice) {
        _previousAudioManagerDelegate = [TAPAudioManager sharedManager].delegate;
        [TAPAudioManager sharedManager].delegate = self;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    if (self.message != nil && self.message.type == TAPChatMessageTypeVoice) {
        [TAPAudioManager sharedManager].delegate = self.previousAudioManagerDelegate;
    }
}

- (void)popUpInfoTappedSingleButtonOrRightButtonWithIdentifier:(NSString *)popupIdentifier {
    [super popUpInfoTappedSingleButtonOrRightButtonWithIdentifier:popupIdentifier];
    
    if ([popupIdentifier isEqualToString:@"File Not Found"] && self.pendingRedownloadMessage != nil) {
        [self fetchFileDataWithMessage:self.pendingRedownloadMessage];
        self.pendingRedownloadMessage = nil;
    }
}

#pragma mark TableViewDelegate
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    TAPMessageModel *message = self.message;
    if(indexPath.section == 0) {
        if (message.type == TAPChatMessageTypeText || message.type == TAPChatMessageTypeLink) {
            //My Chat Text Message
            [tableView registerNib:[TAPMyChatBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPMyChatBubbleTableViewCell description]];
            TAPMyChatBubbleTableViewCell *cell = (TAPMyChatBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPMyChatBubbleTableViewCell description] forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.tag = indexPath.row;
            cell.contentView.tag = indexPath.row;
            cell.userInteractionEnabled = YES;
            cell.contentView.userInteractionEnabled = YES;
            cell.delegate = self;
            [cell setRotaionToDefault];
            cell.message = message;
            cell.mentionIndexesArray = self.mentionArray;
            if (!message.isHidden) {
                [cell setMessage:message];
            }
            if (self.showStar) {
                [cell showStarMessageIconView];
            }
            if (self.showPin) {
                [cell showPinIcon:YES];
            }
            else {
                [cell showPinIcon:NO];
            }
            
            return cell;
        }
        else if (message.type == TAPChatMessageTypeVoice) {
            [tableView registerNib:[TAPMyVoiceNoteBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPMyVoiceNoteBubbleTableViewCell description]];
            TAPMyVoiceNoteBubbleTableViewCell *cell = (TAPMyVoiceNoteBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPMyVoiceNoteBubbleTableViewCell description] forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.tag = indexPath.row;
            cell.contentView.tag = indexPath.row;
            cell.userInteractionEnabled = YES;
            cell.contentView.userInteractionEnabled = YES;
            cell.delegate = self;
            cell.message = message;
            [cell setRotaionToDefault];
            [cell setAudioSliderValue:0.0f];
            
            if (!message.isHidden) {
                [cell setMessage:message];
            }
            if (self.showStar) {
                [cell showStarMessageView];
            }
            if (self.showPin) {
                [cell showPinIcon:YES];
            }
            else {
                [cell showPinIcon:NO];
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
                            fileURL = [TAPUtil nullToEmptyString:fileURL];
                            if (fileURL == nil || [fileURL isEqualToString:@""]) {
                                fileURL = [dataDictionary objectForKey:@"fileURL"];
                            }
                            fileURL = [TAPUtil nullToEmptyString:fileURL];
                            
                            if (fileURL == nil || [fileURL isEqualToString:@""]) {
                                return cell;
                           }
                            
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
                                
                                NSDictionary *currentDataDictionary = message.data;
                                NSString *currentFileID = [currentDataDictionary objectForKey:@"fileID"];
                                if (currentFileID != nil) {
                                  //  [self fetchFileDataWithMessage:message];
                                }
                                
                            }
                        }
                        else {
                            //File exist, show downloaded file
                            [cell showDownloadedState:YES];
                        }
                    }
                }
                
                if (message == self.currentVoiceNoteMessage) {
                    [cell setPlayingState:YES];
                    NSTimeInterval currentTime = [[TAPAudioManager sharedManager] getPlayerCurrentTime];
                    [cell setAudioSliderMaximumValue:[[TAPAudioManager sharedManager] getPlayerDuration]];
                    [cell setAudioSliderValue:currentTime];
                    [cell setVoiceNoteDurationLabel:[self secondToMinuteString:currentTime]];
                }
                else {
                    [cell setPlayingState:NO];
                }
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
            [cell setRotaionToDefault];
         
            if (!message.isHidden) {
                [cell setMessage:message];
            }
            cell.mentionIndexesArray = self.mentionArray;
            if (self.showStar) {
                [cell showStarMessageView];
            }
            if (self.showPin) {
                [cell showPinIcon:YES];
            }
            else {
                [cell showPinIcon:NO];
            }
            
            if (message.isFailedSend) {
                //Update view to failed send
                
                // Fetch image data, get from cache or download if needed
               // [self fetchImageDataWithMessage:message];
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
            [cell setRotaionToDefault];
            
            if (!message.isHidden) {
                [cell setMessage:message];
            }
            cell.mentionIndexesArray = self.mentionArray;
            if (self.showStar) {
                [cell showStarMessageView];
            }
            if (self.showPin) {
                [cell showPinIcon:YES];
            }
            else {
                [cell showPinIcon:NO];
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
            [cell setRotaionToDefault];
            
            if (!message.isHidden) {
                [cell setMessage:message];
            }
            if (self.showStar) {
                [cell showStarMessageView];
            }
            if (self.showPin) {
                [cell showPinIcon:YES];
            }
            else {
                [cell showPinIcon:NO];
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
            [cell setRotaionToDefault];
           
            if (!message.isHidden) {
                [cell setMessage:message];
            }
            if (self.showStar) {
                [cell showStarMessageView];
            }
            if (self.showPin) {
                [cell showPinIcon:YES];
            }
            else {
                [cell showPinIcon:NO];
            }
            return cell;
        }
    }
    else if(indexPath.section == 1) {
        static NSString *cellID = @"TAPContactTableViewCell";
        TapMessageRecipientModel *messageRecipient = [self.readByArray objectAtIndex:indexPath.row];
        TAPUserModel *user = [TAPUserModel new];
        user.userID = messageRecipient.userID;
        user.xcUserID = messageRecipient.xcUserID;
        user.fullname = messageRecipient.fullname;
        user.imageURL = messageRecipient.imageURL;
        
        TAPContactTableViewCell *cell = [[TAPContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        [cell setContactTableViewCellWithUser:user]; //WK Temp
        [cell setContactTableViewCellType:TAPContactTableViewCellTypeDefault];
        [cell isRequireSelection:NO];
        
        TapMessageRecipientModel *messageRecepient = [self.readByArray objectAtIndex:indexPath.row];
        
        NSString *deliveredTime = [TAPUtil getMessageTimestampText:messageRecipient.deliveredTime];
        NSString *readbyTime = [TAPUtil getMessageTimestampText:messageRecipient.readTime];
        
        
        if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
            [cell showSeparatorLine:YES separatorLineType:TAPContactTableViewCellSeparatorTypeFull];
        }
        else {
            [cell showSeparatorLine:YES separatorLineType:TAPContactTableViewCellSeparatorTypeDefault];
        }
        [cell showReadBy:deliveredTime readTime:readbyTime];
        return cell;
    }
    else if(indexPath.section == 2) {
        static NSString *cellID = @"TAPContactTableViewCell";
        TapMessageRecipientModel *messageRecipient = [self.deliveredToArray objectAtIndex:indexPath.row];
        TAPUserModel *user = [TAPUserModel new];
        user.userID = messageRecipient.userID;
        user.xcUserID = messageRecipient.xcUserID;
        user.fullname = messageRecipient.fullname;
        user.imageURL = messageRecipient.imageURL;
        
        TAPContactTableViewCell *cell = [[TAPContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        [cell setContactTableViewCellWithUser:user]; //WK Temp
        [cell setContactTableViewCellType:TAPContactTableViewCellTypeDefault];
        [cell isRequireSelection:NO];
        
        
        NSString *deliveredTime = [TAPUtil getMessageTimestampText:messageRecipient.deliveredTime];
        //NSString *readbyTime = [TAPUtil getMessageTimestampText:messageRecipient.readTime];
        
        [cell showDeliveredTo:deliveredTime];
        //[cell showReadBy:deliveredTime readTime:readbyTime];
        
        
        if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
            [cell showSeparatorLine:YES separatorLineType:TAPContactTableViewCellSeparatorTypeFull];
        }
        else {
            [cell showSeparatorLine:YES separatorLineType:TAPContactTableViewCellSeparatorTypeDefault];
        }
        
        return cell;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return 1;
    }
    else if(section == 1 && ![[TapUI sharedInstance] getReadStatusHiddenState]) {
        return self.readByArray.count;
    }
    else if(section == 2) {
        return self.deliveredToArray.count;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        tableView.estimatedRowHeight = 70.0f;
        return UITableViewAutomaticDimension;
    }
    else {
        return 64.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat headerHeight = 23.0f;
    
    if (section == 1 && (self.readByArray.count == 0 || [[TapUI sharedInstance] getReadStatusHiddenState])) {
        headerHeight = 0.0f;
    }
    else if (section == 2 && self.deliveredToArray.count == 0 && self.readByArray.count > 0) {
        headerHeight = 0.0f;
    }
    else if (section == 0){
        headerHeight = 0.0f;
    }
    
    return headerHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.frame), 23.0f)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UILabel *sectionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, CGRectGetWidth(headerView.frame) - 12.0f, CGRectGetHeight(headerView.frame))];
    sectionTitleLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
    UIFont *sectionTitleLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontMessageInfoSectionLabel];
    sectionTitleLabel.font = sectionTitleLabelFont;
    [headerView addSubview:sectionTitleLabel];
    
    UIImageView *statusIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(headerView.frame) - 14.0f - 12.0f, 4.0f, 14.0f, 14.0f)];
    statusIconImageView.image = [UIImage imageNamed:@"TAPIconDelivered" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    [headerView addSubview:statusIconImageView];
    
    UIView *bottomSeperatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(headerView.frame) - 1, CGRectGetWidth(headerView.frame), 1.0f)];
    bottomSeperatorView.backgroundColor = [[UIColor opaqueSeparatorColor] colorWithAlphaComponent:0.3f];
    [headerView addSubview:bottomSeperatorView];
    
    
    if(section == 1) {
        sectionTitleLabel.text = [NSString stringWithFormat:@"READ BY (%ld)",self.readByArray.count];
        statusIconImageView.image = [statusIconImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPDefaultColorIconPrimary]];
    }
    else if(section == 2) {
        sectionTitleLabel.text = [NSString stringWithFormat:@"DELIVERED TO (%ld)", self.deliveredToArray.count];
    }
    
    return headerView;
}


- (void)setupNavigationView {
    //This method is used to setup the title view of navigation bar, and also bar button view
    
    //Title View
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - 56.0f - 56.0f, 43.0f)];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(titleView.frame), CGRectGetHeight(titleView.frame))];
    
    UIFont *chatRoomNameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontChatRoomNameLabel];
    UIColor *chatRoomNameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorChatRoomNameLabel];
    
    nameLabel.text = NSLocalizedStringFromTableInBundle(@"Message Info", nil, [TAPUtil currentBundle], @"");
    
    
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
    TapBarButtonItem *barButtonItem = [[TapBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
}

#pragma mark TAPMyChatBubbleTableViewCellDelegate

- (void)myChatBubbleDidTappedUrl:(NSURL *)url
                  originalString:(NSString *)originalString {
    [self handleTappedWithURL:url originalString:originalString];
}

- (void)myChatBubbleDidTappedPhoneNumber:(NSString *)phoneNumber
                          originalString:(NSString *)originalString {
    [self handleTappedWithPhoneNumber:phoneNumber originalString:originalString];
}

- (void)myChatBubbleLongPressedUrl:(NSURL *)url
                    originalString:(NSString *)originalString {
    [self handleLongPressedWithURL:url originalString:originalString];
}

- (void)myChatBubbleLongPressedPhoneNumber:(NSString *)phoneNumber
                            originalString:(NSString *)originalString {
    [self handleLongPressedWithPhoneNumber:phoneNumber originalString:originalString];
}

- (void)myChatBubblePressedMentionWithWord:(NSString*)word
                             tappedAtIndex:(NSInteger)index
                                   message:(TAPMessageModel *)message
                       mentionIndexesArray:(NSArray *)mentionIndexesArray {
    [self tapTalkUserMentionTappedWithWord:word tappedAtIndex:index message:message mentionIndexesArray:mentionIndexesArray];
}

- (void)myChatBubbleLongPressedMentionWithWord:(NSString*)word
                                 tappedAtIndex:(NSInteger)index
                                       message:(TAPMessageModel *)message
                           mentionIndexesArray:(NSArray *)mentionIndexesArray {
    [self taptTalkUserMentionLongPressedWithWord:word tappedAtIndex:index message:message mentionIndexesArray:mentionIndexesArray];
}

#pragma mark TAPMyImageBubbleTableViewCellDelegate

- (void)myImageDidTapped:(TAPMyImageBubbleTableViewCell *)myImageBubbleCell {
    CGFloat bubbleImageViewMinY = CGRectGetMinY(myImageBubbleCell.bubbleImageView.frame);
    
    TAPMediaDetailViewController *mediaDetailViewController = [[TAPMediaDetailViewController alloc] init];
    [mediaDetailViewController setMediaDetailViewControllerType:TAPMediaDetailViewControllerTypeImage];
    mediaDetailViewController.delegate = self;
    mediaDetailViewController.message = myImageBubbleCell.message;
    
    UIImage *cellImage = myImageBubbleCell.bubbleImageView.image;
    NSArray *imageSliderImage = [NSArray array];
    if (cellImage != nil) {
        imageSliderImage = @[cellImage];
        
        [mediaDetailViewController setThumbnailImageArray:imageSliderImage];
        [mediaDetailViewController setImageArray:@[cellImage]];
        
        [mediaDetailViewController setActiveIndex:0];
        
        NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        CGRect cellRectInTableView = [self.tableView rectForRowAtIndexPath:selectedIndexPath];
        CGRect cellRectInView = [self.tableView convertRect:cellRectInTableView toView:self.view];
        CGRect imageRectInView = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 26.0f - myImageBubbleCell.bubbleImageViewWidthConstraint.constant, CGRectGetMinY(cellRectInView) + bubbleImageViewMinY + [TAPUtil currentDeviceNavigationBarHeightWithStatusBar:YES iPhoneXLargeLayout:NO], myImageBubbleCell.bubbleImageViewWidthConstraint.constant, myImageBubbleCell.bubbleImageViewHeightConstraint.constant);
        
        [mediaDetailViewController showToViewController:self.navigationController thumbnailImage:cellImage thumbnailFrame:imageRectInView];
//        myImageBubbleCell.bubbleImageView.alpha = 0.0f;
    }
}

- (void)myImageDidTappedUrl:(NSURL *)url
             originalString:(NSString *)originalString {
    [self handleTappedWithURL:url originalString:originalString];
}

- (void)myImageDidTappedPhoneNumber:(NSString *)phoneNumber
                     originalString:(NSString *)originalString {
    [self handleTappedWithPhoneNumber:phoneNumber originalString:originalString];
}

- (void)myImageLongPressedUrl:(NSURL *)url
               originalString:(NSString *)originalString {
    [self handleLongPressedWithURL:url originalString:originalString];
}

- (void)myImageLongPressedPhoneNumber:(NSString *)phoneNumber
                       originalString:(NSString *)originalString {
    [self handleLongPressedWithPhoneNumber:phoneNumber originalString:originalString];
}

- (void)myImageBubblePressedMentionWithWord:(NSString*)word
                              tappedAtIndex:(NSInteger)index
                                    message:(TAPMessageModel *)message
                        mentionIndexesArray:(NSArray *)mentionIndexesArray {
    [self tapTalkUserMentionTappedWithWord:word tappedAtIndex:index message:message mentionIndexesArray:mentionIndexesArray];
}

- (void)myImageBubbleLongPressedMentionWithWord:(NSString*)word
                                  tappedAtIndex:(NSInteger)index
                                        message:(TAPMessageModel *)message
                            mentionIndexesArray:(NSArray *)mentionIndexesArray {
    [self taptTalkUserMentionLongPressedWithWord:word tappedAtIndex:index message:message mentionIndexesArray:mentionIndexesArray];
}

#pragma mark TAPMyVideoBubbleTableViewCellDelegate

- (void)myVideoLongPressedUrl:(NSURL *)url
               originalString:(NSString*)originalString {
    [self handleLongPressedWithURL:url originalString:originalString];
}

- (void)myVideoLongPressedPhoneNumber:(NSString *)phoneNumber
                       originalString:(NSString *)originalString {
    [self handleLongPressedWithPhoneNumber:phoneNumber originalString:originalString];
}

- (void)myVideoDidTappedUrl:(NSURL *)url
             originalString:(NSString*)originalString {
    [self handleTappedWithURL:url originalString:originalString];
}

- (void)myVideoDidTappedPhoneNumber:(NSString *)phoneNumber
                     originalString:(NSString*)originalString {
    [self handleTappedWithPhoneNumber:phoneNumber originalString:originalString];
}

- (void)myVideoDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage {
    [self fetchVideoDataWithMessage:tappedMessage];
}

- (void)myVideoCancelDidTappedWithMessage:(TAPMessageModel *)message {
    [[TAPFileDownloadManager sharedManager] cancelDownloadWithMessage:message];
}

- (void)myVideoBubblePressedMentionWithWord:(NSString*)word
                              tappedAtIndex:(NSInteger)index
                                    message:(TAPMessageModel *)message
                        mentionIndexesArray:(NSArray *)mentionIndexesArray {
    [self tapTalkUserMentionTappedWithWord:word tappedAtIndex:index message:message mentionIndexesArray:mentionIndexesArray];
}

- (void)myVideoBubbleLongPressedMentionWithWord:(NSString*)word
                                  tappedAtIndex:(NSInteger)index
                                        message:(TAPMessageModel *)message
                            mentionIndexesArray:(NSArray *)mentionIndexesArray {
    [self taptTalkUserMentionLongPressedWithWord:word tappedAtIndex:index message:message mentionIndexesArray:mentionIndexesArray];
}

- (void)myVideoPlayDidTappedWithMessage:(TAPMessageModel *)message {
    [self playVideoWithMessage:message];
}

#pragma mark TAPMyFileBubbleTableViewCellDelegate

- (void)myFileDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage {
    [self fetchFileDataWithMessage:tappedMessage];
}

- (void)myFileCancelButtonDidTapped:(TAPMessageModel *)tappedMessage {
    [[TAPFileDownloadManager sharedManager] cancelDownloadWithMessage:tappedMessage];
}

- (void)myFileOpenFileButtonDidTapped:(TAPMessageModel *)tappedMessage {
    [self openFilePreviewViewControllerWithMessage:tappedMessage];
}

#pragma mark TAPMyLocationBubbleTableViewCellDelegate

- (void)myLocationBubbleViewDidTapped:(TAPMessageModel *)tappedMessage {
    NSDictionary *dataDictionary = tappedMessage.data;
    dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *googleMapsAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedStringFromTableInBundle(@"Open in Google Maps", nil, [TAPUtil currentBundle], @"")
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                           [self performSelector:@selector(openLocationInGoogleMaps:) withObject:dataDictionary];
                                       }];
    
    UIAlertAction *appleMapsAction = [UIAlertAction
                                      actionWithTitle:NSLocalizedStringFromTableInBundle(@"Open in Maps", nil, [TAPUtil currentBundle], @"")
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          [self performSelector:@selector(openLocationInAppleMaps:) withObject:dataDictionary];
                                      }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
                                       //Do some thing here
                                   }];
    
    [googleMapsAction setValue:[[UIImage imageNamed:@"TAPIconGoogleMaps" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [appleMapsAction setValue:[[UIImage imageNamed:@"TAPIconAppleMaps" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    [googleMapsAction setValue:@0 forKey:@"titleTextAlignment"];
    [appleMapsAction setValue:@0 forKey:@"titleTextAlignment"];
    
    UIColor *actionSheetDefaultColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorActionSheetDefaultLabel];
    UIColor *actionSheetCancelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorActionSheetCancelButtonLabel];
    
    [googleMapsAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
    [appleMapsAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
    [cancelAction setValue:actionSheetCancelColor forKey:@"titleTextColor"];
    
    [alertController addAction:googleMapsAction];
    [alertController addAction:appleMapsAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark TAPMyVoiceNoteBubbleTableViewCellDelegate

- (void)myVoiceNoteBubblePlayerSliderDidChange:(NSTimeInterval)currentTime message:(TAPMessageModel *)message{
    if ([[TAPAudioManager sharedManager] isPlaying]) {
        [[TAPAudioManager sharedManager] setPlayerCurrentTime:currentTime];
        self.isPlayerSliding = YES;
    }
    else {
       //My Chat
        TAPMyVoiceNoteBubbleTableViewCell *cell = (TAPMyVoiceNoteBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [cell setAudioSliderValue:0.0f];
    }
}

- (void)myVoiceNoteBubblePlayerSliderDidEnd{
    self.isPlayerSliding = NO;
}

- (void)myVoiceNotePlayPauseButtonDidTapped:(TAPMessageModel *)tappedMessage {
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
        [self showFileNotFoundPopUpWithMessage:tappedMessage];
        return;
    }
    
    if (self.currentVoiceNoteMessage == tappedMessage && [filePath isEqualToString:[[TAPAudioManager sharedManager] getPlayerCurrentFilePath]]) {
        if ([[TAPAudioManager sharedManager] isPlaying]) {
            [[TAPAudioManager sharedManager] pausePlayer];
            [self voiceMessagePlayingState:NO];
            self.isMessageAudioPlaying = NO;
        }
        else {
            [[TAPAudioManager sharedManager] resumePlayer];
            [self voiceMessagePlayingState:YES];
            self.isMessageAudioPlaying = YES;
        }
        return;
    }
    [self resetMessageAudioSlider];
    self.isMessageAudioPlaying = YES;
    self.currentVoiceNoteMessage = tappedMessage;
    [[TAPAudioManager sharedManager] playAudio:filePath];
}

- (void)myVoiceNoteDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage {
    [self fetchFileDataWithMessage:tappedMessage];
}

- (void)myVoiceNoteCancelButtonDidTapped:(TAPMessageModel *)tappedMessage {
    [[TAPFileDownloadManager sharedManager] cancelDownloadWithMessage:tappedMessage];
}

#pragma mark TAPAudioManagerDelegate

- (void)startAudioPlay:(NSTimeInterval)duration {
    self.seekBarUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.0001f target:self selector:@selector(seekBarUpdate) userInfo:nil repeats:YES];
//    if (self.isComposerAudioPlaying) {
//        self.voiceNoteAudioSlider.maximumValue = duration;
//    }
//    else
    if (self.isMessageAudioPlaying) {
        if (self.currentVoiceNoteMessage.type == TAPChatMessageTypeVoice) {
            if ([self.currentVoiceNoteMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                //My Chat
                TAPMyVoiceNoteBubbleTableViewCell *cell = (TAPMyVoiceNoteBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell setAudioSliderMaximumValue:duration];
                [cell setPlayingState:YES];
            }
            else {
                //Their Chat
                TAPYourVoiceNoteBubbleTableViewCell *cell = (TAPYourVoiceNoteBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell setAudioSliderMaximumValue:duration];
                [cell setPlayingState:YES];
            }
        }
    }
}

- (void)finishAudioPlay {
    [self.seekBarUpdateTimer invalidate];
//    self.isComposerAudioPlaying = NO;
//    self.isYourMessageAudioPlaying = NO;
//    self.voiceNoteAudioSlider.value = 0.0f;
//    self.playIconImageView.image = [UIImage imageNamed:@"TAPIconPlayComposer" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
//    self.recordingTimeLabel.text = [self secondToMinuteString:self.recordingTimeCounter];
    
    if (!self.isPlayerSliding) {
        self.isMessageAudioPlaying = NO;
    }
    
    if (self.currentVoiceNoteMessage != nil) {
        NSDictionary *dataDictionary = self.currentVoiceNoteMessage.data;
        dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];
        NSNumber *vnDuration = [dataDictionary objectForKey:@"duration"];
        NSInteger durationInt = [vnDuration integerValue];
        durationInt /= 1000;
        
        if(self.currentVoiceNoteMessage.type == TAPChatMessageTypeVoice){
            if ([self.currentVoiceNoteMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                //My Chat
                TAPMyVoiceNoteBubbleTableViewCell *cell = (TAPMyVoiceNoteBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell setAudioSliderValue:0.0f];
                [cell setPlayingState:NO];
                [cell setVoiceNoteDurationLabel:[self secondToMinuteString:durationInt]];
            }
            else {
                //Their Chat
                TAPYourVoiceNoteBubbleTableViewCell *cell = (TAPYourVoiceNoteBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell setAudioSliderValue:0.0f];
                [cell setPlayingState:NO];
                [cell setVoiceNoteDurationLabel:[self secondToMinuteString:durationInt]];
            }
        }
        self.currentVoiceNoteMessage = nil;
    }
}

#pragma mark QLPreviewController
- (NSInteger) numberOfPreviewItemsInPreviewController:(QLPreviewController *) controller {
    return 1;
}

- (id <QLPreviewItem>) previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger) index {
    return self.currentSelectedFileURL;
}

- (BOOL)previewController:(QLPreviewController *)controller shouldOpenURL:(NSURL *)url forPreviewItem:(id <QLPreviewItem>)item {
    return YES;
}

#pragma mark Handle Bubble Delegates

- (void)handleLongPressedWithURL:(NSURL *)url originalString:(NSString *)originalString {
    [TAPUtil tapticImpactFeedbackGenerator];
    if ([url.scheme isEqualToString:@"mailto"]) {
        //handle email address
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *composeAction = [UIAlertAction
                                        actionWithTitle:NSLocalizedStringFromTableInBundle(@"Compose", nil, [TAPUtil currentBundle], @"")
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            if([[UIApplication sharedApplication] canOpenURL:url]) {
                                                if(IS_IOS_11_OR_ABOVE) {
                                                    [[UIApplication sharedApplication] openURL:url options:[NSDictionary dictionary] completionHandler:nil];
                                                }
                                                else {
                                                    [[UIApplication sharedApplication] openURL:url];
                                                }
                                            }
                                        }];
        
        UIAlertAction *copyAction = [UIAlertAction
                                     actionWithTitle:NSLocalizedStringFromTableInBundle(@"Copy", nil, [TAPUtil currentBundle], @"")
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
                                         UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                         [pasteboard setString:originalString];
                                     }];
        
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"")
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction * action) {
            
                                       }];
        
        UIImage *composeEmailActionImage = [UIImage imageNamed:@"TAPIconComposeEmail" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        composeEmailActionImage = [composeEmailActionImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconActionSheetComposeEmail]];
        [composeAction setValue:[composeEmailActionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        
        UIImage *copyActionImage = [UIImage imageNamed:@"TAPIconCopy" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        copyActionImage = [copyActionImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconActionSheetCopy]];
        [copyAction setValue:[copyActionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        
        [composeAction setValue:@0 forKey:@"titleTextAlignment"];
        [copyAction setValue:@0 forKey:@"titleTextAlignment"];
        
        UIColor *actionSheetDefaultColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorActionSheetDefaultLabel];
        UIColor *actionSheetCancelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorActionSheetCancelButtonLabel];
        
        [composeAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
        [copyAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
        [cancelAction setValue:actionSheetCancelColor forKey:@"titleTextColor"];
        
        if ([[TapUI sharedInstance] isComposeEmailMenuEnabled]) {
            [alertController addAction:composeAction];
        }
        if ([[TapUI sharedInstance] isCopyMessageMenuEnabled]) {
            [alertController addAction:copyAction];
        }
        [alertController addAction:cancelAction];
        
        [UIView animateWithDuration:0.2f animations:^{
            [self keyboardWillHideWithHeight:0.0f];
        } completion:^(BOOL finished) {
            [self presentViewController:alertController animated:YES completion:^{
                //after animation
            }];
        }];
    }
    else {
        //handle link
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *openAction = [UIAlertAction
                                     actionWithTitle:NSLocalizedStringFromTableInBundle(@"Open", nil, [TAPUtil currentBundle], @"")
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
                                         if([[UIApplication sharedApplication] canOpenURL:url]) {
                                             if(IS_IOS_11_OR_ABOVE) {
                                                 [[UIApplication sharedApplication] openURL:url options:[NSDictionary dictionary] completionHandler:nil];
                                             }
                                             else {
                                                 [[UIApplication sharedApplication] openURL:url];
                                             }
                                         }
                                     }];
        
        UIAlertAction *copyAction = [UIAlertAction
                                     actionWithTitle:NSLocalizedStringFromTableInBundle(@"Copy", nil, [TAPUtil currentBundle], @"")
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
                                         UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                         [pasteboard setString:originalString];
                                     }];
        
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"")
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction * action) {
            
                                       }];
        
        UIImage *openActionImage = [UIImage imageNamed:@"TAPIconOpen" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        openActionImage = [openActionImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconActionSheetOpen]];
        [openAction setValue:[openActionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        
        UIImage *copyActionImage = [UIImage imageNamed:@"TAPIconCopy" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        copyActionImage = [copyActionImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconActionSheetCopy]];
        [copyAction setValue:[copyActionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        
        [openAction setValue:@0 forKey:@"titleTextAlignment"];
        [copyAction setValue:@0 forKey:@"titleTextAlignment"];
        
        UIColor *actionSheetDefaultColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorActionSheetDefaultLabel];
        UIColor *actionSheetCancelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorActionSheetCancelButtonLabel];
        [openAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
        [copyAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
        [cancelAction setValue:actionSheetCancelColor forKey:@"titleTextColor"];
        
        if ([[TapUI sharedInstance] isOpenLinkMenuEnabled]) {
            [alertController addAction:openAction];
        }
        if ([[TapUI sharedInstance] isCopyMessageMenuEnabled]) {
            [alertController addAction:copyAction];
        }
        [alertController addAction:cancelAction];
        
        [UIView animateWithDuration:0.2f animations:^{
            [self keyboardWillHideWithHeight:0.0f];
        } completion:^(BOOL finished) {
            [self presentViewController:alertController animated:YES completion:^{
                //after animation
            }];
        }];
    }
}

- (void)handleLongPressedWithPhoneNumber:(NSString *)phoneNumber originalString:(NSString *)originalString {
    [TAPUtil tapticImpactFeedbackGenerator];
    //handle number
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *callAction = [UIAlertAction
                                 actionWithTitle:NSLocalizedStringFromTableInBundle(@"Call Number", nil, [TAPUtil currentBundle], @"")
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     NSString *stringURL = [NSString stringWithFormat:@"tel:%@", phoneNumber];
                                     if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:stringURL]]) {
                                         if(IS_IOS_11_OR_ABOVE) {
                                             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringURL] options:[NSDictionary dictionary] completionHandler:nil];
                                         }
                                         else {
                                             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringURL]];
                                         }
                                     }
                                 }];
    
    UIAlertAction *smsAction = [UIAlertAction
                                actionWithTitle:NSLocalizedStringFromTableInBundle(@"SMS Number", nil, [TAPUtil currentBundle], @"")
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    NSString *stringURL = [NSString stringWithFormat:@"sms:%@", phoneNumber];
                                    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:stringURL]]) {
                                        if(IS_IOS_11_OR_ABOVE) {
                                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringURL] options:[NSDictionary dictionary] completionHandler:nil];
                                        }
                                        else {
                                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringURL]];
                                        }
                                    }
                                }];
    
    UIAlertAction *copyAction = [UIAlertAction
                                 actionWithTitle:NSLocalizedStringFromTableInBundle(@"Copy", nil, [TAPUtil currentBundle], @"")
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                     [pasteboard setString:phoneNumber];
                                 }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
        
                                   }];
    
    UIImage *callActionImage = [UIImage imageNamed:@"TAPIconCall" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    callActionImage = [callActionImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconActionSheetCall]];
    [callAction setValue:[callActionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];

    UIImage *smsActionImage = [UIImage imageNamed:@"TAPIconSMS" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    smsActionImage = [smsActionImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconActionSheetSMS]];
    [smsAction setValue:[smsActionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    UIImage *copyActionImage = [UIImage imageNamed:@"TAPIconCopy" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    copyActionImage = [copyActionImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconActionSheetCopy]];
    [copyAction setValue:[copyActionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    [callAction setValue:@0 forKey:@"titleTextAlignment"];
    [smsAction setValue:@0 forKey:@"titleTextAlignment"];
    [copyAction setValue:@0 forKey:@"titleTextAlignment"];
    
    UIColor *actionSheetDefaultColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorActionSheetDefaultLabel];
    UIColor *actionSheetCancelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorActionSheetCancelButtonLabel];
    [callAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
    [smsAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
    [copyAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
    [cancelAction setValue:actionSheetCancelColor forKey:@"titleTextColor"];
    
    if ([[TapUI sharedInstance] isDialNumberMenuEnabled]) {
        [alertController addAction:callAction];
    }
    if ([[TapUI sharedInstance] isSendSMSMenuEnabled]) {
        [alertController addAction:smsAction];
    }
    if ([[TapUI sharedInstance] isCopyMessageMenuEnabled]) {
        [alertController addAction:copyAction];
    }
    [alertController addAction:cancelAction];
    
    [UIView animateWithDuration:0.2f animations:^{
        [self keyboardWillHideWithHeight:0.0f];
    } completion:^(BOOL finished) {
        [self presentViewController:alertController animated:YES completion:^{
            //after animation
        }];
    }];
}

- (void)handleTappedWithURL:(NSURL *)url originalString:(NSString *)originalString {
    if ([url.scheme isEqualToString:@"mailto"]) {
        //handle email address
        //open mail app
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            if(IS_IOS_11_OR_ABOVE) {
                [[UIApplication sharedApplication] openURL:url options:[NSDictionary dictionary] completionHandler:nil];
            }
            else {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }
    else {
        //handle link
        //open webview
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            if(IS_IOS_11_OR_ABOVE) {
                [[UIApplication sharedApplication] openURL:url
                                                   options:@{UIApplicationOpenURLOptionUniversalLinksOnly: @YES}
                                         completionHandler:^(BOOL success){
                                             if(!success) {
                                                 // present in app web view, the app is not installed
                                                 TAPWebViewViewController *webViewController = [[TAPWebViewViewController alloc] init];
                                                 webViewController.urlString = url.absoluteString;
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
}

- (void)handleTappedWithPhoneNumber:(NSString *)phoneNumber originalString:(NSString *)originalString {
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *stringURL = [NSString stringWithFormat:@"tel:%@", phoneNumber];
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:stringURL]]) {
        if(IS_IOS_11_OR_ABOVE) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringURL] options:[NSDictionary dictionary] completionHandler:nil];
        }
        else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:stringURL]];
        }
    }
}

- (void)playVideoWithMessage:(TAPMessageModel *)message {
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
    
    if (filePath == nil || [filePath isEqualToString:@""]
        //|| ![[NSFileManager defaultManager] fileExistsAtPath:filePath]
        ) {
        [self showFileNotFoundPopUpWithMessage:message];
        return;
    }
    
    NSURL *url = [NSURL fileURLWithPath:filePath];
    AVAsset *asset = [AVAsset assetWithURL:url];
    
    if (asset == nil) {
        [self showFileNotFoundPopUpWithMessage:message];
        return;
    }
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:item];
    
    AVPlayerViewController *controller = [[AVPlayerViewController alloc] init];
    controller.delegate = self;
    controller.showsPlaybackControls = YES;
    [self presentViewController:controller animated:YES completion:nil];
    controller.player = player;
    [player play];
}

- (void)showFileNotFoundPopUpWithMessage:(TAPMessageModel *)message {
    NSString *roomID = message.room.roomID;
    NSDictionary *dataDictionary = message.data;
    dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];
    
    NSString *fileID = [dataDictionary objectForKey:@"fileID"];
    fileID = [TAPUtil nullToEmptyString:fileID];
    if (![fileID isEqualToString:@""]) {
        [[TAPFileDownloadManager sharedManager] removeDownloadedFilePathWithKey:fileID roomID:roomID];
    }
    
    NSString *fileURL = [dataDictionary objectForKey:@"fileURL"];
    fileURL = [TAPUtil nullToEmptyString:fileURL];
    if (![fileURL isEqualToString:@""]) {
        [[TAPFileDownloadManager sharedManager] removeDownloadedFilePathWithKey:fileURL roomID:roomID];
    }

    NSString *url = [dataDictionary objectForKey:@"url"];
    url = [TAPUtil nullToEmptyString:url];
    if (![url isEqualToString:@""]) {
        [[TAPFileDownloadManager sharedManager] removeDownloadedFilePathWithKey:url roomID:roomID];
    }
    
    NSIndexPath *messageIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    @try {
        [self.tableView performBatchUpdates:^{
           [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:messageIndexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        completion:^(BOOL finished) {
            
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.reason);
        [self.tableView reloadData];
    }
        
    [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDefault
                     popupIdentifier:@"File Not Found"
                               title:NSLocalizedStringFromTableInBundle(@"Could not find file", nil, [TAPUtil currentBundle], @"")
                   detailInformation:NSLocalizedStringFromTableInBundle(@"We could not find this file in your storage, would you like to download it?", nil, [TAPUtil currentBundle], @"")
               leftOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"")
      singleOrRightOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"OK", nil, [TAPUtil currentBundle], @"")];
    
    _pendingRedownloadMessage = message;
}

- (NSString *)getUserNameFromTappedMention:(NSString *)word
                             tappedAtIndex:(NSInteger)index
                       mentionIndexesArray:(NSArray *)mentionIndexesArray {
    
    NSString *username = @"";
    for (NSInteger counter = 0; counter < [mentionIndexesArray count]; counter++) {
        NSRange userRange = [[mentionIndexesArray objectAtIndex:counter] rangeValue];
        
        NSInteger locationStart = userRange.location;
        NSInteger locationEnd = locationStart + userRange.length - 1;
        
        if (index >= locationStart && index <= locationEnd) {
            username = [word substringWithRange:userRange];
            break;
        }
    }
    
    NSString *prefixToRemove = @"@";
    if ([username hasPrefix:prefixToRemove]) {
        username = [username substringFromIndex:[prefixToRemove length]];
    }
    
    return username;
}

- (void)tapTalkUserMentionTappedWithWord:(NSString *)word
                           tappedAtIndex:(NSInteger)index
                                 message:(TAPMessageModel *)message
                     mentionIndexesArray:(NSArray *)mentionIndexesArray {
    
    NSString *username = [self getUserNameFromTappedMention:word tappedAtIndex:index mentionIndexesArray:mentionIndexesArray];
    
    if ([username isEqualToString:[TAPDataManager getActiveUser].username]) {
        return;
    }
    
    BOOL isParticipant = NO;
    TAPUserModel *user = nil;
    user = [self.participantListDictionary objectForKey:username];
    if (user != nil) {
        isParticipant = YES;
    }
    
    if (isParticipant) {
        //Client implement the delegate for handle tap mention
        id<TapUIChatRoomDelegate> tapUIChatRoomDelegate = [TapUI sharedInstance].chatRoomDelegate;
        if ([tapUIChatRoomDelegate respondsToSelector:@selector(tapTalkUserMentionTappedWithRoom:mentionedUser:isRoomParticipant:message:currentViewController:currentShownNavigationController:)]) {
            [tapUIChatRoomDelegate tapTalkUserMentionTappedWithRoom:message.room mentionedUser:user isRoomParticipant:isParticipant message:message currentViewController:self currentShownNavigationController:self.navigationController];
            return;
        }
        
        TAPProfileViewController *profileViewController = [[TAPProfileViewController alloc] init];
        profileViewController.room = self.message.room;
        profileViewController.user = user;
        profileViewController.delegate = self;
        profileViewController.tapProfileViewControllerType = TAPProfileViewControllerTypeGroupMemberProfile;
        [self.navigationController pushViewController:profileViewController animated:YES];
    }
    else {
        //User not found in participant
        //Check if user is exist
        id<TapUIChatRoomDelegate> tapUIChatRoomDelegate = [TapUI sharedInstance].chatRoomDelegate;
        [TAPDataManager callAPIGetUserByUsername:username success:^(TAPUserModel *user) {
            //User found, open profile
            TAPRoomModel *room = [TAPRoomModel createPersonalRoomIDWithOtherUser:user];
            
            //Client implement the delegate for handle tap mention
            if ([tapUIChatRoomDelegate respondsToSelector:@selector(tapTalkUserMentionTappedWithRoom:mentionedUser:isRoomParticipant:message:currentViewController:currentShownNavigationController:)]) {
                [tapUIChatRoomDelegate tapTalkUserMentionTappedWithRoom:room mentionedUser:user isRoomParticipant:isParticipant message:message currentViewController:self currentShownNavigationController:self.navigationController];
                return;
            }
            
            TAPProfileViewController *profileViewController = [[TAPProfileViewController alloc] init];
            profileViewController.room = room;
            profileViewController.user = user;
            profileViewController.otherUserID = user.userID;
            profileViewController.delegate = self;
            profileViewController.tapProfileViewControllerType = TAPProfileViewControllerTypePersonalFromClickedMention;
            [self.navigationController pushViewController:profileViewController animated:YES];
        } failure:^(NSError *error) {
            // User not found show error
            [TAPUtil performBlock:^{
                NSString *errorMessageString = NSLocalizedStringFromTableInBundle(@"User not found", nil, [TAPUtil currentBundle], @"");
                [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"User Not Found" title:NSLocalizedStringFromTableInBundle(@"Failed", nil, [TAPUtil currentBundle], @"") detailInformation:errorMessageString leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
            } afterDelay:0.1f];
        }];
    }
}

- (void)taptTalkUserMentionLongPressedWithWord:(NSString *)word
                                 tappedAtIndex:(NSInteger)index
                                       message:(TAPMessageModel *)message
                           mentionIndexesArray:(NSArray *)mentionIndexesArray {
    
    NSString *username = [self getUserNameFromTappedMention:word tappedAtIndex:index mentionIndexesArray:mentionIndexesArray];
    
    if ([username isEqualToString:[TAPDataManager getActiveUser].username]) {
        return;
    }
    
    [TAPUtil tapticImpactFeedbackGenerator];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:username message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *viewProfileAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"View Profile", nil, [TAPUtil currentBundle], @"")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
        [self tapTalkUserMentionTappedWithWord:word tappedAtIndex:index message:message mentionIndexesArray:mentionIndexesArray];
    }];
    
    UIAlertAction *sendMessageAction = [UIAlertAction
                                 actionWithTitle:NSLocalizedStringFromTableInBundle(@"Send Message", nil, [TAPUtil currentBundle], @"")
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     [self sendMessageFromLongPressMentionWithUsername:username message:message];
                                 }];
    
    UIAlertAction *copyAction = [UIAlertAction
                                 actionWithTitle:NSLocalizedStringFromTableInBundle(@"Copy", nil, [TAPUtil currentBundle], @"")
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                     [pasteboard setString:username];
                                 }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
        
                                   }];
    
    UIImage *viewProfileActionImage = [UIImage imageNamed:@"TAPIconUser" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    viewProfileActionImage = [viewProfileActionImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconActionSheetViewProfile]];
    [viewProfileAction setValue:[viewProfileActionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    UIImage *sendMessageActionImage = [UIImage imageNamed:@"TAPIconSMS" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    sendMessageActionImage = [sendMessageActionImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconActionSheetSMS]];
    [sendMessageAction setValue:[sendMessageActionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    UIImage *copyActionImage = [UIImage imageNamed:@"TAPIconCopy" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    copyActionImage = [copyActionImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconActionSheetCopy]];
    [copyAction setValue:[copyActionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    [viewProfileAction setValue:@0 forKey:@"titleTextAlignment"];
    [sendMessageAction setValue:@0 forKey:@"titleTextAlignment"];
    [copyAction setValue:@0 forKey:@"titleTextAlignment"];
    
    UIColor *actionSheetDefaultColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorActionSheetDefaultLabel];
    UIColor *actionSheetCancelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorActionSheetCancelButtonLabel];
    
    [viewProfileAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
    [sendMessageAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
    [copyAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
    [cancelAction setValue:actionSheetCancelColor forKey:@"titleTextColor"];
    
    NSString *usernameWithoutPrefix = [username copy];
    NSString *prefixToRemove = @"@";
    if ([username hasPrefix:prefixToRemove]) {
        usernameWithoutPrefix = [username substringFromIndex:[prefixToRemove length]];
    }
    
    if (![usernameWithoutPrefix isEqualToString:[TAPDataManager getActiveUser].username]) {
        //Selected mention is not ours, show other option besides copy
        if ([[TapUI sharedInstance] isViewProfileMenuEnabled]) {
            [alertController addAction:viewProfileAction];
        }
        if ([[TapUI sharedInstance] isSendMessageMenuEnabled]) {
            [alertController addAction:sendMessageAction];
        }
    }
    
    if ([[TapUI sharedInstance] isCopyMessageMenuEnabled]) {
        [alertController addAction:copyAction];
    }
    [alertController addAction:cancelAction];
    
    [UIView animateWithDuration:0.2f animations:^{
        [self keyboardWillHideWithHeight:0.0f];
    } completion:^(BOOL finished) {
        [self presentViewController:alertController animated:YES completion:^{
            //after animation
        }];
    }];
}

- (void)sendMessageFromLongPressMentionWithUsername:(NSString *)username message:(TAPMessageModel *)message {
    NSString *prefixToRemove = @"@";
    if ([username hasPrefix:prefixToRemove]) {
        username = [username substringFromIndex:[prefixToRemove length]];
    }
    
    TAPUserModel *user = nil;
    user = [self.participantListDictionary objectForKey:username];
    if (user != nil) {
        [[TapUI sharedInstance] createRoomWithOtherUser:user success:^(TapUIChatViewController * _Nonnull chatViewController) {
            chatViewController.hidesBottomBarWhenPushed = YES;
            [[[TapUI sharedInstance] roomListViewController].navigationController pushViewController:chatViewController animated:YES];
        }];
    }
    else {
        //User not found in participant
        //Check if user is exist
        [TAPDataManager callAPIGetUserByUsername:username success:^(TAPUserModel *user) {
            //User found, send message
            [[TapUI sharedInstance] createRoomWithOtherUser:user success:^(TapUIChatViewController * _Nonnull chatViewController) {
                chatViewController.hidesBottomBarWhenPushed = YES;
                [[[TapUI sharedInstance] roomListViewController].navigationController pushViewController:chatViewController animated:YES];
            }];
        } failure:^(NSError *error) {
            // User not found show error
            [TAPUtil performBlock:^{
                NSString *errorMessageString = NSLocalizedStringFromTableInBundle(@"User not found", nil, [TAPUtil currentBundle], @"");
                [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"User Not Found" title:NSLocalizedStringFromTableInBundle(@"Failed", nil, [TAPUtil currentBundle], @"") detailInformation:errorMessageString leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
            } afterDelay:0.1f];
        }];
    }
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
        [self showFileNotFoundPopUpWithMessage:tappedMessage];
        return;
    }
    
    self.currentSelectedFileURL = [NSURL fileURLWithPath:filePath];
    
    QLPreviewController *preview = [[QLPreviewController alloc] init];
    preview.dataSource = self;
    preview.delegate = self;
    
    [self presentViewController:preview animated:YES completion:nil];
}

- (void)openLocationInGoogleMaps:(NSDictionary *)dataDictionary {
    CGFloat latitude = [[dataDictionary objectForKey:@"latitude"] floatValue];
    CGFloat longitude = [[dataDictionary objectForKey:@"longitude"] floatValue];
    NSString *address = [dataDictionary objectForKey:@"address"];
    address = [address stringByReplacingOccurrencesOfString:@" " withString:@"%20"]; //Convert address string format
    
    NSURL *googleMapsURL = [NSURL URLWithString:@"comgooglemaps://"];
    
    if ([[UIApplication sharedApplication] canOpenURL:googleMapsURL]) {
        NSString *urlString = [NSString stringWithFormat:@"comgooglemaps://?center=%f,%f&zoom=14&q=%f,%f",latitude, longitude, latitude, longitude];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    } else {
        // GoogleMaps is not installed. Launch AppStore to install GoogleMaps app
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/id/app/id585027354"]];
    }
}

- (void)openLocationInAppleMaps:(NSDictionary *)dataDictionary {
    CGFloat latitude = [[dataDictionary objectForKey:@"latitude"] floatValue];
    CGFloat longitude = [[dataDictionary objectForKey:@"longitude"] floatValue];
    NSString *address = [dataDictionary objectForKey:@"address"];
    address = [address stringByReplacingOccurrencesOfString:@" " withString:@"%20"]; //Convert address string format
    
    NSURL *appleMapsURL = [NSURL URLWithString:@"maps://"];
    
    if ([[UIApplication sharedApplication] canOpenURL:appleMapsURL]) {
        NSString *urlString = [NSString stringWithFormat:@"maps://?ll=%f,%f&q=%@", latitude, longitude, address];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    } else {
        NSLog(@"Can't use maps://");
    }
}

- (void)voiceMessagePlayingState:(BOOL)isPlaying{
    if (self.currentVoiceNoteMessage != nil) {
        if(self.currentVoiceNoteMessage.type == TAPChatMessageTypeVoice){
            if ([self.currentVoiceNoteMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                //My Chat
                TAPMyVoiceNoteBubbleTableViewCell *cell = (TAPMyVoiceNoteBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell setPlayingState:isPlaying];
            }
            else {
                //Their Chat
                TAPYourVoiceNoteBubbleTableViewCell *cell = (TAPYourVoiceNoteBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell setPlayingState:isPlaying];
               
            }
        }
    }
}

- (void)seekBarUpdate{
    if (self.isMessageAudioPlaying && self.currentVoiceNoteMessage != nil && self.currentVoiceNoteMessage.type == TAPChatMessageTypeVoice) {
        NSTimeInterval currentTime = [[TAPAudioManager sharedManager] getPlayerCurrentTime];
        if ([self.currentVoiceNoteMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
            //My Chat
            TAPMyVoiceNoteBubbleTableViewCell *cell = (TAPMyVoiceNoteBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            
            [cell setAudioSliderMaximumValue:[[TAPAudioManager sharedManager] getPlayerDuration]];
            [cell setAudioSliderValue:currentTime];
            [cell setVoiceNoteDurationLabel:[self secondToMinuteString:currentTime]];
        }
        else {
            //Their Chat
            TAPYourVoiceNoteBubbleTableViewCell *cell = (TAPYourVoiceNoteBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            
            [cell setAudioSliderMaximumValue:[[TAPAudioManager sharedManager] getPlayerDuration]];
            [cell setAudioSliderValue:currentTime];
            [cell setVoiceNoteDurationLabel:[self secondToMinuteString:currentTime]];
        }
    }
}

- (void)resetMessageAudioSlider{
    if (self.currentVoiceNoteMessage != nil) {
        NSDictionary *dataDictionary = self.currentVoiceNoteMessage.data;
        dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];
        NSNumber *vnDuration = [dataDictionary objectForKey:@"duration"];
        NSInteger durationInt = [vnDuration integerValue];
        durationInt /= 1000;
        if (self.currentVoiceNoteMessage.type == TAPChatMessageTypeVoice) {
            if ([self.currentVoiceNoteMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                //My Chat
                TAPMyVoiceNoteBubbleTableViewCell *cell = (TAPMyVoiceNoteBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell setAudioSliderValue:0.0f];
                [cell setPlayingState:NO];
                [cell setVoiceNoteDurationLabel:[self secondToMinuteString:durationInt]];
                
            }
            else {
                //Their Chat
                TAPYourVoiceNoteBubbleTableViewCell *cell = (TAPYourVoiceNoteBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell setAudioSliderValue:0.0f];
                [cell setPlayingState:NO];
                [cell setVoiceNoteDurationLabel:[self secondToMinuteString:durationInt]];
               
            }
        }
    }
}

- (NSString *)secondToMinuteString:(NSInteger)second {
    NSInteger minute = second / 60;
    NSInteger sec = second - (minute * 60);
    
    NSString *minuteString = [@(minute) stringValue];
    NSString *secondString = [@(sec) stringValue];;
    if (minute < 10) {
        minuteString = [NSString stringWithFormat:@"0%ld", minute];
    }
    if (sec < 10) {
        secondString = [NSString stringWithFormat:@"0%ld", sec];
    }
    
    return [NSString stringWithFormat:@"%@.%@", minuteString, secondString];
}

#pragma mark Download

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

- (void)fetchVideoDataWithMessage:(TAPMessageModel *)message {
    [[TAPFileDownloadManager sharedManager] receiveVideoDataWithMessage:message start:^(TAPMessageModel * _Nonnull receivedMessage) {
        //Already Handled via Notification
    } progress:^(CGFloat progress, CGFloat total, TAPMessageModel * _Nonnull receivedMessage) {
        //Already Handled via Notification
    } success:^(NSData * _Nonnull fileData, TAPMessageModel * _Nonnull receivedMessage, NSString * _Nonnull filePath) {
        //Already Handled via Notification
    } failure:^(NSError * _Nonnull error, TAPMessageModel * _Nonnull receivedMessage) {
        //Already Handled via Notification
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

- (void)fileDownloadManagerProgressNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *notificationParameterDictionary = (NSDictionary *)[notification object];
        notificationParameterDictionary = [TAPUtil nullToEmptyDictionary:notificationParameterDictionary];
        
        TAPMessageModel *obtainedMessage = [notificationParameterDictionary objectForKey:@"message"];
        if (obtainedMessage == nil) {
            return;
        }
        
        NSString *roomID = obtainedMessage.room.roomID;
        roomID = [TAPUtil nullToEmptyString:roomID];
        
//        TAPRoomModel *currentRoom = [TAPChatManager sharedManager].activeRoom;
        //NSString *currentActiveRoomID = self.currentRoom.roomID;
        //currentActiveRoomID = [TAPUtil nullToEmptyString:currentActiveRoomID];
        
       // if (![roomID isEqualToString:currentActiveRoomID]) {
         //   return;
        //}
        
       // BOOL isSavedMessageRoom = [TAPUtil isSaveMessageRoom:roomID];
       
        
        NSString *localID = obtainedMessage.localID;
        localID = [TAPUtil nullToEmptyString:localID];
        
        NSString *progressString = [notificationParameterDictionary objectForKey:@"progress"];
        CGFloat progress = [progressString floatValue];
        
        NSString *totalString = [notificationParameterDictionary objectForKey:@"total"];
        CGFloat total = [totalString floatValue];
        
        TAPMessageModel *currentMessage = self.message;
        
        TAPChatMessageType type = currentMessage.type;
        if (type == TAPChatMessageTypeImage) {
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                //My Chat
                TAPMyImageBubbleTableViewCell *cell = (TAPMyImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell animateProgressUploadingImageWithProgress:progress total:total];
            }
            else {
                //Their Chat
                TAPYourImageBubbleTableViewCell *cell = (TAPYourImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell animateProgressDownloadingImageWithProgress:progress total:total];
            }
        }
        else if (type == TAPChatMessageTypeFile) {
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                //My Chat
                TAPMyFileBubbleTableViewCell *cell = (TAPMyFileBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell animateProgressDownloadingFileWithProgress:progress total:total];
            }
            else {
                //Their Chat
                TAPYourFileBubbleTableViewCell *cell = (TAPYourFileBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell animateProgressDownloadingFileWithProgress:progress total:total];
            }
        }
        else if (type == TAPChatMessageTypeVideo) {
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                //My Chat
                TAPMyVideoBubbleTableViewCell *cell = (TAPMyVideoBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell animateProgressDownloadingVideoWithProgress:progress total:total];
                [cell setVideoDurationAndSizeProgressViewWithMessage:currentMessage progress:[NSNumber numberWithFloat:progress/total] stateType:TAPMyVideoBubbleTableViewCellStateTypeDownloading];
            }
            else {
                //Their Chat
                TAPYourVideoBubbleTableViewCell *cell = (TAPYourVideoBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell animateProgressDownloadingVideoWithProgress:progress total:total];
                [cell setVideoDurationAndSizeProgressViewWithMessage:currentMessage progress:[NSNumber numberWithFloat:progress/total] stateType:TAPYourVideoBubbleTableViewCellStateTypeDownloading];
            }
        }
        else if (type == TAPChatMessageTypeVoice) {
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                //My Chat
                TAPMyVoiceNoteBubbleTableViewCell *cell = (TAPMyVoiceNoteBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell animateProgressDownloadingFileWithProgress:progress total:total];
            }
            else {
                //Their Chat
                TAPYourVoiceNoteBubbleTableViewCell *cell = (TAPYourVoiceNoteBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell animateProgressDownloadingFileWithProgress:progress total:total];
            }
        }
    });
}

- (void)fileDownloadManagerStartNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *notificationParameterDictionary = (NSDictionary *)[notification object];
        notificationParameterDictionary = [TAPUtil nullToEmptyDictionary:notificationParameterDictionary];
        
        TAPMessageModel *obtainedMessage = [notificationParameterDictionary objectForKey:@"message"];
        if (obtainedMessage == nil) {
            return;
        }
        
        NSString *roomID = obtainedMessage.room.roomID;
        roomID = [TAPUtil nullToEmptyString:roomID];
        
//        TAPRoomModel *currentRoom = [TAPChatManager sharedManager].activeRoom;
       // NSString *currentActiveRoomID = self.currentRoom.roomID;
       // currentActiveRoomID = [TAPUtil nullToEmptyString:currentActiveRoomID];
        
        //if (![roomID isEqualToString:currentActiveRoomID]) {
         //   return;
       // }
        
       // BOOL isSavedMessageRoom = [TAPUtil isSaveMessageRoom:roomID];
       // BOOL isForwardedSavedMessage = NO;
        
      //  if((![obtainedMessage.forwardFrom.localID isEqualToString:@""] && obtainedMessage.forwardFrom != nil) && isSavedMessageRoom){
       //     isForwardedSavedMessage = YES;
      //  }
        
        NSString *localID = obtainedMessage.localID;
        localID = [TAPUtil nullToEmptyString:localID];
        
        TAPMessageModel *currentMessage = self.message;
        
        TAPChatMessageType type = currentMessage.type;

        if (type == TAPChatMessageTypeImage) {
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                //My Chat
                TAPMyImageBubbleTableViewCell *cell = (TAPMyImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                
                if (currentMessage.isFailedSend) {
                    [cell setInitialAnimateUploadingImageWithType:TAPMyImageBubbleTableViewCellStateTypeFailed];
                }
                else {
                    [cell setInitialAnimateUploadingImageWithType:TAPMyImageBubbleTableViewCellStateTypeDownloading];
                }
            }
            else {
                //Their Chat
                TAPYourImageBubbleTableViewCell *cell = (TAPYourImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell setInitialAnimateDownloadingImage];
            }
        }
        else if (type == TAPChatMessageTypeFile) {
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                //My Chat
                TAPMyFileBubbleTableViewCell *cell = (TAPMyFileBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                
                [cell showFileBubbleStatusWithType:TAPMyFileBubbleTableViewCellStateTypeDownloading];
            }
            else {
                //Their Chat
                TAPYourFileBubbleTableViewCell *cell = (TAPYourFileBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell showFileBubbleStatusWithType:TAPYourFileBubbleTableViewCellStateTypeDownloading];
            }
        }
        else if (type == TAPChatMessageTypeVoice) {
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                //My Chat
                TAPMyVoiceNoteBubbleTableViewCell *cell = (TAPMyVoiceNoteBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                
                [cell showFileBubbleStatusWithType:TAPMyVoiceNoteBubbleTableViewCellStateTypeDownloading];
            }
            else {
                //Their Chat
                TAPYourVoiceNoteBubbleTableViewCell *cell = (TAPYourVoiceNoteBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell showFileBubbleStatusWithType:TAPYourVoiceNoteBubbleTableViewCellStateTypeDownloading];
            }
        }
        else if (type == TAPChatMessageTypeVideo) {
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                //My Chat
                TAPMyVideoBubbleTableViewCell *cell = (TAPMyVideoBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell showVideoBubbleStatusWithType:TAPMyVideoBubbleTableViewCellStateTypeDownloading];
            }
            else {
                //Their Chat
                TAPYourVideoBubbleTableViewCell *cell = (TAPYourVideoBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell showVideoBubbleStatusWithType:TAPYourVideoBubbleTableViewCellStateTypeDownloading];
            }
        }
    });
}

- (void)fileDownloadManagerFinishNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *notificationParameterDictionary = (NSDictionary *)[notification object];
        notificationParameterDictionary = [TAPUtil nullToEmptyDictionary:notificationParameterDictionary];
        
        TAPMessageModel *obtainedMessage = [notificationParameterDictionary objectForKey:@"message"];
        if (obtainedMessage == nil) {
            return;
        }
        NSString *roomID = obtainedMessage.room.roomID;
        roomID = [TAPUtil nullToEmptyString:roomID];
        
//        TAPRoomModel *currentRoom = [TAPChatManager sharedManager].activeRoom;
       // NSString *currentActiveRoomID = self.currentRoom.roomID;
        //currentActiveRoomID = [TAPUtil nullToEmptyString:currentActiveRoomID];
        
    //    if (![roomID isEqualToString:currentActiveRoomID]) {
      //      return;
       // }
        //
       // NSString *localID = obtainedMessage.localID;
        //localID = [TAPUtil nullToEmptyString:localID];
        
        TAPMessageModel *currentMessage = self.message;
        //NSArray *messageArray = [self.messageArray copy];
        //NSInteger currentRowIndex = [messageArray indexOfObject:currentMessage];
        
       // BOOL isSavedMessageRoom = [TAPUtil isSaveMessageRoom:roomID];
       // BOOL isForwardedSavedMessage = NO;
        
        //if((![obtainedMessage.forwardFrom.localID isEqualToString:@""] && obtainedMessage.forwardFrom != nil) && isSavedMessageRoom){
         //   isForwardedSavedMessage = YES;
       // }
        
        TAPChatMessageType type = currentMessage.type;
        if (type == TAPChatMessageTypeImage) {
            
            UIImage *fullImage = [notificationParameterDictionary objectForKey:@"fullImage"];
            
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                //My Chat
                TAPMyImageBubbleTableViewCell *cell = (TAPMyImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                if ([cell isKindOfClass:[TAPMyImageBubbleTableViewCell class]] &&
                    fullImage != nil &&
                    [fullImage isKindOfClass:[UIImage class]]
                ) {
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
                TAPYourImageBubbleTableViewCell *cell = (TAPYourImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                if ([cell isKindOfClass:[TAPYourImageBubbleTableViewCell class]] &&
                    fullImage != nil &&
                    [fullImage isKindOfClass:[UIImage class]]
                ) {
                    [cell setFullImage:fullImage];
                }
                [cell animateFinishedDownloadingImage];
            }
        }
        else if (type == TAPChatMessageTypeFile) {
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID] ) {
                //My Chat
                TAPMyFileBubbleTableViewCell *cell = (TAPMyFileBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                if (!currentMessage.isFailedSend) {
                    [cell animateFinishedDownloadFile];
                }
                else {
                    [cell animateFailedUploadFile];
                }
            }
            else {
                //Their Chat
                TAPYourFileBubbleTableViewCell *cell = (TAPYourFileBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell animateFinishedDownloadFile];
            }
        }
        else if (type == TAPChatMessageTypeVoice) {
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                //My Chat
                TAPMyVoiceNoteBubbleTableViewCell *cell = (TAPMyVoiceNoteBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0  inSection:0]];
                if (!currentMessage.isFailedSend) {
                    [cell animateFinishedDownloadFile];
                }
                else {
                    [cell animateFailedUploadFile];
                }
            }
            else {
                //Their Chat
                TAPYourVoiceNoteBubbleTableViewCell *cell = (TAPYourVoiceNoteBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell animateFinishedDownloadFile];
            }
        }
        else if (type == TAPChatMessageTypeVideo) {
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                //My Chat
                TAPMyVideoBubbleTableViewCell *cell = (TAPMyVideoBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
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
                TAPYourVideoBubbleTableViewCell *cell = (TAPYourVideoBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell animateFinishedDownloadVideo];
                [cell setVideoDurationAndSizeProgressViewWithMessage:currentMessage progress:nil stateType:TAPYourVideoBubbleTableViewCellStateTypeDoneDownloaded];
                [cell setThumbnailImageForVideoWithMessage:currentMessage];
            }
        }
    });
}

- (void)fileDownloadManagerFailureNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *notificationParameterDictionary = (NSDictionary *)[notification object];
        notificationParameterDictionary = [TAPUtil nullToEmptyDictionary:notificationParameterDictionary];
        
        TAPMessageModel *obtainedMessage = [notificationParameterDictionary objectForKey:@"message"];
        if (obtainedMessage == nil) {
            return;
        }
        NSError *error = [notificationParameterDictionary objectForKey:@"error"];
        
        NSString *roomID = obtainedMessage.room.roomID;
        roomID = [TAPUtil nullToEmptyString:roomID];
        
//        TAPRoomModel *currentRoom = [TAPChatManager sharedManager].activeRoom;
        NSString *currentActiveRoomID = self.message.room.roomID;
        currentActiveRoomID = [TAPUtil nullToEmptyString:currentActiveRoomID];
        
        if (![roomID isEqualToString:currentActiveRoomID]) {
            return;
        }
        
        NSString *localID = obtainedMessage.localID;
        localID = [TAPUtil nullToEmptyString:localID];
        
        NSInteger currentRowIndex = 0;
        
        TAPMessageModel *currentMessage = self.message;
        TAPChatMessageType type = currentMessage.type;
        
        if (type == TAPChatMessageTypeImage) {
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                //My Chat
                TAPMyImageBubbleTableViewCell *cell = (TAPMyImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                [cell animateFailedUploadingImage];
            }
            else {
                //Their Chat
                TAPYourImageBubbleTableViewCell *cell = (TAPYourImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                [cell animateFailedDownloadingImage];
            }
        }
        else if (type == TAPChatMessageTypeFile) {
            if (error.code == NSURLErrorCancelled) {
                // canceled
                if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                    //My Chat
                    TAPMyFileBubbleTableViewCell *cell = (TAPMyFileBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                    @try {
                        [self.tableView performBatchUpdates:^{
                            //changing beginUpdates and endUpdates with this because of deprecation
                            [cell animateCancelDownloadFile];
                        } completion:^(BOOL finished) {
                        }];
                    }
                    @catch (NSException *exception) {
                        NSLog(@"%@", exception.reason);
                        [self.tableView reloadData];
                    }
                }
                else {
                    //Their Chat
                    TAPYourFileBubbleTableViewCell *cell = (TAPYourFileBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                    @try {
                        [self.tableView performBatchUpdates:^{
                            //changing beginUpdates and endUpdates with this because of deprecation
                            [cell animateCancelDownloadFile];
                        } completion:^(BOOL finished) {
                        }];
                    }
                    @catch (NSException *exception) {
                        NSLog(@"%@", exception.reason);
                        [self.tableView reloadData];
                    }
                }
            } else {
                // failed
                if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                    //My Chat
                    TAPMyFileBubbleTableViewCell *cell = (TAPMyFileBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                    [cell animateFailedDownloadFile];
                }
                else {
                    //Their Chat
                    TAPYourFileBubbleTableViewCell *cell = (TAPYourFileBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                    [cell animateFailedDownloadFile];
                }
            }
            
        }
        else if (type == TAPChatMessageTypeVoice) {
            if (error.code == NSURLErrorCancelled) {
                // canceled
                if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                    //My Chat
                    TAPMyVoiceNoteBubbleTableViewCell *cell = (TAPMyVoiceNoteBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                    @try {
                        [self.tableView performBatchUpdates:^{
                            //changing beginUpdates and endUpdates with this because of deprecation
                            [cell animateCancelDownloadFile];
                        } completion:^(BOOL finished) {
                        }];
                    }
                    @catch (NSException *exception) {
                        NSLog(@"%@", exception.reason);
                        [self.tableView reloadData];
                    }
                }
                else {
                    //Their Chat
                    TAPYourVoiceNoteBubbleTableViewCell *cell = (TAPYourVoiceNoteBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                    @try {
                        [self.tableView performBatchUpdates:^{
                            //changing beginUpdates and endUpdates with this because of deprecation
                            [cell animateCancelDownloadFile];
                        } completion:^(BOOL finished) {
                        }];
                    }
                    @catch (NSException *exception) {
                        NSLog(@"%@", exception.reason);
                        [self.tableView reloadData];
                    }
                }
            } else {
                // failed
                if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                    //My Chat
                    TAPMyVoiceNoteBubbleTableViewCell *cell = (TAPMyVoiceNoteBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                    [cell animateFailedDownloadFile];
                }
                else {
                    //Their Chat
                    TAPYourVoiceNoteBubbleTableViewCell *cell = (TAPYourVoiceNoteBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                    [cell animateFailedDownloadFile];
                }
            }
            
        }
        else if (type == TAPChatMessageTypeVideo) {
            if (error.code == NSURLErrorCancelled) {
                // canceled
                if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                    //My Chat
                    TAPMyVideoBubbleTableViewCell *cell = (TAPMyVideoBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                    @try {
                        [self.tableView performBatchUpdates:^{
                            //changing beginUpdates and endUpdates with this because of deprecation
                            [cell animateCancelDownloadVideo];
                        } completion:^(BOOL finished) {
                        }];
                    }
                    @catch (NSException *exception) {
                        NSLog(@"%@", exception.reason);
                        [self.tableView reloadData];
                    }
                }
                else {
                    //Their Chat
                    TAPYourVideoBubbleTableViewCell *cell = (TAPYourVideoBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                    @try {
                        [self.tableView performBatchUpdates:^{
                            //changing beginUpdates and endUpdates with this because of deprecation
                            [cell animateCancelDownloadVideo];
                        } completion:^(BOOL finished) {
                        }];
                    }
                    @catch (NSException *exception) {
                        NSLog(@"%@", exception.reason);
                        [self.tableView reloadData];
                    }
                }
            } else {
                // failed
                if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                    //My Chat
                    TAPMyVideoBubbleTableViewCell *cell = (TAPMyVideoBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                    [cell animateFailedDownloadVideo];
                }
                else {
                    //Their Chat
                    TAPYourVideoBubbleTableViewCell *cell = (TAPYourVideoBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                    [cell animateFailedDownloadVideo];
                }
            }
        }
    });
}

@end
