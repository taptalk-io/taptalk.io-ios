//
//  TAPStarredMessageViewController.m
//  TapTalk
//
//  Created by TapTalk.io on 21/03/22.
//

#import "TAPSecondaryChatViewController.h"
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

#import "TAPCustomAccessoryView.h"
#import "TAPPickLocationViewController.h"
#import "TAPImagePreviewViewController.h"
#import "TAPPhotoAlbumListViewController.h"
#import "TAPPickLocationViewController.h"
#import "TAPForwardListViewController.h"
#import "TAPWebViewViewController.h"
#import "TAPMediaDetailViewController.h"
#import "TapHighlightCustomButtonView.h"

#import <TapTalk/Base64.h>
static const NSInteger kShowChatAnchorOffset = 70.0f;
static const NSInteger kChatAnchorDefaultBottomConstraint = 63.0f;
static const NSInteger kInputMessageAccessoryViewHeight = 52.0f;
static const NSInteger kInputMessageAccessoryExtensionViewDefaultHeight = 68.0f;

@interface TAPSecondaryChatViewController ()<UITableViewDataSource, UITableViewDataSource,TAPMyChatBubbleTableViewCellDelegate, TAPYourChatBubbleTableViewCellDelegate, TAPMyImageBubbleTableViewCellDelegate, TAPYourImageBubbleTableViewCellDelegate, TAPMyLocationBubbleTableViewCellDelegate, TAPYourLocationBubbleTableViewCellDelegate, TAPMyFileBubbleTableViewCellDelegate, TAPYourFileBubbleTableViewCellDelegate, TAPMyVideoBubbleTableViewCellDelegate, TAPYourVideoBubbleTableViewCellDelegate, TAPMyVoiceNoteBubbleTableViewCellDelegate, TAPYourVoiceNoteBubbleTableViewCellDelegate, UINavigationControllerDelegate, TAPGrowingTextViewDelegate, UIDocumentPickerDelegate, UIImagePickerControllerDelegate,TAPPickLocationViewControllerDelegate, TAPChatManagerDelegate>

@property (strong, nonatomic) IBOutlet TAPBaseTableView *tableView;
@property (strong, atomic) NSMutableDictionary *messageDictionary;
@property (strong, nonatomic) IBOutlet UIView *loadMoreMessageLoadingView;
@property (strong, nonatomic) IBOutlet UILabel *loadMoreMessageLoadingLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *loadMoreMessageLoadingHeightConstraint;
@property (strong, nonatomic) IBOutlet UIImageView *loadMoreMessageLoadingViewImageView;
@property (strong, nonatomic) IBOutlet UIView *emptyStateView;
@property (strong, nonatomic) IBOutlet UILabel *emptyStateTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *emptyStateDescpLabel;
@property (strong, nonatomic) IBOutlet UIImageView *emptyStateImageView;

//pin message
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *unpinViewHeightConstraint;
@property (strong, nonatomic) IBOutlet UILabel *unpinAllLabel;
@property (strong, nonatomic) IBOutlet UIImageView *unpinAllImageView;
@property (strong, nonatomic) IBOutlet UIButton *unpinAllButton;

//loading view
@property (strong, nonatomic) IBOutlet UIView *loadingBackgroundView;
@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet UIImageView *loadingImageView;
@property (strong, nonatomic) IBOutlet UILabel *loadingLabel;


//Composer
@property (strong, nonatomic) IBOutlet TAPCustomAccessoryView *inputMessageAccessoryView;
@property (strong, nonatomic) IBOutlet TAPGrowingTextView *messageTextView;
@property (strong, nonatomic) IBOutlet UIView *sendButtonView;
@property (strong, nonatomic) TapHighlightCustomButtonView *sendButtonHighlightView;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet UIImageView *sendButtonImageView;
@property (strong, nonatomic) IBOutlet UIView *textViewBorderView;

@property (strong, nonatomic) IBOutlet UIButton *attachmentButton;
@property (strong, nonatomic) IBOutlet UIView *attachmentButtonHighlightView;
@property (strong, nonatomic) TapHighlightCustomButtonView *attachmentButtonView;

//Extension View
@property (strong, nonatomic) IBOutlet UIView *quoteView;
@property (strong, nonatomic) IBOutlet UILabel *quoteTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *quoteSubtitleLabel;
@property (strong, nonatomic) IBOutlet TAPImageView *quoteImageView;
@property (strong, nonatomic) IBOutlet UIView *replyMessageView;
@property (strong, nonatomic) IBOutlet UIView *replyMessageInnerContainerView;
@property (strong, nonatomic) IBOutlet UIView *quoteFileView;
@property (strong, nonatomic) IBOutlet UILabel *replyMessageNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *replyMessageMessageLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *inputAccessoryExtensionHeightConstraint;
@property (strong, nonatomic) IBOutlet UIView *inputAccessoryExtensionView;
@property (strong, nonatomic) IBOutlet UIView *extensionSeperatorView;

//Schedule Message
@property (strong, nonatomic) IBOutlet UIView *scheduleMessageBackgroundView;
@property (strong, nonatomic) IBOutlet UIDatePicker *scheduleMessageDatePicker;
@property (strong, nonatomic) IBOutlet UILabel *datePickerTitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *datePickerCancelButton;
@property (strong, nonatomic) IBOutlet UIView *scheduleMessageDatePickerContainerView;
@property (strong, nonatomic) IBOutlet UIView *scheduleMessageSendView;
@property (strong, nonatomic) IBOutlet UIButton *scheduleMessageSendButton;
@property (strong, nonatomic) IBOutlet UILabel *scheduleMessageSendLabel;
@property (strong, nonatomic) TapHighlightCustomButtonView *scheduleMessageHighlightButton;
@property (strong, nonatomic) TAPScheduledMessageModel *selectedScheduleMessage;

@property (strong, nonatomic) IBOutlet UIView *senderInitialNameView;
@property (strong, nonatomic) IBOutlet UILabel *senderInitialNameLabel;
@property (strong, nonatomic) IBOutlet TAPImageView *senderImageView;


@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *messageViewHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewHeightConstraint;


@property (strong, nonatomic) UIView *rightBarInitialNameView;
@property (strong, nonatomic) UILabel *rightBarInitialNameLabel;
@property (strong, nonatomic) TAPImageView *rightBarImageView;
@property (strong, nonatomic) IBOutlet UIImageView *deletedUserImageView;
@property (strong, nonatomic) IBOutlet UIImageView *savedMessageImageView;

@property (strong, nonatomic) TAPMessageModel *currentEditingMessage;

@property (nonatomic) CGFloat loadMoreMessageViewHeight;
@property (nonatomic) CGFloat keyboardHeight;
@property (nonatomic) CGFloat lastKeyboardHeight;
@property (nonatomic) CGFloat initialKeyboardHeight;
@property (nonatomic) CGFloat hiddenKeyboardHeight; // Used to fix table view content inset when scroll view is dragged
@property (nonatomic) CGFloat safeAreaBottomPadding;
@property (nonatomic) CGFloat messageTextViewHeight;
@property (nonatomic) NSInteger lastNumberOfWordArrayForShowMention;
@property (nonatomic) NSInteger lastTypingWordArrayStartIndex;
@property (strong, nonatomic) NSString *lastTypingWordString;

@property (strong, atomic) NSMutableArray *scheduleMessageArray;

@property (strong, atomic) CLLocation *pickedLocation;
@property (strong, nonatomic) NSString *pickedLocationAddress;

@property (strong, nonatomic) TAPDataFileModel *selectedFileScheduleMessage;
@property (strong, nonatomic) NSString *selectedFilePathScheduleMessage;

@property (nonatomic) CGFloat currentInputAccessoryExtensionHeight;

//@property (nonatomic) KeyboardState keyboardState;
@property (nonatomic) BOOL isKeyboardWasShowed;
@property (nonatomic) BOOL isKeyboardShowed;
@property (nonatomic) BOOL isScrollViewDragged;
@property (nonatomic) BOOL isCustomKeyboardAvailable;
@property (nonatomic) BOOL isViewWillAppeared;
@property (nonatomic) BOOL isViewDidAppeared;
@property (nonatomic) BOOL isKeyboardOptionTapped;
@property (nonatomic) BOOL isKeyboardShowedForFirstTime;
@property (nonatomic) BOOL isOnScrollPendingChecking;
@property (nonatomic) BOOL isShowAccessoryView;
@property (nonatomic) BOOL isEditScheduleMessageTimeState;
@property (nonatomic) BOOL isInputAccessoryExtensionShowedFirstTimeOpen;
@property (nonatomic) BOOL isEditingMessage;

@property (strong, nonatomic) NSArray *mediaPreviewDataArray;

- (void)fileDownloadManagerFinishNotification:(NSNotification *)notification;
- (void)addIncomingMessageToArrayAndDictionaryWithMessage:(TAPMessageModel *)message atIndex:(NSInteger)index;

@end

@implementation TAPSecondaryChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _messageDictionary = [NSMutableDictionary dictionary];
    _scheduleMessageArray = [NSMutableArray array];
    
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
    if(self.messageListType == TAPSecondaryChatTypeStarMessage){
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
        }];
    }
    else if(self.messageListType == TAPSecondaryChatTypePinMessage){
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
    else if(self.messageListType == TAPSecondaryChatTypeScheduleMessage){
        NSString *roomID = self.currentRoom.roomID;
        [self showLoadMoreMessageLoadingView:YES];
        self.messageArray = [NSMutableArray new];
        
        [self callAPIGetScheduleMessage:roomID];
        
        _safeAreaBottomPadding = [TAPUtil safeAreaBottomPadding];
        
        self.emptyStateImageView.image = [UIImage imageNamed:@"TAPIconEmptyScheduleMessage" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.emptyStateTitleLabel.text = @"No scheduled message here yet";
        
        //Rotate table view and commit animation
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.0];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        
        [self.tableView setTransform:CGAffineTransformMakeRotation(-M_PI)];
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, 58.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - 10.0f);
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
        [UIView commitAnimations];
        
        self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 58.0f, 0.0f);
        self.tableView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorChatRoomBackground];
        
        //self.emptyStateView.alpha = 1.0f;
        self.emptyStateDescpLabel.alpha = 0.0f;
        
        self.navigationController.delegate = self;
        self.tableViewBottomConstraint.constant = kInputMessageAccessoryViewHeight;
        
        self.messageTextViewHeight = 32.0f;
        self.messageTextView.delegate = self;
        self.textViewBorderView.layer.cornerRadius = 18.0f;
        self.textViewBorderView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorChatComposerBackground];
        self.textViewBorderView.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTextFieldBorderInactive].CGColor;
        self.textViewBorderView.layer.borderWidth = 1.0f;
        self.textViewBorderView.clipsToBounds = YES;
        self.messageTextView.minimumHeight = 32.0f;
        self.messageTextView.maximumHeight = 120.0f;
        
        //Setup schedule message date picker
        self.scheduleMessageSendView.layer.cornerRadius = 15.0f;
//        self.scheduleMessageSendButton.layer.masksToBounds = YES;
        
        UIFont *scheduleFontLabel = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontDatePickerTitleLabel];
        
        self.datePickerTitleLabel.font = scheduleFontLabel;
//        self.scheduleMessageSendLabel.font = scheduleFontLabel;
        self.datePickerCancelButton.titleLabel.font = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontDatePickerCancelLabel];
        
