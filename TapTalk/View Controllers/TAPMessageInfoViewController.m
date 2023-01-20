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

@interface TAPMessageInfoViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *deliveredToArray;
@property (strong, nonatomic) NSArray *readByArray;
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
            if (!message.isHidden) {
                [cell setMessage:message];
            }
            
            return cell;
            
           
        }
        else if(message.type == TAPChatMessageTypeVoice){
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
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
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

#pragma mark Download Notification
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

/**
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
                    [self.tableView performBatchUpdates:^{
                        //changing beginUpdates and endUpdates with this because of deprecation
                        [cell animateCancelDownloadFile];
                    } completion:^(BOOL finished) {
                    }];
                }
                else {
                    //Their Chat
                    TAPYourFileBubbleTableViewCell *cell = (TAPYourFileBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                    [self.tableView performBatchUpdates:^{
                        //changing beginUpdates and endUpdates with this because of deprecation
                        [cell animateCancelDownloadFile];
                    } completion:^(BOOL finished) {
                    }];
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
                    [self.tableView performBatchUpdates:^{
                        //changing beginUpdates and endUpdates with this because of deprecation
                        [cell animateCancelDownloadFile];
                    } completion:^(BOOL finished) {
                    }];
                }
                else {
                    //Their Chat
                    TAPYourVoiceNoteBubbleTableViewCell *cell = (TAPYourVoiceNoteBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                    [self.tableView performBatchUpdates:^{
                        //changing beginUpdates and endUpdates with this because of deprecation
                        [cell animateCancelDownloadFile];
                    } completion:^(BOOL finished) {
                    }];
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
                    [self.tableView performBatchUpdates:^{
                        //changing beginUpdates and endUpdates with this because of deprecation
                        [cell animateCancelDownloadVideo];
                    } completion:^(BOOL finished) {
                    }];
                }
                else {
                    //Their Chat
                    TAPYourVideoBubbleTableViewCell *cell = (TAPYourVideoBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                    [self.tableView performBatchUpdates:^{
                        //changing beginUpdates and endUpdates with this because of deprecation
                        [cell animateCancelDownloadVideo];
                    } completion:^(BOOL finished) {
                    }];
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
*/

@end