//        NSDate *date = self.scheduleMessageDatePicker.date;
//        
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
//        dateFormatter.dateFormat = @"dd/MM/yy";
//
//        NSString *dateString = [dateFormatter stringFromDate: date];
//        
//        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
//        timeFormatter.dateFormat = @"HH:mm";
//
//
//        NSString *timeString = [timeFormatter stringFromDate: date];
//        
//        NSString *scheduleSendAtString = [NSString stringWithFormat:@"Send %@ at %@", dateString, timeString];
//        self.scheduleMessageSendLabel.text = scheduleSendAtString;
        
        [[TAPChatManager sharedManager] addDelegate:self];
        
        [self showInputAccessoryExtensionView:NO];
        _isShowAccessoryView = YES;
        [self reloadInputViews];
        [self.view becomeFirstResponder];
        [self setupInputAccessoryView];
        //[[TAPChatManager sharedManager] checkAndSendPendingScheduleMessage];
    }
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadManagerProgressNotification:) name:TAP_NOTIFICATION_UPLOAD_FILE_PROGRESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadManagerStartNotification:) name:TAP_NOTIFICATION_UPLOAD_FILE_START object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadManagerFinishNotification:) name:TAP_NOTIFICATION_UPLOAD_FILE_FINISH object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadManagerFailureNotification:) name:TAP_NOTIFICATION_UPLOAD_FILE_FAILURE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileDownloadManagerProgressNotification:) name:TAP_NOTIFICATION_DOWNLOAD_FILE_PROGRESS object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileDownloadManagerProgressNotification:) name:TAP_NOTIFICATION_DOWNLOAD_FILE_PROGRESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileDownloadManagerStartNotification:) name:TAP_NOTIFICATION_DOWNLOAD_FILE_START object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileDownloadManagerFinishNotification:) name:TAP_NOTIFICATION_DOWNLOAD_FILE_FINISH object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileDownloadManagerFailureNotification:) name:TAP_NOTIFICATION_DOWNLOAD_FILE_FAILURE object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.view layoutIfNeeded];
    
    if (!self.sendButtonHighlightView) {
        _sendButtonHighlightView = [[TapHighlightCustomButtonView alloc] initWithFrame:CGRectMake(
            0.0f,
            0.0f,
            CGRectGetWidth(self.sendButtonView.frame),
            CGRectGetHeight(self.sendButtonView.frame)
        )];
        [self.sendButtonHighlightView setType:TapHighlightCustomButtonViewTypeClear];
        [self.sendButtonHighlightView setLeftIconImage:[UIImage imageNamed:@"TAPIconSend" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil]];
        [self.sendButtonHighlightView setLeftIconSize:24.0f];
        [self.sendButtonHighlightView setClickAction:@selector(sendButtonDidTapped) target:self];
        [self.sendButtonView addSubview:self.sendButtonHighlightView];
        
        self.sendButtonImageView.alpha = 0.0f;
        self.sendButton.userInteractionEnabled = NO;
    }
    
    if (!self.attachmentButtonView) {
        self.attachmentButtonHighlightView.layer.cornerRadius = CGRectGetWidth(self.attachmentButtonHighlightView.frame) / 2;
        self.attachmentButtonHighlightView.clipsToBounds = YES;
        _attachmentButtonView = [[TapHighlightCustomButtonView alloc] initWithFrame:CGRectMake(
            0.0f,
            0.0f,
            CGRectGetWidth(self.attachmentButtonHighlightView.frame),
            CGRectGetHeight(self.attachmentButtonHighlightView.frame)
        )];
        [self.attachmentButtonView setType:TapHighlightCustomButtonViewTypeClear];
        [self.attachmentButtonView setClickAction:@selector(attachmentButtonDidTapped) target:self];
        [self.attachmentButtonHighlightView addSubview:self.attachmentButtonView];
        
        self.attachmentButton.userInteractionEnabled = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //_isShowAccessoryView = YES;
   // [self reloadInputViews];
  //  [self becomeFirstResponder];
    
    [self setSendButtonActive:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView performWithoutAnimation:^{
        [self.messageTextView becameFirstResponder];
    }];
    
    [UIView performWithoutAnimation:^{
        [self.messageTextView resignFirstResponder];
        [self keyboardWillHideWithHeight:0.0f];
    }];
    _isKeyboardShowed = NO;
    
    if (!self.scheduleMessageHighlightButton) {
        _scheduleMessageHighlightButton = [[TapHighlightCustomButtonView alloc] initWithFrame:CGRectMake(
            0.0f,
            0.0f,
            CGRectGetWidth(self.scheduleMessageSendView.frame),
            CGRectGetHeight(self.scheduleMessageSendView.frame)
        )];
        [self.scheduleMessageHighlightButton setType:TapHighlightCustomButtonViewTypeDefaultSolid];
        [self.scheduleMessageHighlightButton setContainerViewRadius:15.0f];
        [self.scheduleMessageHighlightButton setLabelFont:[[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontDatePickerTitleLabel]];
        NSDate *date = self.scheduleMessageDatePicker.date;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd/MM/yy";
        NSString *dateString = [dateFormatter stringFromDate: date];
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        timeFormatter.dateFormat = @"HH:mm";
        NSString *timeString = [timeFormatter stringFromDate: date];
        NSString *scheduleSendAtString = [NSString stringWithFormat:@"Send %@ at %@", dateString, timeString];
        [self.scheduleMessageHighlightButton setLabelText:scheduleSendAtString];
        [self.scheduleMessageHighlightButton setClickAction:@selector(datePickerSendButtonDidTapped) target:self];
        [self.scheduleMessageSendView addSubview:self.scheduleMessageHighlightButton];
    }
}

- (void)loadView {
    [super loadView];
    CGFloat extensionHeight = 0.0f;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.0];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView performWithoutAnimation:^{
        self.tableView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - [TAPUtil currentDeviceNavigationBarHeightWithStatusBar:YES iPhoneXLargeLayout:NO] - kInputMessageAccessoryViewHeight - extensionHeight - [TAPUtil safeAreaBottomPadding]);
    }];
    [UIView commitAnimations];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_UPLOAD_FILE_PROGRESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_UPLOAD_FILE_START object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_UPLOAD_FILE_FINISH object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_UPLOAD_FILE_FAILURE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_DOWNLOAD_FILE_PROGRESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_DOWNLOAD_FILE_START object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_DOWNLOAD_FILE_FINISH object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_DOWNLOAD_FILE_FAILURE object:nil];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}
 
- (void)setupNavigationView {
    //This method is used to setup the title view of navigation bar, and also bar button view
    
    //Title View
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - 56.0f - 56.0f, 43.0f)];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(titleView.frame), CGRectGetHeight(titleView.frame))];
    
    UIFont *chatRoomNameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontChatRoomNameLabel];
    UIColor *chatRoomNameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorChatRoomNameLabel];
    
    if(self.messageListType == TAPSecondaryChatTypeStarMessage){
        nameLabel.text = NSLocalizedStringFromTableInBundle(@"Starred Messages", nil, [TAPUtil currentBundle], @"");
    }
    else if(self.messageListType == TAPSecondaryChatTypePinMessage){
        nameLabel.text = NSLocalizedStringFromTableInBundle(@"Pinned Messages", nil, [TAPUtil currentBundle], @"");
    }
    else if(self.messageListType == TAPSecondaryChatTypeScheduleMessage){
        nameLabel.text = NSLocalizedStringFromTableInBundle(@"Scheduled Message", nil, [TAPUtil currentBundle], @"");
        
        //Right Bar Button
        BOOL isShowProfileButtonView = [[TapUI sharedInstance] getProfileButtonInChatRoomVisibleState];
        if (isShowProfileButtonView) {
            //Show profile button view in right bar button
            UIView *rightBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];

            _rightBarInitialNameView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
            self.rightBarInitialNameView.alpha = 0.0f;
            self.rightBarInitialNameView.layer.cornerRadius = CGRectGetHeight(self.rightBarInitialNameView.frame) / 2.0f;
            self.rightBarInitialNameView.clipsToBounds = YES;
            [rightBarView addSubview:self.rightBarInitialNameView];
            
            UIFont *initialNameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontRoomAvatarSmallLabel];
            UIColor *initialNameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRoomAvatarSmallLabel];
            _rightBarInitialNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.rightBarInitialNameView.frame), CGRectGetHeight(self.rightBarInitialNameView.frame))];
            self.rightBarInitialNameLabel.font = initialNameLabelFont;
            self.rightBarInitialNameLabel.textColor = initialNameLabelColor;
            self.rightBarInitialNameLabel.textAlignment = NSTextAlignmentCenter;
            [self.rightBarInitialNameView addSubview:self.rightBarInitialNameLabel];
            
            _rightBarImageView = [[TAPImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
            self.rightBarImageView.layer.cornerRadius = CGRectGetHeight(self.rightBarImageView.frame) / 2.0f;
            self.rightBarImageView.clipsToBounds = YES;
            self.rightBarImageView.contentMode = UIViewContentModeScaleAspectFill;
            [rightBarView addSubview:self.rightBarImageView];
            
            _deletedUserImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.rightBarImageView.frame) + 7.0f, CGRectGetMinY(self.rightBarImageView.frame) + 7.0f, 16.0f, 16.0f)];
            self.deletedUserImageView.image = [UIImage imageNamed:@"TAPIconDeletedUser" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
            self.deletedUserImageView.alpha = 0.0f;
            
            _savedMessageImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.rightBarImageView.frame) + 7.0f, CGRectGetMinY(self.rightBarImageView.frame) + 7.0f, 16.0f, 16.0f)];
            self.savedMessageImageView.image = [UIImage imageNamed:@"TAPIconSaveMessageRoomList" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
            self.savedMessageImageView.alpha = 0.0f;
            [rightBarView addSubview:self.savedMessageImageView];
            
            NSString *profileImageURL = self.currentRoom.imageURL.thumbnail;
            
            BOOL isSavedMessageRoom = [TAPUtil isSaveMessageRoom:self.currentRoom.roomID];

            if(self.currentRoom.deleted.longValue > 0){
                //set deleted account profil pict
                self.rightBarInitialNameView.alpha = 1.0f;
                self.rightBarImageView.alpha = 0.0f;
                self.deletedUserImageView.alpha = 1.0f;
                self.rightBarInitialNameView.backgroundColor = [[TAPUtil getColor:@"191919"] colorWithAlphaComponent:0.4f];
                self.rightBarInitialNameLabel.text =@"";
            }
            else if(isSavedMessageRoom){
                //set saved message profil pict
                self.rightBarInitialNameView.alpha = 1.0f;
                self.rightBarImageView.alpha = 0.0f;
                self.savedMessageImageView.alpha = 1.0f;
                self.rightBarInitialNameView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
                self.rightBarInitialNameLabel.text =@"";
            }
            else if (profileImageURL == nil || [profileImageURL isEqualToString:@""]) {
                BOOL isGroup = NO;
                if (self.currentRoom.type == RoomTypeGroup || self.currentRoom.type == RoomTypeTransaction) {
                    isGroup = YES;
                }
                self.rightBarInitialNameView.alpha = 1.0f;
                self.rightBarImageView.alpha = 0.0f;
                self.rightBarInitialNameView.backgroundColor = [[TAPStyleManager sharedManager] getRandomDefaultAvatarBackgroundColorWithName:self.currentRoom.name];
                self.rightBarInitialNameLabel.text = [[TAPStyleManager sharedManager] getInitialsWithName:self.currentRoom.name isGroup:isGroup];
                
                
            }
            else {
                self.rightBarInitialNameView.alpha = 0.0f;
                self.rightBarImageView.alpha = 1.0f;
                [self.rightBarImageView setImageWithURLString:profileImageURL];
            }
            
            UIButton *rightBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(rightBarView.frame), CGRectGetHeight(rightBarView.frame))];
            [rightBarButton addTarget:self action:@selector(profileImageDidTapped) forControlEvents:UIControlEventTouchUpInside];
            [rightBarView addSubview:rightBarButton];
            
            UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarView];
            [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
        }
        
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

- (void)setupInputAccessoryView {
    //Input Accessory Extension View
    
    //Setup font for composer textview label same as bubble chat body label size
    UIFont *bubbleLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontRightBubbleMessageBody];
    self.messageTextView.textView.font = bubbleLabelFont;
    self.messageTextView.placeholderLabel.font = bubbleLabelFont;
    
    self.sendButtonView.layer.cornerRadius = CGRectGetHeight(self.sendButtonView.frame) / 2.0f;
    self.sendButtonView.clipsToBounds = YES;
    
    self.inputMessageAccessoryView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    UIImage *closeImage = [UIImage imageNamed:@"TAPIconClose" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    closeImage = [closeImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChatRoomCancelQuote]];
   // self.inputMessageAccessoryCloseImageView.image = closeImage;
        
  //  self.replyMessageInnerContainerView.layer.cornerRadius = 4.0f;
    //self.quoteImageView.layer.cornerRadius = 4.0f;
    //self.quoteImageView.clipsToBounds = YES;
    //self.quoteFileView.layer.cornerRadius = CGRectGetHeight(self.quoteImageView.frame)/2.0f;
    
    //self.linkPreviewComposerImageView.layer.cornerRadius = 4.0f;
    //self.linkPreviewComposerImageView.clipsToBounds = YES;
    //self.linkPreviewComposerImageView.backgroundColor = [UIColor clearColor];
    
    //[self checkIsContainQuoteMessage];
   // [self checkIsContainForwardMessage];
}

#pragma mark - Data Source
#pragma mark UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messageArray count];
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
    if (self.messageListType == TAPSecondaryChatTypeStarMessage) {
        return 10.0f;
    }
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.messageListType == TAPSecondaryChatTypeStarMessage) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(tableView.frame), CGRectGetMinY(tableView.frame), CGRectGetWidth(tableView.frame), 10.0f)];
        return view;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (self.messageListType == TAPSecondaryChatTypePinMessage || self.messageListType == TAPSecondaryChatTypeScheduleMessage) {
        return 10.0f;
    }
    return FLT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (self.messageListType == TAPSecondaryChatTypePinMessage || self.messageListType == TAPSecondaryChatTypeScheduleMessage) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(tableView.frame), CGRectGetMinY(tableView.frame), CGRectGetWidth(tableView.frame), 10.0f)];
        return view;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TAPMessageModel *message = [self.messageArray objectAtIndex:indexPath.row];
    
    BOOL isSavedMessageRoom = [TAPUtil isSaveMessageRoom:self.currentRoom.roomID];
    BOOL isForwardedSavedMessage = NO;
    
    if((![message.forwardFrom.localID isEqualToString:@""] && message.forwardFrom != nil) && isSavedMessageRoom){
        isForwardedSavedMessage = YES;
    }
    
    if (([message.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID] && !isForwardedSavedMessage) || self.messageListType == TAPSecondaryChatTypeScheduleMessage) {
        if (message.type == TAPChatMessageTypeText || message.type == TAPChatMessageTypeLink) {
            [tableView registerNib:[TAPMyChatBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPMyChatBubbleTableViewCell description]];
            TAPMyChatBubbleTableViewCell *cell = (TAPMyChatBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPMyChatBubbleTableViewCell description] forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.tag = indexPath.row;
            cell.contentView.tag = indexPath.row;
            cell.userInteractionEnabled = YES;
            cell.contentView.userInteractionEnabled = YES;
            cell.delegate = self;
            if(self.messageListType == TAPSecondaryChatTypeStarMessage){
                [cell setRotaionToDefault];
                [cell showStarMessageIconView];
                [cell showSeperator];
            }
            else if(self.messageListType == TAPSecondaryChatTypePinMessage){
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
            if(self.messageListType == TAPSecondaryChatTypeStarMessage){
                [cell setRotaionToDefault];
                [cell showStarMessageView];
                [cell showSeperatorView];
            }
            else if(self.messageListType == TAPSecondaryChatTypePinMessage){
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
            if(self.messageListType == TAPSecondaryChatTypeStarMessage){
                [cell setRotaionToDefault];
                [cell showStarMessageView];
                [cell showSeperator];
            }
            else if(self.messageListType == TAPSecondaryChatTypePinMessage){
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
            if(self.messageListType == TAPSecondaryChatTypeStarMessage){
                [cell setRotaionToDefault];
                [cell showStarMessageView];
                [cell showSeperator];
            }
            else if(self.messageListType == TAPSecondaryChatTypePinMessage){
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
            if(self.messageListType == TAPSecondaryChatTypeStarMessage){
                [cell setRotaionToDefault];
                [cell showStarMessageView];
                [cell showSeperator];
            }
            else if(self.messageListType == TAPSecondaryChatTypePinMessage){
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
            
            if(self.messageListType == TAPSecondaryChatTypeStarMessage){
                [cell setRotaionToDefault];
                [cell showStarMessageView];
                [cell showSeperator];
            }
            else if(self.messageListType == TAPSecondaryChatTypePinMessage){
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
            if(self.messageListType == TAPSecondaryChatTypeStarMessage){
                [cell setRotaionToDefault];
                [cell showStarMessageView];
                [cell showSeperator];
            }
            else if(self.messageListType == TAPSecondaryChatTypePinMessage){
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
            if(self.messageListType == TAPSecondaryChatTypeStarMessage){
                [cell setRotaionToDefault];
                [cell showStarMessageView];
                [cell showSeperator];
            }
            else if(self.messageListType == TAPSecondaryChatTypePinMessage){
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
            if(self.messageListType == TAPSecondaryChatTypeStarMessage){
                [cell setRotaionToDefault];
                [cell showStarMessageView];
                [cell showSeperator];
            }
            else if(self.messageListType == TAPSecondaryChatTypePinMessage){
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
            if(self.messageListType == TAPSecondaryChatTypeStarMessage){
                [cell setRotaionToDefault];
                [cell showStarMessageView];
                [cell showSeperator];
            }
            else if(self.messageListType == TAPSecondaryChatTypePinMessage){
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
            if(self.messageListType == TAPSecondaryChatTypeStarMessage){
                [cell setRotaionToDefault];
                [cell showStarMessageView];
                [cell showSeperator];
            }
            else if(self.messageListType == TAPSecondaryChatTypePinMessage){
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
            if(self.messageListType == TAPSecondaryChatTypeStarMessage){
                [cell setRotaionToDefault];
                [cell showStarMessageView];
                [cell showSeperator];
            }
            else if(self.messageListType == TAPSecondaryChatTypePinMessage){
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

- (void)myChatBubbleLongPressedWithMessage:(TAPMessageModel *)longPressedMessage {
    [self handleLongPressedWithMessage:longPressedMessage];
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

- (void)myImageBubbleLongPressedWithMessage:(TAPMessageModel *)longPressedMessage {
    [self handleLongPressedWithMessage:longPressedMessage];
}

- (void)myVideoRetryUploadDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage{
    [self goBackToMessage:tappedMessage];
}

- (void)myVideoBubbleLongPressedWithMessage:(TAPMessageModel *)longPressedMessage {
    [self handleLongPressedWithMessage:longPressedMessage];
}

- (void)myFileQuoteViewDidTapped:(TAPMessageModel *)tappedMessage {
    [self goBackToMessage:tappedMessage];
}

- (void)myFileBubbleLongPressedWithMessage:(TAPMessageModel *)longPressedMessage {
    [self handleLongPressedWithMessage:longPressedMessage];
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

- (void)myLocationBubbleLongPressedWithMessage:(TAPMessageModel *)longPressedMessage {
    [self handleLongPressedWithMessage:longPressedMessage];
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

#pragma mark TAPGrowingTextView
- (void)growingTextViewShouldChangeTextInRange:(NSRange)range
                               replacementText:(NSString *)text
                                       newText:(NSString *)newText {
    NSInteger textLength = [newText length];
    if (self.isEditingMessage) {
        NSString *captionString;
        NSString *updatedNewText = newText;
        if (self.currentEditingMessage.type == TAPChatMessageTypeImage || self.currentEditingMessage.type == TAPChatMessageTypeVideo) {
            NSDictionary *dataDictionary = self.currentEditingMessage.data;
            dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];
            captionString = [dataDictionary objectForKey:@"caption"];
            captionString = [TAPUtil nullToEmptyString:captionString];
            if (textLength >= [[TapTalk sharedInstance] getMaxCaptionLength]) {
                updatedNewText = [newText substringToIndex:[[TapTalk sharedInstance] getMaxCaptionLength]];
                self.messageTextView.text = updatedNewText;
                [self.messageTextView setTypingEnabled:NO];
            }
            else{
                [self.messageTextView setTypingEnabled:YES];
            }
            
        }
        else if (self.currentEditingMessage.type == TAPChatMessageTypeText || self.currentEditingMessage.type == TAPChatMessageTypeLink) {
            captionString = self.currentEditingMessage.body;
            if (textLength >= kCharacterLimit) {
                updatedNewText = [newText substringToIndex:kCharacterLimit];
                self.messageTextView.text = updatedNewText;
                [self.messageTextView setTypingEnabled:NO];
            }
            else {
                [self.messageTextView setTypingEnabled:YES];
            }
        }
        
        if ([captionString isEqualToString:updatedNewText]) {
            [self setSendButtonActive:NO];
        }
        else {
            [self setSendButtonActive:YES];
        }
    }
    else {
        [self.messageTextView setTypingEnabled:YES];
    }
    
    if ([newText isEqualToString:@""]) {
        self.lastNumberOfWordArrayForShowMention = 0;
        _lastTypingWordArrayStartIndex = 0;
        _lastTypingWordString = @"";
    }
        
    NSInteger indexChar = 0;
    BOOL isErasing = NO;
    //DV Note
    //When user is erase a character, range.length = 1, but when user add a character range.length = 0
    if (range.length != 0) {
        //User erase a character
        //Example when there is string hello and user would erase char 'o' at the end, range.location would become 4 and range.length = 1
        indexChar = range.location - range.length;
        isErasing = YES;
    }
    else {
        //User added a character
        //Example when there is string hello and user would add char 'w' at the end (become hellow), range.location would become 5 and range.length = 0
        indexChar = range.location;
    }
    
    NSString *trimmedString = [newText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray *wordArray = [trimmedString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger currentWordLength = 0;
    NSString *selectedWord = @"";
    NSInteger numberOfSeparator = [wordArray count] - 1;
    for (NSInteger counter = 0; counter < [wordArray count]; counter++) {
        NSString *word = [wordArray objectAtIndex:counter];
        currentWordLength = currentWordLength + [word length];
        if(indexChar - (numberOfSeparator - 1) <= currentWordLength) {
            selectedWord = word;
            _lastTypingWordArrayStartIndex = counter;
            _lastTypingWordString = selectedWord;
            break;
        }
    }

    
   
           
//    [self filterMentionListWithKeyword:selectedWord];
//    if ([self.filteredMentionListArray count] == 0) {
//        [self showMentionListView:NO animated:YES];
//        [self.mentionListTableView reloadData];
//    }
//    else {
//        if (self.mentionListTableView.alpha != 1.0f) {
//            [self showMentionListView:YES animated:YES];
//        }
//
//        [self.mentionListTableView reloadData];
//        [self.mentionListTableView setContentOffset:CGPointZero animated:YES];
//    }

}

- (void)growingTextView:(TAPGrowingTextView *)textView shouldChangeHeight:(CGFloat)height {
    CGFloat previousHeight = self.messageTextViewHeight;
    [UIView animateWithDuration:0.2f animations:^{
        self.messageTextViewHeight = height;
        self.messageTextViewHeightConstraint.constant = height;
        self.messageViewHeightConstraint.constant = self.messageTextViewHeight + 16.0f + 4.0f;
        self.inputMessageAccessoryView.frame = CGRectMake(CGRectGetMinX(self.inputMessageAccessoryView.frame), CGRectGetMinY(self.inputMessageAccessoryView.frame) - height + previousHeight, CGRectGetWidth(self.inputMessageAccessoryView.frame), CGRectGetHeight(self.inputMessageAccessoryView.frame) + height - previousHeight);
        [self.inputMessageAccessoryView layoutIfNeeded];
    }];
}

- (void)growingTextViewDidBeginEditing:(TAPGrowingTextView *)textView {
    
  //  [self setKeyboardStateDefault];
    
    if (textView.text != nil) {
        if (![textView.text isEqualToString:@""]) {
           
        }
    }
}

- (void)growingTextViewDidStartTyping:(TAPGrowingTextView *)textView {
    /**
    if(!self.isEditingMessage){
        [self setSendButtonActive:YES];
    }
    */
    [self setSendButtonActive:YES];
}

- (void)growingTextViewDidStopTyping:(TAPGrowingTextView *)textView {
    /**
    if(self.isEditingMessage && (self.currentEditingMessage.type == TAPChatMessageTypeImage || self.currentEditingMessage.type == TAPChatMessageTypeVideo)){
        [self setSendButtonActive:YES];
    }
    else{
        [self setSendButtonActive:NO];
    }
    */
    [self setSendButtonActive:NO];

}

#pragma mark UIScrollView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
   // _isScrollViewDragged = YES;
    [self.view endEditing:YES];
    [self.messageTextView resignFirstResponder];
   // [self keyboardWillHideWithHeight:0.0f];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    /**
    _isScrollViewDragged = NO;
    
    //move chat anchor button position to default position according to keyboard height
    [UIView animateWithDuration:0.2f animations:^{
      
        CGFloat currentKeyboardHeight;
        if (self.isKeyboardShowed) {
            currentKeyboardHeight = self.keyboardHeight;
        }
        else {
            currentKeyboardHeight = self.hiddenKeyboardHeight;
        }
        CGFloat tableViewYContentInset = currentKeyboardHeight - [TAPUtil safeAreaBottomPadding] - kInputMessageAccessoryViewHeight;
        
        self.tableView.contentInset = UIEdgeInsetsMake(tableViewYContentInset, self.tableView.contentInset.left, self.tableView.contentInset.bottom, self.tableView.contentInset.right);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(tableViewYContentInset, self.tableView.scrollIndicatorInsets.left, self.tableView.scrollIndicatorInsets.bottom, self.tableView.scrollIndicatorInsets.right);
        
        [self.view layoutIfNeeded];
        
        if (tableViewYContentInset <= self.safeAreaBottomPadding + kInputMessageAccessoryViewHeight) {
            //set keyboard state to default
            //[self setKeyboardStateDefault];
        }
    }];
    */
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
 
}


#pragma mark Input Accessory

- (__kindof UIView *)inputAccessoryView {
    
    
    if (self.isShowAccessoryView) {
        return self.inputMessageAccessoryView;
        
    }
    else {
        return nil;
        
    }
   
}


- (void)showInputAccessoryView {
    _isShowAccessoryView = YES;
    [self reloadInputViews];
    [self becomeFirstResponder];
}

- (void)hideInputAccessoryView {
    _isShowAccessoryView = NO;
    [self reloadInputViews];
}

- (void)setEditMessageWithMessage:(TAPMessageModel *)message {
    if(message.type == TAPChatMessageTypeText || message.type == TAPChatMessageTypeLink){
        self.replyMessageMessageLabel.text = [TAPUtil nullToEmptyString:message.body];
        self.messageTextView.text = [TAPUtil nullToEmptyString:message.body];
        self.replyMessageNameLabel.text = NSLocalizedStringFromTableInBundle(@"Edit Message", nil, [TAPUtil currentBundle], @"");
    }
    else if(message.type == TAPChatMessageTypeImage || message.type == TAPChatMessageTypeVideo){
        NSDictionary *dataDictionary = message.data;
        dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];
        NSString *captionString = [dataDictionary objectForKey:@"caption"];
        captionString = [TAPUtil nullToEmptyString:captionString];
        
        self.messageTextView.text = [TAPUtil nullToEmptyString:captionString];
        
        TAPMessageModel *quotedMessageModel = [message copy];
        //convert to quote model
        TAPQuoteModel *quote = [TAPQuoteModel constructFromMessageModel:quotedMessageModel];
        [self setEditMessageWithQuote:quote];
    }
    
    self.isEditingMessage = YES;
    [self setSendButtonActive:NO];
    
}

- (void)setEditMessageWithQuote:(TAPQuoteModel *)quote {
    self.quoteTitleLabel.text = NSLocalizedStringFromTableInBundle(@"Edit Message", nil, [TAPUtil currentBundle], @"");
    
    self.quoteSubtitleLabel.text = quote.content;
    
    self.quoteImageView.image = nil;
    
    if ([quote.fileType isEqualToString:[NSString stringWithFormat:@"%ld", TAPChatMessageTypeFile]] || [quote.fileType isEqualToString:@"file"]) {
        //TYPE FILE
        self.quoteFileView.alpha = 1.0f;
        self.quoteImageView.alpha = 0.0f;
    }
    else {
//        if (quote.imageURL != nil && ![quote.imageURL isEqualToString:@""]) {
//            [self.quoteImageView setImageWithURLString:quote.imageURL];
//        }
//        if (self.quoteImageView.image == nil && quote.fileID != nil && ![quote.fileID isEqualToString:@""]) {
//            [self.quoteImageView setImageWithURLString:quote.fileID];
//        }
        if ([quote.fileType isEqualToString:@"image"] && quote.imageURL != nil && ![quote.imageURL isEqualToString:@""]) {
            [self.quoteImageView setImageWithURLString:quote.imageURL];
        }
        else if (quote.fileID != nil && ![quote.fileID isEqualToString:@""]) {
            [self.quoteImageView setImageWithURLString:quote.fileID];
        }
        
        self.quoteFileView.alpha = 0.0f;
        self.quoteImageView.alpha = 1.0f;
    }
    self.isEditingMessage = YES;
    [self setSendButtonActive:NO];
}

- (void)showInputAccessoryExtensionView:(BOOL)show {
    if (show) {
        _currentInputAccessoryExtensionHeight = kInputMessageAccessoryExtensionViewDefaultHeight;
        self.inputAccessoryExtensionView.alpha = 1.0f;
        if (self.isKeyboardShowed) {
            _keyboardHeight = kInputMessageAccessoryViewHeight + self.safeAreaBottomPadding + self.currentInputAccessoryExtensionHeight + self.initialKeyboardHeight;
        }
        else {
            _keyboardHeight = kInputMessageAccessoryViewHeight + self.safeAreaBottomPadding + self.currentInputAccessoryExtensionHeight;
        }
        
        if (self.isKeyboardShowedForFirstTime) {
            [UIView animateWithDuration:0.2f animations:^{
                self.inputAccessoryExtensionHeightConstraint.constant = self.currentInputAccessoryExtensionHeight;
                [self.inputAccessoryView layoutIfNeeded];
                [[[self.inputAccessoryView superview] superview] layoutIfNeeded];
            }];
        }
        else {
            self.inputAccessoryExtensionHeightConstraint.constant = self.currentInputAccessoryExtensionHeight;
        }
        
        if (self.isKeyboardShowed) {
            [self keyboardWillShowWithHeight:self.keyboardHeight];
        }
        else {
            [self keyboardWillHideWithHeight:self.keyboardHeight];
        }
    }
    else {
        _currentInputAccessoryExtensionHeight = 0.0f;
        self.inputAccessoryExtensionView.alpha = 0.0f;
        if (self.isKeyboardShowed) {
            _keyboardHeight = /*kInputMessageAccessoryViewHeight + self.safeAreaBottomPadding +*/ self.currentInputAccessoryExtensionHeight + self.initialKeyboardHeight;
        }
        else {
            _keyboardHeight = kInputMessageAccessoryViewHeight + self.safeAreaBottomPadding + self.currentInputAccessoryExtensionHeight;
        }
        
        if (self.isKeyboardShowedForFirstTime) {
            [UIView animateWithDuration:0.2f animations:^{
                self.inputAccessoryExtensionHeightConstraint.constant = 0.0f;
                [self.inputAccessoryView layoutIfNeeded];
                [[[self.inputAccessoryView superview] superview] layoutIfNeeded];
            }];
        }
        else {
            self.inputAccessoryExtensionHeightConstraint.constant = 0.0f;
        }
        
        if (self.isInputAccessoryExtensionShowedFirstTimeOpen) {
            _initialKeyboardHeight = 0.0f;
            _isInputAccessoryExtensionShowedFirstTimeOpen = NO;
        }
        
        if (self.isKeyboardShowed) {
            [self keyboardWillShowWithHeight:self.keyboardHeight];
        }
        else {
            [self keyboardWillHideWithHeight:self.keyboardHeight];
        }
    }
}

#pragma mark TAPChatManagerDelegate
- (void)chatManagerDidReceiveUpdateScheduleMessage:(NSString *)eventName data:(NSDictionary *)data {
    NSDictionary *room = [data objectForKey:@"room"];
    NSString *roomID = [room objectForKey:@"roomID"];
    
    [self callAPIGetScheduleMessage:roomID];
}

- (void)chatManagerDidReceiveGenerateScheduleMessage:(TAPMessageModel *)message scheduleTime:(NSNumber *)scheduleTime {
    self.emptyStateView.alpha = 0.0f;
    TAPMessageModel *obtainedMessage = message;
    
    obtainedMessage.created = scheduleTime;
    
    NSInteger counter = 0;
    for(TAPMessageModel *message in self.messageArray) {
        if(obtainedMessage.created.longValue < message.created.longValue) {
            
            break;
        }
        counter += 1;
    }
    
    TAPScheduledMessageModel *scheduleMessage = [TAPScheduledMessageModel new];
    
    scheduleMessage.message = obtainedMessage;
    scheduleMessage.scheduleTime = scheduleTime;
    
  //  [[TAPChatManager sharedManager] saveScheduleMessageToPendingMessageArray:scheduleMessage];
    
    [self.messageArray insertObject:obtainedMessage atIndex:counter];
    
    [self.tableView reloadData];
    [self.messageDictionary setObject:obtainedMessage forKey:obtainedMessage.localID];
    
}

#pragma mark Attachment
- (void)openGallery {
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusAuthorized) {
        //        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        //        imagePicker.allowsEditing = NO;
        //        imagePicker.delegate = self;
        //        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //
        //        [self presentViewController:imagePicker animated:YES completion:^{
        //            //completion
        //        }];
        TAPPhotoAlbumListViewController *photoAlbumListViewController = [[TAPPhotoAlbumListViewController alloc] init];
        [photoAlbumListViewController setPhotoAlbumListViewControllerType:TAPPhotoAlbumListViewControllerTypeDefault];
        photoAlbumListViewController.delegate = self;
        if (self.currentRoom.type != RoomTypeChannel) {
            photoAlbumListViewController.isNotFromPersonalRoom = YES;
        }
        [photoAlbumListViewController setParticipantListArray:self.currentRoom.participants];

        UINavigationController *photoAlbumListNavigationController = [[UINavigationController alloc] initWithRootViewController:photoAlbumListViewController];
        photoAlbumListNavigationController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:photoAlbumListNavigationController animated:YES completion:nil];
    }
    else if (status == PHAuthorizationStatusNotDetermined) {
        //request
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self openGallery];
            });
        }];
    }
    else {
        //No permission. Trying to normally request it
        NSString *accessDescription = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSPhotoLibraryUsageDescription"];
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:accessDescription message:NSLocalizedStringFromTableInBundle(@"To give permissions tap on 'Change Settings' button", nil, [TAPUtil currentBundle], @"") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"") style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"Change Settings", nil, [TAPUtil currentBundle], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (IS_IOS_11_OR_ABOVE) {
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


- (void)openCamera {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (status == AVAuthorizationStatusAuthorized) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.allowsEditing = NO;
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:imagePicker animated:YES completion:^{
            //completion
        }];
    }
    else if (status == AVAuthorizationStatusNotDetermined) {
        //request
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self openCamera];
            });
        }];
    }
    else {
        //No permission. Trying to normally request it
        NSString *accessDescription = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSPhotoLibraryUsageDescription"];
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:accessDescription message:NSLocalizedStringFromTableInBundle(@"To give permissions tap on 'Change Settings' button", nil, [TAPUtil currentBundle], @"") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"") style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"Change Settings", nil, [TAPUtil currentBundle], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (IS_IOS_11_OR_ABOVE) {
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

- (void)openFiles {
    UIDocumentPickerViewController *documentPickerViewController = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data"] inMode:UIDocumentPickerModeImport];
    documentPickerViewController.delegate = self;
    documentPickerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:documentPickerViewController animated:YES completion:^{
        //        if (@available(iOS 11.0, *)) {
        //            documentPickerViewController.allowsMultipleSelection = YES;
        //        }
    }];
}

- (void)pickLocation {
    
    [[TAPLocationManager sharedManager] requestAuthorization];
    
    TAPPickLocationViewController *pickLocationViewController = [[TAPPickLocationViewController alloc] init];
    pickLocationViewController.delegate = self;
    pickLocationViewController.selectedLocationCoordinate = CLLocationCoordinate2DMake(-999, -999);
    UINavigationController *pickLocationNavigationController = [[UINavigationController alloc] initWithRootViewController:pickLocationViewController];
    pickLocationNavigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:pickLocationNavigationController animated:YES completion:nil];
}

#pragma mark UIDocumentPicker
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    
    NSError *error = nil;
    NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
    NSLog(@"url file test:%@",[urls firstObject]);
    [coordinator coordinateReadingItemAtURL:[urls firstObject] options:NSFileCoordinatorReadingImmediatelyAvailableMetadataOnly error:&error byAccessor:^(NSURL *newURL) {
        
        NSError *err = nil;
        NSNumber *fileSize;
        if(![[urls firstObject] getPromisedItemResourceValue:&fileSize forKey:NSURLFileSizeKey error:&err]) {
            NSLog(@"Failed error: %@", error);
            return;
        } else {
            
            TAPCoreConfigsModel *coreConfigs = [TAPDataManager getCoreConfigs];
            NSNumber *maxFileSize = coreConfigs.chatMediaMaxFileSize;
            NSInteger maxFileSizeInMB = [maxFileSize integerValue] / 1024 / 1024; //Convert to MB
            if ([fileSize doubleValue] > [maxFileSize doubleValue]) {
                //File size is larger than max file size
                NSString *subjectMessage = NSLocalizedStringFromTableInBundle(@"Maximum file size is ", nil, [TAPUtil currentBundle], @"");
                NSString *errorMessage = [NSString stringWithFormat:@"%@ %ld MB.",subjectMessage, (long)maxFileSizeInMB];
                [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error File Size Excedeed" title:NSLocalizedStringFromTableInBundle(@"Sorry", nil, [TAPUtil currentBundle], @"") detailInformation:errorMessage leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
                return;
            }
            
            NSString *filePath = [[urls firstObject] absoluteString];
            NSString *encodedFileName = [filePath lastPathComponent];
            NSString *decodedFileName = [encodedFileName stringByRemovingPercentEncoding];
            
            //Get Mimetype
            NSString *fileExtension = [newURL pathExtension];
            NSString *mimeType = [TAPUtil mimeTypeForFileWithExtension:fileExtension];
            NSData *fileData = [NSData dataWithContentsOfURL:newURL];
            
            TAPDataFileModel *dataFile = [TAPDataFileModel new];
            dataFile.fileName = decodedFileName;
            dataFile.mediaType = mimeType;
            dataFile.size = fileSize;
            dataFile.fileData = fileData;
            
#ifdef DEBUG
            NSLog(@"FileName: %@ \nMimeType:%@ \nFileSize: %ld",decodedFileName, mimeType, [fileSize doubleValue]);
#endif
           // [[TAPChatManager sharedManager] sendFileMessage:dataFile filePath:filePath];
            self.selectedFileScheduleMessage = dataFile;
            self.selectedFilePathScheduleMessage = filePath;
            
            [self showDatePicker:YES];
        }
    }];
}

- (void)sendFileMessage:(TAPDataFileModel *)dataFile
               filePath:(NSString *)filePath {
    
    //Check if forward message exist, send forward message
  //  [self checkAndSendForwardedMessageWithRoom:room];
    
    NSString *fileName = dataFile.fileName;
    fileName = [TAPUtil nullToEmptyString:fileName];
    
    NSString *mediaType = dataFile.mediaType;
    mediaType = [TAPUtil nullToEmptyString:mediaType];
    
    NSNumber *size = dataFile.size;
    
    NSString *messageBodyString = [NSString stringWithFormat:@"📎 %@", fileName];
    
    NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc] init];

    [dataDictionary setObject:filePath forKey:@"filePath"];
    [dataDictionary setObject:fileName forKey:@"fileName"];
    [dataDictionary setObject:mediaType forKey:@"mediaType"];
    [dataDictionary setObject:size forKey:@"size"];
    
    TAPMessageModel *message = [self createMessageModelWithRoom:nil
                                                           body:messageBodyString
                                                           type:TAPChatMessageTypeFile
                                                    messageData:dataDictionary];
    
    
    //Add message to waiting upload file dictionary in ChatManager to prepare save to database
//    [[TAPChatManager sharedManager] addToWaitingUploadFileMessage:message];
    
  //  [[TAPChatManager sharedManager] notifySendMessageToDelegate:message];
   // [[TAPFileUploadManager sharedManager] sendFileWithData:message];
}



#pragma mark UIImagePickerController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        if ([[info objectForKey:@"UIImagePickerControllerMediaType"] isEqualToString:@"public.image"]) {
            //IMAGE TYPE
            UIImage *selectedImage;
            
            if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
                selectedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
            }
            else if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
                selectedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
            }
            
            [self performSelector:@selector(showImagePreviewControllerWithSelectedImage:) withObject:selectedImage afterDelay:0.3f];
            
        }
    }];
}

#pragma mark TAPPhotoAlbumListViewController
- (void)photoAlbumListViewControllerSelectImageWithDataArray:(NSArray *)dataArray {
    
}

- (void)photoAlbumListViewControllerDidFinishAndSendImageWithDataArray:(NSArray *)dataArray {
    //Handle send image from gallery
    /**
    if(self.currentInputAccessoryExtensionHeight > 0.0f) {
        [self showInputAccessoryExtensionView:NO];
        self.chatAnchorButtonBottomConstrait.constant = kChatAnchorDefaultBottomConstraint + self.keyboardHeight - kInputMessageAccessoryViewHeight;
        self.chatAnchorBackgroundViewBottomConstrait.constant = kChatAnchorDefaultBottomConstraint + self.keyboardHeight - kInputMessageAccessoryViewHeight;
        
//        if (self.chatAnchorBackgroundView.alpha == 1.0f) {
//            self.mentionAnchorButtonBottomConstrait.constant = 20.0f;
//            self.mentionAnchorBackgroundViewBottomConstrait.constant = 20.0f;
//        }
//        else if (self.chatAnchorBackgroundView.alpha == 0.0f) {
//            self.mentionAnchorButtonBottomConstrait.constant = 0.0f;
//            self.mentionAnchorBackgroundViewBottomConstrait.constant = 0.0f;
//        }
        
        CGFloat tableViewYContentInset = self.keyboardHeight - [TAPUtil safeAreaBottomPadding] - kInputMessageAccessoryViewHeight;
        
        self.tableView.contentInset = UIEdgeInsetsMake(tableViewYContentInset, self.tableView.contentInset.left, self.tableView.contentInset.bottom, self.tableView.contentInset.right);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(tableViewYContentInset, self.tableView.scrollIndicatorInsets.left, self.tableView.scrollIndicatorInsets.bottom, self.tableView.scrollIndicatorInsets.right);
    }
    */
    /**
    //hide empty chat
    [UIView animateWithDuration:0.2f animations:^{
        if (self.emptyView.alpha != 0.0f) {
            self.emptyView.alpha = 0.0f;
            self.saveMessageEmptyContainerView.alpha = 0.0f;
        }
    }];
    */
    self.mediaPreviewDataArray = dataArray;
    [self showDatePicker:YES];
    
    //check if keyboard was showed
    //CS NOTE- need to add delay to prevent wrong inset because keyboardwillshow did not called if the method called directly
    //[self performSelector:@selector(checkKeyboard) withObject:nil afterDelay:0.05f];
}

- (void)sendVidioMessage:(PHAsset *)asset caption:(NSString *)caption thumbnailImageData:(NSData *)thumbnailImageData {
    caption = [TAPUtil nullToEmptyString:caption];
    
    NSString *messageBodyCaption = [NSString string];
    //Check contain caption or not
    if ([caption isEqualToString:@""]) {
        messageBodyCaption = NSLocalizedStringFromTableInBundle(@"🎥 Video", nil, [TAPUtil currentBundle], @"");
    }
    else {
        messageBodyCaption = [NSString stringWithFormat:@"🎥 %@", caption];
    }
    
    NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc] init];
    
    CGFloat imageWidthFloat = (CGFloat)asset.pixelWidth;
    CGFloat imageHeightFloat = (CGFloat)asset.pixelHeight;
    
    NSNumber *imageHeight = [NSNumber numberWithFloat:imageHeightFloat];
    NSNumber *imageWidth = [NSNumber numberWithFloat:imageWidthFloat];
    
    NSTimeInterval videoDuration = ceil(asset.duration);
    NSInteger videoDurationInteger = videoDuration * 1000; // in miliseconds
    
    NSString *thumbnailImageBase64String = [thumbnailImageData base64EncodedString];
    
    NSString *assetIdentifier = asset.localIdentifier;
    
//    PHAsset *obtainedAsset = [[TAPFetchMediaManager sharedManager] getAssetFromUserPreferenceWithKey:assetKey];
    
//    PHFetchOptions *allMediaOptions = [[PHFetchOptions alloc] init];
//    allMediaOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
//    PHFetchResult *allMedia = [PHAsset fetchAssetsWithOptions:allMediaOptions];
//
//    [allMedia enumerateObjectsUsingBlock:^(PHAsset * _Nonnull resultAsset, NSUInteger idx, BOOL * _Nonnull stop) {
//
//        if([assetIdentifier isEqualToString:resultAsset.localIdentifier]) {
//            // asset here
//        }
//    }];
    
    //Save asset to dictionary
    [[TAPFileUploadManager sharedManager] saveToPendingUploadAssetDictionaryWithAsset:asset];
    
    [dataDictionary setObject:imageHeight forKey:@"height"];
    [dataDictionary setObject:imageWidth forKey:@"width"];
//    [dataDictionary setObject:asset forKey:@"asset"];
    [dataDictionary setObject:assetIdentifier forKey:@"assetIdentifier"];
    [dataDictionary setObject:thumbnailImageBase64String forKey:@"thumbnail"];
    [dataDictionary setObject:caption forKey:@"caption"];
    [dataDictionary setObject:[NSNumber numberWithInteger:videoDurationInteger] forKey:@"duration"];
    
    TAPMessageModel *message = [self createMessageModelWithRoom:nil
                                                           body:messageBodyCaption
                                                           type:TAPChatMessageTypeVideo
                                                    messageData:dataDictionary];
}

- (void)sendImageMessage:(PHAsset *)asset caption:(NSString *)caption {
    caption = [TAPUtil nullToEmptyString:caption];
    
    NSString *messageBodyCaption = [NSString string];
    //Check contain caption or not
    if ([caption isEqualToString:@""]) {
        messageBodyCaption = NSLocalizedStringFromTableInBundle(@"🖼 Photo", nil, [TAPUtil currentBundle], @"");
    }
    else {
        messageBodyCaption = [NSString stringWithFormat:@"🖼 %@", caption];
    }
    
    NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc] init];
    
    CGFloat imageWidthFloat = (CGFloat)asset.pixelWidth;
    CGFloat imageHeightFloat = (CGFloat)asset.pixelHeight;
    
    NSNumber *imageHeight = [NSNumber numberWithFloat:imageHeightFloat];
    NSNumber *imageWidth = [NSNumber numberWithFloat:imageWidthFloat];
    
    NSString *assetIdentifier = asset.localIdentifier;

    //Save asset to dictionary
    //[[TAPFileUploadManager sharedManager] saveToPendingUploadAssetDictionaryWithAsset:asset];
    
    [dataDictionary setObject:imageHeight forKey:@"height"];
    [dataDictionary setObject:imageWidth forKey:@"width"];
    [dataDictionary setObject:assetIdentifier forKey:@"assetIdentifier"];
    [dataDictionary setObject:caption forKey:@"caption"];
    
    TAPMessageModel *message = [self createMessageModelWithRoom:nil
                                                           body:messageBodyCaption
                                                           type:TAPChatMessageTypeImage
                                                    messageData:dataDictionary];
    
}

#pragma mark TAPPickLocationViewController
- (void)pickLocationViewControllerSetLocationWithLatitude:(CGFloat)latitude
                                                longitude:(CGFloat)longitude
                                                  address:(NSString *)address
                                               postalCode:(NSString *)postalCode {
    self.pickedLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    self.pickedLocationAddress = address;
    [self showDatePicker:YES];
    /**
    if(self.currentInputAccessoryExtensionHeight > 0.0f) {
        [self showInputAccessoryExtensionView:NO];
        self.chatAnchorButtonBottomConstrait.constant = kChatAnchorDefaultBottomConstraint + self.keyboardHeight - kInputMessageAccessoryViewHeight;
        self.chatAnchorBackgroundViewBottomConstrait.constant = kChatAnchorDefaultBottomConstraint + self.keyboardHeight - kInputMessageAccessoryViewHeight;

//        if (self.chatAnchorBackgroundView.alpha == 1.0f) {
//            self.mentionAnchorButtonBottomConstrait.constant = 20.0f;
//            self.mentionAnchorBackgroundViewBottomConstrait.constant = 20.0f;
//        }
//        else if (self.chatAnchorBackgroundView.alpha == 0.0f) {
//            self.mentionAnchorButtonBottomConstrait.constant = 0.0f;
//            self.mentionAnchorBackgroundViewBottomConstrait.constant = 0.0f;
//        }
        
        CGFloat tableViewYContentInset = self.keyboardHeight - [TAPUtil safeAreaBottomPadding] - kInputMessageAccessoryViewHeight;
        
        self.tableView.contentInset = UIEdgeInsetsMake(tableViewYContentInset, self.tableView.contentInset.left, self.tableView.contentInset.bottom, self.tableView.contentInset.right);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(tableViewYContentInset, self.tableView.scrollIndicatorInsets.left, self.tableView.scrollIndicatorInsets.bottom, self.tableView.scrollIndicatorInsets.right);
    }
    */
    
}

- (void)sendLocationMessage:(CGFloat)latitude longitude:(CGFloat)longitude address:(NSString *)address {
    
    //Check if forward message exist, send forward message
   // [self checkAndSendForwardedMessageWithRoom:room];

    NSString *messageBodyString = NSLocalizedStringFromTableInBundle(@"📍Location", nil, [TAPUtil currentBundle], @"");
    
    NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc] init];
    
    [dataDictionary setObject:[NSNumber numberWithFloat:latitude] forKey:@"latitude"];
    [dataDictionary setObject:[NSNumber numberWithFloat:longitude] forKey:@"longitude"];
    [dataDictionary setObject:address forKey:@"address"];
    
    TAPMessageModel *message = [self createMessageModelWithRoom:nil
                                                           body:messageBodyString
                                                           type:TAPChatMessageTypeLocation
                                                    messageData:dataDictionary];
    
}

#pragma mark Keyboard
- (void)keyboardWillShowWithHeight:(CGFloat)keyboardHeight {
    if(!self.isKeyboardShowedForFirstTime) {
        _isKeyboardShowedForFirstTime = YES;
        
        return;
    }
    
    // Commented to prevent incorrectly reassigned keyboardHeight value if this method is called after growing text view had changed height
//        keyboardHeight = CGRectGetHeight([UIScreen mainScreen].bounds) - [self.inputMessageAccessoryView.superview convertPoint:self.inputMessageAccessoryView.frame.origin toView:nil].y;
    
    if (keyboardHeight < 0) {
        return;
    }
    
    if (self.isKeyboardOptionTapped && self.isKeyboardShowed) {
        _keyboardHeight = self.inputAccessoryExtensionHeightConstraint.constant + keyboardHeight;
        CGFloat tableViewYContentInset = self.keyboardHeight - [TAPUtil safeAreaBottomPadding] - kInputMessageAccessoryViewHeight;
        
        [UIView animateWithDuration:0.2f animations:^{
            
//            if (self.chatAnchorBackgroundView.alpha == 1.0f) {
//                self.mentionAnchorButtonBottomConstrait.constant = 20.0f;
//                self.mentionAnchorBackgroundViewBottomConstrait.constant = 20.0f;
//            }
//            else if (self.chatAnchorBackgroundView.alpha == 0.0f) {
//                self.mentionAnchorButtonBottomConstrait.constant = 0.0f;
//                self.mentionAnchorBackgroundViewBottomConstrait.constant = 0.0f;
//            }
            
            self.tableView.contentInset = UIEdgeInsetsMake(tableViewYContentInset, self.tableView.contentInset.left, self.tableView.contentInset.bottom, self.tableView.contentInset.right);
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(tableViewYContentInset, self.tableView.scrollIndicatorInsets.left, self.tableView.scrollIndicatorInsets.bottom, self.tableView.scrollIndicatorInsets.right);
            
            CGFloat safeAreaGap = [TAPUtil safeAreaBottomPadding];
            CGFloat mentionListTableViewBottomValue = self.keyboardHeight;
            if (IS_IPHONE_X_FAMILY) {
                mentionListTableViewBottomValue = mentionListTableViewBottomValue - safeAreaGap;
            }
            
            
        } completion:^(BOOL finished) {
            //Do something after animation completed.
        }];
        
        return;
    }
    
    CGFloat accessoryViewAndSafeAreaHeight = self.safeAreaBottomPadding + kInputMessageAccessoryViewHeight;
    
    //set initial keyboard height to prevent wrong keyboard height usage
    if (self.initialKeyboardHeight == 0.0f && keyboardHeight !=  accessoryViewAndSafeAreaHeight && keyboardHeight != kInputMessageAccessoryViewHeight + self.safeAreaBottomPadding && keyboardHeight != kInputMessageAccessoryViewHeight) {
        _initialKeyboardHeight = keyboardHeight;
    }
    
    if (self.keyboardHeight == 0.0f) {
        //set keyboardHeight if height != accessoryViewAndSafeAreaHeight && keyboardHeight == initialKeyboardHeight
        if (keyboardHeight != accessoryViewAndSafeAreaHeight && keyboardHeight == self.initialKeyboardHeight) {
            _lastKeyboardHeight = self.keyboardHeight;
            _keyboardHeight = keyboardHeight;
        }
    }
    CGFloat tempHeight = 0.0f;
//    if (keyboardHeight > self.keyboardHeight) {
        //set keyboardHeight if height != accessoryViewAndSafeAreaHeight && keyboardHeight == initialKeyboardHeight
//        if (keyboardHeight != accessoryViewAndSafeAreaHeight && keyboardHeight == self.initialKeyboardHeight) {
            tempHeight = self.keyboardHeight;
            _lastKeyboardHeight = self.keyboardHeight;
            _keyboardHeight = keyboardHeight;
//        }
//    }
    
    //handle change keyboard height if keyboard is change to emoji
    if (keyboardHeight > self.initialKeyboardHeight && keyboardHeight != accessoryViewAndSafeAreaHeight) {
        _lastKeyboardHeight = self.keyboardHeight;
        _keyboardHeight = keyboardHeight;
    }
    
    //set keyboard height to initial height
    if (keyboardHeight == self.initialKeyboardHeight && self.isKeyboardShowed) {
        _lastKeyboardHeight = self.keyboardHeight;
        _keyboardHeight = self.initialKeyboardHeight;
    }
    
    //DV Note - 12 Mar 2020
    //adding validation to check if keyHeight is minus
    //    [self.keyboardViewController setKeyboardHeight:self.initialKeyboardHeight - kInputMessageAccessoryViewHeight];
    if (self.isKeyboardShowed) {
        CGFloat keyHeight = self.initialKeyboardHeight - kInputMessageAccessoryViewHeight;
        if (keyHeight < 0.0f) {
            keyHeight = 0.0f;
        }
       // [self.keyboardViewController setKeyboardHeight:keyHeight];
    }
    //END DV Note
    
    //reject if scrollView is being dragged
    if (self.isScrollViewDragged) {
        return;
    }
    
    CGFloat tableViewYContentInset = self.keyboardHeight - [TAPUtil safeAreaBottomPadding] - kInputMessageAccessoryViewHeight;
    
    CGFloat lastTableViewYContentInset = self.tableView.contentInset.top;
    
    self.tableView.contentInset = UIEdgeInsetsMake(tableViewYContentInset, self.tableView.contentInset.left, self.tableView.contentInset.bottom, self.tableView.contentInset.right);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(tableViewYContentInset, self.tableView.scrollIndicatorInsets.left, self.tableView.scrollIndicatorInsets.bottom, self.tableView.scrollIndicatorInsets.right);
    
    CGFloat safeAreaGap = [TAPUtil safeAreaBottomPadding];
    
    
    [UIView animateWithDuration:0.2f animations:^{
        
//        if (self.chatAnchorBackgroundView.alpha == 1.0f) {
//            self.mentionAnchorButtonBottomConstrait.constant = 20.0f;
//            self.mentionAnchorBackgroundViewBottomConstrait.constant = 20.0f;
//        }
//        else if (self.chatAnchorBackgroundView.alpha == 0.0f) {
//            self.mentionAnchorButtonBottomConstrait.constant = 0.0f;
//            self.mentionAnchorBackgroundViewBottomConstrait.constant = 0.0f;
//        }
        
        CGFloat messageViewHeightDifference = self.messageViewHeightConstraint.constant - kInputMessageAccessoryViewHeight;
        if (messageViewHeightDifference < 0) {
            messageViewHeightDifference = 0.0f;
        }
        
        CGFloat newYContentOffset = self.tableView.contentOffset.y - self.keyboardHeight + self.safeAreaBottomPadding + kInputMessageAccessoryViewHeight + messageViewHeightDifference;
        
        /**
        if (fabs(tableViewYContentInset - lastTableViewYContentInset) == kInputMessageAccessoryExtensionViewDefaultHeight) {
            newYContentOffset = self.tableView.contentOffset.y + lastTableViewYContentInset - tableViewYContentInset;
        }
        */
        if(self.isKeyboardShowed) {
            if (self.keyboardHeight > self.lastKeyboardHeight) {
                newYContentOffset = self.tableView.contentOffset.y + (self.lastKeyboardHeight - self.keyboardHeight);
            }
            else {
                newYContentOffset = self.tableView.contentOffset.y;
            }
        }
        
        if(self.tableView.contentOffset.y == 0.0f) {
            newYContentOffset = 0.0f;
        }
        
        if (newYContentOffset < tableViewYContentInset) {
            newYContentOffset = -tableViewYContentInset;
        }
        
        [self.tableView setContentOffset:CGPointMake(0.0f, newYContentOffset)];
        [self.view layoutIfNeeded];
        
        //DV Note - 12 Mar 2020
        //adding validation to check if keyHeight is minus
        //    [self.keyboardViewController setKeyboardHeight:self.initialKeyboardHeight - kInputMessageAccessoryViewHeight];
        if (!self.isKeyboardShowed) {
            CGFloat keyHeight = self.initialKeyboardHeight - kInputMessageAccessoryViewHeight;
            if (keyHeight < 0.0f) {
                keyHeight = 0.0f;
            }
           // [self.keyboardViewController setKeyboardHeight:keyHeight];
        }
        //END DV Note
        
    } completion:^(BOOL finished) {
        //Do something after animation completed.
        //set keyboardHeight if height != accessoryViewAndSafeAreaHeight && keyboardHeight == initialKeyboardHeight
        if (tempHeight != 0.0f && tempHeight != accessoryViewAndSafeAreaHeight && keyboardHeight == self.initialKeyboardHeight) {
            _lastKeyboardHeight = self.keyboardHeight;
            _keyboardHeight = tempHeight;
        }
    }];
    
    if (keyboardHeight != accessoryViewAndSafeAreaHeight && keyboardHeight != kInputMessageAccessoryViewHeight + self.safeAreaBottomPadding && keyboardHeight != kInputMessageAccessoryViewHeight) {
        _isKeyboardShowed = YES;
    }
}

- (void)keyboardWillHideWithHeight:(CGFloat)keyboardHeight {
    
    if (self.isKeyboardOptionTapped && self.isKeyboardShowed) {
        return;
    }
    
    //set default keyboard height including accessory view height
    _keyboardHeight = self.messageViewHeightConstraint.constant + self.safeAreaBottomPadding + self.currentInputAccessoryExtensionHeight;
    _hiddenKeyboardHeight = self.messageViewHeightConstraint.constant + self.safeAreaBottomPadding + self.currentInputAccessoryExtensionHeight;
    
    //reject if scrollView is being dragged
    if (self.isScrollViewDragged) {
        _isKeyboardShowed = NO;
        return;
    }
    
    CGFloat messageViewHeightDifference = self.messageViewHeightConstraint.constant - kInputMessageAccessoryViewHeight;
    if (messageViewHeightDifference < 0) {
        messageViewHeightDifference = 0.0f;
    }
    
    self.tableView.contentInset = UIEdgeInsetsMake(self.currentInputAccessoryExtensionHeight + messageViewHeightDifference, self.tableView.contentInset.left, self.tableView.contentInset.bottom, self.tableView.contentInset.right);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.currentInputAccessoryExtensionHeight, self.tableView.scrollIndicatorInsets.left, self.tableView.scrollIndicatorInsets.bottom, self.tableView.scrollIndicatorInsets.right);
    
    CGFloat safeAreaGap = [TAPUtil safeAreaBottomPadding];
    CGFloat mentionListTableViewBottomValue = self.keyboardHeight;
    if (IS_IPHONE_X_FAMILY) {
        mentionListTableViewBottomValue = mentionListTableViewBottomValue - safeAreaGap;
    }
    
    [UIView animateWithDuration:0.2f animations:^{
        /**
        if(self.isCustomKeyboardAvailable) {
            self.keyboardOptionButtonView.alpha = 1.0f;
            self.keyboardOptionButton.alpha = 1.0f;
            self.keyboardOptionButton.userInteractionEnabled = YES;
            self.messageViewLeftConstraint.constant = 4.0f;
            self.keyboardOptionViewRightConstraint.constant = 16.0f;
            [self.inputMessageAccessoryView layoutIfNeeded];
        }
        */
        
//        if (self.chatAnchorBackgroundView.alpha == 1.0f) {
//            self.mentionAnchorButtonBottomConstrait.constant = 20.0f;
//            self.mentionAnchorBackgroundViewBottomConstrait.constant = 20.0f;
//        }
//        else if (self.chatAnchorBackgroundView.alpha == 0.0f) {
//            self.mentionAnchorButtonBottomConstrait.constant = 0.0f;
//            self.mentionAnchorBackgroundViewBottomConstrait.constant = 0.0f;
//        }
        
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        //Do something after animation completed.
    }];
    
    _isKeyboardShowed = NO;
}

#pragma mark Custom Method
- (void)handleLongPressedWithMessage:(TAPMessageModel *)message {
    
    if(!self.messageListType == TAPSecondaryChatTypeScheduleMessage) {
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSInteger rowIndex = [self.messageArray indexOfObject:message];
    UIAlertAction *sendNowAction = [UIAlertAction
                                 actionWithTitle:NSLocalizedStringFromTableInBundle(@"Send Now", nil, [TAPUtil currentBundle], @"")
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
        TAPScheduledMessageModel *scheduleMessage = [self.scheduleMessageArray objectAtIndex:rowIndex];
        
        [[TAPCoreMessageManager sharedManager] sendScheduledMessageNow:scheduleMessage.scheduleID roomID:message.room.roomID success:^(NSArray<NSNumber *> * _Nonnull sentIDs) {
            
            [self.navigationController popViewControllerAnimated:YES];
            
        } failure:^(NSError * _Nonnull error) {
            
        }];
        
    }];
    
    UIAlertAction *rescheduleAction = [UIAlertAction
                                 actionWithTitle:NSLocalizedStringFromTableInBundle(@"Reschedule", nil, [TAPUtil currentBundle], @"")
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
        self.isEditScheduleMessageTimeState = YES;
        [self showDatePicker:YES];
        TAPScheduledMessageModel *scheduleMessage = [self.scheduleMessageArray objectAtIndex:rowIndex];
        self.selectedScheduleMessage = scheduleMessage;
    }];
    
    UIAlertAction *editAction = [UIAlertAction
                                 actionWithTitle:NSLocalizedStringFromTableInBundle(@"Edit", nil, [TAPUtil currentBundle], @"")
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
        if (message.type == TAPChatMessageTypeText || message.type == TAPChatMessageTypeLink) {
            [self showInputAccessoryExtensionView:NO];
            self.quoteView.alpha = 0.0f;
            self.replyMessageView.alpha = 1.0f;
            [self setEditMessageWithMessage:message];
            [self showInputAccessoryExtensionView:YES];
      
            TAPMessageModel *quotedMessageModel = [message copy];
        }
        else {
            TAPMessageModel *quotedMessageModel = [message copy];
            
            [self showInputAccessoryExtensionView:NO];
            self.quoteView.alpha = 1.0f;
            self.replyMessageView.alpha = 0.0f;
            [self showInputAccessoryExtensionView:YES];
            [self setEditMessageWithMessage:message];
        }
        self.currentEditingMessage = message;
    }];
    
    UIAlertAction *copyAction = [UIAlertAction
                                 actionWithTitle:NSLocalizedStringFromTableInBundle(@"Copy", nil, [TAPUtil currentBundle], @"")
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                     if (message.type == TAPChatMessageTypeText || message.type == TAPChatMessageTypeLink) {
                                         [pasteboard setString:message.body];
                                     }
                                 }];
    
    UIAlertAction *deleteMessageAction = [UIAlertAction
                                          actionWithTitle:NSLocalizedStringFromTableInBundle(@"Delete", nil, [TAPUtil currentBundle], @"")
                                          style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * action) {
        TAPScheduledMessageModel *scheduleMessage = [self.scheduleMessageArray objectAtIndex:rowIndex];
        TAPMessageModel *message = [self.messageArray objectAtIndex:rowIndex];
        [self.scheduleMessageArray removeObject:scheduleMessage];
        [self.messageArray removeObject:message];
        
        [self.tableView reloadData];
        
        if(self.messageArray.count == 0) {
            self.emptyStateView.alpha = 1.0f;
        }
        
        [[TAPCoreMessageManager sharedManager] deleteScheduledMessage:scheduleMessage.scheduleID roomID:message.room.roomID success:^(NSArray<NSNumber *> * _Nonnull deletedIDs) {
            
        } failure:^(NSError * _Nonnull error) {
            
        }];
                                             
                                          }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
                                       //Do some thing here
                                   }];
    
    
    
    UIImage *sendNowActionImage = [UIImage imageNamed:@"TAPIconSendNow" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    sendNowActionImage = [sendNowActionImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconActionSheetCopy]];
    [sendNowAction setValue:[sendNowActionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    UIImage *rescheduleActionImage = [UIImage imageNamed:@"TAPIconReschedule" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    rescheduleActionImage = [rescheduleActionImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconActionSheetCopy]];
    [rescheduleAction setValue:[rescheduleActionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    UIImage *editActionImage = [UIImage imageNamed:@"TAPIconEditMessage" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    editActionImage = [editActionImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconActionSheetCopy]];
    [editAction setValue:[editActionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    UIImage *copyActionImage = [UIImage imageNamed:@"TAPIconCopy" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    copyActionImage = [copyActionImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconActionSheetCopy]];
    [copyAction setValue:[copyActionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    UIImage *deleteMessageActionImage = [UIImage imageNamed:@"TAPIconTrashChatComposer" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    deleteMessageActionImage = [deleteMessageActionImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconActionSheetTrash]];
    [deleteMessageAction setValue:[deleteMessageActionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    [sendNowAction setValue:@0 forKey:@"titleTextAlignment"];
    [rescheduleAction setValue:@0 forKey:@"titleTextAlignment"];
    [editAction setValue:@0 forKey:@"titleTextAlignment"];
    [copyAction setValue:@0 forKey:@"titleTextAlignment"];
    [deleteMessageAction setValue:@0 forKey:@"titleTextAlignment"];
    
    UIColor *actionSheetDefaultColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorActionSheetDefaultLabel];
    UIColor *actionSheetCancelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorActionSheetCancelButtonLabel];
    UIColor *actionSheetDestructiveColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorActionSheetDestructiveLabel];
    
    [sendNowAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
    [rescheduleAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
    [editAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
    [copyAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
    [deleteMessageAction setValue:actionSheetDestructiveColor forKey:@"titleTextColor"];
    [cancelAction setValue:actionSheetCancelColor forKey:@"titleTextColor"];
    
    [alertController addAction:sendNowAction];
    [alertController addAction:rescheduleAction];
    [alertController addAction:editAction];
    
    if ([[TapUI sharedInstance] isCopyMessageMenuEnabled] && (message.type == TAPChatMessageTypeText || message.type == TAPChatMessageTypeLink)) {
        //Show copy action for chat type text only
        [alertController addAction:copyAction];
    }
    
    if ([[TapUI sharedInstance] isDeleteMessageMenuEnabled] && [message.user.userID isEqualToString:[TAPDataManager getActiveUser].userID] && !message.isSending) {
        //Show delete message for our bubble (my bubble) only
        [alertController addAction:deleteMessageAction];
    }
    
    [alertController addAction:cancelAction];
    
    [UIView animateWithDuration:0.2f animations:^{
      //  [self.messageTextView resignFirstResponder];
        [self keyboardWillHideWithHeight:0.0f];
    } completion:^(BOOL finished) {
        [self presentViewController:alertController animated:YES completion:^{
            //after animation
        }];
    }];
}

-(void)goBackToMessage:(TAPMessageModel *)message {
    if(self.messageListType == TAPSecondaryChatTypeStarMessage){
        [self.navigationController popViewControllerAnimated:NO];
        if ([self.delegate respondsToSelector:@selector(starMessageBubbleCliked:)]) {
            [self.delegate starMessageBubbleCliked:message];
        }
    }
    else if(self.messageListType == TAPSecondaryChatTypePinMessage){
        [self.navigationController popViewControllerAnimated:YES];
        if ([self.delegate respondsToSelector:@selector(starMessageBubbleCliked:)]) {
            [self.delegate starMessageBubbleCliked:message];
        }
        
    }
}

- (void)resetScheculeSelectedData {
    self.pickedLocation = nil;
    self.isEditScheduleMessageTimeState = NO;
    self.selectedFileScheduleMessage = nil;
    self.selectedScheduleMessage = nil;
    self.mediaPreviewDataArray = nil;
    self.isEditingMessage = NO;
}

- (void)callAPIGetScheduleMessage:(NSString *)roomID {
    [TAPDataManager callAPIGetScheduleMessage:roomID success:^(NSArray<TAPScheduledMessageModel *> *scheduleMessageArray) {
        self.scheduleMessageArray = [scheduleMessageArray mutableCopy];
        
        if(scheduleMessageArray.count == 0) {
            self.emptyStateView.alpha = 1.0f;
        }
        else {
            self.emptyStateView.alpha = 0.0f;
        }
        
        [self.messageArray removeAllObjects];
        [self.messageDictionary removeAllObjects];
        for(TAPScheduledMessageModel *scheduleMessage in scheduleMessageArray) {
            NSInteger counter = 0;
            NSNumber *scheduledTime = scheduleMessage.scheduleTime;
            for(TAPScheduledMessageModel *schduleMessage in self.scheduleMessageArray){
                if(scheduledTime > scheduleMessage.scheduleTime) {
                    break;
                }
                counter += 1;
            }
            scheduleMessage.message.created = scheduleMessage.scheduleTime;
            [self.messageArray addObject:scheduleMessage.message];
            [self.messageDictionary setObject: scheduleMessage.message forKey: scheduleMessage.message.localID];
        }
        
       // for(TAPScheduleMessageModel *scheduleMessage in [[TAPChatManager sharedManager] pending])
    
        [TAPUtil performBlock:^{
            if(self.chatroomScheduleContentString != nil && ![self.chatroomScheduleContentString isEqualToString:@""]) {
                [self sendScheduleText:self.chatroomScheduleContentString scheduleTime:self.chatRoomScheduleTimne];
                self.chatroomScheduleContentString = nil;
            }
        } afterDelay:0.5f];
        
        
        [self.tableView reloadData];
        [self showLoadMoreMessageLoadingView:NO];
        
    } failure:^(NSError *error) {
        [self showLoadMoreMessageLoadingView:NO];
    }];
}

- (void)setSendButtonActive:(BOOL)isActive {
    if (isActive) {
        self.sendButtonView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChatComposerSendBackground];
//        self.sendButtonImageView.image = [self.sendButtonImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChatComposerSend]];
//        self.sendButton.userInteractionEnabled = YES;
        self.sendButtonHighlightView.button.userInteractionEnabled = YES;
    }
    else {
        self.sendButtonView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChatComposerSendBackgroundInactive];
//        self.sendButtonImageView.image = [self.sendButtonImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChatComposerSendInactive]];
//        self.sendButton.userInteractionEnabled = NO;
        self.sendButtonHighlightView.button.userInteractionEnabled = NO;
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


- (IBAction)attachmentButtonDidTapped:(id)sender {
    [self attachmentButtonDidTapped];
}

- (void)attachmentButtonDidTapped {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *documentsAction = [UIAlertAction
                                      actionWithTitle:NSLocalizedStringFromTableInBundle(@"Documents", nil, [TAPUtil currentBundle], @"")
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          [self performSelector:@selector(openFiles) withObject:nil];
                                      }];
    
    UIAlertAction *cameraAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedStringFromTableInBundle(@"Camera", nil, [TAPUtil currentBundle], @"")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       [self performSelector:@selector(openCamera) withObject:nil];
                                   }];
    
    UIAlertAction *galleryAction = [UIAlertAction
                                    actionWithTitle:NSLocalizedStringFromTableInBundle(@"Gallery", nil, [TAPUtil currentBundle], @"")
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        [self performSelector:@selector(openGallery) withObject:nil];
                                    }];
    
    UIAlertAction *locationAction = [UIAlertAction
                                     actionWithTitle:NSLocalizedStringFromTableInBundle(@"Location", nil, [TAPUtil currentBundle], @"")
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
                                         [self performSelector:@selector(pickLocation) withObject:nil];
                                     }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
                                       //[self checkAndShowInputAccessoryView];
                                       //[self checkKeyboard];
                                   }];
    
    UIImage *documentActionImage = [UIImage imageNamed:@"TAPIconDocuments" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    documentActionImage = [documentActionImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconActionSheetDocument]];
    [documentsAction setValue:[documentActionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    UIImage *cameraActionImage = [UIImage imageNamed:@"TAPIconPhoto" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    cameraActionImage = [cameraActionImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconActionSheetCamera]];
    [cameraAction setValue:[cameraActionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    UIImage *galleryActionImage = [UIImage imageNamed:@"TAPIconGallery" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    galleryActionImage = [galleryActionImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconActionSheetGallery]];
    [galleryAction setValue:[galleryActionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    UIImage *locationActionImage = [UIImage imageNamed:@"TAPIconLocation" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    locationActionImage = [locationActionImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconActionSheetLocation]];
    [locationAction setValue:[locationActionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    [documentsAction setValue:@0 forKey:@"titleTextAlignment"];
    [cameraAction setValue:@0 forKey:@"titleTextAlignment"];
    [galleryAction setValue:@0 forKey:@"titleTextAlignment"];
    [locationAction setValue:@0 forKey:@"titleTextAlignment"];
    
    UIColor *actionSheetDefaultColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorActionSheetDefaultLabel];
    UIColor *actionSheetCancelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorActionSheetCancelButtonLabel];

    [documentsAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
    [cameraAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
    [galleryAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
    [locationAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
    [cancelAction setValue:actionSheetCancelColor forKey:@"titleTextColor"];
    
    if ([[TapUI sharedInstance] isDocumentAttachmentEnabled]) {
        [alertController addAction:documentsAction];
    }
    if ([[TapUI sharedInstance] isCameraAttachmentEnabled]) {
        [alertController addAction:cameraAction];
    }
    if ([[TapUI sharedInstance] isGalleryAttachmentEnabled]) {
        [alertController addAction:galleryAction];
    }
    
    if (//[[TapTalk sharedInstance] obtainGooglePlacesAPIInitializeState] &&
        [[TapUI sharedInstance] isLocationAttachmentEnabled]
    ) {
        //Only show when Google Places API Key is insert
        [alertController addAction:locationAction];
    }

    [alertController addAction:cancelAction];
    
    if (self.messageTextView.isFirstResponder) {
        self.isKeyboardWasShowed = YES;
    }
    else {
        self.isKeyboardWasShowed = NO;
    }
    
    [UIView animateWithDuration:0.2f animations:^{
        [self.messageTextView resignFirstResponder];
        [self keyboardWillHideWithHeight:0.0f];
    } completion:^(BOOL finished) {
        [self presentViewController:alertController animated:YES completion:^{
            //after animation
        }];
    }];
    
}

- (void)showDatePicker:(BOOL)isShow {
    if(isShow) {
        if(self.isEditScheduleMessageTimeState) {
            
        }
        else {
            
        }
        
        long currentTime = [TAPUtil currentTimeInMillis].longValue;
        long plusOneMinute = currentTime + 60000;
        [self.scheduleMessageDatePicker setDate:[NSDate dateWithTimeIntervalSince1970:plusOneMinute/1000]animated:NO];
        
        self.scheduleMessageDatePickerContainerView.alpha = 1.0f;
        [self.messageTextView resignFirstResponder];
        [self hideInputAccessoryView];
    }
    else {
        self.scheduleMessageDatePickerContainerView.alpha = 0.0f;
        [self showInputAccessoryView];
        [self resetScheculeSelectedData];
    }
}

- (IBAction)sendButtonDidTapped:(id)sender {
    [self sendButtonDidTapped];
}

- (void)sendButtonDidTapped {
    if(self.isEditingMessage) {
        self.isEditingMessage = NO;
        NSInteger index = [self.messageArray indexOfObject:self.currentEditingMessage];
        TAPScheduledMessageModel *scheduleMessage = [self.scheduleMessageArray objectAtIndex:index];
        self.currentEditingMessage.body = self.messageTextView.text;
        [TAPDataManager callAPIEditScheduleMessageContent:scheduleMessage.scheduleID updatedMessage:self.currentEditingMessage success:^(BOOL isEditContentSuccess) {
            
        } failure:^(NSError *error) {
            
        }];
        
        [self showInputAccessoryExtensionView:NO];
        self.messageTextView.text = @"";
    }
    else {
        [self showDatePicker:YES];
    }
    
}


- (IBAction)datePickerSendButtonDidTapped:(id)sender {
    [self datePickerSendButtonDidTapped];
}

- (void)datePickerSendButtonDidTapped {
    NSDate *date = self.scheduleMessageDatePicker.date;
    NSNumber *scheduleTime = [NSNumber numberWithDouble:[date timeIntervalSince1970] * 1000.0f];
    
    long currentTime = [TAPUtil currentTimeInMillis].longValue;
    
    if (currentTime > scheduleTime.longValue) {
        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"" title:NSLocalizedStringFromTableInBundle(@"Error", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"Invalid Schedule Time", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
        return;
    }
    
    
    if(self.mediaPreviewDataArray != nil) {
        for (TAPMediaPreviewModel *mediaPreview in self.mediaPreviewDataArray) {
            PHAsset *asset = mediaPreview.asset;
            
            UIImage *thumbnailImage = mediaPreview.thumbnailImage;
            NSData *thumbnailImageData = UIImageJPEGRepresentation(thumbnailImage, [[TapTalk sharedInstance] getImageCompressionQuality]);
            
            NSString *caption = mediaPreview.caption;
            caption = [TAPUtil nullToEmptyString:caption];
            
            if (asset.mediaType == PHAssetMediaTypeImage) {
                [[TAPChatManager sharedManager] sendImageMessageWithPHAsset:asset caption:caption room:[TAPChatManager sharedManager].activeRoom scheduleTime:scheduleTime success:^(TAPMessageModel *message) {
                    
                } failure:^(NSError *error) {
                    
                }];
            }
            else if (asset.mediaType == PHAssetMediaTypeVideo) {
                [[TAPChatManager sharedManager] sendVideoMessageWithPHAsset:asset caption:caption thumbnailImageData:thumbnailImageData scheduleTime:scheduleTime];
            }
            
        }
        
        self.mediaPreviewDataArray = nil;
    }
    else if(self.pickedLocation != nil) {
        CLLocationCoordinate2D coordinate = [self.pickedLocation coordinate];
        [[TAPChatManager sharedManager] sendLocationMessage:coordinate.latitude longitude:coordinate.longitude address:self.pickedLocationAddress room:[TAPChatManager sharedManager].activeRoom scheduleTime:scheduleTime success:^(TAPMessageModel *message) {
        
        } failure:^(NSError *error) {
            
        }];
        self.pickedLocation = nil;
    }
    else if(self.selectedFileScheduleMessage != nil){
        [[TAPChatManager sharedManager] sendFileMessage:self.selectedFileScheduleMessage filePath:self.selectedFilePathScheduleMessage scheduleTime:scheduleTime];
        self.selectedFileScheduleMessage = nil;
    }
    else if(self.isEditScheduleMessageTimeState) {
        self.isEditScheduleMessageTimeState = NO;
        
        NSInteger counter = 0;
        TAPMessageModel *scheduleMessage = self.selectedScheduleMessage.message;
        [self.messageArray removeObject:scheduleMessage];
        scheduleMessage.created = scheduleTime;
        for(TAPMessageModel *message in self.messageArray) {
            if(scheduleMessage.created.longValue < message.created.longValue) {
                
                break;
            }
            counter += 1;
        }
        
        [self.messageArray insertObject:scheduleMessage atIndex:counter];
        
        [self.tableView reloadData];
        
        [TAPDataManager callAPIEditScheduleMessageTime:self.selectedScheduleMessage.scheduleID scheduledTime:scheduleTime success:^(BOOL isEditTimeSuccess) {
            if(isEditTimeSuccess) {
                
            }
        } failure:^(NSError *error) {
            
        }];
    }
    else {
        NSString *body = self.messageTextView.text;
        [self sendScheduleText:body scheduleTime:scheduleTime];
    }
    
    [self showDatePicker:NO];
    
    
}

- (void)sendScheduleText:(NSString *)body scheduleTime:(NSNumber *)scheduleTime {
    [[TAPChatManager sharedManager] sendTextMessage:body room:[TAPChatManager sharedManager].activeRoom scheduleTime:scheduleTime success:^(TAPMessageModel *scheduleMessage) {
        
    }failure:^(NSError *error) {
        
    }];
    
    self.messageTextView.text = @"";
}

- (IBAction)inputExtensionCloseButtonDidTapped:(id)sender {
    [self showInputAccessoryExtensionView:NO];
    self.messageTextView.text = @"";
    self.isEditingMessage = NO;
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


- (IBAction)datePickerCloseButtonDidTapped:(id)sender {
    [self showDatePicker:NO];
}


- (IBAction)scheduleMessageDatePickerValueChange:(id)sender {
    NSDate *date = self.scheduleMessageDatePicker.date;
    
    long currentTime = [TAPUtil currentTimeInMillis].longValue;
    
    NSNumber *scheduleTime = [NSNumber numberWithDouble:[date timeIntervalSince1970] * 1000.0f];
    long scheduleTimeLong  = scheduleTime.longValue;
    long plusOneMinute = currentTime + 60000;
    if(plusOneMinute > scheduleTimeLong) {
        //self.scheduleMessageSendButton.userInteractionEnabled = NO;
        [self.scheduleMessageDatePicker setDate:[NSDate dateWithTimeIntervalSince1970:plusOneMinute/1000]animated:YES];
        date = [NSDate dateWithTimeIntervalSince1970:plusOneMinute/1000];
    }
    else {
        //self.scheduleMessageSendButton.userInteractionEnabled = YES;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"dd/MM/yy";

    NSString *dateString = [dateFormatter stringFromDate: date];
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"HH:mm";


    NSString *timeString = [timeFormatter stringFromDate: date];
    
    NSString *scheduleSendAtString = [NSString stringWithFormat:@"Send %@ at %@", dateString, timeString];
//    self.scheduleMessageSendLabel.text = scheduleSendAtString;
    [self.scheduleMessageHighlightButton setLabelText:scheduleSendAtString];
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


- (TAPMessageModel *)createMessageModelWithRoom:(TAPRoomModel *)room
                                           body:(NSString *)body
                                           type:(TAPChatMessageType)type
                                    messageData:messageData {
    
    TAPMessageModel *message;
    
    // Check if quote message available
    id quotedMessageObject = [[TAPChatManager sharedManager].quotedMessageDictionary objectForKey:room.roomID];
    if (quotedMessageObject != nil) {
        if ([quotedMessageObject isKindOfClass:[TAPMessageModel class]]) {
            // Construct message with quoted message model
            TAPMessageModel *quotedMessage = (TAPMessageModel *)quotedMessageObject;
            message = [TAPMessageModel createMessageWithUser:nil
                                                        room:room
                                                        body:body
                                                        type:type
                                               quotedMessage:quotedMessage
                                                 messageData:messageData];
        }
        else if ([quotedMessageObject isKindOfClass:[TAPQuoteModel class]]) {
            // Construct message with existing quote model
            TAPQuoteModel *quote = (TAPQuoteModel *)quotedMessageObject;
            message = [TAPMessageModel createMessageWithUser:nil
                                                        room:room
                                                        body:body
                                                        type:type
                                                       quote:quote
                                                 messageData:messageData];
        }
    }
    else {
        // Construct message model without quote
        message = [TAPMessageModel createMessageWithUser:nil
                                                    room:room
                                                    body:body
                                                    type:type
                                             messageData:messageData];
    }
    
    /**
    
    // Check and add userInfo to message data if available
    // userInfo contains custom information from client, used for custom quote click action
    id userInfo = [self.userInfoDictionary objectForKey:room.roomID];
    if (userInfo != nil) {
        NSMutableDictionary *dataDictionary = message.data;
        if (dataDictionary == nil) {
            dataDictionary = [[NSMutableDictionary alloc] init];
        }
        
        [dataDictionary setObject:userInfo forKey:@"userInfo"];
        message.data = dataDictionary;
    }
    
    */
    return message;
}

- (void)profileImageDidTapped {
    NSString *otherUserID = [[TAPChatManager sharedManager] getOtherUserIDWithRoomID:self.currentRoom.roomID];
    otherUserID = [TAPUtil nullToEmptyString:otherUserID];
    TAPUserModel *otherUser = [[TAPContactManager sharedManager] getUserWithUserID:otherUserID];
    //CS NOTE - add resign first responder before every pushVC to handle keyboard height
    [self.messageTextView resignFirstResponder];
    [self keyboardWillHideWithHeight:0.0f];
    
    if (self.currentRoom.type == RoomTypePersonal) {
        id<TapUIChatRoomDelegate> tapUIChatRoomDelegate = [TapUI sharedInstance].chatRoomDelegate;
        if ([tapUIChatRoomDelegate respondsToSelector:@selector(tapTalkChatRoomProfileButtonTapped:otherUser:room:currentShownNavigationController:)]) {
            [tapUIChatRoomDelegate tapTalkChatRoomProfileButtonTapped:self otherUser:otherUser room:self.currentRoom currentShownNavigationController:self.navigationController];
        }
        else {
            TAPProfileViewController *profileViewController = [[TAPProfileViewController alloc] init];
            profileViewController.room = self.currentRoom;
            profileViewController.otherUserID = otherUserID;
            profileViewController.delegate = self;
            if([TAPUtil isSaveMessageRoom:self.currentRoom.roomID]){
                profileViewController.tapProfileViewControllerType = TAPProfileViewControllerTypeSavedMessageProfile;
            }
            [self.navigationController pushViewController:profileViewController animated:YES];
        }
    }
    else if (self.currentRoom.type == RoomTypeGroup) {
        id<TapUIChatRoomDelegate> tapUIChatRoomDelegate = [TapUI sharedInstance].chatRoomDelegate;
        if ([tapUIChatRoomDelegate respondsToSelector:@selector(tapTalkGroupChatRoomProfileButtonTapped:room:currentShownNavigationController:)]) {
            [tapUIChatRoomDelegate tapTalkGroupChatRoomProfileButtonTapped:self room:self.currentRoom currentShownNavigationController:self.navigationController];
        }
        else {
            TAPProfileViewController *profileViewController = [[TAPProfileViewController alloc] init];
            profileViewController.room = self.currentRoom;
            profileViewController.otherUserID = otherUserID;
            profileViewController.delegate = self;
            [self.navigationController pushViewController:profileViewController animated:YES];
        }
    }
}


#pragma mark Upload Notification
- (void)fileUploadManagerProgressNotification:(NSNotification *)notification {
    NSDictionary *notificationParameterDictionary = (NSDictionary *)[notification object];
    
    TAPMessageModel *obtainedMessage = [notificationParameterDictionary objectForKey:@"message"];
    
    NSString *roomID = obtainedMessage.room.roomID;
    roomID = [TAPUtil nullToEmptyString:roomID];
    
    
//    TAPRoomModel *currentRoom = [TAPChatManager sharedManager].activeRoom;
    NSString *currentActiveRoomID = self.currentRoom.roomID;
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
    
    TAPMessageModel *currentMessage = [self.messageDictionary objectForKey:localID];
    NSArray *messageArray = [self.messageArray copy];
    NSInteger currentRowIndex = [messageArray indexOfObject:currentMessage];
    
    TAPChatMessageType type = currentMessage.type;
    if (type == TAPChatMessageTypeImage) {
        TAPMyImageBubbleTableViewCell *cell = (TAPMyImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
        [cell animateProgressUploadingImageWithProgress:progress total:total];
    }
    else if (type == TAPChatMessageTypeFile) {
        TAPMyFileBubbleTableViewCell *cell = (TAPMyFileBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
        [cell animateProgressUploadingFileWithProgress:progress total:total];
    }
    else if (type == TAPChatMessageTypeVideo) {
        TAPMyVideoBubbleTableViewCell *cell = (TAPMyVideoBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
        cell.message = obtainedMessage;
        [cell animateProgressUploadingVideoWithProgress:progress total:total];
    }
    else if (type == TAPChatMessageTypeVoice) {
        TAPMyVoiceNoteBubbleTableViewCell *cell = (TAPMyVoiceNoteBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
        [cell animateProgressUploadingFileWithProgress:progress total:total];
    }
}

- (void)fileUploadManagerStartNotification:(NSNotification *)notification {
    NSDictionary *notificationParameterDictionary = (NSDictionary *)[notification object];
    
    TAPMessageModel *obtainedMessage = [notificationParameterDictionary objectForKey:@"message"];
    
  //  [self.messageArray addObject:obtainedMessage];
  //  [self.messageDictionary setObject:obtainedMessage forKey:obtainedMessage.localID];
 //   [self.tableView reloadData];
    
    
    NSString *roomID = obtainedMessage.room.roomID;
    roomID = [TAPUtil nullToEmptyString:roomID];
    
//    TAPRoomModel *currentRoom = [TAPChatManager sharedManager].activeRoom;
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
        TAPMyImageBubbleTableViewCell *cell = (TAPMyImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
        
        [cell setInitialAnimateUploadingImageWithType:TAPMyImageBubbleTableViewCellStateTypeUploading];
    }
    else if (type == TAPChatMessageTypeFile) {
        TAPMyFileBubbleTableViewCell *cell = (TAPMyFileBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
        
        [self.tableView performBatchUpdates:^{
            //changing beginUpdates and endUpdates with this because of deprecation
            [cell showFileBubbleStatusWithType:TAPMyFileBubbleTableViewCellStateTypeUploading];
        } completion:^(BOOL finished) {
        }];
    }
    else if (type == TAPChatMessageTypeVoice) {
        TAPMyVoiceNoteBubbleTableViewCell *cell = (TAPMyVoiceNoteBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
        
        [self.tableView performBatchUpdates:^{
            //changing beginUpdates and endUpdates with this because of deprecation
            [cell showFileBubbleStatusWithType:TAPMyVoiceNoteBubbleTableViewCellStateTypeUploading];
        } completion:^(BOOL finished) {
        }];
    }
    else if (type == TAPChatMessageTypeVideo) {
        TAPMyVideoBubbleTableViewCell *cell = (TAPMyVideoBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
        cell.message = obtainedMessage;
        
        [self.tableView performBatchUpdates:^{
            //changing beginUpdates and endUpdates with this because of deprecation
            [cell showVideoBubbleStatusWithType:TAPMyVideoBubbleTableViewCellStateTypeUploading];
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)fileUploadManagerFinishNotification:(NSNotification *)notification {
    NSDictionary *notificationParameterDictionary = (NSDictionary *)[notification object];
    
    TAPMessageModel *obtainedMessage = [notificationParameterDictionary objectForKey:@"message"];
    
    NSString *roomID = obtainedMessage.room.roomID;
    roomID = [TAPUtil nullToEmptyString:roomID];
    
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
        TAPMyImageBubbleTableViewCell *cell = (TAPMyImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
        [cell animateFinishedUploadingImage];
//        NSArray<NSIndexPath *> *indexPaths = @[[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
//        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
      }
    else if (type == TAPChatMessageTypeFile) {
        TAPMyFileBubbleTableViewCell *cell = (TAPMyFileBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];

        [self.tableView performBatchUpdates:^{
            //changing beginUpdates and endUpdates with this because of deprecation
            [cell animateFinishedUploadFile];
        } completion:^(BOOL finished) {
        }];
    }
    else if (type == TAPChatMessageTypeVoice) {
        TAPMyVoiceNoteBubbleTableViewCell *cell = (TAPMyVoiceNoteBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];

        [self.tableView performBatchUpdates:^{
            //changing beginUpdates and endUpdates with this because of deprecation
            [cell animateFinishedUploadFile];
        } completion:^(BOOL finished) {
        }];
    }
    else if (type == TAPChatMessageTypeVideo) {
        TAPMyVideoBubbleTableViewCell *cell = (TAPMyVideoBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
        cell.message = obtainedMessage;
        
        [self.tableView performBatchUpdates:^{
            //changing beginUpdates and endUpdates with this because of deprecation
            [cell animateFinishedUploadVideo];
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)fileUploadManagerFailureNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *notificationParameterDictionary = (NSDictionary *)[notification object];
        
        TAPMessageModel *obtainedMessage = [notificationParameterDictionary objectForKey:@"message"];
        
        NSString *roomID = obtainedMessage.room.roomID;
        roomID = [TAPUtil nullToEmptyString:roomID];
        
    //    TAPRoomModel *currentRoom = [TAPChatManager sharedManager].activeRoom;
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
        
        //Update message status to array and dictionary
        currentMessage.isFailedSend = YES;
        currentMessage.isSending = NO;
        
        TAPChatMessageType type = currentMessage.type;
        if (type == TAPChatMessageTypeImage) {
            TAPMyImageBubbleTableViewCell *cell = (TAPMyImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
            [cell setMessage:currentMessage];
            
            [self.tableView performBatchUpdates:^{
                //changing beginUpdates and endUpdates with this because of deprecation
                [cell animateFailedUploadingImage];
            } completion:^(BOOL finished) {
            }];
        }
        else if (type == TAPChatMessageTypeFile) {
            TAPMyFileBubbleTableViewCell *cell = (TAPMyFileBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
            [cell setMessage:currentMessage];
            
            [self.tableView performBatchUpdates:^{
                //changing beginUpdates and endUpdates with this because of deprecation
                [cell animateFailedUploadFile];
            } completion:^(BOOL finished) {
            }];
        }
        else if (type == TAPChatMessageTypeVoice) {
            TAPMyVoiceNoteBubbleTableViewCell *cell = (TAPMyVoiceNoteBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
            [cell setMessage:currentMessage];
            
            [self.tableView performBatchUpdates:^{
                //changing beginUpdates and endUpdates with this because of deprecation
                [cell animateFailedUploadFile];
            } completion:^(BOOL finished) {
            }];
        }
        else if (type == TAPChatMessageTypeVideo) {
            TAPMyVideoBubbleTableViewCell *cell = (TAPMyVideoBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
            cell.message = obtainedMessage;
            [cell setMessage:currentMessage];
            
            [self.tableView performBatchUpdates:^{
                //changing beginUpdates and endUpdates with this because of deprecation
                [cell animateFailedUploadVideo];
            } completion:^(BOOL finished) {
            }];
        }
    });
}

#pragma mark Download Notification
- (void)fileDownloadManagerProgressNotification:(NSNotification *)notification {
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
        
        BOOL isSavedMessageRoom = [TAPUtil isSaveMessageRoom:roomID];
        BOOL isForwardedSavedMessage = NO;
        
        if((![obtainedMessage.forwardFrom.localID isEqualToString:@""] && obtainedMessage.forwardFrom != nil) && isSavedMessageRoom){
            isForwardedSavedMessage = YES;
        }
        
        NSString *localID = obtainedMessage.localID;
        localID = [TAPUtil nullToEmptyString:localID];
        
        NSString *progressString = [notificationParameterDictionary objectForKey:@"progress"];
        CGFloat progress = [progressString floatValue];
        
        NSString *totalString = [notificationParameterDictionary objectForKey:@"total"];
        CGFloat total = [totalString floatValue];
        
        TAPMessageModel *currentMessage = [self.messageDictionary objectForKey:localID];
        NSArray *messageArray = [self.messageArray copy];
        NSInteger currentRowIndex = [messageArray indexOfObject:currentMessage];
        
        TAPChatMessageType type = currentMessage.type;
        if (type == TAPChatMessageTypeImage) {
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID] && !isForwardedSavedMessage) {
                //My Chat
                TAPMyImageBubbleTableViewCell *cell = (TAPMyImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                [cell animateProgressUploadingImageWithProgress:progress total:total];
            }
            else {
                //Their Chat
                TAPYourImageBubbleTableViewCell *cell = (TAPYourImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                [cell animateProgressDownloadingImageWithProgress:progress total:total];
            }
        }
        else if (type == TAPChatMessageTypeFile) {
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID] && !isForwardedSavedMessage) {
                //My Chat
                TAPMyFileBubbleTableViewCell *cell = (TAPMyFileBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                [cell animateProgressDownloadingFileWithProgress:progress total:total];
            }
            else {
                //Their Chat
                TAPYourFileBubbleTableViewCell *cell = (TAPYourFileBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                [cell animateProgressDownloadingFileWithProgress:progress total:total];
            }
        }
        else if (type == TAPChatMessageTypeVideo) {
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID] && !isForwardedSavedMessage) {
                //My Chat
                TAPMyVideoBubbleTableViewCell *cell = (TAPMyVideoBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                [cell animateProgressDownloadingVideoWithProgress:progress total:total];
                [cell setVideoDurationAndSizeProgressViewWithMessage:currentMessage progress:[NSNumber numberWithFloat:progress/total] stateType:TAPMyVideoBubbleTableViewCellStateTypeDownloading];
            }
            else {
                //Their Chat
                TAPYourVideoBubbleTableViewCell *cell = (TAPYourVideoBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                [cell animateProgressDownloadingVideoWithProgress:progress total:total];
                [cell setVideoDurationAndSizeProgressViewWithMessage:currentMessage progress:[NSNumber numberWithFloat:progress/total] stateType:TAPYourVideoBubbleTableViewCellStateTypeDownloading];
            }
        }
        else if (type == TAPChatMessageTypeVoice) {
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID] && !isForwardedSavedMessage) {
                //My Chat
                TAPMyVoiceNoteBubbleTableViewCell *cell = (TAPMyVoiceNoteBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                [cell animateProgressDownloadingFileWithProgress:progress total:total];
            }
            else {
                //Their Chat
                TAPYourVoiceNoteBubbleTableViewCell *cell = (TAPYourVoiceNoteBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                [cell animateProgressDownloadingFileWithProgress:progress total:total];
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
        
//        TAPRoomModel *currentRoom = [TAPChatManager sharedManager].activeRoom;
        NSString *currentActiveRoomID = self.currentRoom.roomID;
        currentActiveRoomID = [TAPUtil nullToEmptyString:currentActiveRoomID];
        
        if (![roomID isEqualToString:currentActiveRoomID]) {
            return;
        }
        
        BOOL isSavedMessageRoom = [TAPUtil isSaveMessageRoom:roomID];
        BOOL isForwardedSavedMessage = NO;
        
        if((![obtainedMessage.forwardFrom.localID isEqualToString:@""] && obtainedMessage.forwardFrom != nil) && isSavedMessageRoom){
            isForwardedSavedMessage = YES;
        }
        
        NSString *localID = obtainedMessage.localID;
        localID = [TAPUtil nullToEmptyString:localID];
        
        TAPMessageModel *currentMessage = [self.messageDictionary objectForKey:localID];
        NSArray *messageArray = [self.messageArray copy];
        NSInteger currentRowIndex = [messageArray indexOfObject:currentMessage];
        
        TAPChatMessageType type = currentMessage.type;

        if (type == TAPChatMessageTypeImage) {
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID] && !isForwardedSavedMessage) {
                //My Chat
                TAPMyImageBubbleTableViewCell *cell = (TAPMyImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                
                if (currentMessage.isFailedSend) {
                    [cell setInitialAnimateUploadingImageWithType:TAPMyImageBubbleTableViewCellStateTypeFailed];
                }
                else {
                    [cell setInitialAnimateUploadingImageWithType:TAPMyImageBubbleTableViewCellStateTypeDownloading];
                }
            }
            else {
                //Their Chat
                TAPYourImageBubbleTableViewCell *cell = (TAPYourImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                [cell setInitialAnimateDownloadingImage];
            }
        }
        else if (type == TAPChatMessageTypeFile) {
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID] && !isForwardedSavedMessage) {
                //My Chat
                TAPMyFileBubbleTableViewCell *cell = (TAPMyFileBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                
                [cell showFileBubbleStatusWithType:TAPMyFileBubbleTableViewCellStateTypeDownloading];
            }
            else {
                //Their Chat
                TAPYourFileBubbleTableViewCell *cell = (TAPYourFileBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                [cell showFileBubbleStatusWithType:TAPYourFileBubbleTableViewCellStateTypeDownloading];
            }
        }
        else if (type == TAPChatMessageTypeVoice) {
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID] && !isForwardedSavedMessage) {
                //My Chat
                TAPMyVoiceNoteBubbleTableViewCell *cell = (TAPMyVoiceNoteBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                
                [cell showFileBubbleStatusWithType:TAPMyVoiceNoteBubbleTableViewCellStateTypeDownloading];
            }
            else {
                //Their Chat
                TAPYourVoiceNoteBubbleTableViewCell *cell = (TAPYourVoiceNoteBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                [cell showFileBubbleStatusWithType:TAPYourVoiceNoteBubbleTableViewCellStateTypeDownloading];
            }
        }
        else if (type == TAPChatMessageTypeVideo) {
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID] && !isForwardedSavedMessage) {
                //My Chat
                TAPMyVideoBubbleTableViewCell *cell = (TAPMyVideoBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                [cell showVideoBubbleStatusWithType:TAPMyVideoBubbleTableViewCellStateTypeDownloading];
            }
            else {
                //Their Chat
                TAPYourVideoBubbleTableViewCell *cell = (TAPYourVideoBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                [cell showVideoBubbleStatusWithType:TAPYourVideoBubbleTableViewCellStateTypeDownloading];
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
