 //
//  TapUIChatViewController.m
//  TapTalk
//
//  Created by Dominic Vedericho on 10/08/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TapUIChatViewController.h"

#import <AFNetworking/AFNetworking.h>
#import <Photos/Photos.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "TAPCustomAccessoryView.h"
#import "TAPGradientView.h"
#import "TAPCustomButtonView.h"

#import "TAPConnectionStatusViewController.h"
#import "TAPKeyboardViewController.h"
#import "TAPProfileViewController.h"
#import "TAPImagePreviewViewController.h"
#import "TAPPhotoAlbumListViewController.h"
#import "TAPPickLocationViewController.h"
#import "TAPForwardListViewController.h"
#import "TAPWebViewViewController.h"
#import "TAPMediaDetailViewController.h"

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

#import "TAPProductListBubbleTableViewCell.h"
#import "TAPUnreadMessagesBubbleTableViewCell.h"
#import "TAPLoadingTableViewCell.h"
#import "TAPSystemMessageTableViewCell.h"

#import "TAPQuoteModel.h"

@import QuickLook;

static const NSInteger kShowChatAnchorOffset = 70.0f;
static const NSInteger kChatAnchorDefaultBottomConstraint = 63.0f;
static const NSInteger kInputMessageAccessoryViewHeight = 52.0f;
static const NSInteger kInputMessageAccessoryExtensionViewDefaultHeight = 68.0f;

typedef NS_ENUM(NSInteger, KeyboardState) {
    keyboardStateDefault = 0,
    keyboardStateOptions = 1,
};

typedef NS_ENUM(NSInteger, InputAccessoryExtensionType) {
    inputAccessoryExtensionTypeQuote = 0,
    inputAccessoryExtensionTypeReplyMessage = 1,
};

typedef NS_ENUM(NSInteger, LoadMoreMessageViewType) {
    LoadMoreMessageViewTypeOlderMessage = 0,
    LoadMoreMessageViewTypeNewMessage = 1,
};

typedef NS_ENUM(NSInteger, TopFloatingIndicatorViewType) {
    TopFloatingIndicatorViewTypeUnreadMessage = 0,
    TopFloatingIndicatorViewTypeLoading = 1
};

@interface TapUIChatViewController () <UIGestureRecognizerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate, UIImagePickerControllerDelegate, QLPreviewControllerDelegate, QLPreviewControllerDataSource, UIAdaptivePresentationControllerDelegate, TAPGrowingTextViewDelegate, TAPChatManagerDelegate, TAPConnectionStatusViewControllerDelegate, TAPImagePreviewViewControllerDelegate, TAPMediaDetailViewControllerDelegate, TAPPhotoAlbumListViewControllerDelegate, TAPPickLocationViewControllerDelegate, TAPMyChatBubbleTableViewCellDelegate, TAPYourChatBubbleTableViewCellDelegate, TAPMyImageBubbleTableViewCellDelegate, TAPYourImageBubbleTableViewCellDelegate, TAPProductListBubbleTableViewCellDelegate, TAPMyLocationBubbleTableViewCellDelegate, TAPYourLocationBubbleTableViewCellDelegate, TAPMyFileBubbleTableViewCellDelegate, TAPYourFileBubbleTableViewCellDelegate, TAPMyVideoBubbleTableViewCellDelegate, TAPYourVideoBubbleTableViewCellDelegate, TAPMyChatDeletedBubbleTableViewCellDelegate, TAPYourChatDeletedBubbleTableViewCellDelegate, TAPProfileViewControllerDelegate>

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *messageViewHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *messageViewLeftConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *keyboardOptionViewRightConstraint;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
@property (strong, nonatomic) IBOutlet UIView *textViewBorderView;
@property (strong, nonatomic) IBOutlet TAPGrowingTextView *messageTextView;
@property (strong, nonatomic) IBOutlet UITextField *secondaryTextField;
@property (strong, nonatomic) IBOutlet UIView *emptyView;
@property (strong, nonatomic) IBOutlet UILabel *emptyTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *emptyDescriptionLabel;
@property (strong, nonatomic) IBOutlet UIView *senderInitialNameView;
@property (strong, nonatomic) IBOutlet UILabel *senderInitialNameLabel;
@property (strong, nonatomic) IBOutlet TAPImageView *senderImageView;
@property (strong, nonatomic) IBOutlet UIView *recipientInitialNameView;
@property (strong, nonatomic) IBOutlet UILabel *recipientInitialNameLabel;
@property (strong, nonatomic) IBOutlet TAPImageView *recipientImageView;
@property (strong, nonatomic) IBOutlet TAPCustomAccessoryView *inputMessageAccessoryView;
@property (strong, nonatomic) IBOutlet UIImageView *inputMessageAccessoryCloseImageView;
@property (strong, nonatomic) IBOutlet UIImageView *inputMessageAccessoryDocumentsImageView;
@property (strong, nonatomic) IBOutlet UIView *sendButtonView;
@property (strong, nonatomic) IBOutlet UIImageView *sendButtonImageView;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet UIView *keyboardOptionButtonView;
@property (strong, nonatomic) IBOutlet UIImageView *keyboardOptionButtonImageView;
@property (strong, nonatomic) IBOutlet UIButton *keyboardOptionButton;
@property (strong, nonatomic) IBOutlet UIView *quoteStandingSeparatorView;

@property (strong, nonatomic) IBOutlet UIView *dummyNavigationBarView;
@property (strong, nonatomic) IBOutlet UILabel *dummyNavigationBarTitleLabel;

@property (strong, nonatomic) IBOutlet UIView *topFloatingIndicatorView;
@property (strong, nonatomic) IBOutlet UILabel *topFloatingIndicatorLabel;
@property (strong, nonatomic) IBOutlet UIImageView *topFloatingIndicatorImageView;
@property (strong, nonatomic) IBOutlet UIButton *topFloatingIndicatorButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topFloatingIndicatorWidthConstraint;

@property (strong, nonatomic) IBOutlet UIView *mentionTableBackgroundView;
@property (strong, nonatomic) IBOutlet UIView *mentionLoadingBackgroundView;
@property (strong, nonatomic) IBOutlet UIView *mentionLoadingView;
@property (strong, nonatomic) IBOutlet UIImageView *mentionLoadingImageView;
@property (strong, nonatomic) IBOutlet UILabel *mentionLoadingCancelLabel;
@property (strong, nonatomic) IBOutlet UIButton *mentionLoadingCancelButton;
- (IBAction)mentionLoadingCancelButtonDidTapped:(id)sender;

@property (strong, nonatomic) IBOutlet UITableView *mentionListTableView;

@property (strong, nonatomic) IBOutlet UIButton *attachmentButton;

@property (nonatomic) TopFloatingIndicatorViewType topFloatingIndicatorViewType;

@property (strong, nonatomic) UIView *titleView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIView *userDescriptionView;
@property (strong, nonatomic) UIView *userStatusView;
@property (strong, nonatomic) UILabel *userStatusLabel;
@property (strong, nonatomic) NSTimer *lastSeenTimer;
@property (strong, nonatomic) UIView *userTypingView;
@property (strong, nonatomic) UILabel *typingLabel;

@property (strong, nonatomic) UIView *rightBarInitialNameView;
@property (strong, nonatomic) UILabel *rightBarInitialNameLabel;
@property (strong, nonatomic) TAPImageView *rightBarImageView;

@property (strong, nonatomic) TAPConnectionStatusViewController *connectionStatusViewController;
@property (strong, nonatomic) TAPKeyboardViewController *keyboardViewController;

@property (strong, atomic) NSMutableArray *messageArray; //RN Note - Use atomic for thread safety
@property (strong, atomic) NSMutableDictionary *messageDictionary;

@property (strong, nonatomic) NSMutableDictionary *cellHeightsDictionary;
@property (strong, nonatomic) TAPMessageModel *selectedMessage;
@property (strong, nonatomic) TAPOnlineStatusModel *onlineStatus;

@property (strong, nonatomic) NSNumber *minCreatedMessage;
@property (strong, nonatomic) NSNumber *loadedMaxCreated;

@property (strong, nonatomic) NSString *tappedMessageLocalID;

@property (strong, nonatomic) NSURL *currentSelectedFileURL;

@property (nonatomic) CGFloat messageTextViewHeight;
@property (nonatomic) CGFloat safeAreaBottomPadding;
@property (nonatomic) CGFloat keyboardHeight;
@property (nonatomic) CGFloat lastKeyboardHeight;
@property (nonatomic) CGFloat initialKeyboardHeight;
@property (nonatomic) CGFloat hiddenKeyboardHeight; // Used to fix table view content inset when scroll view is dragged
@property (nonatomic) CGFloat currentInputAccessoryExtensionHeight;

@property (nonatomic) long apiBeforeLastCreated;
@property (nonatomic) BOOL isLastPage;
@property (nonatomic) KeyboardState keyboardState;
@property (nonatomic) BOOL isKeyboardWasShowed;
@property (nonatomic) BOOL isKeyboardShowed;
@property (nonatomic) BOOL isScrollViewDragged;
@property (nonatomic) BOOL isCustomKeyboardAvailable;
@property (nonatomic) BOOL isViewWillAppeared;
@property (nonatomic) BOOL isViewDidAppeared;
@property (nonatomic) BOOL isKeyboardOptionTapped;
@property (nonatomic) BOOL isKeyboardShowedForFirstTime;
@property (nonatomic) BOOL isInputAccessoryExtensionShowedFirstTimeOpen;
@property (nonatomic) BOOL isTopFloatingIndicatorLoading;
@property (nonatomic) BOOL isUnreadButtonShown;
@property (nonatomic) BOOL isSwipeGestureEnded;
@property (nonatomic) BOOL isShowingTopFloatingIdentifier;

@property (nonatomic) CGFloat connectionStatusHeight;

@property (strong, nonatomic) IBOutlet UIView *chatAnchorBackgroundView;
@property (strong, nonatomic) IBOutlet UIImageView *chatAnchorImageView;
@property (strong, nonatomic) IBOutlet UIButton *chatAnchorButton;
@property (strong, nonatomic) IBOutlet TAPGradientView *chatAnchorBadgeView;
@property (strong, nonatomic) IBOutlet UILabel *chatAnchorBadgeLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *chatAnchorButtonBottomConstrait;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *chatAnchorBackgroundViewBottomConstrait;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *chatAnchorButtonHeightConstrait;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *chatAnchorBackgroundViewHeightConstrait;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *chatAnchorBadgeViewHeightConstrait;

@property (strong, nonatomic) IBOutlet UIView *mentionAnchorBackgroundView;
@property (strong, nonatomic) IBOutlet UIImageView *mentionAnchorImageView;
@property (strong, nonatomic) IBOutlet UIButton *mentionAnchorButton;
@property (strong, nonatomic) IBOutlet TAPGradientView *mentionAnchorBadgeView;
@property (strong, nonatomic) IBOutlet UILabel *mentionAnchorBadgeLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *mentionAnchorButtonBottomConstrait;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *mentionAnchorBackgroundViewBottomConstrait;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *mentionAnchorButtonHeightConstrait;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *mentionAnchorBackgroundViewHeightConstrait;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *mentionAnchorBadgeViewHeightConstrait;

//Input Accessory Extension
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
@property (nonatomic) InputAccessoryExtensionType inputAccessoryExtensionType;

//Load More Message Loading View
@property (strong, nonatomic) IBOutlet UIView *loadMoreMessageLoadingView;
@property (strong, nonatomic) IBOutlet UILabel *loadMoreMessageLoadingLabel;
@property (strong, nonatomic) IBOutlet UIImageView *loadMoreMessageLoadingViewImageView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *loadMoreMessageLoadingHeightConstraint;
@property (nonatomic) CGFloat loadMoreMessageViewHeight;

//Deleted Room View
@property (strong, nonatomic) IBOutlet UIView *deletedRoomView;
@property (strong, nonatomic) IBOutlet UILabel *deletedRoomTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *deletedRoomContentLabel;
@property (strong, nonatomic) IBOutlet UIView *deleteRoomButtonContainerView;
@property (strong, nonatomic) IBOutlet UIImageView *deletedRoomIconImageView;
@property (strong, nonatomic) IBOutlet UIView *deleteRoomButtonView;
@property (strong, nonatomic) IBOutlet UILabel *deleteRoomButtonLabel;
@property (strong, nonatomic) IBOutlet UIImageView *deleteRoomButtonIconImageView;
@property (strong, nonatomic) IBOutlet UIButton *deleteRoomButton;
@property (strong, nonatomic) IBOutlet UIImageView *deleteRoomButtonLoadingImageView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *mentionListTableViewBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *mentionListTableViewHeightConstraint;

//Kicked or Removed Group Room View
@property (strong, nonatomic) IBOutlet UIView *kickedGroupRoomBackgroundView;
@property (strong, nonatomic) IBOutlet UIView *kickedGroupRoomInfoView;
@property (strong, nonatomic) IBOutlet UILabel *kickedGroupRoomInfoLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *deletedRoomViewHeightConstraint;

//Add to Contacts View
@property (strong, nonatomic) IBOutlet UIView *addToContactContainerView;
@property (strong, nonatomic) IBOutlet UIView *addContactView;
@property (strong, nonatomic) IBOutlet UILabel *addContactLabel;
@property (strong, nonatomic) IBOutlet UIButton *addContactButton;
@property (strong, nonatomic) IBOutlet UIView *blockContactView;
@property (strong, nonatomic) IBOutlet UILabel *blockContactLabel;
@property (strong, nonatomic) IBOutlet UIButton *blockContactButton;
@property (strong, nonatomic) IBOutlet UIView *closeButtonView;
@property (strong, nonatomic) IBOutlet UIImageView *closeButtonImageView;
@property (strong, nonatomic) IBOutlet UIButton *closeButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *blockUserViewWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *addToContactsViewWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *addToContactsViewLeftConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *addToContactsViewHeightConstraint;
- (IBAction)blockUserButtonDidTapped:(id)sender;
- (IBAction)addContactButtonDidTapped:(id)sender;
- (IBAction)closeAddContactButtonDidTapped:(id)sender;

@property (strong, nonatomic) NSMutableArray *anchorUnreadMessageArray;
@property (strong, nonatomic) NSMutableDictionary *anchorMentionMessageDictionary;
@property (strong, nonatomic) NSMutableArray *anchorMentionMessageArray;
@property (strong, nonatomic) NSMutableArray *scrolledPendingMessageArray;
@property (strong, nonatomic) NSMutableArray *scrolledPendingMentionArray;
@property (strong, nonatomic) NSMutableArray *filteredMentionListArray;

@property (nonatomic) BOOL isOnScrollPendingChecking;
@property (nonatomic) BOOL isNeedRefreshOnNetworkDown;
@property (nonatomic) BOOL isShowAccessoryView;
@property (nonatomic) BOOL isFirstLoadData;
@property (nonatomic) BOOL isLoadingOldMessageFromAPI;

@property (nonatomic) NSInteger lastLoadingCellRowPosition;

@property (nonatomic) NSInteger lastNumberOfWordArrayForShowMention;
@property (nonatomic) NSInteger lastTypingWordArrayStartIndex;
@property (strong, nonatomic) NSString *lastTypingWordString;

@property (strong, nonatomic) TAPUserModel *otherUser;
@property (nonatomic) BOOL isOtherUserIsContact;

@property (strong, nonatomic) NSString *unreadLocalID;
@property (nonatomic) NSInteger numberOfUnreadMessages;
@property (nonatomic) BOOL isShowingUnreadMessageIdentifier;

@property (weak, nonatomic) id openedBubbleCell;

// Textview mention loop index
@property (nonatomic) NSInteger mentionLoopIndex;
@property (nonatomic) NSInteger mentionCursorIndex;

//DV Temp
@property (nonatomic) BOOL disableTriggerHapticFeedbackOnDrag;


//Custom Method
- (void)setupNavigationViewData;
- (void)setupInputAccessoryView;
- (void)setupDeletedRoomView;
- (void)showDeletedRoomView:(BOOL)show isGroup:(BOOL)isGroup;
- (void)setDeleteRoomButtonAsLoading:(BOOL)loading animated:(BOOL)animated;
- (void)setupKickedGroupView;
- (void)checkAndSetupAddToContactsView;
- (void)checkIsContainQuoteMessage;
- (void)setSendButtonActive:(BOOL)isActive;
- (IBAction)sendButtonDidTapped:(id)sender;
- (IBAction)handleTapOnTableView:(UITapGestureRecognizer *)gestureRecognizer;
- (IBAction)chatAnchorButtonDidTapped:(id)sender;
- (IBAction)mentionAnchorButtonDidTapped:(id)sender;
- (IBAction)inputAccessoryExtensionCloseButtonDidTapped:(id)sender;
- (IBAction)topFloatingIndicatorButtonDidTapped:(id)sender;
- (IBAction)deleteGroupButtonDidTapped:(id)sender;
- (void)backButtonDidTapped;
- (void)addIncomingMessageToArrayAndDictionaryWithMessage:(TAPMessageModel *)message atIndex:(NSInteger)index;
- (void)removeMessageFromArrayAndDictionaryWithLocalID:(NSString *)localID;
- (void)handleMessageFromSocket:(TAPMessageModel *)message isUpdatedMessage:(BOOL)isUpdated;
- (void)destroySequence;
- (void)firstLoadData;
- (void)fetchBeforeMessageFromAPIAndUpdateUIWithRoomID:(NSString *)roomID maxCreated:(NSNumber *)maxCreated;
- (void)retrieveExistingMessages;
- (void)updateMessageDataAndUIWithMessages:(NSArray *)messageArray checkFirstUnreadMessage:(BOOL)checkFirstUnreadMessage toTop:(BOOL)toTop updateUserDetail:(BOOL)updateUserDetail withCompletionHandler:(void(^)())completionHandler;
- (void)sortAndFilterMessageArray;
- (void)updateMessageModelValueWithMessage:(TAPMessageModel *)message;
- (void)callAPIAfterAndUpdateUIAndScrollToTop:(BOOL)scrollToTop;
- (void)saveMessageDraft;
- (void)applicationWillEnterForegroundNotification:(NSNotification *)notification;
- (void)checkAnchorUnreadLabel;
- (void)addMessageToAnchorUnreadArray:(TAPMessageModel *)message;
- (void)removeMessageFromAnchorUnreadArray:(TAPMessageModel *)message;
- (void)timerRefreshLastSeen;
- (void)updateLastSeenWithTimestamp:(NSTimeInterval)timestamp;
- (void)processMessageAsRead:(TAPMessageModel *)message forceMarkAsRead:(BOOL)force;
- (void)processVisibleMessageAsRead;
- (void)processAllPreviousMessageAsRead;
- (void)setAsTyping:(BOOL)typing;
- (void)setAsTypingNoAfterDelay;
- (void)showInputAccessoryExtensionView:(BOOL)show;
- (void)setInputAccessoryExtensionType:(InputAccessoryExtensionType)inputAccessoryExtensionType;
- (void)checkAndShowInputAccessoryView;

- (void)showLoadMoreMessageLoadingView:(BOOL)show
                              withType:(LoadMoreMessageViewType)type;
- (void)showTopFloatingIdentifierView:(BOOL)show
                             withType:(TopFloatingIndicatorViewType)type
               numberOfUnreadMessages:(NSInteger)numberOfUnreadMessages
                             animated:(BOOL)animated;
- (void)showLoadMessageCellLoading:(BOOL)show;
- (void)setReplyMessageWithMessage:(TAPMessageModel *)message;
- (void)setQuoteWithQuote:(TAPQuoteModel *)quote userID:(NSString *)userID;
- (void)showImagePreviewControllerWithSelectedImage:(UIImage *)image;
- (void)fetchImageDataWithMessage:(TAPMessageModel *)message;
- (void)fetchFileDataWithMessage:(TAPMessageModel *)message;
- (void)fetchVideoDataWithMessage:(TAPMessageModel *)message;
- (void)handleLongPressedWithURL:(NSURL *)url originalString:(NSString *)originalString;
- (void)handleLongPressedWithPhoneNumber:(NSString *)phoneNumber originalString:(NSString *)originalString;
- (void)handleTappedWithURL:(NSURL *)url originalString:(NSString *)originalString;
- (void)handleTappedWithPhoneNumber:(NSString *)phoneNumber originalString:(NSString *)originalString;
- (void)handleLongPressedWithMessage:(TAPMessageModel *)message;
- (void)openFiles;
- (void)openCamera;
- (void)openGallery;
- (void)pickLocation;
- (void)openLocationInGoogleMaps:(NSDictionary *)dataDictionary;
- (void)openLocationInAppleMaps:(NSDictionary *)dataDictionary;
- (void)checkAndRefreshOnlineStatus;
- (void)scrollToFirstUnreadMessage;
- (void)scrollToMessageAndLoadDataWithLocalID:(NSString *)localID;
- (BOOL)checkIsRowVisibleWithRowIndex:(NSInteger)rowIndex;
- (void)checkAndShowUnreadButton;
- (void)showDeleteMessageActionWithMessageArray:(NSString *)deletedMessageIDArray;

- (void)fileUploadManagerProgressNotification:(NSNotification *)notification;
- (void)fileUploadManagerStartNotification:(NSNotification *)notification;
- (void)fileUploadManagerFinishNotification:(NSNotification *)notification;
- (void)fileUploadManagerFailureNotification:(NSNotification *)notification;
- (void)userProfileDidChangeNotification:(NSNotification *)notification;

- (void)fileDownloadManagerProgressNotification:(NSNotification *)notification;
- (void)fileDownloadManagerStartNotification:(NSNotification *)notification;
- (void)fileDownloadManagerFinishNotification:(NSNotification *)notification;
- (void)fileDownloadManagerFailureNotification:(NSNotification *)notification;

- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification;

- (void)refreshRoomStatusUIInfo;
- (void)refreshTypingLabelState;

- (void)checkAndShowRoomViewState;

@end

@implementation TapUIChatViewController

#pragma mark - Lifecycle
- (instancetype)initWithOtherUser:(TAPUserModel *)otherUser {
    if (self = [super initWithNibName:@"TapUIChatViewController" bundle:[TAPUtil currentBundle]]) {
        TAPRoomModel *roomData = [TAPRoomModel createPersonalRoomIDWithOtherUser:otherUser];
        self.currentRoom = roomData;
    }
    return self;
}

- (instancetype)initWithRoom:(TAPRoomModel *)room {
    if (self = [super initWithNibName:@"TapUIChatViewController" bundle:[TAPUtil currentBundle]]) {
        self.currentRoom = room;
    }
    return self;
}

- (instancetype)initWithRoom:(TAPRoomModel *)room scrollToMessageWithLocalID:(NSString *)messageLocalID {
    if (self = [super initWithNibName:@"TapUIChatViewController" bundle:[TAPUtil currentBundle]]) {
        self.currentRoom = room;
        self.scrollToMessageLocalIDString = messageLocalID;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    id quotedMessage = [[TAPChatManager sharedManager] getQuotedMessageObjectWithRoomID:self.currentRoom.roomID];
    CGFloat extensionHeight = 0.0f;
    if(quotedMessage != nil) {
        extensionHeight = kInputMessageAccessoryExtensionViewDefaultHeight;
        _isInputAccessoryExtensionShowedFirstTimeOpen = YES;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.0];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView performWithoutAnimation:^{
        self.tableView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - [TAPUtil currentDeviceNavigationBarHeightWithStatusBar:YES iPhoneXLargeLayout:NO] - kInputMessageAccessoryViewHeight - extensionHeight - [TAPUtil safeAreaBottomPadding]);
    }];
    [UIView commitAnimations];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //Open room and save to active room
    [[TAPChatManager sharedManager] openRoom:self.currentRoom];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityStatusChange:) name:TAP_NOTIFICATION_REACHABILITY_STATUS_CHANGED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadManagerProgressNotification:) name:TAP_NOTIFICATION_UPLOAD_FILE_PROGRESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadManagerStartNotification:) name:TAP_NOTIFICATION_UPLOAD_FILE_START object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadManagerFinishNotification:) name:TAP_NOTIFICATION_UPLOAD_FILE_FINISH object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadManagerFailureNotification:) name:TAP_NOTIFICATION_UPLOAD_FILE_FAILURE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileDownloadManagerProgressNotification:) name:TAP_NOTIFICATION_DOWNLOAD_FILE_PROGRESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileDownloadManagerStartNotification:) name:TAP_NOTIFICATION_DOWNLOAD_FILE_START object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileDownloadManagerFinishNotification:) name:TAP_NOTIFICATION_DOWNLOAD_FILE_FINISH object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileDownloadManagerFailureNotification:) name:TAP_NOTIFICATION_DOWNLOAD_FILE_FAILURE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userProfileDidChangeNotification:) name:TAP_NOTIFICATION_USER_PROFILE_CHANGES object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotification:) name:TAP_NOTIFICATION_APPLICATION_DID_BECOME_ACTIVE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForegroundNotification:) name:TAP_NOTIFICATION_APPLICATION_WILL_ENTER_FOREGROUND object:nil];
    
    [[TAPChatManager sharedManager] addDelegate:self];
    self.navigationController.delegate = self;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    //Initialization Data
    _messageArray = [[NSMutableArray alloc] init];
    _messageDictionary = [[NSMutableDictionary alloc] init];
    _cellHeightsDictionary = [[NSMutableDictionary alloc] init];
    _anchorUnreadMessageArray = [[NSMutableArray alloc] init];
    _anchorMentionMessageDictionary = [[NSMutableDictionary alloc] init];
    _anchorMentionMessageArray = [[NSMutableArray alloc] init];
    _scrolledPendingMessageArray = [[NSMutableArray alloc] init];
    _scrolledPendingMentionArray = [[NSMutableArray alloc] init];
    _filteredMentionListArray = [[NSMutableArray alloc] init];
    _otherUser = nil;
    _isKeyboardWasShowed = NO;
    _isKeyboardShowed = NO;
    _isShowAccessoryView = YES;
    _isShowingUnreadMessageIdentifier = NO;
    _safeAreaBottomPadding = [TAPUtil safeAreaBottomPadding];
    _selectedMessage = nil;
    _mentionIndexesDictionary = [[NSMutableDictionary alloc] init];
    
    if (self.tappedMessageLocalID == nil) {
        _tappedMessageLocalID = @"";
    }
    
    _keyboardState = keyboardStateDefault;
    _keyboardHeight = 0.0f;
    _initialKeyboardHeight = 0.0f;
    _lastKeyboardHeight = 0.0f;
    
    _lastNumberOfWordArrayForShowMention = 0;
    _lastTypingWordArrayStartIndex = 0;
    _lastTypingWordString = @"";
    
    self.messageTextViewHeight = 32.0f;
    self.messageTextView.delegate = self;
    self.textViewBorderView.layer.cornerRadius = 18.0f;
    self.textViewBorderView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorChatComposerBackground];
    self.textViewBorderView.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTextFieldBorderInactive].CGColor;
    self.textViewBorderView.layer.borderWidth = 1.0f;
    self.textViewBorderView.clipsToBounds = YES;
    self.messageTextView.minimumHeight = 32.0f;
    self.messageTextView.maximumHeight = 120.0f;
        
    if (IS_IPHONE_X_FAMILY) {
        self.chatAnchorButtonBottomConstrait.constant = kChatAnchorDefaultBottomConstraint + self.safeAreaBottomPadding;
        self.chatAnchorBackgroundViewBottomConstrait.constant = kChatAnchorDefaultBottomConstraint + self.safeAreaBottomPadding;
    }
    
    self.chatAnchorBadgeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.chatAnchorBadgeView.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorUnreadBadgeBackground].CGColor;
    self.chatAnchorBadgeView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorUnreadBadgeBackground];
    self.chatAnchorBadgeView.layer.borderWidth = 1.0f;
    self.chatAnchorBadgeView.layer.cornerRadius = CGRectGetHeight(self.chatAnchorBadgeView.frame) / 2.0f;
    self.chatAnchorBackgroundView.layer.cornerRadius = CGRectGetHeight(self.chatAnchorBackgroundView.frame) / 2.0f;

    self.mentionAnchorBadgeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mentionAnchorBadgeView.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorUnreadBadgeBackground].CGColor;
    self.mentionAnchorBadgeView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorUnreadBadgeBackground];
    self.mentionAnchorBadgeView.layer.borderWidth = 1.0f;
    self.mentionAnchorBadgeView.layer.cornerRadius = CGRectGetHeight(self.mentionAnchorBadgeView.frame) / 2.0f;
    self.mentionAnchorBackgroundView.layer.cornerRadius = CGRectGetHeight(self.mentionAnchorBackgroundView.frame) / 2.0f;

    
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
    
    self.mentionListTableViewHeightConstraint.constant = 150.0f;
    self.mentionListTableView.clipsToBounds = YES;
    self.mentionListTableView.layer.cornerRadius = 15.0f;
    self.mentionListTableView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;

    self.mentionTableBackgroundView.clipsToBounds = YES;
    self.mentionTableBackgroundView.layer.cornerRadius = 15.0f;
    self.mentionTableBackgroundView.layer.shadowRadius = 10.0f;
    self.mentionTableBackgroundView.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f].CGColor;
    self.mentionTableBackgroundView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.mentionTableBackgroundView.layer.shadowOpacity = 1.0f;
    self.mentionTableBackgroundView.layer.masksToBounds = NO;
    
    self.view.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorChatRoomBackground];
    self.quoteStandingSeparatorView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorQuoteLayoutDecorationBackground];
    
    //Connection status view
    _connectionStatusViewController = [[TAPConnectionStatusViewController alloc] init];
    [self addChildViewController:self.connectionStatusViewController];
    [self.connectionStatusViewController didMoveToParentViewController:self];
    self.connectionStatusViewController.delegate = self;
    [self.view addSubview:self.connectionStatusViewController.view];
    _connectionStatusHeight = CGRectGetHeight(self.connectionStatusViewController.view.frame);
    
    self.inputMessageAccessoryDocumentsImageView.image = [self.inputMessageAccessoryDocumentsImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconFileWhite]];
    
    //Custom Keyboard
    _keyboardViewController = [[TAPKeyboardViewController alloc] initWithNibName:@"TAPKeyboardViewController" bundle:[TAPUtil currentBundle]];
    TAPUserModel *currentUser = [TAPDataManager getActiveUser];
    NSString *otherUserID = [[TAPChatManager sharedManager] getOtherUserIDWithRoomID:self.currentRoom.roomID];
    if (self.currentRoom.type == RoomTypePersonal) {
        _otherUser = [[TAPContactManager sharedManager] getUserWithUserID:otherUserID];
        if (self.otherUser == nil) {
            self.inputMessageAccessoryView.alpha = 0.0f;
        }
    }
    
    NSArray *keyboardArray = [NSArray array];
    id<TapUICustomKeyboardDelegate> customKeyboardDelegate = [TapUI sharedInstance].customKeyboardDelegate;
    if ([customKeyboardDelegate respondsToSelector:@selector(setCustomKeyboardItemsForRoom:sender:recipient:)]) {
        keyboardArray = [customKeyboardDelegate setCustomKeyboardItemsForRoom:self.currentRoom sender:currentUser recipient:self.otherUser];
    }
    
    if([keyboardArray count] > 0) {
        //There's custom keyboard for this type
        [self.keyboardViewController setCustomKeyboardArray:keyboardArray sender:currentUser recipient:self.otherUser room:self.currentRoom];
        _isCustomKeyboardAvailable = YES;
    }
    else {
        //There's no custom keyboard for this type
        _isCustomKeyboardAvailable = NO;
        self.keyboardOptionButtonView.alpha = 0.0f;
        self.keyboardOptionButton.alpha = 0.0f;
        self.keyboardOptionButton.userInteractionEnabled = NO;
        self.messageViewLeftConstraint.constant = -38.0f;
        self.keyboardOptionViewRightConstraint.constant = -26.0f;
    }
    //END Custom Keyboard
    
    _lastSeenTimer = [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(timerRefreshLastSeen) userInfo:nil repeats:YES];
    
    [self setupNavigationViewData];
    [self setupInputAccessoryView];
    [self setupDeletedRoomView];
    [self setupKickedGroupView];
    
    //Setup mention loading view
    self.mentionLoadingImageView.image = [UIImage imageNamed:@"TAPIconLoaderProgress" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    self.mentionLoadingImageView.image = [self.mentionLoadingImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconLoadingProgressPrimary]];
    self.mentionLoadingView.layer.cornerRadius = 6.0f;
    self.mentionLoadingCancelLabel.text = NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"");
    UIFont *popupLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontPopupLoadingLabel];
    UIColor *popupLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorPopupLoadingLabel];
    self.mentionLoadingCancelLabel.textColor = popupLabelColor;
    self.mentionLoadingCancelLabel.font = popupLabelFont;
    
    self.mentionLoadingBackgroundView.alpha = 0.0;
    self.mentionLoadingImageView.alpha = 0.0;
    self.mentionLoadingCancelLabel.alpha = 0.0f;
    self.mentionLoadingCancelButton.alpha = 0.0f;
    self.mentionLoadingCancelButton.userInteractionEnabled = NO;
    
    self.mentionLoadingBackgroundView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    self.mentionLoadingBackgroundView.layer.zPosition = 1;
    [self.navigationController.view addSubview:self.mentionLoadingBackgroundView];
    [self.navigationController.view bringSubviewToFront:self.mentionLoadingBackgroundView];
    
    //Get unread mention
    NSString *usernameString = [TAPDataManager getActiveUser].username;
    usernameString = [TAPUtil nullToEmptyString:usernameString];
    
    NSString *userIDString = [TAPDataManager getActiveUser].userID;
    userIDString = [TAPUtil nullToEmptyString:userIDString];
    
    NSString *roomIDString = self.currentRoom.roomID;
    roomIDString = [TAPUtil nullToEmptyString:roomIDString];
    
    if (self.currentRoom.type == RoomTypeGroup || self.currentRoom.type == RoomTypeChannel) {
        [TAPDataManager getDatabaseUnreadMentionsInRoomWithUsername:usernameString roomID:roomIDString activeUserID:userIDString success:^(NSArray *unreadMentionMessages) {
            [self addMessageToAnchorMentionArrayWithMessageArray:unreadMentionMessages];
            if ([self.anchorMentionMessageDictionary count] > 0) {
                self.mentionAnchorBackgroundView.alpha = 1.0f;
                self.mentionAnchorBadgeView.alpha = 1.0f;
                self.mentionAnchorButton.alpha = 1.0f;
                self.mentionAnchorBadgeLabel.text = [NSString stringWithFormat:@"%li", [self.anchorMentionMessageDictionary count]];
                
                if (self.chatAnchorBackgroundView.alpha == 0.0f) {
                    self.chatAnchorButtonHeightConstrait.constant = 0.0f;
                    self.chatAnchorBackgroundViewHeightConstrait.constant = 0.0f;
                    self.mentionAnchorButtonBottomConstrait.constant = 0.0f;
                    self.mentionAnchorBackgroundViewBottomConstrait.constant = 0.0f;
                }
            }
        } failure:^(NSError *error) {

        }];
    }
    
    //load data
    [self firstLoadData];
    
    [[TAPChatManager sharedManager] refreshShouldRefreshOnlineStatus];
    
    if (self.chatViewControllerType == TapUIChatViewControllerTypePeek) {
        //Hide accessory view when peek 3D touch
        self.inputMessageAccessoryView.alpha = 0.0f;
        self.dummyNavigationBarView.alpha = 1.0f;
        self.dummyNavigationBarTitleLabel.alpha = 1.0f;
        self.dummyNavigationBarTitleLabel.text = self.currentRoom.name;
    }
    
    //Set top floating indicator view label color
    UIFont *unreadMessageIdentifierButtonLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontUnreadMessageButtonLabel];
    UIColor *unreadMessageIdentifierButtonLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorUnreadMessageButtonLabel];
    self.topFloatingIndicatorLabel.font = unreadMessageIdentifierButtonLabelFont;
    self.topFloatingIndicatorLabel.textColor = unreadMessageIdentifierButtonLabelColor;
    self.topFloatingIndicatorView.layer.cornerRadius = 8.0f;
    self.topFloatingIndicatorView.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f].CGColor;
    self.topFloatingIndicatorView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.topFloatingIndicatorView.layer.shadowOpacity = 1.0f;
    self.topFloatingIndicatorView.layer.shadowRadius = 4.0f;
    [self.topFloatingIndicatorButton addTarget:self action:@selector(topFloatingIndicatorButtonDidTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    //check if there's scroll to message passed from open room method
    //if yes scroll to message after open chat room
//    if (![TAPUtil isEmptyString:self.scrollToMessageLocalIDString]) {
//        [self scrollToMessageAndLoadDataWithLocalID:self.scrollToMessageLocalIDString];
//    }
    
    self.tableViewBottomConstraint.constant = kInputMessageAccessoryViewHeight;
    self.mentionListTableViewBottomConstraint.constant = kInputMessageAccessoryViewHeight;
    
    // Set quote layout label font and color
    UIFont *quoteTitleLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontQuoteLayoutTitleLabel];
    UIColor *quoteTitleLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorQuoteLayoutTitleLabel];
    UIFont *quoteSubtitleLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontQuoteLayoutContentLabel];
    UIColor *quoteSubtitleLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorQuoteLayoutContentLabel];
    
    [self.quoteTitleLabel setFont:quoteTitleLabelFont];
    [self.quoteTitleLabel setTextColor:quoteTitleLabelColor];
    [self.quoteSubtitleLabel setFont:quoteSubtitleLabelFont];
    [self.quoteSubtitleLabel setTextColor:quoteSubtitleLabelColor];

    [self.replyMessageNameLabel setFont:quoteTitleLabelFont];
    [self.replyMessageNameLabel setTextColor:quoteTitleLabelColor];
    [self.replyMessageMessageLabel setFont:quoteSubtitleLabelFont];
    [self.replyMessageMessageLabel setTextColor:quoteSubtitleLabelColor];
    
    id<TapUIChatRoomDelegate> tapUIChatRoomDelegate = [TapUI sharedInstance].chatRoomDelegate;
    if ([tapUIChatRoomDelegate respondsToSelector:@selector(tapTalkChatRoomDidOpen:otherUser:currentViewController:currentShownNavigationController:)]) {
        
        [tapUIChatRoomDelegate tapTalkChatRoomDidOpen:self.currentRoom otherUser:self.otherUser currentViewController:self currentShownNavigationController:self.navigationController];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Open room and save to active room
    //Check when isFirstLoadData is false because we already called open room in viewDidLoad method to prevent double called
    if (!self.isFirstLoadData) {
        [[TAPChatManager sharedManager] openRoom:self.currentRoom];
    }
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.connectionStatusViewController.isChatViewControllerAppear = self.isViewWillAppeared;
    self.connectionStatusViewController.view.frame = CGRectMake(CGRectGetMinX(self.connectionStatusViewController.view.frame), CGRectGetMinY(self.connectionStatusViewController.view.frame), CGRectGetWidth(self.connectionStatusViewController.view.frame), self.connectionStatusHeight);
    if (IS_IOS_11_OR_ABOVE) {
        [self.tableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    
    if (self.currentRoom.isDeleted) {
        return;
    }
    
    _isViewWillAppeared = YES;
    _isSwipeGestureEnded = NO;
    if (!self.currentRoom.isDeleted) {
        _isShowAccessoryView = YES;
    }
    [self reloadInputViews];
    
    //Check chat room contains mesage draft or not
    TAPRoomModel *room = [TAPChatManager sharedManager].activeRoom;
    NSString *roomID = room.roomID;
    roomID = [TAPUtil nullToEmptyString:roomID];
    NSString *draftMessage = [[TAPChatManager sharedManager] getMessageFromDraftWithRoomID:roomID];
    draftMessage = [TAPUtil nullToEmptyString:draftMessage];
    
    [self.messageTextView setInitialText:draftMessage];
    if (![self.messageTextView.text isEqualToString:@""]) {
        [self setSendButtonActive:YES];
        
        if(self.isCustomKeyboardAvailable) {
            [UIView animateWithDuration:0.2f animations:^{
                self.keyboardOptionButtonView.alpha = 1.0f;
                self.keyboardOptionButton.alpha = 1.0f;
                self.keyboardOptionButton.userInteractionEnabled = YES;
                self.messageViewLeftConstraint.constant = 4.0f;
                self.keyboardOptionViewRightConstraint.constant = 16.0f;
                [self.view layoutIfNeeded];
            } completion:^(BOOL finished) {
                //Do something after animation completed.
            }];
        }
    }
    else {
        [self setSendButtonActive:NO];
        [self checkIsContainQuoteMessage];
    }
    
    [self checkAndRefreshOnlineStatus];
    [self setKeyboardStateDefault];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _isViewDidAppeared = YES;
    
    [self.navigationController.interactivePopGestureRecognizer addTarget:self
                                                                  action:@selector(handleNavigationPopGesture:)];
    
    if (self.initialKeyboardHeight == 0.0f) {
        [UIView performWithoutAnimation:^{
            [self.messageTextView becameFirstResponder];
        }];
        
        [UIView performWithoutAnimation:^{
            [self.messageTextView resignFirstResponder];
            [self keyboardWillHideWithHeight:0.0f];
        }];
        _isKeyboardShowed = NO;
    }
    
    [self processVisibleMessageAsRead];

    //check if last message is deleted room
    [self checkAndShowRoomViewState];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    _isViewWillAppeared = NO;
    self.connectionStatusViewController.isChatViewControllerAppear = self.isViewWillAppeared;
    
    //Save existing message to draft
    [self saveMessageDraft];
    
    if([self.delegate respondsToSelector:@selector(chatViewControllerShouldUpdateUnreadBubbleForRoomID:)]) {
        [self.delegate chatViewControllerShouldUpdateUnreadBubbleForRoomID:self.currentRoom.roomID];
    }
    
    _keyboardHeight = self.inputAccessoryExtensionHeightConstraint.constant + self.safeAreaBottomPadding + kInputMessageAccessoryViewHeight;
    
    [[TAPChatManager sharedManager] saveAllUnsentMessageInMainThread];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    _isViewDidAppeared = NO;
    
    [self.navigationController.interactivePopGestureRecognizer removeTarget:self action:@selector(handleNavigationPopGesture:)];
    
    //stop typing animation sequence
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    //Override present view controller method to resign keyboard before presenting view controller from Chat Room to avoid keyboard accessory missing after VC presented from Chat Room
    [self.secondaryTextField resignFirstResponder];
    [self.messageTextView resignFirstResponder];
    [self keyboardWillHideWithHeight:0.0f];
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_APPLICATION_WILL_ENTER_FOREGROUND object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_REACHABILITY_STATUS_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_UPLOAD_FILE_PROGRESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_UPLOAD_FILE_START object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_UPLOAD_FILE_FINISH object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_UPLOAD_FILE_FAILURE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_DOWNLOAD_FILE_PROGRESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_DOWNLOAD_FILE_START object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_DOWNLOAD_FILE_FINISH object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_DOWNLOAD_FILE_FAILURE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_USER_PROFILE_CHANGES object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_APPLICATION_DID_BECOME_ACTIVE object:nil];
    
    id<TapUIChatRoomDelegate> tapUIChatRoomDelegate = [TapUI sharedInstance].chatRoomDelegate;
    if ([tapUIChatRoomDelegate respondsToSelector:@selector(tapTalkChatRoomDidClose:otherUser:currentViewController:currentShownNavigationController:)]) {
        
        [tapUIChatRoomDelegate tapTalkChatRoomDidClose:self.currentRoom otherUser:self.otherUser currentViewController:self currentShownNavigationController:self.navigationController];
    }
}

#pragma mark - Data Source
#pragma mark UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.mentionListTableView && self.currentRoom.type != RoomTypePersonal) {
        if (![[TapUI sharedInstance] isMentionUsernameEnabled]) {
            return 0;
        }
        return [self.filteredMentionListArray count];
    }
    
    //Chat table view
    if (self.isLoadingOldMessageFromAPI && [self.messageArray count] > 0 && !self.isShowingTopFloatingIdentifier) {
        return [self.messageArray count] + 1;
    }
    return [self.messageArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.mentionListTableView && self.currentRoom.type != RoomTypePersonal) {
        tableView.estimatedRowHeight = 54.0f;
        return UITableViewAutomaticDimension;
    }
    else {
        //Chat Table View
        if (indexPath.row == [self.messageArray count] && [self.messageArray count] > 0) {
            //load more view cell
            //loading
            return 48.0f;
        }
        
        TAPMessageModel *currentMessage = [self.messageArray objectAtIndex:indexPath.row];
        if (currentMessage != nil) {
            BOOL isHidden = currentMessage.isHidden;
            if (isHidden) {
                //Set height = 0 for hidden message
                return 0.0f;
            }
        }
        
        if (currentMessage.type == TAPChatMessageTypeProduct) {
            //DV Note - For product list height
            //    Collection view height (347.0f) + 16.0f gap
            return 363.0f;
        }
        else if (currentMessage.type == TAPChatMessageTypeUnreadMessageIdentifier) {
            //Unread message identifier UI
            return 42.0f;
        }
        else {
            tableView.estimatedRowHeight = 70.0f;
            return UITableViewAutomaticDimension;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.mentionListTableView && self.currentRoom.type != RoomTypePersonal) {
        return UITableViewAutomaticDimension;
    }
    
    if (indexPath.row < [self.messageArray count]) {
        TAPMessageModel *currentMessage = [self.messageArray objectAtIndex:indexPath.row];
        if (currentMessage != nil) {
            BOOL isHidden = currentMessage.isHidden;
            if (isHidden) {
                //Set height = 0 for hidden message
                return 0.0f;
            }
        }
        
        NSNumber *height = [self.cellHeightsDictionary objectForKey:currentMessage.localID];
        if (height) {
            CGFloat heightFloat = [height doubleValue];
            if (heightFloat < 0.0f) {
                heightFloat = 0.0f;
            }
            return heightFloat;
        }
        return UITableViewAutomaticDimension;
    }
    
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.mentionListTableView && [[TapUI sharedInstance] isMentionUsernameEnabled]) {
        return 10.0f;
    }

    return FLT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.mentionListTableView && [[TapUI sharedInstance] isMentionUsernameEnabled]) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 10.0f)];
        view.layer.cornerRadius = 15.0f;
        view.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
        view.clipsToBounds = YES;
        return view;
    }

    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return FLT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.mentionListTableView && self.currentRoom.type != RoomTypePersonal) {
        [tableView registerNib:[TAPMentionListXIBTableViewCell cellNib] forCellReuseIdentifier:[TAPMentionListXIBTableViewCell description]];
        TAPMentionListXIBTableViewCell *cell = (TAPMentionListXIBTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPMentionListXIBTableViewCell description] forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if ([self.filteredMentionListArray count] != 0) {
            TAPUserModel *user = [self.filteredMentionListArray objectAtIndex:indexPath.row];
            [cell setMentionListCellWithUser:user];
            
            if (indexPath.row == [self.filteredMentionListArray count] - 1) {
                [cell showSeparatorView:NO];
            }
            else {
                [cell showSeparatorView:YES];
            }
        }

        return cell;
    }
    
    if ([self.messageArray count] != 0) {
        if (indexPath.row == [self.messageArray count]) {
            //load more view cell
            //loading
            [tableView registerNib:[TAPLoadingTableViewCell cellNib] forCellReuseIdentifier:[TAPLoadingTableViewCell description]];
            TAPLoadingTableViewCell *cell = (TAPLoadingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPLoadingTableViewCell description] forIndexPath:indexPath];
            [cell animateLoading:YES];
            return cell;
        }
        
        TAPMessageModel *message = [self.messageArray objectAtIndex:indexPath.row];
        
        //Check user is equal to current user
        if ([message.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
            //My Chat
            if (message.isDeleted) {
                //Deleted Message (My Chat)
                [tableView registerNib:[TAPMyChatDeletedBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPMyChatDeletedBubbleTableViewCell description]];
                TAPMyChatDeletedBubbleTableViewCell *cell = (TAPMyChatDeletedBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPMyChatDeletedBubbleTableViewCell description] forIndexPath:indexPath];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.tag = indexPath.row;
                cell.contentView.tag = indexPath.row;
                cell.userInteractionEnabled = YES;
                cell.contentView.userInteractionEnabled = YES;
                cell.delegate = self;
                [cell showStatusLabel:NO animated:NO updateStatusIcon:NO message:message];
                
                return cell;
            }
            else {
                if (message.type == TAPChatMessageTypeText) {
                    //My Chat Text Message
                    [tableView registerNib:[TAPMyChatBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPMyChatBubbleTableViewCell description]];
                    TAPMyChatBubbleTableViewCell *cell = (TAPMyChatBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPMyChatBubbleTableViewCell description] forIndexPath:indexPath];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.tag = indexPath.row;
                    cell.contentView.tag = indexPath.row;
                    cell.userInteractionEnabled = YES;
                    cell.contentView.userInteractionEnabled = YES;
                    cell.delegate = self;
                    
                    if ([[TapUI sharedInstance] isMentionUsernameEnabled]) {
                        NSArray *mentionArray = [self.mentionIndexesDictionary objectForKey:message.localID];
                        if ([mentionArray count] > 0) {
                            cell.mentionIndexesArray = mentionArray;
                        }
                    }

                    cell.message = message;
                    
                    if (!message.isHidden) {
                        if (![self.tappedMessageLocalID isEqualToString:@""] && [self.tappedMessageLocalID isEqualToString:message.localID]) {
                            [cell showBubbleHighlight];
                            _tappedMessageLocalID = @"";
                        }
                        [cell setMessage:message];
                    }
                    
                    if (self.selectedMessage != nil && [self.selectedMessage.localID isEqualToString:message.localID]) {
                        [cell showStatusLabel:YES animated:NO updateStatusIcon:NO message:message];
                    }
                    else {
                        [cell showStatusLabel:NO animated:NO updateStatusIcon:NO message:message];
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
                    
                    if ([[TapUI sharedInstance] isMentionUsernameEnabled]) {
                        NSArray *mentionArray = [self.mentionIndexesDictionary objectForKey:message.localID];
                        if ([mentionArray count] > 0) {
                            cell.mentionIndexesArray = mentionArray;
                        }
                    }
                    
                    cell.message = message;
                    
                    [cell showStatusLabel:YES];
                    
                    if (!message.isHidden) {
                        if (![self.tappedMessageLocalID isEqualToString:@""] && [self.tappedMessageLocalID isEqualToString:message.localID]) {
                            [cell showBubbleHighlight];
                            _tappedMessageLocalID = @"";
                        }
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
                    
                    if ([[TapUI sharedInstance] isMentionUsernameEnabled]) {
                        NSArray *mentionArray = [self.mentionIndexesDictionary objectForKey:message.localID];
                        if ([mentionArray count] > 0) {
                            cell.mentionIndexesArray = mentionArray;
                        }
                    }
                    
                    if (!message.isHidden) {
                        if (![self.tappedMessageLocalID isEqualToString:@""] && [self.tappedMessageLocalID isEqualToString:message.localID]) {
                            [cell showBubbleHighlight];
                            _tappedMessageLocalID = @"";
                        }
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
                    
                    if (!message.isHidden) {
                        if (![self.tappedMessageLocalID isEqualToString:@""] && [self.tappedMessageLocalID isEqualToString:message.localID]) {
                            [cell showBubbleHighlight];
                            _tappedMessageLocalID = @"";
                        }
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
                    
                    if (!message.isHidden) {
                        if (![self.tappedMessageLocalID isEqualToString:@""] && [self.tappedMessageLocalID isEqualToString:message.localID]) {
                            [cell showBubbleHighlight];
                            _tappedMessageLocalID = @"";
                        }
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
                else if (message.type == TAPChatMessageTypeProduct) {
                    //Product Message
                    [tableView registerNib:[TAPProductListBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPProductListBubbleTableViewCell description]];
                    TAPProductListBubbleTableViewCell *cell = (TAPProductListBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPProductListBubbleTableViewCell description] forIndexPath:indexPath];
                    NSArray *productListArray = [message.data objectForKey:@"items"];
                    [cell setProductListBubbleCellWithData:productListArray];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    [cell setProductListBubbleTableViewCellType:TAPProductListBubbleTableViewCellTypeSingleOption];
                    cell.isCurrentActiveUserProduct = YES;
                    cell.delegate = self;
                    return cell;
                }
                else if (message.type == TAPChatMessageTypeUnreadMessageIdentifier) {
                    //Unread Identifier
                    [tableView registerNib:[TAPUnreadMessagesBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPUnreadMessagesBubbleTableViewCell description]];
                    TAPUnreadMessagesBubbleTableViewCell *cell = (TAPUnreadMessagesBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPUnreadMessagesBubbleTableViewCell description] forIndexPath:indexPath];
                    return cell;
                }
                else if (message.type == TAPChatMessageTypeSystemMessage) {
                    //System Message
                    [tableView registerNib:[TAPSystemMessageTableViewCell cellNib] forCellReuseIdentifier:[TAPSystemMessageTableViewCell description]];
                    TAPSystemMessageTableViewCell *cell = (TAPSystemMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPSystemMessageTableViewCell description] forIndexPath:indexPath];
                    [cell setMessage:message];
                    return cell;
                }
                else {
                    //check if custom bubble available
                    NSDictionary *cellDataDictionary = [[TAPCustomBubbleManager sharedManager] getCustomBubbleClassNameWithType:message.type];
                    
                    if([cellDataDictionary count] > 0 && cellDataDictionary != nil) {
                        //if custom bubble from client available
                        NSString *cellName = [cellDataDictionary objectForKey:@"name"];
                        id userDelegate = [cellDataDictionary objectForKey:@"delegate"];
                        NSBundle *obtainedBundle = [cellDataDictionary objectForKey:@"bundle"];
                        
                        UINib *cellNib = [UINib nibWithNibName:cellName bundle:obtainedBundle];
                        [tableView registerNib:cellNib forCellReuseIdentifier:cellName];
                        
                        TAPBaseGeneralBubbleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName forIndexPath:indexPath];
                        cell.delegate = userDelegate;
                        cell.clipsToBounds = YES;
                        if (!message.isHidden) {
                            [cell setMessage:message];
                        }
                        return cell;
                    }
                }
            }
        }
        else {
            //Their Chat
            if (message.isDeleted) {
                //Deleted Message (Their Chat)
                [tableView registerNib:[TAPYourChatDeletedBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPYourChatDeletedBubbleTableViewCell description]];
                TAPYourChatDeletedBubbleTableViewCell *cell = (TAPYourChatDeletedBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPYourChatDeletedBubbleTableViewCell description] forIndexPath:indexPath];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.tag = indexPath.row;
                cell.contentView.tag = indexPath.row;
                cell.userInteractionEnabled = YES;
                cell.contentView.userInteractionEnabled = YES;
                cell.delegate = self;
                [cell setMessage:message];
                [cell showStatusLabel:NO animated:NO];
                
                return cell;
            }
            else {
                if (message.type == TAPChatMessageTypeText) {
                    
                    //Their Chat Message
                    [tableView registerNib:[TAPYourChatBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPYourChatBubbleTableViewCell description]];
                    TAPYourChatBubbleTableViewCell *cell = (TAPYourChatBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPYourChatBubbleTableViewCell description] forIndexPath:indexPath];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.tag = indexPath.row;
                    cell.contentView.tag = indexPath.row;
                    cell.userInteractionEnabled = YES;
                    cell.contentView.userInteractionEnabled = YES;
                    cell.delegate = self;
                    
                    if ([[TapUI sharedInstance] isMentionUsernameEnabled]) {
                        NSArray *mentionArray = [self.mentionIndexesDictionary objectForKey:message.localID];
                        if ([mentionArray count] > 0) {
                            cell.mentionIndexesArray = mentionArray;
                        }
                    }
                    
                    cell.message = message;
                    
                    if (!message.isHidden) {
                        if (![self.tappedMessageLocalID isEqualToString:@""] && [self.tappedMessageLocalID isEqualToString:message.localID]) {
                            [cell showBubbleHighlight];
                            _tappedMessageLocalID = @"";
                        }
                        [cell setMessage:message];
                    }
                    
                    if (self.selectedMessage != nil && [self.selectedMessage.localID isEqualToString:message.localID]) {
                        [cell showStatusLabel:YES animated:NO];
                    }
                    else {
                        [cell showStatusLabel:NO animated:NO];
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
                    
                    if ([[TapUI sharedInstance] isMentionUsernameEnabled]) {
                        NSArray *mentionArray = [self.mentionIndexesDictionary objectForKey:message.localID];
                        if ([mentionArray count] > 0) {
                            cell.mentionIndexesArray = mentionArray;
                        }
                    }
                    
                    cell.message = message;
                    
                    if (!message.isHidden) {
                        if (![self.tappedMessageLocalID isEqualToString:@""] && [self.tappedMessageLocalID isEqualToString:message.localID]) {
                            [cell showBubbleHighlight];
                            _tappedMessageLocalID = @"";
                        }
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
                    
                    if ([[TapUI sharedInstance] isMentionUsernameEnabled]) {
                        NSArray *mentionArray = [self.mentionIndexesDictionary objectForKey:message.localID];
                        if ([mentionArray count] > 0) {
                            cell.mentionIndexesArray = mentionArray;
                        }
                    }
                    
                    cell.message = message;
                    
                    if (!message.isHidden) {
                        if (![self.tappedMessageLocalID isEqualToString:@""] && [self.tappedMessageLocalID isEqualToString:message.localID]) {
                            [cell showBubbleHighlight];
                            _tappedMessageLocalID = @"";
                        }
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
                    
                    if (!message.isHidden) {
                        if (![self.tappedMessageLocalID isEqualToString:@""] && [self.tappedMessageLocalID isEqualToString:message.localID]) {
                            [cell showBubbleHighlight];
                            _tappedMessageLocalID = @"";
                        }
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
                    
                    if (!message.isHidden) {
                        if (![self.tappedMessageLocalID isEqualToString:@""] && [self.tappedMessageLocalID isEqualToString:message.localID]) {
                            [cell showBubbleHighlight];
                            _tappedMessageLocalID = @"";
                        }
                        [cell setMessage:message];
                    }
                    
                    [cell showStatusLabel:YES animated:NO];
                    
                    return cell;
                }
                else if (message.type == TAPChatMessageTypeProduct) {
                    //Product Message
                    [tableView registerNib:[TAPProductListBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPProductListBubbleTableViewCell description]];
                    TAPProductListBubbleTableViewCell *cell = (TAPProductListBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPProductListBubbleTableViewCell description] forIndexPath:indexPath];
                    NSArray *productListArray = [message.data objectForKey:@"items"];
                    [cell setProductListBubbleCellWithData:productListArray];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.delegate = self;
                    cell.isCurrentActiveUserProduct = NO;
                    [cell setProductListBubbleTableViewCellType:TAPProductListBubbleTableViewCellTypeTwoOption];
                    return cell;
                }
                else if (message.type == TAPChatMessageTypeUnreadMessageIdentifier) {
                    //Unread Identifier
                    [tableView registerNib:[TAPUnreadMessagesBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPUnreadMessagesBubbleTableViewCell description]];
                    TAPUnreadMessagesBubbleTableViewCell *cell = (TAPUnreadMessagesBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPUnreadMessagesBubbleTableViewCell description] forIndexPath:indexPath];
                    return cell;
                }
                else if (message.type == TAPChatMessageTypeSystemMessage) {
                    //System Message
                    [tableView registerNib:[TAPSystemMessageTableViewCell cellNib] forCellReuseIdentifier:[TAPSystemMessageTableViewCell description]];
                    TAPSystemMessageTableViewCell *cell = (TAPSystemMessageTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPSystemMessageTableViewCell description] forIndexPath:indexPath];
                    [cell setMessage:message];
                    return cell;
                }
                else {
                    //check if custom bubble available
                    NSDictionary *cellDataDictionary = [[TAPCustomBubbleManager sharedManager] getCustomBubbleClassNameWithType:message.type];
                    
                    if([cellDataDictionary count] > 0 && cellDataDictionary != nil) {
                        //if custom bubble from client available
                        NSString *cellName = [cellDataDictionary objectForKey:@"name"];
                        id userDelegate = [cellDataDictionary objectForKey:@"delegate"];
                        NSBundle *obtainedBundle = [cellDataDictionary objectForKey:@"bundle"];
                        
                        UINib *cellNib = [UINib nibWithNibName:cellName bundle:obtainedBundle];
                        [tableView registerNib:cellNib forCellReuseIdentifier:cellName];
                        
                        TAPBaseGeneralBubbleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName forIndexPath:indexPath];
                        cell.delegate = userDelegate;
                        cell.clipsToBounds = YES;
                        if (!message.isHidden) {
                            [cell setMessage:message];
                        }
                        return cell;
                    }
                }
            }
        }
    }
    
    //    [tableView registerNib:[TAPBaseXIBRotatedTableViewCell cellNib] forCellReuseIdentifier:[TAPBaseXIBRotatedTableViewCell description]];
    //    TAPBaseXIBRotatedTableViewCell *cell = (TAPBaseXIBRotatedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPBaseXIBRotatedTableViewCell description] forIndexPath:indexPath];
    //    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.backgroundColor = [TAPUtil getColor:@"F3F3F3"];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (tableView == self.mentionListTableView) {
        return;
    }
    
    if ([self.messageArray count] == 0 || indexPath.row >= [self.messageArray count]) {
        //reject when out of message bounds
        return;
    }
    
    //Process message as Read, remove local notification and call API read
    TAPMessageModel *message = [self.messageArray objectAtIndex:indexPath.row];
    if (![message.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
        //Their chat
        [self processMessageAsRead:message forceMarkAsRead:NO];
    }
    
    //Check and remove unread count message array
    if ([self.anchorUnreadMessageArray count] > 0) {
        TAPMessageModel *message = [self.messageArray objectAtIndex:indexPath.row];
        [self removeMessageFromAnchorUnreadArray:message];
    }
    
    //Check and remove unread mention message array
    if ([self.anchorMentionMessageDictionary count] > 0) {
        TAPMessageModel *message = [self.messageArray objectAtIndex:indexPath.row];
        [self removeMessageFromAnchorMention:message];
    }
    
    //Retreive before message
    if (indexPath.row == [self.messageArray count] - 5 && !self.isLoadingOldMessageFromAPI) {
        [self retrieveExistingMessages];
    }
    
    //save cell height to prevent jumpy effects
    TAPMessageModel *currentMessage = [self.messageArray objectAtIndex:indexPath.row];
    if (currentMessage != nil) {
        BOOL isHidden = currentMessage.isHidden;
        if (isHidden) {
            //Set height = 0 for hidden message
            [self.cellHeightsDictionary setObject:@(0.0f) forKey:currentMessage.localID];
        }
        else {
            //save cell height to prevent jumpy effects
            if (cell.frame.size.height >= 0.0f) {
                [self.cellHeightsDictionary setObject:@(cell.frame.size.height) forKey:currentMessage.localID];
            }
        }
    }
}

#pragma mark QLPreviewController
- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller {
    return 1;
}

- (id <QLPreviewItem>) previewController:(QLPreviewController *)controller previewItemAtIndex: (NSInteger) index {
    return self.currentSelectedFileURL;
}

#pragma mark - Delegate
#pragma mark UITableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.mentionListTableView) {
        TAPUserModel *user = [self.filteredMentionListArray objectAtIndex:indexPath.row];
        NSString *username = user.username;
        username = [TAPUtil nullToEmptyString:username];
    
//        NSString *trimmedMessageString = [TAPUtil stringByTrimmingTrailingWhitespaceAndNewlineCharactersWithString:self.messageTextView.text];
//        NSRange lastSpaceRange = [self.messageTextView.text rangeOfString:@" @" options:NSBackwardsSearch];
//        NSRange lastNewLineRange = [self.messageTextView.text rangeOfString:@"\n@" options:NSBackwardsSearch];
//
//        //Detect which one is the last word in sentence
//        NSInteger lastStartIndex;
//        if (lastSpaceRange.location == NSNotFound && lastNewLineRange.location == NSNotFound) {
//            //Not found space or new line
//            lastStartIndex = -1;
//        }
//        else if (lastSpaceRange.location == NSNotFound && lastNewLineRange.location != NSNotFound) {
//            //Only found new line with following @ ("\n@")
//            lastStartIndex = lastNewLineRange.location;
//        }
//        else if (lastSpaceRange.location != NSNotFound && lastNewLineRange.location == NSNotFound) {
//            //Only found space with following @ (" @")
//            lastStartIndex = lastSpaceRange.location;
//        }
//        else if (lastSpaceRange.location >= lastNewLineRange.location) {
//            //Last word is separated by space
//            lastStartIndex = lastSpaceRange.location;
//        }
//        else {
//            //Last word is separated by newline
//            lastStartIndex = lastNewLineRange.location;
//        }
//
//        NSString *replacedString;
//        NSArray *wordArray = [self.messageTextView.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//        if ([wordArray count] > 1 && lastStartIndex != -1) {
//            NSInteger totalReplacedWordLength = [trimmedMessageString length] - lastStartIndex;
//            NSRange replacedRange = NSMakeRange(lastStartIndex, totalReplacedWordLength);
//            replacedString = [trimmedMessageString stringByReplacingCharactersInRange:replacedRange withString:@""];
//            //Adding space in the end of the username
//            replacedString = [replacedString stringByAppendingString:[NSString stringWithFormat:@" @%@ ", username]];
//        }
//        else {
//            //Adding space in the end of the username
//            replacedString = [NSString stringWithFormat:@"@%@ ", username];
//        }
//        [self.messageTextView setText:replacedString];
        
        NSString *text = self.messageTextView.text;
        if ([self.messageTextView.text length] >= self.mentionCursorIndex) {
            // Append username to typed text
            self.messageTextView.text = [self.messageTextView.text stringByReplacingCharactersInRange:NSMakeRange(self.mentionLoopIndex + 1, self.mentionCursorIndex - self.mentionLoopIndex - 1) withString:[NSString stringWithFormat:@"%@ ", username]];
            [self showMentionListView:NO animated:YES];
        }
    }
}

#pragma mark UIScrollView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.mentionListTableView) {
        return;
    }
    
    _isScrollViewDragged = YES;
    
    //Hide unread message indicator top view
    if (self.topFloatingIndicatorViewType == TopFloatingIndicatorViewTypeUnreadMessage && self.topFloatingIndicatorView.alpha == 1.0f) {
        [TAPUtil performBlock:^{
            [self showTopFloatingIdentifierView:NO withType:TopFloatingIndicatorViewTypeUnreadMessage numberOfUnreadMessages:0 animated:YES];
        } afterDelay:1.0f];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.mentionListTableView) {
        return;
    }
    
    _isScrollViewDragged = NO;
    
    //move chat anchor button position to default position according to keyboard height
    [UIView animateWithDuration:0.2f animations:^{
        self.chatAnchorButtonBottomConstrait.constant = kChatAnchorDefaultBottomConstraint + self.keyboardHeight - kInputMessageAccessoryViewHeight;
        self.chatAnchorBackgroundViewBottomConstrait.constant = kChatAnchorDefaultBottomConstraint + self.keyboardHeight - kInputMessageAccessoryViewHeight;

//        if (self.chatAnchorBackgroundView.alpha == 1.0f) {
//            self.mentionAnchorButtonBottomConstrait.constant = 20.0f;
//            self.mentionAnchorBackgroundViewBottomConstrait.constant = 20.0f;
//        }
//        if (self.chatAnchorBackgroundView.alpha == 0.0f) {
//            self.chatAnchorButtonHeightConstrait.constant = 0.0f;
//            self.chatAnchorBackgroundViewHeightConstrait.constant = 0.0f;
//            self.mentionAnchorButtonBottomConstrait.constant = 0.0f;
//            self.mentionAnchorBackgroundViewBottomConstrait.constant = 0.0f;
//        }
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
            [self setKeyboardStateDefault];
        }
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.mentionListTableView) {
        return;
    }
    
    if (scrollView.contentOffset.y > kShowChatAnchorOffset) {
        
        [self showMentionAnchorView:YES];
        
        if (self.chatAnchorBackgroundView.alpha != 1.0f) {
            [UIView animateWithDuration:0.2f animations:^{
                self.chatAnchorButtonHeightConstrait.constant = 40.0f;
                self.chatAnchorBackgroundViewHeightConstrait.constant = 40.0f;
                
                self.mentionAnchorButtonBottomConstrait.constant = 20.0f;
                self.mentionAnchorBackgroundViewBottomConstrait.constant = 20.0f;
                
                self.chatAnchorBackgroundView.alpha = 1.0f;
                self.chatAnchorImageView.alpha = 1.0f;
                self.chatAnchorButton.alpha = 1.0f;
                [self.view layoutIfNeeded];
            }];
            
            [self checkAnchorUnreadLabel];
        }
    }
    else {
        //Check scrolled pending array
        if (!self.isOnScrollPendingChecking) {
            _isOnScrollPendingChecking = YES;

            NSInteger numberOfPendingArray = 0;
            if ([self.scrolledPendingMessageArray count] > 0) {
                numberOfPendingArray = [self.scrolledPendingMessageArray count];

                //Add pending message to messageArray (pending message has previously inserted in messageDictionary in didReceiveNewMessage)
                [self.messageArray insertObjects:self.scrolledPendingMessageArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, numberOfPendingArray)]];

                [self.scrolledPendingMessageArray removeAllObjects];

                NSMutableArray *indexesArray = [NSMutableArray array];
                for (NSInteger counter = 0; counter < numberOfPendingArray; counter++) {
                    [indexesArray addObject:[NSIndexPath indexPathForRow:counter inSection:0]];
                }

                [self.tableView performBatchUpdates:^{
                    //changing beginUpdates and endUpdates with this because of deprecation
                    [self.tableView insertRowsAtIndexPaths:indexesArray withRowAnimation:UITableViewRowAnimationTop];
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:numberOfPendingArray - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                } completion:^(BOOL finished) {
                    
                }];
//                [self.tableView reloadData];
            }

            _isOnScrollPendingChecking = NO;
        }
        
        if ([self.scrolledPendingMessageArray count] > 0) {
           if (self.chatAnchorBackgroundView.alpha != 0.0f) {
               [UIView animateWithDuration:0.2f delay:0.1f options:UIViewAnimationOptionTransitionNone animations:^{
                   self.chatAnchorBackgroundView.alpha = 0.0f;
                   self.chatAnchorImageView.alpha = 0.0f;
                   self.chatAnchorButton.alpha = 0.0f;
                   self.chatAnchorBadgeView.alpha = 0.0f;
                   
                   if ([self.anchorMentionMessageDictionary count] > 0) {
                       self.chatAnchorButtonHeightConstrait.constant = 0.0f;
                       self.chatAnchorBackgroundViewHeightConstrait.constant = 0.0f;
                       self.mentionAnchorButtonBottomConstrait.constant = 0.0f;
                       self.mentionAnchorBackgroundViewBottomConstrait.constant = 0.0f;
                       [self.view layoutIfNeeded];
                   }
               } completion:nil];
           }
        }
        else {
            [UIView animateWithDuration:0.2f animations:^{
                self.chatAnchorBackgroundView.alpha = 0.0f;
                self.chatAnchorImageView.alpha = 0.0f;
                self.chatAnchorButton.alpha = 0.0f;
                self.chatAnchorBadgeView.alpha = 0.0f;
            }];
        }
        
        if ([self.anchorMentionMessageDictionary count] <= 0) {
            [self showMentionAnchorView:NO];
        }
        else {
            self.chatAnchorButtonHeightConstrait.constant = 0.0f;
            self.chatAnchorBackgroundViewHeightConstrait.constant = 0.0f;
            self.mentionAnchorButtonBottomConstrait.constant = 0.0f;
            self.mentionAnchorBackgroundViewBottomConstrait.constant = 0.0f;
        }
    }
    
    //CS NOTE - move chat anchor button as the keyboard move interactively
    CGPoint positionInView = [scrollView.panGestureRecognizer locationInView:self.view];
    CGFloat keyboardAndAccessoryViewHeight = self.safeAreaBottomPadding + kInputMessageAccessoryViewHeight + self.currentInputAccessoryExtensionHeight;
    CGFloat totalKeyboardHeight = self.keyboardHeight; //include inputView height
    CGFloat keyboardMinYPositionInView = CGRectGetHeight([UIScreen mainScreen].bounds) - totalKeyboardHeight;
    
    CGFloat touchYPosition = positionInView.y + [TAPUtil currentDeviceNavigationBarHeightWithStatusBar:YES iPhoneXLargeLayout:NO];
    
    if (self.isKeyboardShowed && touchYPosition >= keyboardMinYPositionInView && self.keyboardHeight != keyboardAndAccessoryViewHeight && self.isScrollViewDragged) {
        CGFloat keyboardHeightDifference = touchYPosition - keyboardMinYPositionInView;
        
        if (keyboardHeightDifference < 0.0f) {
            keyboardHeightDifference = 0.0f;
        }
        
        CGFloat chatAnchorBottomConstraint = kChatAnchorDefaultBottomConstraint + (totalKeyboardHeight - keyboardHeightDifference) - kInputMessageAccessoryViewHeight - self.currentInputAccessoryExtensionHeight;
        
        CGFloat messageViewHeightDifference = self.messageViewHeightConstraint.constant - kInputMessageAccessoryViewHeight;
        if (messageViewHeightDifference < 0) {
            messageViewHeightDifference = 0.0f;
        }
        
        if (chatAnchorBottomConstraint < kChatAnchorDefaultBottomConstraint + self.currentInputAccessoryExtensionHeight + self.safeAreaBottomPadding + messageViewHeightDifference) {
            chatAnchorBottomConstraint = kChatAnchorDefaultBottomConstraint + self.currentInputAccessoryExtensionHeight + self.safeAreaBottomPadding + messageViewHeightDifference;
        }
        self.chatAnchorButtonBottomConstrait.constant = chatAnchorBottomConstraint;
        self.chatAnchorBackgroundViewBottomConstrait.constant = chatAnchorBottomConstraint;

//        if (self.chatAnchorBackgroundView.alpha == 1.0f) {
//            self.mentionAnchorButtonBottomConstrait.constant = 20.0f;
//            self.mentionAnchorBackgroundViewBottomConstrait.constant = 20.0f;
//        }
//        else if (self.chatAnchorBackgroundView.alpha == 0.0f) {
//            self.mentionAnchorButtonBottomConstrait.constant = 0.0f;
//            self.mentionAnchorBackgroundViewBottomConstrait.constant = 0.0f;
//        }
    }
}

#pragma mark UINavigationController
- (void)handleNavigationPopGesture:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self performSelector:@selector(checkIfNeedCloseRoomAfterDelay) withObject:nil afterDelay:0.5f];
        self.isSwipeGestureEnded = YES;
    }
}

- (void)checkIfNeedCloseRoomAfterDelay {
    if (!self.isViewWillAppeared) {
        [self.lastSeenTimer invalidate];
        _lastSeenTimer = nil;
        [self destroySequence];
    }
}

#pragma mark UIDocumentPicker
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    
    NSError *error = nil;
    NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
    
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
            [[TAPChatManager sharedManager] sendFileMessage:dataFile filePath:filePath];
            
            [TAPUtil performBlock:^{
                if ([self.messageArray count] != 0) {
                    [self chatAnchorButtonDidTapped:[[UIButton alloc] init]]; //Scroll table view to top with pending message logic
                }
            } afterDelay:0.2f];
        }
    }];
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    
}

#pragma mark TAPChatManager
- (void)chatManagerDidSendNewMessage:(TAPMessageModel *)message {
    // Trigger send message callback to TapUI
    id<TapUIChatRoomDelegate> tapUIChatRoomDelegate = [TapUI sharedInstance].chatRoomDelegate;
    if ([tapUIChatRoomDelegate respondsToSelector:@selector(tapTalkActiveUserDidSendMessage:room:currentViewController:currentShownNavigationController:)]) {
        
        [tapUIChatRoomDelegate tapTalkActiveUserDidSendMessage:message room:message.room currentViewController:self currentShownNavigationController:self.navigationController];
    }
    
    //DV Note - 6 Nov 2020
    //Check if message.roomID is not equal to active room ID, dont send message
    //This is to handle case bubble show in previous room
    if (![message.room.roomID isEqualToString:[TAPChatManager sharedManager].activeRoom.roomID]) {
        return;
    }
    
    //Handle mapping mention index to array
    NSArray *mentionIndexArray = [NSArray array];
    if (message.type == TAPChatMessageTypeText) {
        NSString *messageContainString = message.body;
        messageContainString = [TAPUtil nullToEmptyString:messageContainString];
        mentionIndexArray = [TAPUtil getMentionIndexes:messageContainString];
    }
    else if (message.type == TAPChatMessageTypeImage || message.type == TAPChatMessageTypeVideo) {
        NSString *messageContainString = [message.data objectForKey:@"caption"];
        messageContainString = [TAPUtil nullToEmptyString:messageContainString];
        mentionIndexArray = [TAPUtil getMentionIndexes:messageContainString];
    }
    
    if ([mentionIndexArray count] > 0) {
        [self.mentionIndexesDictionary removeObjectForKey:message.localID];
        [self.mentionIndexesDictionary setObject:mentionIndexArray forKey:message.localID];
    }
    
    [self addIncomingMessageToArrayAndDictionaryWithMessage:message atIndex:0];
    NSIndexPath *insertAtIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];

    [self.tableView performBatchUpdates:^{
        //changing beginUpdates and endUpdates with this because of deprecation
        [self.tableView insertRowsAtIndexPaths:@[insertAtIndexPath] withRowAnimation:UITableViewRowAnimationTop];
    } completion:^(BOOL finished) {
        [self.tableView scrollsToTop];
    }];
}

//- (void)chatManagerDidAddUnreadMessageIdentifier:(TAPMessageModel *)message indexPosition:(NSInteger)index {
//    //CS NOTE - add delay to add unread message identifier to prevent crash caused by unsynced data and ui
//    [TAPUtil performBlock:^{
//        [self addIncomingMessageToArrayAndDictionaryWithMessage:message atIndex:index];
//        //Add unread message identifier to message array and dictionary with index
//        NSIndexPath *insertAtIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
//        [self.tableView beginUpdates];
//        [self.tableView insertRowsAtIndexPaths:@[insertAtIndexPath] withRowAnimation:UITableViewRowAnimationMiddle];
//        [self.tableView endUpdates];
//    } afterDelay:0.2f];
//}

- (void)chatManagerDidReceiveNewMessageInActiveRoom:(TAPMessageModel *)message {
    if (![message.room.roomID isEqualToString:self.currentRoom.roomID]) {
        //If message don't have the same room id, reject message
        return;
    }
    
    [self handleMessageFromSocket:message isUpdatedMessage:NO];
    
    
    if (message.room.isLocked) {
        [self showInputAccessoryExtensionView:NO];
        [[TAPChatManager sharedManager] removeQuotedMessageObjectWithRoomID:self.currentRoom.roomID];
        [self.messageTextView setText:@""];
        [self hideInputAccessoryView];
    }
    else {
        //Check if user remove us from the group while we are inside the chat room, handle the case
        if (message.room.type == RoomTypePersonal && message.room.isDeleted) {
            [self.view endEditing:YES];
            [self showDeletedRoomView:YES isGroup:NO isGroupDeleted:NO];
        }
        else if (message.type == TAPChatMessageTypeSystemMessage && [message.action isEqualToString:@"room/removeParticipant"]) {
            if ([message.target.targetID isEqualToString:[TAPDataManager getActiveUser].userID]) {
                //Check if system message with action remove participant and target user is current user
                //show deleted chat room view
                [self.view endEditing:YES];
                [self showDeletedRoomView:YES isGroup:YES isGroupDeleted:NO];
            }
            //refresh room members by API
            [self checkAndRefreshOnlineStatus];
        }
        else if (message.type == TAPChatMessageTypeSystemMessage && [message.action isEqualToString:@"room/addParticipant"]) {
            if ([message.target.targetID isEqualToString:[TAPDataManager getActiveUser].userID]) {
                [self.view endEditing:YES];
                [self showDeletedRoomView:NO isGroup:YES isGroupDeleted:NO];
            }
            //refresh room members by API
            [self checkAndRefreshOnlineStatus];
        }
        else if (message.type == TAPChatMessageTypeSystemMessage && [message.action isEqualToString:@"room/delete"]) {
            [self.view endEditing:YES];
            
            if (message.room.type == RoomTypePersonal) {
                [self showDeletedRoomView:YES isGroup:NO isGroupDeleted:NO];
            }
            else if (message.room.type == RoomTypeGroup || message.room.type == RoomTypeTransaction) {
                [self showDeletedRoomView:YES isGroup:YES isGroupDeleted:YES];
            }
        }
    }
}

- (void)chatManagerDidReceiveUpdateMessageInActiveRoom:(TAPMessageModel *)message {
    if (![message.room.roomID isEqualToString:self.currentRoom.roomID]) {
        //If message don't have the same room id, reject message
        return;
    }
    
    [self handleMessageFromSocket:message isUpdatedMessage:YES];
}


- (void)chatManagerDidReceiveOnlineStatus:(TAPOnlineStatusModel *)onlineStatus {
    _onlineStatus = onlineStatus;
    NSTimeInterval currentLastSeen = (double)self.onlineStatus.lastActive.doubleValue/1000.0f;
    [self updateLastSeenWithTimestamp:currentLastSeen];
}

- (void)chatManagerDidReceiveStartTyping:(TAPTypingModel *)typing {
    NSString *currentRoomID = [TAPChatManager sharedManager].activeRoom.roomID;
    currentRoomID = [TAPUtil nullToEmptyString:currentRoomID];
    
    NSString *typingRoomID = typing.roomID;
    typingRoomID = [TAPUtil nullToEmptyString:typingRoomID];
    
    if ([typingRoomID isEqualToString:currentRoomID]) {
        [self setAsTyping:YES];
    }
}

- (void)chatManagerDidReceiveStopTyping:(TAPTypingModel *)typing {
    NSString *currentRoomID = [TAPChatManager sharedManager].activeRoom.roomID;
    currentRoomID = [TAPUtil nullToEmptyString:currentRoomID];
    
    NSString *typingRoomID = typing.roomID;
    typingRoomID = [TAPUtil nullToEmptyString:typingRoomID];
    
    if ([typingRoomID isEqualToString:currentRoomID]) {
        if (self.currentRoom.type == RoomTypePersonal) {
            [self setAsTyping:NO];
        }
        else {
            [self refreshTypingLabelState];
        }
    }
}

#pragma mark TAPMyChatBubbleTableViewCell
- (void)myChatBubbleViewDidTapped:(TAPMessageModel *)tappedMessage {
    if (tappedMessage.isFailedSend) {
        NSInteger messageIndex = [self.messageArray indexOfObject:tappedMessage];
        NSString *currentMessageString = tappedMessage.body;
        [TAPDataManager deleteDatabaseMessageWithData:@[tappedMessage] success:^{
            [self.messageArray removeObjectAtIndex:messageIndex];
            [self.messageDictionary removeObjectForKey:tappedMessage.localID];
            NSIndexPath *deleteAtIndexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
            [self.tableView performBatchUpdates:^{
                //changing beginUpdates and endUpdates with this because of deprecation
                [self.tableView deleteRowsAtIndexPaths:@[deleteAtIndexPath] withRowAnimation:UITableViewRowAnimationTop];
            } completion:^(BOOL finished) {
                [[TAPChatManager sharedManager] sendTextMessage:currentMessageString];
            }];

        } failure:^(NSError *error) {
            
        }];
    }
    else if (!tappedMessage.isSending) {
        if (tappedMessage == self.selectedMessage) {
            //select message that had been selected
            self.selectedMessage = nil;
            
            NSInteger messageIndex = [self.messageArray indexOfObject:tappedMessage];
            NSIndexPath *selectedMessageIndexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
            TAPMyChatBubbleTableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedMessageIndexPath];
            
            [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
                //animation
                [self.tableView performBatchUpdates:^{
                    //changing beginUpdates and endUpdates with this because of deprecation
                    [cell showStatusLabel:NO animated:YES updateStatusIcon:YES message:tappedMessage];
                    [cell layoutIfNeeded];
                } completion:^(BOOL finished) {
                    
                }];
            } completion:^(BOOL finished) {
                //completion
            }];
        }
        else {
            //select message that had not been selected
            if (self.selectedMessage == nil) {
                //no messages had been selected
                self.selectedMessage = tappedMessage;
                NSInteger messageIndex = [self.messageArray indexOfObject:tappedMessage];
                NSIndexPath *selectedMessageIndexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
                
                TAPMyChatBubbleTableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedMessageIndexPath];
                
                [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
                    //animation
                    [self.tableView performBatchUpdates:^{
                        //changing beginUpdates and endUpdates with this because of deprecation
                        [cell showStatusLabel:YES animated:YES updateStatusIcon:YES message:tappedMessage];
                        [cell layoutIfNeeded];
                    } completion:^(BOOL finished) {
                        
                    }];
                } completion:^(BOOL finished) {
                    //completion
                }];
            }
            else {
                //a message had been selected
                NSInteger previousMessageIndex = [self.messageArray indexOfObject:self.selectedMessage];
                NSIndexPath *selectedPreviousMessageIndexPath = [NSIndexPath indexPathForRow:previousMessageIndex inSection:0];
                
                id previousCell;
                BOOL isMyCell = NO;
                if ([self.selectedMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                    previousCell = (TAPMyChatBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:selectedPreviousMessageIndexPath];
                    isMyCell = YES;
                }
                else {
                    previousCell = (TAPYourChatBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:selectedPreviousMessageIndexPath];
                }
                
                self.selectedMessage = tappedMessage;
                NSInteger messageIndex = [self.messageArray indexOfObject:tappedMessage];
                NSIndexPath *selectedMessageIndexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
                
                TAPMyChatBubbleTableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedMessageIndexPath];
                
                [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
                    //animation
                    if (isMyCell) {
                        [previousCell showStatusLabel:NO animated:YES updateStatusIcon:YES message:tappedMessage];
                    }
                    else {
                        [previousCell showStatusLabel:NO animated:YES];
                    }
                    [previousCell layoutIfNeeded];
                    
                    [cell showStatusLabel:YES animated:YES updateStatusIcon:YES message:tappedMessage];
                    [cell layoutIfNeeded];
                    [self.tableView performBatchUpdates:^{
                        //changing beginUpdates and endUpdates with this because of deprecation
                    } completion:^(BOOL finished) {
                    }];
                } completion:^(BOOL finished) {
                    //completion
                }];
            }
        }
    }
}

- (void)myChatReplyDidTapped {
    if (self.otherUser == nil && self.currentRoom.type == RoomTypePersonal) {
        return;
    }
    
    //set selected message to chat field
    NSInteger messageIndex = [self.messageArray indexOfObject:self.selectedMessage];
    NSIndexPath *selectedMessageIndexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
    //WK Note : Do reply here later.
    [self showInputAccessoryExtensionView:NO];
    [self setInputAccessoryExtensionType:inputAccessoryExtensionTypeReplyMessage];
    [self setReplyMessageWithMessage:self.selectedMessage];
    [self showInputAccessoryExtensionView:YES];
    
    TAPMessageModel *quotedMessageModel = [self.selectedMessage copy];
    [[TAPChatManager sharedManager] saveToQuotedMessage:self.selectedMessage userInfo:nil roomID:self.currentRoom.roomID];
    
    //remove selectedMessage
    self.selectedMessage = nil;
    
    TAPMyChatBubbleTableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedMessageIndexPath];
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
        //animation
        [cell showStatusLabel:NO animated:YES updateStatusIcon:YES message:self.selectedMessage];
        [cell layoutIfNeeded];
        [self.tableView performBatchUpdates:^{
            //changing beginUpdates and endUpdates with this because of deprecation
        } completion:^(BOOL finished) {
        }];
    } completion:^(BOOL finished) {
        //completion
    }];
}

- (void)myChatQuoteViewDidTapped:(TAPMessageModel *)tappedMessage {
    [self messageBubbleQuoteViewDidTapped:tappedMessage];
}

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

- (void)myChatBubbleLongPressedWithMessage:(TAPMessageModel *)longPressedMessage {
    [self handleLongPressedWithMessage:longPressedMessage];
}

- (void)myChatBubbleDidTriggerSwipeToReplyWithMessage:(TAPMessageModel *)message {
    [self processSwipeToReplyWithMessage:message];
}

- (void)myChatBubblePressedMentionWithWord:(NSString*)word
                             tappedAtIndex:(NSInteger)index
                                   message:(TAPMessageModel *)message
                       mentionIndexesArray:(NSArray *)mentionIndexesArray {
    
    NSString *username = @"";
    for (NSInteger counter = 0; counter < [mentionIndexesArray count]; counter++) {
        NSRange userRange = [[mentionIndexesArray objectAtIndex:counter] rangeValue];
        
        NSInteger locationStart = userRange.location;
        NSInteger locationEnd = locationStart + userRange.length - 1; // -1 for omit location start
        
        if (index >= locationStart && index <= locationEnd) {
            username = [word substringWithRange:userRange];
            break;
        }
    }
    
    NSString *prefixToRemove = @"@";
    if ([username hasPrefix:prefixToRemove]) {
        username = [username substringFromIndex:[prefixToRemove length]];
    }
    
    if ([username isEqualToString:[TAPDataManager getActiveUser].username]) {
        //if tap our username, nothing happens
        return;
    }
    
    [self tapTalkUserMentionTappedWithRoom:self.currentRoom message:message usernameString:username];
}

- (void)myChatBubbleLongPressedMentionWithWord:(NSString*)word
                                 tappedAtIndex:(NSInteger)index
                                       message:(TAPMessageModel *)message
                           mentionIndexesArray:(NSArray *)mentionIndexesArray {
    NSString *username = @"";
    for (NSInteger counter = 0; counter < [mentionIndexesArray count]; counter++) {
        NSRange userRange = [[mentionIndexesArray objectAtIndex:counter] rangeValue];
        
        NSInteger locationStart = userRange.location;
        NSInteger locationEnd = locationStart + userRange.length - 1; // -1 for omit location start
        
        if (index >= locationStart && index <= locationEnd) {
            username = [word substringWithRange:userRange];
            break;
        }
    }
    
    if ([username isEqualToString:[TAPDataManager getActiveUser].username]) {
        //if tap our username, nothing happens
        return;
    }
    
    [TAPUtil tapticImpactFeedbackGenerator];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:username message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *viewProfileAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"View Profile", nil, [TAPUtil currentBundle], @"")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
        [self myChatBubblePressedMentionWithWord:word tappedAtIndex:index message:message mentionIndexesArray:mentionIndexesArray];
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
                                     [self checkAndShowInputAccessoryView];
                                     UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                     [pasteboard setString:username];
                                 }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
                                       [self checkAndShowInputAccessoryView];
                                       [self checkKeyboard];
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
    
    if (self.secondaryTextField.isFirstResponder || self.messageTextView.isFirstResponder) {
        self.isKeyboardWasShowed = YES;
    }
    else {
        self.isKeyboardWasShowed = NO;
    }
    
    [UIView animateWithDuration:0.2f animations:^{
        [self.messageTextView resignFirstResponder];
        [self.secondaryTextField resignFirstResponder];
        [self keyboardWillHideWithHeight:0.0f];
    } completion:^(BOOL finished) {
        [self presentViewController:alertController animated:YES completion:^{
            //after animation
        }];
    }];
}

#pragma mark TAPMyChatDeletedBubbleTableViewCell
- (void)myChatDeletedBubbleViewDidTapped:(TAPMessageModel *)tappedMessage {
    if (!tappedMessage.isSending) {
        if (tappedMessage == self.selectedMessage) {
            //select message that had been selected
            self.selectedMessage = nil;
            
            NSInteger messageIndex = [self.messageArray indexOfObject:tappedMessage];
            NSIndexPath *selectedMessageIndexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
            TAPMyChatBubbleTableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedMessageIndexPath];
            
            [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
                //animation
                [self.tableView performBatchUpdates:^{
                    //changing beginUpdates and endUpdates with this because of deprecation
                    [cell showStatusLabel:NO animated:YES updateStatusIcon:YES message:tappedMessage];
                    [cell layoutIfNeeded];
                } completion:^(BOOL finished) {
                }];
            } completion:^(BOOL finished) {
                //completion
            }];
        }
        else {
            //select message that had not been selected
            if (self.selectedMessage == nil) {
                //no messages had been selected
                self.selectedMessage = tappedMessage;
                NSInteger messageIndex = [self.messageArray indexOfObject:tappedMessage];
                NSIndexPath *selectedMessageIndexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
                
                TAPMyChatBubbleTableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedMessageIndexPath];
                
                [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
                    //animation
                    [self.tableView performBatchUpdates:^{
                        //changing beginUpdates and endUpdates with this because of deprecation
                        [cell showStatusLabel:YES animated:YES updateStatusIcon:YES message:tappedMessage];
                        [cell layoutIfNeeded];
                    } completion:^(BOOL finished) {
                    }];
                } completion:^(BOOL finished) {
                    //completion
                }];
            }
            else {
                //a message had been selected
                NSInteger previousMessageIndex = [self.messageArray indexOfObject:self.selectedMessage];
                NSIndexPath *selectedPreviousMessageIndexPath = [NSIndexPath indexPathForRow:previousMessageIndex inSection:0];
                
                id previousCell;
                BOOL isMyCell = NO;
                if ([self.selectedMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                    previousCell = (TAPMyChatBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:selectedPreviousMessageIndexPath];
                    isMyCell = YES;
                }
                else {
                    previousCell = (TAPYourChatBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:selectedPreviousMessageIndexPath];
                }
                
                self.selectedMessage = tappedMessage;
                NSInteger messageIndex = [self.messageArray indexOfObject:tappedMessage];
                NSIndexPath *selectedMessageIndexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
                
                TAPMyChatBubbleTableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedMessageIndexPath];
                
                [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
                    //animation
                    if (isMyCell) {
                        [previousCell showStatusLabel:NO animated:YES updateStatusIcon:YES message:tappedMessage];
                    }
                    else {
                        [previousCell showStatusLabel:NO animated:YES];
                    }
                    [previousCell layoutIfNeeded];
                    
                    [cell showStatusLabel:YES animated:YES updateStatusIcon:YES message:tappedMessage];
                    [cell layoutIfNeeded];
                    [self.tableView performBatchUpdates:^{
                        //changing beginUpdates and endUpdates with this because of deprecation
                    } completion:^(BOOL finished) {
                    }];
                } completion:^(BOOL finished) {
                    //completion
                }];
            }
        }
    }
}


#pragma mark TAPMyImageBubbleTableViewCell
- (void)myImageCancelDidTappedWithMessage:(TAPMessageModel *)message {
    
    //Cancel uploading task
    [[TAPFileUploadManager sharedManager] cancelUploadingOperationWithMessage:message];
    
    //Remove message from array and dictionary in ChatViewController
    TAPMessageModel *currentDeletedMessage = [self.messageDictionary objectForKey:message.localID];
    NSInteger deletedIndex = [self.messageArray indexOfObject:currentDeletedMessage];
    [self removeMessageFromArrayAndDictionaryWithLocalID:message.localID];
    
    //Remove from WaitingUploadDictionary in ChatManager
    [[TAPChatManager sharedManager] removeFromWaitingUploadFileMessage:message];
    
    //Remove message from database
    [TAPDataManager deleteDatabaseMessageWithData:@[message] success:^{
        
    } failure:^(NSError *error) {
        
    }];
    
    //Update chat room UI
    NSIndexPath *deleteAtIndexPath = [NSIndexPath indexPathForRow:deletedIndex inSection:0];
    [self.tableView performBatchUpdates:^{
        //changing beginUpdates and endUpdates with this because of deprecation
        [self.tableView deleteRowsAtIndexPaths:@[deleteAtIndexPath] withRowAnimation:UITableViewRowAnimationTop];
    } completion:^(BOOL finished) {
    }];
}

- (void)myImageReplyDidTappedWithMessage:(TAPMessageModel *)message {
    
    if (self.otherUser == nil && self.currentRoom.type == RoomTypePersonal) {
        return;
    }
    
    TAPMessageModel *quotedMessageModel = [message copy];
    
    //WK Note : Do reply here later.
    [self showInputAccessoryExtensionView:NO];
    [self setInputAccessoryExtensionType:inputAccessoryExtensionTypeQuote];
    [self showInputAccessoryExtensionView:YES];
    
    TAPQuoteModel *quote = [TAPQuoteModel constructFromMessageModel:quotedMessageModel];
    [self setQuoteWithQuote:quote userID:quotedMessageModel.user.userID];
    
    quotedMessageModel.quote = quote;
    
    [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessageModel userInfo:nil roomID:self.currentRoom.roomID];
    
    //remove selectedMessage
    self.selectedMessage = nil;
}

- (void)myImageQuoteDidTappedWithMessage:(TAPMessageModel *)message {
    [self messageBubbleQuoteViewDidTapped:message];
}

- (void)myImageRetryDidTappedWithMessage:(TAPMessageModel *)message {
    if ([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] == AFNetworkReachabilityStatusNotReachable) {
        return;
    }
    
    NSInteger messageIndex = [self.messageArray indexOfObject:message];
    
    [TAPDataManager deleteDatabaseMessageWithData:@[message] success:^{
            [self.messageArray removeObjectAtIndex:messageIndex];
            [self.messageDictionary removeObjectForKey:message.localID];
            NSIndexPath *deleteAtIndexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
            [self.tableView performBatchUpdates:^{
                //changing beginUpdates and endUpdates with this because of deprecation
                [self.tableView deleteRowsAtIndexPaths:@[deleteAtIndexPath] withRowAnimation:UITableViewRowAnimationTop];
            } completion:^(BOOL finished) {
            }];
        
            NSDictionary *dataDictionary = message.data;
            dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];
            NSString *currentCaption = [dataDictionary objectForKey:@"caption"];
            currentCaption = [TAPUtil nullToEmptyString:currentCaption];
        
            [TAPImageView imageFromCacheWithKey:message.localID message:message
            success:^(UIImage *savedImage, TAPMessageModel *resultMessage) {
                [[TAPChatManager sharedManager] sendImageMessage:savedImage caption:currentCaption];
            }
            failure:^(TAPMessageModel *resultMessage) {
                NSString *assetIdentifier = [dataDictionary objectForKey:@"assetIdentifier"];
                assetIdentifier = [TAPUtil nullToEmptyString:assetIdentifier];
                
                if (![assetIdentifier isEqualToString:@""]) {
                    NSArray<NSString *> *assetIdentifierArray = [NSArray arrayWithObject:assetIdentifier];
                    PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:assetIdentifierArray options:nil];
                    PHAsset *imageAsset = [fetchResult firstObject];
                    if (imageAsset != nil) {
                        [[TAPChatManager sharedManager] sendImageMessageWithPHAsset:imageAsset caption:currentCaption];
                    }
                    else {
                        // Image data not found
                        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage
                                         popupIdentifier:@"Image Asset Not Found"
                                                   title:NSLocalizedStringFromTableInBundle(@"Unable to Resend Message", nil, [TAPUtil currentBundle], @"")
                                       detailInformation:NSLocalizedStringFromTableInBundle(@"Image data is not found, please try resending the message from camera or gallery.", nil, [TAPUtil currentBundle], @"")
                                   leftOptionButtonTitle:nil
                          singleOrRightOptionButtonTitle:nil];
                    }
                }
                else {
                    NSString *key = [TAPUtil getFileKeyFromMessage:message];
                    if (![key isEqualToString:@""] && message.isFailedSend) {
                        // Image already uploaded, resend message
                        TAPMessageModel *messageToResend = [TAPMessageModel createMessageWithUser:message.user
                                                                                             room:message.room
                                                                                             body:message.body
                                                                                             type:message.type
                                                                                            quote:message.quote
                                                                                      messageData:message.data];
                        NSInteger messageIndex = [self.messageArray indexOfObject:message];
                        [[TAPChatManager sharedManager] sendCustomMessage:messageToResend];
                    }
                    else {
                        // Image data not found
                        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage
                                         popupIdentifier:@"Image Asset Not Found"
                                                   title:NSLocalizedStringFromTableInBundle(@"Unable to Resend Message", nil, [TAPUtil currentBundle], @"")
                                       detailInformation:NSLocalizedStringFromTableInBundle(@"Image data is not found, please try resending the message from camera or gallery.", nil, [TAPUtil currentBundle], @"")
                                   leftOptionButtonTitle:nil
                          singleOrRightOptionButtonTitle:nil];
                    }
                }
            }];
    } failure:^(NSError *error) {
        
    }];
}

- (void)myImageDidTapped:(TAPMyImageBubbleTableViewCell *)myImageBubbleCell {
    CGFloat bubbleImageViewMinY = CGRectGetMinY(myImageBubbleCell.bubbleImageView.frame);
    
    TAPMediaDetailViewController *mediaDetailViewController = [[TAPMediaDetailViewController alloc] init];
    [mediaDetailViewController setMediaDetailViewControllerType:TAPMediaDetailViewControllerTypeImage];
    mediaDetailViewController.delegate = self;
    mediaDetailViewController.message = myImageBubbleCell.message;
    
    UIImage *cellImage = myImageBubbleCell.bubbleImageView.image;
    NSArray *imageSliderImage = [NSArray array];
    if(cellImage != nil) {
        [self.messageTextView resignFirstResponder];
        [self.secondaryTextField resignFirstResponder];
        [self keyboardWillHideWithHeight:0.0f];
        
        _isShowAccessoryView = NO;
        [self reloadInputViews];
        
        imageSliderImage = @[cellImage];
        
        [mediaDetailViewController setThumbnailImageArray:imageSliderImage];
        [mediaDetailViewController setImageArray:@[cellImage]];
        
        [mediaDetailViewController setActiveIndex:0];
        
        NSInteger selectedRow = [self.messageArray indexOfObject:myImageBubbleCell.message];
        NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:selectedRow inSection:0];
        CGRect cellRectInTableView = [self.tableView rectForRowAtIndexPath:selectedIndexPath];
        CGRect cellRectInView = [self.tableView convertRect:cellRectInTableView toView:self.view];
        CGRect imageRectInView = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 16.0f - myImageBubbleCell.bubbleImageViewWidthConstraint.constant, CGRectGetMinY(cellRectInView) + bubbleImageViewMinY + [TAPUtil currentDeviceNavigationBarHeightWithStatusBar:YES iPhoneXLargeLayout:NO], myImageBubbleCell.bubbleImageViewWidthConstraint.constant, myImageBubbleCell.bubbleImageViewHeightConstraint.constant);
        
        [mediaDetailViewController showToViewController:self.navigationController thumbnailImage:cellImage thumbnailFrame:imageRectInView];
        myImageBubbleCell.bubbleImageView.alpha = 0.0f;
        _openedBubbleCell = myImageBubbleCell;
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

- (void)myImageBubbleLongPressedWithMessage:(TAPMessageModel *)longPressedMessage {
    [self handleLongPressedWithMessage:longPressedMessage];
}

- (void)myImageBubbleDidTriggerSwipeToReplyWithMessage:(TAPMessageModel *)message {
    [self processSwipeToReplyWithMessage:message];
}

- (void)myImageBubblePressedMentionWithWord:(NSString*)word
                              tappedAtIndex:(NSInteger)index
                                    message:(TAPMessageModel *)message
                        mentionIndexesArray:(NSArray *)mentionIndexesArray {
    
    NSString *username = @"";
    for (NSInteger counter = 0; counter < [mentionIndexesArray count]; counter++) {
        NSRange userRange = [[mentionIndexesArray objectAtIndex:counter] rangeValue];
        
        NSInteger locationStart = userRange.location;
        NSInteger locationEnd = locationStart + userRange.length - 1; // -1 for omit location start
        
        if (index >= locationStart && index <= locationEnd) {
            username = [word substringWithRange:userRange];
            break;
        }
    }
    
    NSString *prefixToRemove = @"@";
    if ([username hasPrefix:prefixToRemove]) {
        username = [username substringFromIndex:[prefixToRemove length]];
    }
    
    if ([username isEqualToString:[TAPDataManager getActiveUser].username]) {
        //if tap our username, nothing happens
        return;
    }
    
    [self tapTalkUserMentionTappedWithRoom:self.currentRoom message:message usernameString:username];
}

- (void)myImageBubbleLongPressedMentionWithWord:(NSString*)word
                                  tappedAtIndex:(NSInteger)index
                                        message:(TAPMessageModel *)message
                            mentionIndexesArray:(NSArray *)mentionIndexesArray {
    NSString *username = @"";
    for (NSInteger counter = 0; counter < [mentionIndexesArray count]; counter++) {
        NSRange userRange = [[mentionIndexesArray objectAtIndex:counter] rangeValue];
        
        NSInteger locationStart = userRange.location;
        NSInteger locationEnd = locationStart + userRange.length - 1; // -1 for omit location start
        
        if (index >= locationStart && index <= locationEnd) {
            username = [word substringWithRange:userRange];
            break;
        }
    }
    
    if ([username isEqualToString:[TAPDataManager getActiveUser].username]) {
        //if tap our username, nothing happens
        return;
    }
    
    [TAPUtil tapticImpactFeedbackGenerator];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:username message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *viewProfileAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"View Profile", nil, [TAPUtil currentBundle], @"")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
        [self myImageBubblePressedMentionWithWord:word tappedAtIndex:index message:message mentionIndexesArray:mentionIndexesArray];
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
                                     [self checkAndShowInputAccessoryView];
                                     UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                     [pasteboard setString:username];
                                 }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
                                       [self checkAndShowInputAccessoryView];
                                       [self checkKeyboard];
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
    
    if (self.secondaryTextField.isFirstResponder || self.messageTextView.isFirstResponder) {
        self.isKeyboardWasShowed = YES;
    }
    else {
        self.isKeyboardWasShowed = NO;
    }
    
    [UIView animateWithDuration:0.2f animations:^{
        [self.messageTextView resignFirstResponder];
        [self.secondaryTextField resignFirstResponder];
        [self keyboardWillHideWithHeight:0.0f];
    } completion:^(BOOL finished) {
        [self presentViewController:alertController animated:YES completion:^{
            //after animation
        }];
    }];
}


#pragma mark TAPMyFileBubbleTableViewCell
- (void)myFileQuoteViewDidTapped:(TAPMessageModel *)tappedMessage {
    [self messageBubbleQuoteViewDidTapped:tappedMessage];
}

- (void)myFileReplyDidTapped:(TAPMessageModel *)tappedMessage {
    
    if (self.otherUser == nil && self.currentRoom.type == RoomTypePersonal) {
        return;
    }
    
    TAPMessageModel *quotedMessageModel = [tappedMessage copy];
    
    [self showInputAccessoryExtensionView:NO];
    [self setInputAccessoryExtensionType:inputAccessoryExtensionTypeQuote];
    [self showInputAccessoryExtensionView:YES];
    
    //convert to quote model
    TAPQuoteModel *quote = [TAPQuoteModel constructFromMessageModel:quotedMessageModel];
    [self setQuoteWithQuote:quote userID:quotedMessageModel.user.userID];
    
    quotedMessageModel.quote = quote;
    
    [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessageModel userInfo:nil roomID:self.currentRoom.roomID];
    
    //remove selectedMessage
    self.selectedMessage = nil;
}

- (void)myFileBubbleLongPressedWithMessage:(TAPMessageModel *)longPressedMessage {
    [self handleLongPressedWithMessage:longPressedMessage];
}

- (void)myFileDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage {
    [self fetchFileDataWithMessage:tappedMessage];
}

- (void)myFileRetryUploadDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage {
    if ([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] == AFNetworkReachabilityStatusNotReachable) {
        return;
    }
    
    NSDictionary *dataDictionary = tappedMessage.data;
    NSString *key = [TAPUtil getFileKeyFromMessage:tappedMessage];
    
    if ([key isEqualToString:@""]) {
        //Remove from waiting upload dictionary in ChatManager
        [[TAPChatManager sharedManager] removeFromWaitingUploadFileMessage:tappedMessage];
        
        //File exist, retry upload file
        NSInteger messageIndex = [self.messageArray indexOfObject:tappedMessage];
        
        [TAPDataManager deleteDatabaseMessageWithData:@[tappedMessage] success:^{
            
            [self removeMessageFromArrayAndDictionaryWithLocalID:tappedMessage.localID];
            
            NSIndexPath *deleteAtIndexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
            [self.tableView performBatchUpdates:^{
                //changing beginUpdates and endUpdates with this because of deprecation
                [self.tableView deleteRowsAtIndexPaths:@[deleteAtIndexPath] withRowAnimation:UITableViewRowAnimationTop];
            } completion:^(BOOL finished) {
            }];
            
            NSString *fileName = [tappedMessage.data objectForKey:@"fileName"];
            fileName = [TAPUtil nullToEmptyString:fileName];
            
            NSString *mediaType = [tappedMessage.data objectForKey:@"mediaType"];
            mediaType = [TAPUtil nullToEmptyString:mediaType];
            
            NSString *size = [tappedMessage.data objectForKey:@"size"];
            size = [TAPUtil nullToEmptyString:size];
            
            TAPDataFileModel *dataFile = [TAPDataFileModel new];
            dataFile.fileName = fileName;
            dataFile.mediaType = mediaType;
            dataFile.size = size;
            
            NSString *filePath = [dataDictionary objectForKey:@"filePath"];
            filePath = [TAPUtil nullToEmptyString:filePath];
            
            NSURL *newURL = [NSURL URLWithString:filePath];
            NSData *fileData = [NSData dataWithContentsOfURL:newURL];
            dataFile.fileData = fileData;
            
            [[TAPChatManager sharedManager] sendFileMessage:dataFile filePath:filePath];
            
        } failure:^(NSError *error) {
            
        }];
    }
    else if (tappedMessage.isFailedSend) {
        // File already uploaded, resend message
        TAPMessageModel *messageToResend = [TAPMessageModel createMessageWithUser:tappedMessage.user
                                                                             room:tappedMessage.room
                                                                             body:tappedMessage.body
                                                                             type:tappedMessage.type
                                                                            quote:tappedMessage.quote
                                                                      messageData:tappedMessage.data];
        NSInteger messageIndex = [self.messageArray indexOfObject:tappedMessage];
        [TAPDataManager deleteDatabaseMessageWithData:@[tappedMessage] success:^{
            [self.messageArray removeObjectAtIndex:messageIndex];
            [self.messageDictionary removeObjectForKey:tappedMessage.localID];
            NSIndexPath *deleteAtIndexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
            [self.tableView performBatchUpdates:^{
                //changing beginUpdates and endUpdates with this because of deprecation
                [self.tableView deleteRowsAtIndexPaths:@[deleteAtIndexPath] withRowAnimation:UITableViewRowAnimationTop];
            } completion:^(BOOL finished) {
            }];
            
            [[TAPChatManager sharedManager] sendCustomMessage:messageToResend];
        } failure:^(NSError *error) {
            
        }];
    }
    else {
        //File not exist, retry download file
        [self fetchFileDataWithMessage:tappedMessage];
    }
}

- (void)myFileCancelButtonDidTapped:(TAPMessageModel *)tappedMessage {
    NSDictionary *dataDictionary = tappedMessage.data;
    NSString *key = [TAPUtil getFileKeyFromMessage:tappedMessage];
    
    if ([key isEqualToString:@""]) {
        //File exist, uploading file state
        //Cancel uploading task
        [[TAPFileUploadManager sharedManager] cancelUploadingOperationWithMessage:tappedMessage];
        
        //Remove message from array and dictionary in ChatViewController
        TAPMessageModel *currentDeletedMessage = [self.messageDictionary objectForKey:tappedMessage.localID];
        NSInteger deletedIndex = [self.messageArray indexOfObject:currentDeletedMessage];
        [self removeMessageFromArrayAndDictionaryWithLocalID:tappedMessage.localID];
        
        //Remove from WaitingUploadDictionary in ChatManager
        [[TAPChatManager sharedManager] removeFromWaitingUploadFileMessage:tappedMessage];
        
        //Remove message from database
        [TAPDataManager deleteDatabaseMessageWithData:@[tappedMessage] success:^{
            
        } failure:^(NSError *error) {
            
        }];
        
        //Update chat room UI
        NSIndexPath *deleteAtIndexPath = [NSIndexPath indexPathForRow:deletedIndex inSection:0];
        [self.tableView performBatchUpdates:^{
            //changing beginUpdates and endUpdates with this because of deprecation
            [self.tableView deleteRowsAtIndexPaths:@[deleteAtIndexPath] withRowAnimation:UITableViewRowAnimationTop];
        } completion:^(BOOL finished) {
        }];
    }
    else {
        //File not exist, download file
        //Cancel downloading task
        [[TAPFileDownloadManager sharedManager] cancelDownloadWithMessage:tappedMessage];
    }
}

- (void)myFileOpenFileButtonDidTapped:(TAPMessageModel *)tappedMessage {
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
    
    if (filePath == nil || [filePath isEqualToString:@""]) {
        return;
    }
    
    self.currentSelectedFileURL = [NSURL fileURLWithPath:filePath];
    
    QLPreviewController *preview = [[QLPreviewController alloc] init];
    preview.dataSource = self;
    preview.delegate = self;
    
    [self presentViewController:preview animated:YES completion:nil];
}

- (void)myFileBubbleDidTriggerSwipeToReplyWithMessage:(TAPMessageModel *)message {
    [self processSwipeToReplyWithMessage:message];
}

#pragma mark TAPMyLocationBubbleTableViewCell
- (void)myLocationBubbleViewDidTapped:(TAPMessageModel *)tappedMessage {
    if (tappedMessage.isFailedSend) {
        NSInteger messageIndex = [self.messageArray indexOfObject:tappedMessage];
        
        NSDictionary *dataDictionary = tappedMessage.data;
        dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];
        
        NSString *currentAddress = [dataDictionary objectForKey:@"address"];
        currentAddress = [TAPUtil nullToEmptyString:currentAddress];
        CGFloat currentLatitude = [[dataDictionary objectForKey:@"latitude"] floatValue];
        CGFloat currentLongitude = [[dataDictionary objectForKey:@"longitude"] floatValue];
        
        [TAPDataManager deleteDatabaseMessageWithData:@[tappedMessage] success:^{
            [self.messageArray removeObjectAtIndex:messageIndex];
            [self.messageDictionary removeObjectForKey:tappedMessage.localID];
            NSIndexPath *deleteAtIndexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
            [self.tableView performBatchUpdates:^{
                //changing beginUpdates and endUpdates with this because of deprecation
                [self.tableView deleteRowsAtIndexPaths:@[deleteAtIndexPath] withRowAnimation:UITableViewRowAnimationTop];
            } completion:^(BOOL finished) {
            }];
            
            [[TAPChatManager sharedManager] sendLocationMessage:currentLatitude longitude:currentLongitude address:currentAddress];
        } failure:^(NSError *error) {
            
        }];
    }
    else if (!tappedMessage.isSending) {
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
                                           [self checkAndShowInputAccessoryView];
                                           [self checkKeyboard];
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
}

- (void)myLocationQuoteViewDidTapped:(TAPMessageModel *)tappedMessage {
    [self messageBubbleQuoteViewDidTapped:tappedMessage];
}

- (void)myLocationReplyDidTapped:(TAPMessageModel *)tappedMessage {
    
    if (self.otherUser == nil && self.currentRoom.type == RoomTypePersonal) {
        return;
    }
    
    NSInteger messageIndex = [self.messageArray indexOfObject:tappedMessage];
    NSIndexPath *selectedMessageIndexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
    
    [self showInputAccessoryExtensionView:NO];
    [self setInputAccessoryExtensionType:inputAccessoryExtensionTypeReplyMessage];
    [self setReplyMessageWithMessage:tappedMessage];
    [self showInputAccessoryExtensionView:YES];
    
    TAPMessageModel *quotedMessageModel = [tappedMessage copy];
    [[TAPChatManager sharedManager] saveToQuotedMessage:tappedMessage userInfo:nil roomID:self.currentRoom.roomID];
    
    //remove selectedMessage
    self.selectedMessage = nil;
    
    TAPMyLocationBubbleTableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedMessageIndexPath];
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
        //animation
        [cell showStatusLabel:YES animated:YES updateStatusIcon:YES message:tappedMessage];
        //        [cell showStatusLabel:NO animated:YES updateStatusIcon:YES message:tappedMessage];
        [cell layoutIfNeeded];
        [self.tableView performBatchUpdates:^{
            //changing beginUpdates and endUpdates with this because of deprecation
        } completion:^(BOOL finished) {
        }];
    } completion:^(BOOL finished) {
        //completion
    }];
}

- (void)myLocationBubbleLongPressedWithMessage:(TAPMessageModel *)longPressedMessage {
    [self handleLongPressedWithMessage:longPressedMessage];
}

- (void)myLocationBubbleDidTriggerSwipeToReplyWithMessage:(TAPMessageModel *)message {
    [self processSwipeToReplyWithMessage:message];
}

#pragma mark TAPMyVideoBubbleTableViewCell
- (void)myVideoQuoteDidTappedWithMessage:(TAPMessageModel *)message {
    [self messageBubbleQuoteViewDidTapped:message];
}

- (void)myVideoReplyDidTappedWithMessage:(TAPMessageModel *)message {
    if (self.otherUser == nil && self.currentRoom.type == RoomTypePersonal) {
        return;
    }
    
    TAPMessageModel *quotedMessageModel = [message copy];
    
    //WK Note : Do reply here later.
    [self showInputAccessoryExtensionView:NO];
    [self setInputAccessoryExtensionType:inputAccessoryExtensionTypeQuote];
    [self showInputAccessoryExtensionView:YES];
    
    //convert to quote model
    TAPQuoteModel *quote = [TAPQuoteModel constructFromMessageModel:message];
    [self setQuoteWithQuote:quote userID:quotedMessageModel.user.userID];
    
    quotedMessageModel.quote = quote;
    
    [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessageModel userInfo:nil roomID:self.currentRoom.roomID];
    
    //remove selectedMessage
    self.selectedMessage = nil;
}

- (void)myVideoBubbleLongPressedWithMessage:(TAPMessageModel *)longPressedMessage {
    [self handleLongPressedWithMessage:longPressedMessage];
}

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

- (void)myVideoCancelDidTappedWithMessage:(TAPMessageModel *)message {
    NSString *key = [TAPUtil getFileKeyFromMessage:message];
    
    if ([key isEqualToString:@""]) {
        //Video exist, uploading file state
        //Cancel uploading task
        [[TAPFileUploadManager sharedManager] cancelUploadingOperationWithMessage:message];
        
        //Remove message from array and dictionary in ChatViewController
        TAPMessageModel *currentDeletedMessage = [self.messageDictionary objectForKey:message.localID];
        NSInteger deletedIndex = [self.messageArray indexOfObject:currentDeletedMessage];
        [self removeMessageFromArrayAndDictionaryWithLocalID:message.localID];
        
        //Remove from WaitingUploadDictionary in ChatManager
        [[TAPChatManager sharedManager] removeFromWaitingUploadFileMessage:message];
        
        //Remove message from database
        [TAPDataManager deleteDatabaseMessageWithData:@[message] success:^{
            
        } failure:^(NSError *error) {
            
        }];
        
        //Update chat room UI
        NSIndexPath *deleteAtIndexPath = [NSIndexPath indexPathForRow:deletedIndex inSection:0];
        [self.tableView performBatchUpdates:^{
            //changing beginUpdates and endUpdates with this because of deprecation
            [self.tableView deleteRowsAtIndexPaths:@[deleteAtIndexPath] withRowAnimation:UITableViewRowAnimationTop];
        } completion:^(BOOL finished) {
        }];
    }
    else {
        //Video not exist, download file
        //Cancel downloading task
        [[TAPFileDownloadManager sharedManager] cancelDownloadWithMessage:message];
    }
}

- (void)myVideoRetryUploadDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage {
    NSLog(@"myVideoRetryUploadDownloadButtonDidTapped: %ld", [[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus]);
    if ([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] == AFNetworkReachabilityStatusNotReachable) {
        return;
    }
    
    NSString *key = [TAPUtil getFileKeyFromMessage:tappedMessage];
    
    if ([key isEqualToString:@""]) {
        //Video exist, retry upload
        NSInteger messageIndex = [self.messageArray indexOfObject:tappedMessage];
        
        NSString *caption = [tappedMessage.data objectForKey:@"caption"];
        caption = [TAPUtil nullToEmptyString:caption];
        
        [TAPDataManager deleteDatabaseMessageWithData:@[tappedMessage] success:^{

            [self.messageArray removeObjectAtIndex:messageIndex];
            [self.messageDictionary removeObjectForKey:tappedMessage.localID];
            NSIndexPath *deleteAtIndexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
            [self.tableView performBatchUpdates:^{
                //changing beginUpdates and endUpdates with this because of deprecation
                [self.tableView deleteRowsAtIndexPaths:@[deleteAtIndexPath] withRowAnimation:UITableViewRowAnimationTop];
            } completion:^(BOOL finished) {
            }];
            
            NSString *thumbnailImageBase64String = [tappedMessage.data objectForKey:@"thumbnail"];
            NSData *thumbnailImageData = [[NSData alloc] initWithBase64EncodedString:thumbnailImageBase64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
            
            //            PHAsset *asset = [tappedMessage.data objectForKey:@"asset"];
            NSString *assetIdentifier = [tappedMessage.data objectForKey:@"assetIdentifier"];
            assetIdentifier = [TAPUtil nullToEmptyString:assetIdentifier];
            
            PHAsset *asset = [[TAPFileUploadManager sharedManager] getAssetFromPendingUploadAssetDictionaryWithAssetIdentifier:assetIdentifier];
            
            if (asset != nil && asset.mediaType == PHAssetMediaTypeVideo) {
                [[TAPChatManager sharedManager] sendVideoMessageWithPHAsset:asset caption:caption thumbnailImageData:thumbnailImageData];
            }
            else {
                NSArray<NSString *> *assetIdentifierArray = [NSArray arrayWithObject:assetIdentifier];
                PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:assetIdentifierArray options:nil];
                PHAsset *videoAsset = [fetchResult firstObject];
                if (videoAsset != nil && videoAsset.mediaType == PHAssetMediaTypeVideo) {
                    [[TAPChatManager sharedManager] sendVideoMessageWithPHAsset:videoAsset caption:caption thumbnailImageData:thumbnailImageData];
                }
                else {
                    // Video data not found
                    [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage
                                     popupIdentifier:@"Video Asset Not Found"
                                               title:NSLocalizedStringFromTableInBundle(@"Unable to Resend Message", nil, [TAPUtil currentBundle], @"")
                                   detailInformation:NSLocalizedStringFromTableInBundle(@"Video data is not found, please try resending the message from camera or gallery.", nil, [TAPUtil currentBundle], @"")
                               leftOptionButtonTitle:nil
                      singleOrRightOptionButtonTitle:nil];
                }
            }
        } failure:^(NSError *error) {
            
        }];
    }
    else if (tappedMessage.isFailedSend) {
        // Video already uploaded, resend message
        TAPMessageModel *messageToResend = [TAPMessageModel createMessageWithUser:tappedMessage.user
                                                                             room:tappedMessage.room
                                                                             body:tappedMessage.body
                                                                             type:tappedMessage.type
                                                                            quote:tappedMessage.quote
                                                                      messageData:tappedMessage.data];
        NSInteger messageIndex = [self.messageArray indexOfObject:tappedMessage];
        [TAPDataManager deleteDatabaseMessageWithData:@[tappedMessage] success:^{
            [self.messageArray removeObjectAtIndex:messageIndex];
            [self.messageDictionary removeObjectForKey:tappedMessage.localID];
            NSIndexPath *deleteAtIndexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
            [self.tableView performBatchUpdates:^{
                //changing beginUpdates and endUpdates with this because of deprecation
                [self.tableView deleteRowsAtIndexPaths:@[deleteAtIndexPath] withRowAnimation:UITableViewRowAnimationTop];
            } completion:^(BOOL finished) {
            }];
            
            [[TAPChatManager sharedManager] sendCustomMessage:messageToResend];
        } failure:^(NSError *error) {
            
        }];
    }
    else {
        //Video not exist, retry download
        [self fetchVideoDataWithMessage:tappedMessage];
    }
}

- (void)myVideoDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage {
    [self fetchVideoDataWithMessage:tappedMessage];
}

- (void)myVideoPlayDidTappedWithMessage:(TAPMessageModel *)message {
    [self playVideoWithMessage:message];
}

- (void)myVideoBubbleDidTriggerSwipeToReplyWithMessage:(TAPMessageModel *)message {
    [self processSwipeToReplyWithMessage:message];
}

- (void)myVideoBubblePressedMentionWithWord:(NSString*)word
                              tappedAtIndex:(NSInteger)index
                                    message:(TAPMessageModel *)message
                        mentionIndexesArray:(NSArray *)mentionIndexesArray {
    
    NSString *username = @"";
    for (NSInteger counter = 0; counter < [mentionIndexesArray count]; counter++) {
        NSRange userRange = [[mentionIndexesArray objectAtIndex:counter] rangeValue];
        
        NSInteger locationStart = userRange.location;
        NSInteger locationEnd = locationStart + userRange.length - 1; // -1 for omit location start
        
        if (index >= locationStart && index <= locationEnd) {
            username = [word substringWithRange:userRange];
            break;
        }
    }
    
    NSString *prefixToRemove = @"@";
    if ([username hasPrefix:prefixToRemove]) {
        username = [username substringFromIndex:[prefixToRemove length]];
    }
    
    if ([username isEqualToString:[TAPDataManager getActiveUser].username]) {
        //if tap our username, nothing happens
        return;
    }
    
    [self tapTalkUserMentionTappedWithRoom:self.currentRoom message:message usernameString:username];
}

- (void)myVideoBubbleLongPressedMentionWithWord:(NSString*)word
                                  tappedAtIndex:(NSInteger)index
                                        message:(TAPMessageModel *)message
                            mentionIndexesArray:(NSArray *)mentionIndexesArray {
    NSString *username = @"";
    for (NSInteger counter = 0; counter < [mentionIndexesArray count]; counter++) {
        NSRange userRange = [[mentionIndexesArray objectAtIndex:counter] rangeValue];
        
        NSInteger locationStart = userRange.location;
        NSInteger locationEnd = locationStart + userRange.length - 1; // -1 for omit location start
        
        if (index >= locationStart && index <= locationEnd) {
            username = [word substringWithRange:userRange];
            break;
        }
    }
    
    if ([username isEqualToString:[TAPDataManager getActiveUser].username]) {
        //if tap our username, nothing happens
        return;
    }
    
    [TAPUtil tapticImpactFeedbackGenerator];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:username message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *viewProfileAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"View Profile", nil, [TAPUtil currentBundle], @"")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
        [self myVideoBubblePressedMentionWithWord:word tappedAtIndex:index message:message mentionIndexesArray:mentionIndexesArray];
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
                                     [self checkAndShowInputAccessoryView];
                                     UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                     [pasteboard setString:username];
                                 }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
                                       [self checkAndShowInputAccessoryView];
                                       [self checkKeyboard];
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
    
    if (self.secondaryTextField.isFirstResponder || self.messageTextView.isFirstResponder) {
        self.isKeyboardWasShowed = YES;
    }
    else {
        self.isKeyboardWasShowed = NO;
    }
    
    [UIView animateWithDuration:0.2f animations:^{
        [self.messageTextView resignFirstResponder];
        [self.secondaryTextField resignFirstResponder];
        [self keyboardWillHideWithHeight:0.0f];
    } completion:^(BOOL finished) {
        [self presentViewController:alertController animated:YES completion:^{
            //after animation
        }];
    }];
}

#pragma mark TAPYourChatBubbleTableViewCell
- (void)yourChatBubbleViewDidTapped:(TAPMessageModel *)tappedMessage {
    if (!tappedMessage.isSending) {
        if (tappedMessage == self.selectedMessage) {
            //select message that had been selected
            self.selectedMessage = nil;
            
            NSInteger messageIndex = [self.messageArray indexOfObject:tappedMessage];
            NSIndexPath *selectedMessageIndexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
            TAPYourChatBubbleTableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedMessageIndexPath];
            
            [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
                //animation
                [cell showStatusLabel:NO animated:YES];
                [cell layoutIfNeeded];
                [self.tableView performBatchUpdates:^{
                    //changing beginUpdates and endUpdates with this because of deprecation
                } completion:^(BOOL finished) {
                }];
            } completion:^(BOOL finished) {
                //completion
            }];
        }
        else {
            //select message that had not been selected
            if (self.selectedMessage == nil) {
                //no messages had been selected
                self.selectedMessage = tappedMessage;
                NSInteger messageIndex = [self.messageArray indexOfObject:tappedMessage];
                NSIndexPath *selectedMessageIndexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
                
                TAPYourChatBubbleTableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedMessageIndexPath];
                
                [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
                    //animation
                    [cell showStatusLabel:YES animated:YES];
                    [cell layoutIfNeeded];
                    [self.tableView performBatchUpdates:^{
                        //changing beginUpdates and endUpdates with this because of deprecation
                    } completion:^(BOOL finished) {
                    }];
                } completion:^(BOOL finished) {
                    //completion
                }];
            }
            else {
                //a message had been selected
                NSInteger previousMessageIndex = [self.messageArray indexOfObject:self.selectedMessage];
                NSIndexPath *selectedPreviousMessageIndexPath = [NSIndexPath indexPathForRow:previousMessageIndex inSection:0];
                
                id previousCell;
                BOOL isMyCell = NO;
                if ([self.selectedMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                    previousCell = (TAPMyChatBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:selectedPreviousMessageIndexPath];
                    isMyCell = YES;
                }
                else {
                    previousCell = (TAPYourChatBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:selectedPreviousMessageIndexPath];
                }
                
                self.selectedMessage = tappedMessage;
                NSInteger messageIndex = [self.messageArray indexOfObject:tappedMessage];
                NSIndexPath *selectedMessageIndexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
                
                TAPYourChatBubbleTableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedMessageIndexPath];
                
                [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
                    //animation
                    if (isMyCell) {
                        [previousCell showStatusLabel:NO animated:YES updateStatusIcon:YES message:tappedMessage];
                    }
                    else {
                        [previousCell showStatusLabel:NO animated:YES];
                    }
                    [previousCell layoutIfNeeded];
                    
                    [cell showStatusLabel:YES animated:YES];
                    [cell layoutIfNeeded];
                    [self.tableView performBatchUpdates:^{
                        //changing beginUpdates and endUpdates with this because of deprecation
                    } completion:^(BOOL finished) {
                    }];
                } completion:^(BOOL finished) {
                    //completion
                }];
            }
        }
    }
}

- (void)yourChatReplyDidTapped {
    
    if (self.otherUser == nil && self.currentRoom.type == RoomTypePersonal) {
        return;
    }
    
    [self checkAndShowInputAccessoryView];
    
    //set selected message to chat field
    NSInteger messageIndex = [self.messageArray indexOfObject:self.selectedMessage];
    NSIndexPath *selectedMessageIndexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
    //WK Note : Do reply here later.
    [self showInputAccessoryExtensionView:NO];
    [self setInputAccessoryExtensionType:inputAccessoryExtensionTypeReplyMessage];
    [self setReplyMessageWithMessage:self.selectedMessage];
    [self showInputAccessoryExtensionView:YES];
    
    TAPMessageModel *quotedMessageModel = [self.selectedMessage copy];
    [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessageModel userInfo:nil roomID:self.currentRoom.roomID];
    
    //remove selectedMessage
    self.selectedMessage = nil;
    
    TAPYourChatBubbleTableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedMessageIndexPath];
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
        //animation
        [cell showStatusLabel:NO animated:YES];
        [cell layoutIfNeeded];
        [self.tableView performBatchUpdates:^{
            //changing beginUpdates and endUpdates with this because of deprecation
        } completion:^(BOOL finished) {
        }];
    } completion:^(BOOL finished) {
        //completion
    }];
}

- (void)yourChatQuoteViewDidTapped:(TAPMessageModel *)tappedMessage {
    [self messageBubbleQuoteViewDidTapped:tappedMessage];
}

- (void)yourChatBubbleDidTappedUrl:(NSURL *)url
                    originalString:(NSString *)originalString {
    [self handleTappedWithURL:url originalString:originalString];
}

- (void)yourChatBubbleDidTappedPhoneNumber:(NSString *)phoneNumber
                            originalString:(NSString *)originalString {
    [self handleTappedWithPhoneNumber:phoneNumber originalString:originalString];
}

- (void)yourChatBubbleLongPressedUrl:(NSURL *)url
                      originalString:(NSString *)originalString {
    [self handleLongPressedWithURL:url originalString:originalString];
}

- (void)yourChatBubbleLongPressedPhoneNumber:(NSString *)phoneNumber
                              originalString:(NSString *)originalString {
    [self handleLongPressedWithPhoneNumber:phoneNumber originalString:originalString];
}

- (void)yourChatBubbleLongPressedWithMessage:(TAPMessageModel *)longPressedMessage {
    [self handleLongPressedWithMessage:longPressedMessage];
}

- (void)yourChatBubbleDidTappedProfilePictureWithMessage:(TAPMessageModel *)tappedMessage {
    [self openUserProfileFromGroupChatWithMessage:tappedMessage];
}

- (void)yourChatBubbleDidTriggerSwipeToReplyWithMessage:(TAPMessageModel *)message {
    [self processSwipeToReplyWithMessage:message];
}

- (void)yourChatBubblePressedMentionWithWord:(NSString*)word
                               tappedAtIndex:(NSInteger)index
                                     message:(TAPMessageModel *)message
                         mentionIndexesArray:(NSArray *)mentionIndexesArray {
    NSString *username = @"";
    for (NSInteger counter = 0; counter < [mentionIndexesArray count]; counter++) {
        NSRange userRange = [[mentionIndexesArray objectAtIndex:counter] rangeValue];
        
        NSInteger locationStart = userRange.location;
        NSInteger locationEnd = locationStart + userRange.length - 1; // -1 for omit location start
        
        if (index >= locationStart && index <= locationEnd) {
            username = [word substringWithRange:userRange];
            break;
        }
    }
    
    NSString *prefixToRemove = @"@";
    if ([username hasPrefix:prefixToRemove]) {
        username = [username substringFromIndex:[prefixToRemove length]];
    }
    
    if ([username isEqualToString:[TAPDataManager getActiveUser].username]) {
        //if tap our username, nothing happens
        return;
    }
    
    [self tapTalkUserMentionTappedWithRoom:self.currentRoom message:message usernameString:username];
}

- (void)yourChatBubbleLongPressedMentionWithWord:(NSString*)word
                                   tappedAtIndex:(NSInteger)index
                                         message:(TAPMessageModel *)message
                             mentionIndexesArray:(NSArray *)mentionIndexesArray {
    NSString *username = @"";
    for (NSInteger counter = 0; counter < [mentionIndexesArray count]; counter++) {
        NSRange userRange = [[mentionIndexesArray objectAtIndex:counter] rangeValue];
        
        NSInteger locationStart = userRange.location;
        NSInteger locationEnd = locationStart + userRange.length - 1; // -1 for omit location start
        
        if (index >= locationStart && index <= locationEnd) {
            username = [word substringWithRange:userRange];
            break;
        }
    }
    
    if ([username isEqualToString:[TAPDataManager getActiveUser].username]) {
        //if tap our username, nothing happens
        return;
    }
    
    [TAPUtil tapticImpactFeedbackGenerator];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:username message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *viewProfileAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"View Profile", nil, [TAPUtil currentBundle], @"")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
        [self yourChatBubblePressedMentionWithWord:word tappedAtIndex:index message:message mentionIndexesArray:mentionIndexesArray];
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
                                     [self checkAndShowInputAccessoryView];
                                     UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                     [pasteboard setString:username];
                                 }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
                                       [self checkAndShowInputAccessoryView];
                                       [self checkKeyboard];
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
    
    if (self.secondaryTextField.isFirstResponder || self.messageTextView.isFirstResponder) {
        self.isKeyboardWasShowed = YES;
    }
    else {
        self.isKeyboardWasShowed = NO;
    }
    
    [UIView animateWithDuration:0.2f animations:^{
        [self.messageTextView resignFirstResponder];
        [self.secondaryTextField resignFirstResponder];
        [self keyboardWillHideWithHeight:0.0f];
    } completion:^(BOOL finished) {
        [self presentViewController:alertController animated:YES completion:^{
            //after animation
        }];
    }];
}

#pragma mark TAPYourChatDeletedBubbleTableViewCell
- (void)yourChatDeletedBubbleViewDidTapped:(TAPMessageModel *)tappedMessage {
    if (!tappedMessage.isSending) {
        if (tappedMessage == self.selectedMessage) {
            //select message that had been selected
            self.selectedMessage = nil;
            
            NSInteger messageIndex = [self.messageArray indexOfObject:tappedMessage];
            NSIndexPath *selectedMessageIndexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
            TAPYourChatBubbleTableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedMessageIndexPath];
            
            [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
                //animation
                [cell showStatusLabel:NO animated:YES];
                [cell layoutIfNeeded];
                [self.tableView performBatchUpdates:^{
                    //changing beginUpdates and endUpdates with this because of deprecation
                } completion:^(BOOL finished) {
                }];
            } completion:^(BOOL finished) {
                //completion
            }];
        }
        else {
            //select message that had not been selected
            if (self.selectedMessage == nil) {
                //no messages had been selected
                self.selectedMessage = tappedMessage;
                NSInteger messageIndex = [self.messageArray indexOfObject:tappedMessage];
                NSIndexPath *selectedMessageIndexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
                
                TAPYourChatBubbleTableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedMessageIndexPath];
                
                [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
                    //animation
                    [cell showStatusLabel:YES animated:YES];
                    [cell layoutIfNeeded];
                    [self.tableView performBatchUpdates:^{
                        //changing beginUpdates and endUpdates with this because of deprecation
                    } completion:^(BOOL finished) {
                    }];
                } completion:^(BOOL finished) {
                    //completion
                }];
            }
            else {
                //a message had been selected
                NSInteger previousMessageIndex = [self.messageArray indexOfObject:self.selectedMessage];
                NSIndexPath *selectedPreviousMessageIndexPath = [NSIndexPath indexPathForRow:previousMessageIndex inSection:0];
                
                id previousCell;
                BOOL isMyCell = NO;
                if ([self.selectedMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                    previousCell = (TAPMyChatBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:selectedPreviousMessageIndexPath];
                    isMyCell = YES;
                }
                else {
                    previousCell = (TAPYourChatBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:selectedPreviousMessageIndexPath];
                }
                
                self.selectedMessage = tappedMessage;
                NSInteger messageIndex = [self.messageArray indexOfObject:tappedMessage];
                NSIndexPath *selectedMessageIndexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
                
                TAPYourChatBubbleTableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedMessageIndexPath];
                
                [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
                    //animation
                    if (isMyCell) {
                        [previousCell showStatusLabel:NO animated:YES updateStatusIcon:YES message:tappedMessage];
                    }
                    else {
                        [previousCell showStatusLabel:NO animated:YES];
                    }
                    [previousCell layoutIfNeeded];
                    
                    [cell showStatusLabel:YES animated:YES];
                    [cell layoutIfNeeded];
                    [self.tableView performBatchUpdates:^{
                        //changing beginUpdates and endUpdates with this because of deprecation
                    } completion:^(BOOL finished) {
                    }];
                } completion:^(BOOL finished) {
                    //completion
                }];
            }
        }
    }
}

- (void)yourChatDeletedBubbleDidTappedProfilePictureWithMessage:(TAPMessageModel *)tappedMessage {
    [self openUserProfileFromGroupChatWithMessage:tappedMessage];
}

#pragma mark TAPYourImageBubbleTableViewCell
- (void)yourImageReplyDidTappedWithMessage:(TAPMessageModel *)message {
    
    if (self.otherUser == nil && self.currentRoom.type == RoomTypePersonal) {
        return;
    }
    
    TAPMessageModel *quotedMessageModel = [message copy];
    
    //WK Note : Do reply here later.
    [self showInputAccessoryExtensionView:NO];
    [self setInputAccessoryExtensionType:inputAccessoryExtensionTypeQuote];
    [self showInputAccessoryExtensionView:YES];
    
    //convert to quote model
    TAPQuoteModel *quote = [TAPQuoteModel constructFromMessageModel:message];
    [self setQuoteWithQuote:quote userID:quotedMessageModel.user.userID];
    
    quotedMessageModel.quote = quote;
    
    [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessageModel userInfo:nil roomID:self.currentRoom.roomID];
    
    //remove selectedMessage
    self.selectedMessage = nil;
}

- (void)yourImageQuoteDidTappedWithMessage:(TAPMessageModel *)message {
    [self messageBubbleQuoteViewDidTapped:message];
}

- (void)yourImageDidTapped:(TAPYourImageBubbleTableViewCell *)yourImageBubbleCell {
    CGFloat bubbleImageViewMinY = CGRectGetMinY(yourImageBubbleCell.bubbleImageView.frame);
    
    TAPMediaDetailViewController *mediaDetailViewController = [[TAPMediaDetailViewController alloc] init];
    [mediaDetailViewController setMediaDetailViewControllerType:TAPMediaDetailViewControllerTypeImage];
    mediaDetailViewController.delegate = self;
    mediaDetailViewController.message = yourImageBubbleCell.message;
    
    UIImage *cellImage = yourImageBubbleCell.bubbleImageView.image;
    NSArray *imageSliderImage = [NSArray array];
    if(cellImage != nil) {
        [self.messageTextView resignFirstResponder];
        [self.secondaryTextField resignFirstResponder];
        [self keyboardWillHideWithHeight:0.0f];
        
        _isShowAccessoryView = NO;
        [self reloadInputViews];
        
        imageSliderImage = @[cellImage];
        TAPMessageModel *currentMessage = yourImageBubbleCell.message;
        
        [mediaDetailViewController setThumbnailImageArray:imageSliderImage];
        [mediaDetailViewController setImageArray:@[cellImage]];
        
        [mediaDetailViewController setActiveIndex:0];
        
        NSInteger selectedRow = [self.messageArray indexOfObject:yourImageBubbleCell.message];
        NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:selectedRow inSection:0];
        CGRect cellRectInTableView = [self.tableView rectForRowAtIndexPath:selectedIndexPath];
        CGRect cellRectInView = [self.tableView convertRect:cellRectInTableView toView:self.view];
        
        //Default left gap for personal chat
        CGFloat xPosition = 16.0f;
        if (currentMessage.room.type == RoomTypeGroup || currentMessage.room.type == RoomTypeChannel || currentMessage.room.type == RoomTypeTransaction) {
            //left gap + image width + gap between image and bubble view
            xPosition = 16.0f + 30.0f + 4.0f;
        }
        
        CGRect imageRectInView = CGRectMake(xPosition, CGRectGetMinY(cellRectInView) + bubbleImageViewMinY + [TAPUtil currentDeviceNavigationBarHeightWithStatusBar:YES iPhoneXLargeLayout:NO], yourImageBubbleCell.bubbleImageViewWidthConstraint.constant, yourImageBubbleCell.bubbleImageViewHeightConstraint.constant);
        
        [mediaDetailViewController showToViewController:self.navigationController thumbnailImage:cellImage thumbnailFrame:imageRectInView];
        yourImageBubbleCell.bubbleImageView.alpha = 0.0f;
        _openedBubbleCell = yourImageBubbleCell;
    }
}

- (void)yourImageDidTappedUrl:(NSURL *)url
               originalString:(NSString *)originalString {
    [self handleTappedWithURL:url originalString:originalString];
}

- (void)yourImageDidTappedPhoneNumber:(NSString *)phoneNumber
                       originalString:(NSString *)originalString {
    [self handleTappedWithPhoneNumber:phoneNumber originalString:originalString];
}

- (void)yourImageLongPressedUrl:(NSURL *)url
                 originalString:(NSString *)originalString {
    [self handleLongPressedWithURL:url originalString:originalString];
}

- (void)yourImageLongPressedPhoneNumber:(NSString *)phoneNumber
                         originalString:(NSString *)originalString {
    [self handleLongPressedWithPhoneNumber:phoneNumber originalString:originalString];
}

- (void)yourImageBubbleLongPressedWithMessage:(TAPMessageModel *)longPressedMessage {
    [self handleLongPressedWithMessage:longPressedMessage];
}

- (void)yourImageBubbleDidTappedProfilePictureWithMessage:(TAPMessageModel *)tappedMessage {
    [self openUserProfileFromGroupChatWithMessage:tappedMessage];
}

- (void)yourImageBubbleDidTriggerSwipeToReplyWithMessage:(TAPMessageModel *)message {
    [self processSwipeToReplyWithMessage:message];
}

- (void)yourImageBubblePressedMentionWithWord:(NSString*)word
                                tappedAtIndex:(NSInteger)index
                                      message:(TAPMessageModel *)message
                          mentionIndexesArray:(NSArray *)mentionIndexesArray {
    NSString *username = @"";
    for (NSInteger counter = 0; counter < [mentionIndexesArray count]; counter++) {
        NSRange userRange = [[mentionIndexesArray objectAtIndex:counter] rangeValue];
        
        NSInteger locationStart = userRange.location;
        NSInteger locationEnd = locationStart + userRange.length - 1; // -1 for omit location start
        
        if (index >= locationStart && index <= locationEnd) {
            username = [word substringWithRange:userRange];
            break;
        }
    }
    
    NSString *prefixToRemove = @"@";
    if ([username hasPrefix:prefixToRemove]) {
        username = [username substringFromIndex:[prefixToRemove length]];
    }
    
    if ([username isEqualToString:[TAPDataManager getActiveUser].username]) {
        //if tap our username, nothing happens
        return;
    }
    
    [self tapTalkUserMentionTappedWithRoom:self.currentRoom message:message usernameString:username];
}

- (void)yourImageBubbleLongPressedMentionWithWord:(NSString*)word
                                    tappedAtIndex:(NSInteger)index
                                          message:(TAPMessageModel *)message
                              mentionIndexesArray:(NSArray *)mentionIndexesArray {
    NSString *username = @"";
    for (NSInteger counter = 0; counter < [mentionIndexesArray count]; counter++) {
        NSRange userRange = [[mentionIndexesArray objectAtIndex:counter] rangeValue];
        
        NSInteger locationStart = userRange.location;
        NSInteger locationEnd = locationStart + userRange.length - 1; // -1 for omit location start
        
        if (index >= locationStart && index <= locationEnd) {
            username = [word substringWithRange:userRange];
            break;
        }
    }
    
    if ([username isEqualToString:[TAPDataManager getActiveUser].username]) {
        //if tap our username, nothing happens
        return;
    }
    
    [TAPUtil tapticImpactFeedbackGenerator];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:username message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *viewProfileAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"View Profile", nil, [TAPUtil currentBundle], @"")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
        [self yourImageBubblePressedMentionWithWord:word tappedAtIndex:index message:message mentionIndexesArray:mentionIndexesArray];
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
                                     [self checkAndShowInputAccessoryView];
                                     UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                     [pasteboard setString:username];
                                 }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
                                       [self checkAndShowInputAccessoryView];
                                       [self checkKeyboard];
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
    
    if (self.secondaryTextField.isFirstResponder || self.messageTextView.isFirstResponder) {
        self.isKeyboardWasShowed = YES;
    }
    else {
        self.isKeyboardWasShowed = NO;
    }
    
    [UIView animateWithDuration:0.2f animations:^{
        [self.messageTextView resignFirstResponder];
        [self.secondaryTextField resignFirstResponder];
        [self keyboardWillHideWithHeight:0.0f];
    } completion:^(BOOL finished) {
        [self presentViewController:alertController animated:YES completion:^{
            //after animation
        }];
    }];
}


#pragma mark TAPYourFileBubbleTableViewCell
- (void)yourFileBubbleViewDidTapped:(TAPMessageModel *)tappedMessage {
    
}

- (void)yourFileQuoteViewDidTapped:(TAPMessageModel *)tappedMessage {
    [self messageBubbleQuoteViewDidTapped:tappedMessage];
}

- (void)yourFileReplyDidTapped:(TAPMessageModel *)tappedMessage {
    
    if (self.otherUser == nil && self.currentRoom.type == RoomTypePersonal) {
        return;
    }
    
    TAPMessageModel *quotedMessageModel = [tappedMessage copy];
    
    //WK Note : Do reply here later.
    [self showInputAccessoryExtensionView:NO];
    [self setInputAccessoryExtensionType:inputAccessoryExtensionTypeQuote];
    [self showInputAccessoryExtensionView:YES];
    
    NSString *fileName = [quotedMessageModel.data objectForKey:@"fileName"];
    fileName = [TAPUtil nullToEmptyString:fileName];
    
    NSString *fileExtension  = [[fileName pathExtension] uppercaseString];
    
    fileName = [fileName stringByDeletingPathExtension];
    
    if ([fileExtension isEqualToString:@""]) {
        fileExtension = [quotedMessageModel.data objectForKey:@"mediaType"];
        fileExtension = [TAPUtil nullToEmptyString:fileExtension];
        fileExtension = [fileExtension lastPathComponent];
        fileExtension = [fileExtension uppercaseString];
    }
    
    NSString *fileSize = [NSByteCountFormatter stringFromByteCount:[[quotedMessageModel.data objectForKey:@"size"] integerValue] countStyle:NSByteCountFormatterCountStyleBinary];
    
    //convert to quote model
    TAPQuoteModel *quote = [TAPQuoteModel constructFromMessageModel:quotedMessageModel];
    [self setQuoteWithQuote:quote userID:quotedMessageModel.user.userID];
    
    quotedMessageModel.quote = quote;
    
    [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessageModel userInfo:nil roomID:self.currentRoom.roomID];
    
    //remove selectedMessage
    self.selectedMessage = nil;
}

- (void)yourFileBubbleLongPressedWithMessage:(TAPMessageModel *)longPressedMessage {
    [self handleLongPressedWithMessage:longPressedMessage];
}

- (void)yourFileDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage {
    [self fetchFileDataWithMessage:tappedMessage];
}

- (void)yourFileRetryDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage {
    [self fetchFileDataWithMessage:tappedMessage];
}

- (void)yourFileCancelButtonDidTapped:(TAPMessageModel *)tappedMessage {
    //Cancel downloading task
    [[TAPFileDownloadManager sharedManager] cancelDownloadWithMessage:tappedMessage];
}

- (void)yourFileOpenFileButtonDidTapped:(TAPMessageModel *)tappedMessage {
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
    
    if (filePath == nil || [filePath isEqualToString:@""]) {
        return;
    }
    
    self.currentSelectedFileURL = [NSURL fileURLWithPath:filePath];
    
    QLPreviewController *preview = [[QLPreviewController alloc] init];
    preview.dataSource = self;
    preview.delegate = self;
    
    [self presentViewController:preview animated:YES completion:nil];
}

- (void)yourFileBubbleDidTappedProfilePictureWithMessage:(TAPMessageModel *)tappedMessage {
    [self openUserProfileFromGroupChatWithMessage:tappedMessage];
}

- (void)yourFileBubbleDidTriggerSwipeToReplyWithMessage:(TAPMessageModel *)message {
    [self processSwipeToReplyWithMessage:message];
}

#pragma mark TAPYourLocationBubbleTableViewCell
- (void)yourLocationBubbleViewDidTapped:(TAPMessageModel *)tappedMessage {
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
                                       [self checkAndShowInputAccessoryView];
                                       [self checkKeyboard];
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

- (void)yourLocationQuoteViewDidTapped:(TAPMessageModel *)tappedMessage {
    [self messageBubbleQuoteViewDidTapped:tappedMessage];
}

- (void)yourLocationReplyDidTapped:(TAPMessageModel *)tappedMessage {
    
    if (self.otherUser == nil && self.currentRoom.type == RoomTypePersonal) {
        return;
    }
    
    NSInteger messageIndex = [self.messageArray indexOfObject:tappedMessage];
    NSIndexPath *selectedMessageIndexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
    
    [self showInputAccessoryExtensionView:NO];
    [self setInputAccessoryExtensionType:inputAccessoryExtensionTypeReplyMessage];
    [self setReplyMessageWithMessage:tappedMessage];
    [self showInputAccessoryExtensionView:YES];
    
    TAPMessageModel *quotedMessageModel = [tappedMessage copy];
    [[TAPChatManager sharedManager] saveToQuotedMessage:tappedMessage userInfo:nil roomID:self.currentRoom.roomID];
    
    //remove selectedMessage
    self.selectedMessage = nil;
    
    TAPYourLocationBubbleTableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedMessageIndexPath];
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
        //animation
        [cell showStatusLabel:YES animated:YES];
        [cell layoutIfNeeded];
        [self.tableView performBatchUpdates:^{
            //changing beginUpdates and endUpdates with this because of deprecation
        } completion:^(BOOL finished) {
        }];
    } completion:^(BOOL finished) {
        //completion
    }];
    
}

- (void)yourLocationBubbleLongPressedWithMessage:(TAPMessageModel *)longPressedMessage {
    [self handleLongPressedWithMessage:longPressedMessage];
}

- (void)yourLocationBubbleDidTappedProfilePictureWithMessage:(TAPMessageModel *)tappedMessage {
    [self openUserProfileFromGroupChatWithMessage:tappedMessage];
}

- (void)yourLocationBubbleDidTriggerSwipeToReplyWithMessage:(TAPMessageModel *)message {
    [self processSwipeToReplyWithMessage:message];
}

#pragma mark TAPYourVideoBubbleTableViewCell
- (void)yourVideoQuoteDidTappedWithMessage:(TAPMessageModel *)message {
    [self messageBubbleQuoteViewDidTapped:message];
}

- (void)yourVideoReplyDidTappedWithMessage:(TAPMessageModel *)message {
    if (self.otherUser == nil && self.currentRoom.type == RoomTypePersonal) {
        return;
    }
    
    TAPMessageModel *quotedMessageModel = [message copy];
    
    //WK Note : Do reply here later.
    [self showInputAccessoryExtensionView:NO];
    [self setInputAccessoryExtensionType:inputAccessoryExtensionTypeQuote];
    [self showInputAccessoryExtensionView:YES];
    
    //convert to quote model
    TAPQuoteModel *quote = [TAPQuoteModel constructFromMessageModel:quotedMessageModel];
    [self setQuoteWithQuote:quote userID:quotedMessageModel.user.userID];
    
    quotedMessageModel.quote = quote;
    
    [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessageModel userInfo:nil roomID:self.currentRoom.roomID];
    
    //remove selectedMessage
    self.selectedMessage = nil;
}

- (void)yourVideoBubbleLongPressedWithMessage:(TAPMessageModel *)longPressedMessage {
    [self handleLongPressedWithMessage:longPressedMessage];
}

- (void)yourVideoLongPressedUrl:(NSURL *)url
                 originalString:(NSString*)originalString {
    [self handleLongPressedWithURL:url originalString:originalString];
}

- (void)yourVideoLongPressedPhoneNumber:(NSString *)phoneNumber
                         originalString:(NSString*)originalString {
    [self handleLongPressedWithPhoneNumber:phoneNumber originalString:originalString];
}

- (void)yourVideoDidTappedUrl:(NSURL *)url
               originalString:(NSString*)originalString {
    [self handleTappedWithURL:url originalString:originalString];
}

- (void)yourVideoDidTappedPhoneNumber:(NSString *)phoneNumber
                       originalString:(NSString*)originalString {
    [self handleTappedWithPhoneNumber:phoneNumber originalString:originalString];
}

- (void)yourVideoPlayDidTappedWithMessage:(TAPMessageModel *)message {
    [self playVideoWithMessage:message];
}

- (void)yourVideoCancelDidTappedWithMessage:(TAPMessageModel *)message {
    NSString *key = [TAPUtil getFileKeyFromMessage:message];
    
    if ([key isEqualToString:@""]) {
        //Video exist, uploading file state
        //Cancel uploading task
        [[TAPFileUploadManager sharedManager] cancelUploadingOperationWithMessage:message];
        
        //Remove message from array and dictionary in ChatViewController
        TAPMessageModel *currentDeletedMessage = [self.messageDictionary objectForKey:message.localID];
        NSInteger deletedIndex = [self.messageArray indexOfObject:currentDeletedMessage];
        [self removeMessageFromArrayAndDictionaryWithLocalID:message.localID];
        
        //Remove from WaitingUploadDictionary in ChatManager
        [[TAPChatManager sharedManager] removeFromWaitingUploadFileMessage:message];
        
        //Remove message from database
        [TAPDataManager deleteDatabaseMessageWithData:@[message] success:^{
            
        } failure:^(NSError *error) {
            
        }];
        
        //Update chat room UI
        NSIndexPath *deleteAtIndexPath = [NSIndexPath indexPathForRow:deletedIndex inSection:0];
        [self.tableView performBatchUpdates:^{
            //changing beginUpdates and endUpdates with this because of deprecation
            [self.tableView deleteRowsAtIndexPaths:@[deleteAtIndexPath] withRowAnimation:UITableViewRowAnimationTop];
        } completion:^(BOOL finished) {
        }];
    }
    else {
        //Video not exist, download file
        //Cancel downloading task
        [[TAPFileDownloadManager sharedManager] cancelDownloadWithMessage:message];
    }
}

- (void)yourVideoRetryDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage {
    [self fetchVideoDataWithMessage:tappedMessage];
}

- (void)yourVideoDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage {
    [self fetchVideoDataWithMessage:tappedMessage];
}

- (void)yourVideoBubbleDidTappedProfilePictureWithMessage:(TAPMessageModel *)tappedMessage {
    [self openUserProfileFromGroupChatWithMessage:tappedMessage];
}

- (void)yourVideoBubbleDidTriggerSwipeToReplyWithMessage:(TAPMessageModel *)message {
    [self processSwipeToReplyWithMessage:message];
}

- (void)yourVideoBubblePressedMentionWithWord:(NSString*)word
                                tappedAtIndex:(NSInteger)index
                                      message:(TAPMessageModel *)message
                          mentionIndexesArray:(NSArray *)mentionIndexesArray {
    NSString *username = @"";
    for (NSInteger counter = 0; counter < [mentionIndexesArray count]; counter++) {
        NSRange userRange = [[mentionIndexesArray objectAtIndex:counter] rangeValue];
        
        NSInteger locationStart = userRange.location;
        NSInteger locationEnd = locationStart + userRange.length - 1; // -1 for omit location start
        
        if (index >= locationStart && index <= locationEnd) {
            username = [word substringWithRange:userRange];
            break;
        }
    }
    
    NSString *prefixToRemove = @"@";
    if ([username hasPrefix:prefixToRemove]) {
        username = [username substringFromIndex:[prefixToRemove length]];
    }
    
    if ([username isEqualToString:[TAPDataManager getActiveUser].username]) {
        //if tap our username, nothing happens
        return;
    }
    
    [self tapTalkUserMentionTappedWithRoom:self.currentRoom message:message usernameString:username];
}

- (void)yourVideoBubbleLongPressedMentionWithWord:(NSString*)word
                                    tappedAtIndex:(NSInteger)index
                                          message:(TAPMessageModel *)message
                              mentionIndexesArray:(NSArray *)mentionIndexesArray {
    NSString *username = @"";
    for (NSInteger counter = 0; counter < [mentionIndexesArray count]; counter++) {
        NSRange userRange = [[mentionIndexesArray objectAtIndex:counter] rangeValue];
        
        NSInteger locationStart = userRange.location;
        NSInteger locationEnd = locationStart + userRange.length - 1; // -1 for omit location start
        
        if (index >= locationStart && index <= locationEnd) {
            username = [word substringWithRange:userRange];
            break;
        }
    }
    
    if ([username isEqualToString:[TAPDataManager getActiveUser].username]) {
        //if tap our username, nothing happens
        return;
    }
    
    [TAPUtil tapticImpactFeedbackGenerator];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:username message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *viewProfileAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"View Profile", nil, [TAPUtil currentBundle], @"")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
        [self yourVideoBubblePressedMentionWithWord:word tappedAtIndex:index message:message mentionIndexesArray:mentionIndexesArray];
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
                                     [self checkAndShowInputAccessoryView];
                                     UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                     [pasteboard setString:username];
                                 }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
                                       [self checkAndShowInputAccessoryView];
                                       [self checkKeyboard];
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
    
    if (self.secondaryTextField.isFirstResponder || self.messageTextView.isFirstResponder) {
        self.isKeyboardWasShowed = YES;
    }
    else {
        self.isKeyboardWasShowed = NO;
    }
    
    [UIView animateWithDuration:0.2f animations:^{
        [self.messageTextView resignFirstResponder];
        [self.secondaryTextField resignFirstResponder];
        [self keyboardWillHideWithHeight:0.0f];
    } completion:^(BOOL finished) {
        [self presentViewController:alertController animated:YES completion:^{
            //after animation
        }];
    }];
}

#pragma mark TAPProductListBubbleTableViewCell
- (void)productListBubbleDidTappedLeftOrSingleOptionWithData:(NSDictionary *)productDictionary isSingleOptionView:(BOOL)isSingleOption {
   
    TAPUserModel *currentUser = [TAPDataManager getActiveUser];
    NSString *otherUserID = [[TAPChatManager sharedManager] getOtherUserIDWithRoomID:[TAPChatManager sharedManager].activeRoom.roomID];
    TAPUserModel *otherUser = [[TAPContactManager sharedManager] getUserWithUserID:otherUserID];

    TAPProductModel *product = [TAPDataManager productModelFromDictionary:productDictionary];
    TAPRoomModel *room = [TAPChatManager sharedManager].activeRoom;

    id<TapUIChatRoomDelegate> tapUIChatRoomDelegate = [TapUI sharedInstance].chatRoomDelegate;
    if ([tapUIChatRoomDelegate respondsToSelector:@selector(tapTalkProductListBubbleLeftOrSingleButtonTapped:room:recipient:isSingleOption:)]) {
        [tapUIChatRoomDelegate tapTalkProductListBubbleLeftOrSingleButtonTapped:product room:room recipient:otherUser isSingleOption:isSingleOption];
    }
}

- (void)productListBubbleDidTappedRightOptionWithData:(NSDictionary *)productDictionary isSingleOptionView:(BOOL)isSingleOption {
    TAPUserModel *currentUser = [TAPDataManager getActiveUser];
    NSString *otherUserID = [[TAPChatManager sharedManager] getOtherUserIDWithRoomID:[TAPChatManager sharedManager].activeRoom.roomID];
    TAPUserModel *otherUser = [[TAPContactManager sharedManager] getUserWithUserID:otherUserID];
    
    TAPProductModel *product = [TAPDataManager productModelFromDictionary:productDictionary];
    TAPRoomModel *room = [TAPChatManager sharedManager].activeRoom;
    
    id<TapUIChatRoomDelegate> tapUIChatRoomDelegate = [TapUI sharedInstance].chatRoomDelegate;
    if ([tapUIChatRoomDelegate respondsToSelector:@selector(tapTalkProductListBubbleRightButtonTapped:room:recipient:isSingleOption:)]) {
        [tapUIChatRoomDelegate tapTalkProductListBubbleRightButtonTapped:product room:room recipient:otherUser isSingleOption:isSingleOption];
    }
}

#pragma mark TAPGrowingTextView
- (void)growingTextViewShouldChangeTextInRange:(NSRange)range
                               replacementText:(NSString *)text
                                       newText:(NSString *)newText {
    
    if (self.currentRoom.type == RoomTypePersonal) {
        return;
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

    BOOL isSubstractArray = NO;
    if (self.lastNumberOfWordArrayForShowMention > [wordArray count]) {
        isSubstractArray = YES;
    }
    
    _lastNumberOfWordArrayForShowMention = [wordArray count];
    
    if ([text isEqualToString:@" "] || [text isEqualToString:@"\n"] || ([text isEqualToString:@""] && isSubstractArray)) {
        [self.filteredMentionListArray removeAllObjects];
        [self showMentionListView:NO animated:YES];
        [self.mentionListTableView reloadData];
        return;
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
    [self checkAndSearchUserMentionList:newText isErasing:isErasing];
}

- (void)growingTextView:(TAPGrowingTextView *)textView shouldChangeHeight:(CGFloat)height {
    [UIView animateWithDuration:0.2f animations:^{
        self.messageTextViewHeight = height;
        self.messageTextViewHeightConstraint.constant = height;
        self.messageViewHeightConstraint.constant = self.messageTextViewHeight + 16.0f + 4.0f;
        [self.messageTextView layoutIfNeeded];
        [self.inputMessageAccessoryView layoutIfNeeded];
        [self.view layoutIfNeeded];
    }];
#ifdef DEBUG
    NSLog(@">>>> growingTextViewShouldChangeHeight messageTextViewHeight: %f", height);
    NSLog(@">>>> growingTextViewShouldChangeHeight messageViewHeightConstraint: %f", self.messageViewHeightConstraint.constant);
#endif
}

- (void)growingTextViewDidBeginEditing:(TAPGrowingTextView *)textView {
    
    [self setKeyboardStateDefault];
    
    if (textView.text != nil) {
        if (![textView.text isEqualToString:@""]) {
            if(self.isCustomKeyboardAvailable) {
                [UIView animateWithDuration:0.2f animations:^{
                    self.keyboardOptionButtonView.alpha = 0.0f;
                    self.keyboardOptionButton.alpha = 0.0f;
                    self.keyboardOptionButton.userInteractionEnabled = NO;
                    self.messageViewLeftConstraint.constant = -38.0f;
                    self.keyboardOptionViewRightConstraint.constant = -26.0f;
                    [self.messageTextView layoutIfNeeded];
                    [self.inputMessageAccessoryView layoutIfNeeded];
                    [self.view layoutIfNeeded];
                }];
            }
        }
    }
}

- (void)growingTextViewDidStartTyping:(TAPGrowingTextView *)textView {
    [self setSendButtonActive:YES];
    if (self.isCustomKeyboardAvailable) {
        [UIView animateWithDuration:0.2f animations:^{
            self.keyboardOptionButtonView.alpha = 0.0f;
            self.keyboardOptionButton.alpha = 0.0f;
            self.keyboardOptionButton.userInteractionEnabled = NO;
            self.messageViewLeftConstraint.constant = -38.0f;
            self.keyboardOptionViewRightConstraint.constant = -26.0f;
            [self.messageTextView layoutIfNeeded];
            [self.inputMessageAccessoryView layoutIfNeeded];
        }];
    }
    [[TAPChatManager sharedManager] startTyping];
}

- (void)growingTextViewDidStopTyping:(TAPGrowingTextView *)textView {
    [self setSendButtonActive:NO];
    if (self.isCustomKeyboardAvailable) {
        [UIView animateWithDuration:0.2f animations:^{
            self.keyboardOptionButtonView.alpha = 1.0f;
            self.keyboardOptionButton.alpha = 1.0f;
            self.keyboardOptionButton.userInteractionEnabled = YES;
            self.messageViewLeftConstraint.constant = 4.0f;
            self.keyboardOptionViewRightConstraint.constant = 16.0f;
            [self.messageTextView layoutIfNeeded];
            [self.inputMessageAccessoryView layoutIfNeeded];
            [self.view layoutIfNeeded];
        }];
    }
    [[TAPChatManager sharedManager] stopTyping];
}

#pragma mark TAPConnectionStatusViewController
- (void)connectionStatusViewControllerDelegateHeightChange:(CGFloat)height {
//DV Note - v1.0.18
//28 Nov 2019 - Temporary comment to hide connecting, waiting for network, connected state for further changing UI flow
//    self.connectionStatusHeight = height;
//
//    CGFloat currentHeight = height;
//    if (self.connectionStatusHeight == 0.0f && self.loadMoreMessageViewHeight== 0.0f) {
//        currentHeight = 0.0f;
//    }
//    else if (self.connectionStatusHeight > 0.0f) {
//        currentHeight = self.connectionStatusHeight;
//    }
//    else if (self.loadMoreMessageViewHeight > 0.0f) {
//        currentHeight = self.loadMoreMessageViewHeight;
//    }
//
//    [UIView animateWithDuration:0.2f animations:^{
//        //change frame
//        self.tableViewTopConstraint.constant = currentHeight - 50.0f;
//        [self.view layoutIfNeeded];
//    }];
//END DV Note
}

#pragma mark TAPImagePreviewViewController
- (void)imagePreviewDidTapSendButtonWithData:(NSArray *)dataArray {
    
    //hide empty chat
    [UIView animateWithDuration:0.2f animations:^{
        if (self.emptyView.alpha != 0.0f) {
            self.emptyView.alpha = 0.0f;
        }
    }];
    
    for (TAPMediaPreviewModel *mediaPreview in dataArray) {
        PHAsset *asset = mediaPreview.asset;
        NSString *caption = mediaPreview.caption;
        caption = [TAPUtil nullToEmptyString:caption];
        
        if (asset == nil) {
            //Send image using UIImage
            UIImage *image = mediaPreview.image;
            [[TAPChatManager sharedManager] sendImageMessage:image caption:caption];
        }
        else {
            //Send using PHAsset
            UIImage *thumbnailImage = mediaPreview.thumbnailImage;
            NSData *thumbnailImageData = UIImageJPEGRepresentation(thumbnailImage, 1.0f);
            
            if (asset.mediaType == PHAssetMediaTypeImage) {
                [[TAPChatManager sharedManager] sendImageMessageWithPHAsset:asset caption:caption];
            }
            else if (asset.mediaType == PHAssetMediaTypeVideo) {
                [[TAPChatManager sharedManager] sendVideoMessageWithPHAsset:asset caption:caption thumbnailImageData:thumbnailImageData];
            }
        }
    }
    
    [TAPUtil performBlock:^{
        if ([self.messageArray count] != 0) {
            [self chatAnchorButtonDidTapped:[[UIButton alloc] init]]; //Scroll table view to top with pending message logic
        }
    } afterDelay:0.2f];
    
    //check if keyboard was showed
    //CS NOTE- need to add delay to prevent wrong inset because keyboardwillshow did not called if the method called directly
    [self performSelector:@selector(checkKeyboard) withObject:nil afterDelay:0.05f];
}

- (void)imagePreviewCancelButtonDidTapped {
    [self checkAndShowInputAccessoryView];
    [self checkKeyboard];
}

- (void)imagePreviewDidSendDataAndCompleteDismissView {
    [self checkAndShowInputAccessoryView];
    [self checkKeyboard];
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
    
    //hide empty chat
    [UIView animateWithDuration:0.2f animations:^{
        if (self.emptyView.alpha != 0.0f) {
            self.emptyView.alpha = 0.0f;
        }
    }];
    
    for (TAPMediaPreviewModel *mediaPreview in dataArray) {
        PHAsset *asset = mediaPreview.asset;
        
        UIImage *thumbnailImage = mediaPreview.thumbnailImage;
        NSData *thumbnailImageData = UIImageJPEGRepresentation(thumbnailImage, 1.0f);
        
        NSString *caption = mediaPreview.caption;
        caption = [TAPUtil nullToEmptyString:caption];
        
        if (asset.mediaType == PHAssetMediaTypeImage) {
            [[TAPChatManager sharedManager] sendImageMessageWithPHAsset:asset caption:caption];
        }
        else if (asset.mediaType == PHAssetMediaTypeVideo) {
            [[TAPChatManager sharedManager] sendVideoMessageWithPHAsset:asset caption:caption thumbnailImageData:thumbnailImageData];
        }
    }
    
    [TAPUtil performBlock:^{
        if ([self.messageArray count] != 0) {
            [self chatAnchorButtonDidTapped:[[UIButton alloc] init]]; //Scroll table view to top with pending message logic
        }
    } afterDelay:0.2f];
    
    //check if keyboard was showed
    //CS NOTE- need to add delay to prevent wrong inset because keyboardwillshow did not called if the method called directly
    [self performSelector:@selector(checkKeyboard) withObject:nil afterDelay:0.05f];
}

#pragma mark TAPMediaDetailViewController
- (void)mediaDetailViewControllerWillStartClosingAnimation {
    //need to reload inputView after presenting another vc on top
    [self checkAndShowInputAccessoryView];
}

- (void)mediaDetailViewControllerDidFinishClosingAnimation {
    if ([self.openedBubbleCell isKindOfClass:[TAPMyImageBubbleTableViewCell class]]) {
        TAPMyImageBubbleTableViewCell *cell = (TAPMyImageBubbleTableViewCell *)self.openedBubbleCell;
        cell.bubbleImageView.alpha = 1.0f;
    }
    else if ([self.openedBubbleCell isKindOfClass:[TAPYourImageBubbleTableViewCell class]]) {
        TAPYourImageBubbleTableViewCell *cell = (TAPYourImageBubbleTableViewCell *)self.openedBubbleCell;
        cell.bubbleImageView.alpha = 1.0f;
    }
}

#pragma mark TAPPickLocationViewController
- (void)pickLocationViewControllerSetLocationWithLatitude:(CGFloat)latitude
                                                longitude:(CGFloat)longitude
                                                  address:(NSString *)address
                                               postalCode:(NSString *)postalCode {
    [[TAPChatManager sharedManager] sendLocationMessage:latitude longitude:longitude address:address];
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
    
    [TAPUtil performBlock:^{
        if ([self.messageArray count] != 0) {
            [self chatAnchorButtonDidTapped:[[UIButton alloc] init]]; //Scroll table view to top with pending message logic
        }
    } afterDelay:0.2f];
}

#pragma mark QLPreviewController
- (BOOL)previewController:(QLPreviewController *)controller shouldOpenURL:(NSURL *)url forPreviewItem:(id <QLPreviewItem>)item {
    return YES;
}

- (void)previewControllerDidDismiss:(QLPreviewController *)controller {
    [self.inputAccessoryView becomeFirstResponder];
}

#pragma mark TAPProfileViewController
- (void)profileViewControllerDidTriggerLeaveOrDeleteGroupWithRoom:(TAPRoomModel *)room {
    if ([self.delegate respondsToSelector:@selector(chatViewControllerDidLeaveOrDeleteGroupWithRoom:)]) {
        [self.delegate chatViewControllerDidLeaveOrDeleteGroupWithRoom:room];
    }
}

#pragma mark - Custom Method
#pragma mark ViewDidLoad Method
- (void)setupNavigationViewData {
    //This method is used to setup the title view of navigation bar, and also bar button view
    
    TAPRoomModel *room = [TAPChatManager sharedManager].activeRoom;
    
    //Title View
    _titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - 56.0f - 56.0f, 43.0f)];
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 2.0f, CGRectGetWidth(self.titleView.frame), 22.0f)];
    
    UIFont *chatRoomNameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontChatRoomNameLabel];
    UIColor *chatRoomNameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorChatRoomNameLabel];
    self.nameLabel.text = room.name;
    self.nameLabel.textColor = chatRoomNameLabelColor;
    self.nameLabel.font = chatRoomNameLabelFont;
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.titleView addSubview:self.nameLabel];
    
    _userStatusView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, (16.0f - 7.0f) / 2.0f + 1.6f, 7.0f, 7.0f)];
    self.userStatusView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconUserStatusActive];
    self.userStatusView.layer.cornerRadius = CGRectGetHeight(self.userStatusView.frame) / 2.0f;
    self.userStatusView.alpha = 0.0f;
    self.userStatusView.clipsToBounds = YES;
    
    UIFont *chatRoomStatusLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontChatRoomStatusLabel];
    UIColor *chatRoomStatusLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorChatRoomStatusLabel];
    _userStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.userStatusView.frame) + 4.0f, 0.0f, 0.0f, 16.0f)];
    self.userStatusLabel.textColor = chatRoomStatusLabelColor;
    self.userStatusLabel.font = chatRoomStatusLabelFont;
    self.userStatusLabel.textAlignment = NSTextAlignmentCenter;
    [self.userStatusLabel sizeToFit];
    self.userStatusLabel.frame = CGRectMake(CGRectGetMinX(self.userStatusLabel.frame), CGRectGetMinY(self.userStatusLabel.frame), CGRectGetWidth(self.userStatusLabel.frame), 16.0f);
    
    CGFloat userStatusViewWidth = CGRectGetWidth(self.userStatusLabel.frame) + CGRectGetWidth(self.userStatusView.frame) + 4.0f;
    _userDescriptionView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.nameLabel.frame), userStatusViewWidth, 16.0f)];
    self.userDescriptionView.center = CGPointMake(self.nameLabel.center.x, self.userDescriptionView.center.y);
    [self.userDescriptionView addSubview:self.userStatusView];
    [self.userDescriptionView addSubview:self.userStatusLabel];
    
    if (room.type != RoomTypeTransaction) {
        [self.titleView addSubview:self.userDescriptionView];
    }
    
    [self.navigationItem setTitleView:self.titleView];
    
    _userTypingView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.nameLabel.frame), 100.0f, 16.0f)];
    self.userTypingView.backgroundColor = [UIColor clearColor];
    [self.titleView addSubview:self.userTypingView];
    
    UIImageView *typingAnimationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 16.0f, 16.0f)];
    typingAnimationImageView.animationImages = @[[UIImage imageNamed:@"TAPTypingSequence-1" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil], [UIImage imageNamed:@"TAPTypingSequence-2" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil], [UIImage imageNamed:@"TAPTypingSequence-3" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil], [UIImage imageNamed:@"TAPTypingSequence-4" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil], [UIImage imageNamed:@"TAPTypingSequence-5" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil], [UIImage imageNamed:@"TAPTypingSequence-6" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil], [UIImage imageNamed:@"TAPTypingSequence-7" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil], [UIImage imageNamed:@"TAPTypingSequence-8" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil], [UIImage imageNamed:@"TAPTypingSequence-9" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil], [UIImage imageNamed:@"TAPTypingSequence-10" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil], [UIImage imageNamed:@"TAPTypingSequence-11" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil], [UIImage imageNamed:@"TAPTypingSequence-12" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil], [UIImage imageNamed:@"TAPTypingSequence-13" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil], [UIImage imageNamed:@"TAPTypingSequence-14" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil], [UIImage imageNamed:@"TAPTypingSequence-15" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil], [UIImage imageNamed:@"TAPTypingSequence-16" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil]];
    typingAnimationImageView.animationDuration = 0.6f;
    typingAnimationImageView.animationRepeatCount = 0.0f;
    [typingAnimationImageView startAnimating];
    [self.userTypingView addSubview:typingAnimationImageView];
    
    _typingLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(typingAnimationImageView.frame) + 4.0f, 0.0f, 100.0f, 16.0f)];
    self.typingLabel.font = chatRoomStatusLabelFont;
    self.typingLabel.textColor = chatRoomStatusLabelColor;
    self.typingLabel.text = NSLocalizedStringFromTableInBundle(@"typing", nil, [TAPUtil currentBundle], @"");
    [self.typingLabel sizeToFit];
    self.typingLabel.frame = CGRectMake(CGRectGetMaxX(typingAnimationImageView.frame) + 4.0f, 0.0f, CGRectGetWidth(self.typingLabel.frame), 16.0f);
    [self.userTypingView addSubview:self.typingLabel];
    
    self.userTypingView.frame = CGRectMake(CGRectGetMinX(self.userTypingView.frame), CGRectGetMinY(self.userTypingView.frame), CGRectGetMaxX(self.typingLabel.frame), CGRectGetHeight(self.userTypingView.frame));
    self.userTypingView.center = CGPointMake(self.nameLabel.center.x, self.userTypingView.center.y);
    
    [self setAsTyping:NO];
    [self isShowOnlineDotStatus:NO];
    
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
        
        NSString *profileImageURL = room.imageURL.thumbnail;
        if (profileImageURL == nil || [profileImageURL isEqualToString:@""]) {
            BOOL isGroup = NO;
            if (self.currentRoom.type == RoomTypeGroup || self.currentRoom.type == RoomTypeTransaction) {
                isGroup = YES;
            }
            
            self.rightBarInitialNameView.alpha = 1.0f;
            self.rightBarImageView.alpha = 0.0f;
            self.rightBarInitialNameView.backgroundColor = [[TAPStyleManager sharedManager] getRandomDefaultAvatarBackgroundColorWithName:room.name];
            self.rightBarInitialNameLabel.text = [[TAPStyleManager sharedManager] getInitialsWithName:room.name isGroup:isGroup];
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
    
    //Left Bar Button
    UIImage *buttonImage = [UIImage imageNamed:@"TAPIconBackArrow" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    buttonImage = [buttonImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconNavigationBarBackButton]];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
    
    self.quoteFileView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconQuotedFileBackground];
    
    self.deletedRoomIconImageView.image = [self.deletedRoomIconImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconDeletedChatRoom]];
    
    self.chatAnchorBackgroundView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChatRoomScrollToBottomBackground];
    
    if (IS_BELOW_IOS_13) {
        self.chatAnchorImageView.image = [UIImage imageNamed:@"TAPIconChatAnchor" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    }
    else {
        self.chatAnchorImageView.image = [UIImage imageNamed:@"TAPIconChatAnchor" inBundle:[TAPUtil currentBundle] withConfiguration:nil];
    }

    self.chatAnchorImageView.image = [self.chatAnchorImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChatRoomScrollToBottom]];

    self.mentionAnchorBackgroundView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChatRoomScrollToBottomBackground];
    
    if (IS_BELOW_IOS_13) {
        self.mentionAnchorImageView.image = [UIImage imageNamed:@"TAPIconMentionAnchor" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    }
    else {
        self.mentionAnchorImageView.image = [UIImage imageNamed:@"TAPIconMentionAnchor" inBundle:[TAPUtil currentBundle] withConfiguration:nil];
    }
    
    self.mentionAnchorImageView.image = [self.mentionAnchorImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChatRoomScrollToBottom]];
    
    self.topFloatingIndicatorImageView.image = [self.topFloatingIndicatorImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChatRoomUnreadButton]];
    
    self.attachmentButton.imageView.image = [self.attachmentButton.imageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChatComposerAttach]];

}

- (void)checkIsContainQuoteMessage {
    id quotedMessage = [[TAPChatManager sharedManager] getQuotedMessageObjectWithRoomID:self.currentRoom.roomID];
    if (quotedMessage) {
        [self showInputAccessoryExtensionView:YES];
        if ([quotedMessage isKindOfClass:[TAPMessageModel class]]) {
            _isInputAccessoryExtensionShowedFirstTimeOpen = YES;
            TAPMessageModel *quoteMessageModel = (TAPMessageModel *)quotedMessage;
            
            //if reply exists check if image in quote exists
            //if image exists change view to Quote View
            if((quoteMessageModel.quote.fileID && ![quoteMessageModel.quote.fileID isEqualToString:@""]) || (quoteMessageModel.quote.imageURL && ![quoteMessageModel.quote.imageURL isEqualToString:@""])) {
                [self setInputAccessoryExtensionType:inputAccessoryExtensionTypeQuote];
                [self setQuoteWithQuote:quoteMessageModel.quote userID:quoteMessageModel.user.userID];
            }
            else {
                [self setInputAccessoryExtensionType:inputAccessoryExtensionTypeReplyMessage];
                [self setReplyMessageWithMessage:quoteMessageModel];
                
                //Set send button to active when forward model is available
                TAPChatManagerQuoteActionType quoteActionType =  [[TAPChatManager sharedManager] getQuoteActionTypeWithRoomID:self.currentRoom.roomID];
                if (quoteActionType == TAPChatManagerQuoteActionTypeForward) {
                    [self setSendButtonActive:YES];
                }
            }
        }
        else if ([quotedMessage isKindOfClass:[TAPQuoteModel class]]) {
            TAPQuoteModel *quoteModel = (TAPQuoteModel *)quotedMessage;
            [self setInputAccessoryExtensionType:inputAccessoryExtensionTypeQuote];
            [self setQuoteWithQuote:quoteModel userID:@""];
        }
    }
    else {
        [self showInputAccessoryExtensionView:NO];
        [self setSendButtonActive:NO];
    }
}

- (void)setupInputAccessoryView {
    //Input Accessory Extension View
    
    //Setup font for composer textview label same as bubble chat body label size
    UIFont *bubbleLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontRightBubbleMessageBody];
    self.messageTextView.textView.font = bubbleLabelFont;
    self.messageTextView.placeholderLabel.font = bubbleLabelFont;

    self.keyboardOptionButtonView.layer.cornerRadius = CGRectGetHeight(self.keyboardOptionButtonView.frame) / 2.0f;
    self.keyboardOptionButtonView.clipsToBounds = YES;
    
    self.sendButtonView.layer.cornerRadius = CGRectGetHeight(self.sendButtonView.frame) / 2.0f;
    self.sendButtonView.clipsToBounds = YES;
    
    self.inputMessageAccessoryView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    UIImage *closeImage = [UIImage imageNamed:@"TAPIconClose" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    closeImage = [closeImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChatRoomCancelQuote]];
    self.inputMessageAccessoryCloseImageView.image = closeImage;
        
    self.replyMessageInnerContainerView.layer.cornerRadius = 4.0f;
    self.quoteImageView.layer.cornerRadius = 4.0f;
    self.quoteImageView.clipsToBounds = YES;
    self.quoteFileView.layer.cornerRadius = CGRectGetHeight(self.quoteImageView.frame)/2.0f;
    
    [self checkIsContainQuoteMessage];
}

- (void)setupDeletedRoomView {
    //Setup Deleted Room View

    self.deleteRoomButtonView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonDestructiveBackground];
    self.deleteRoomButtonView.layer.cornerRadius = 8.0f;
    self.deletedRoomView.clipsToBounds = YES;
    
    UIFont *buttonFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontButtonLabel];
    UIColor *buttonColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorButtonLabel];
    self.deleteRoomButtonLabel.text = NSLocalizedStringFromTableInBundle(@"Delete Chat", nil, [TAPUtil currentBundle], @"");
    self.deleteRoomButtonLabel.textAlignment = NSTextAlignmentCenter;
    self.deleteRoomButtonLabel.font = buttonFont;
    self.deleteRoomButtonLabel.textColor = buttonColor;

    self.deleteRoomButtonIconImageView.image = [UIImage imageNamed:@"TAPIconTrash" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    self.deleteRoomButtonIconImageView.image = [self.deleteRoomButtonIconImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonIcon]];
    
    self.deleteRoomButtonLoadingImageView.image = [UIImage imageNamed:@"TAPIconLoadingSmall" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    self.deleteRoomButtonLoadingImageView.image = [self.deleteRoomButtonLoadingImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonIcon]];
    
    UIFont *deletedChatRoomTitleLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontDeletedChatRoomInfoTitleLabel];
    UIColor *deletedChatRoomTitleLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorDeletedChatRoomInfoTitleLabel];
    UIFont *deletedChatRoomContentLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontDeletedChatRoomInfoContentLabel];
    UIColor *deletedChatRoomContentLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorDeletedChatRoomInfoContentLabel];
    //    UIColor *deletedChatRoomIconColor = [[TAPStyleManager sharedManager] getComponentColorForType:]; //DV ICON
    
    self.deletedRoomView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDeletedChatRoomInfoBackground];
    self.deletedRoomTitleLabel.textColor = deletedChatRoomTitleLabelColor;
    self.deletedRoomTitleLabel.font = deletedChatRoomTitleLabelFont;
    self.deletedRoomContentLabel.textColor = deletedChatRoomContentLabelColor;
    self.deletedRoomContentLabel.font = deletedChatRoomContentLabelFont;
    //    [self.deletedRoomIconImageView setImageTintColor:@"deletedChatRoomIconColor"]; //DV ICON
    
    self.deletedRoomViewHeightConstraint.constant = [TAPUtil safeAreaBottomPadding] + kInputMessageAccessoryViewHeight;
}

- (void)showDeletedRoomView:(BOOL)show isGroup:(BOOL)isGroup isGroupDeleted:(BOOL)isGroupDeleted {
    
    [self.messageTextView resignFirstResponder];
    [self.secondaryTextField resignFirstResponder];
    [self keyboardWillHideWithHeight:0.0f];
    
    if (isGroup) {
        if (isGroupDeleted) {
            self.deletedRoomContentLabel.text = NSLocalizedStringFromTableInBundle(@"Sorry, this group is unavailable", nil, [TAPUtil currentBundle], @"");
        }
        else {
            self.deletedRoomContentLabel.text = NSLocalizedStringFromTableInBundle(@"You are no longer a participant in this group", nil, [TAPUtil currentBundle], @"");
        }
    }
    else {
        self.deletedRoomContentLabel.text = NSLocalizedStringFromTableInBundle(@"This user is no longer available", nil, [TAPUtil currentBundle], @"");
    }
    
    //Delete button used to delete room
    if (show) {
        
        _isShowAccessoryView = NO;
        [self reloadInputViews];
        
//        if (withDeleteButton) {
//            //74 is button height and padding
//            self.deletedRoomViewHeightConstraint.constant = [TAPUtil safeAreaBottomPadding] + kInputMessageAccessoryViewHeight + 74.0f;
//            self.tableViewBottomConstraint.constant = kInputMessageAccessoryViewHeight + 74.0f;
//        }
//        else {
//            self.deletedRoomViewHeightConstraint.constant = [TAPUtil safeAreaBottomPadding] + kInputMessageAccessoryViewHeight;
//            self.tableViewBottomConstraint.constant = kInputMessageAccessoryViewHeight;
//        }
        
        //74 is button height and padding
        self.deletedRoomViewHeightConstraint.constant = [TAPUtil safeAreaBottomPadding] + kInputMessageAccessoryViewHeight + 74.0f;
        self.tableViewBottomConstraint.constant = kInputMessageAccessoryViewHeight + 74.0f;
        self.mentionListTableViewBottomConstraint.constant = kInputMessageAccessoryViewHeight + 74.0f;
        
        self.deletedRoomView.alpha = 1.0f;
    }
    else {
        self.tableViewBottomConstraint.constant = kInputMessageAccessoryViewHeight;
        self.mentionListTableViewBottomConstraint.constant = kInputMessageAccessoryViewHeight;
        
        self.deletedRoomView.alpha = 0.0f;
        [self showInputAccessoryView];
    }
}

- (void)setupKickedGroupView {
    //Setup Kicked Group View
    self.kickedGroupRoomBackgroundView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
    
    self.kickedGroupRoomInfoView.layer.cornerRadius = 8.0f;
    self.kickedGroupRoomInfoView.clipsToBounds = YES;
    self.kickedGroupRoomInfoView.backgroundColor = [[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorSystemMessageBackground] colorWithAlphaComponent:0.82f];
    self.kickedGroupRoomInfoView.layer.shadowColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorSystemMessageBackgroundShadow].CGColor;
    self.kickedGroupRoomInfoView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    self.kickedGroupRoomInfoView.layer.shadowOpacity = 0.4f;
    self.kickedGroupRoomInfoView.layer.shadowRadius = 4.0f;
    
    UIFont *systemMessageFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontSystemMessageBody];
    UIColor *systemMessageColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorSystemMessageBody];
    self.kickedGroupRoomInfoLabel.textColor = systemMessageColor;
    self.kickedGroupRoomInfoLabel.font = systemMessageFont;
}

- (void)checkAndSetupAddToContactsView {
    if (![[TapUI sharedInstance] isAddContactEnabled] || ![[TapUI sharedInstance] getAddToContactsButtonInChatRoomVisibleState]) {
        return;
    }
    //Setup Add to Contacts View
    UIFont *clickableLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontClickableLabel];
    UIColor *clickableLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorClickableLabel];
    UIFont *destructiveClickableLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontClickableDestructiveLabel];
    UIColor *destructiveClickableLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorClickableDestructiveLabel];
    
    self.blockContactLabel.font = destructiveClickableLabelFont;
    self.blockContactLabel.textColor = destructiveClickableLabelColor;
    self.addContactLabel.font = clickableLabelFont;
    self.addContactLabel.textColor = clickableLabelColor;
    self.closeButtonImageView.image = [self.closeButtonImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonIconPrimary]];
    
    CGFloat halfViewWidth = (CGRectGetWidth([UIScreen mainScreen].bounds) - 60.0f) / 2.0f;
    //DV Note - 13 Nov 2019 - Temporary set block contact option width to 0 because not ready
    //DV TODO - add block contact here
//    self.2.constant = halfViewWidth;
//    self.addToContactsViewWidthConstraint = halfViewWidth;
    self.blockUserViewWidthConstraint.constant = 0.0f;
    self.addToContactsViewWidthConstraint.constant = halfViewWidth * 2;
    //END DV Note
    self.addToContactsViewHeightConstraint.constant = 0.0f;
    
    if (self.currentRoom.type != RoomTypeGroup) {
        BOOL obtainedState;
        NSDictionary *obtainedStateDictionary = [[NSUserDefaults standardUserDefaults] secureDictionaryForKey:TAP_PREFS_USER_IGNORE_ADD_CONTACT_POPUP_DICTIONARY valid:nil];
        if (obtainedStateDictionary != nil && [obtainedStateDictionary count] != 0) {
            NSNumber *obtainedStateNumber = [obtainedStateDictionary objectForKey:self.currentRoom.roomID];
            obtainedState = [obtainedStateNumber boolValue];
        }
        
        if (obtainedState || self.isOtherUserIsContact) {
            return;
        }
        else {
            self.addToContactsViewHeightConstraint.constant = 48.0f;
            //DV Note - 13 Nov 2019 - Temporary set constant to 60.0f to make it center, set to 0.0f when block contact is implemented
            self.addToContactsViewLeftConstraint.constant = 60.0f;
            //END DV Note
            [UIView animateWithDuration:0.2f animations:^{
                self.addToContactContainerView.alpha = 1.0f;
            }];
        }
    }
    
}

- (void)setSendButtonActive:(BOOL)isActive {
    if (isActive) {
        self.sendButtonView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChatComposerSendBackground];
        self.sendButtonImageView.image = [self.sendButtonImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChatComposerSend]];
        self.sendButton.userInteractionEnabled = YES;
    }
    else {
        self.sendButtonView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChatComposerSendBackgroundInactive];
        self.sendButtonImageView.image = [self.sendButtonImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChatComposerSendInactive]];
        self.sendButton.userInteractionEnabled = NO;
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
}

- (void)fileUploadManagerStartNotification:(NSNotification *)notification {
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
      }
    else if (type == TAPChatMessageTypeFile) {
        TAPMyFileBubbleTableViewCell *cell = (TAPMyFileBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];

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
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
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
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
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
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
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
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
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
        else if (type == TAPChatMessageTypeVideo) {
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
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
        
        TAPChatMessageType type = currentMessage.type;
        if (type == TAPChatMessageTypeImage) {
            
            UIImage *fullImage = [notificationParameterDictionary objectForKey:@"fullImage"];
            
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                //My Chat
                TAPMyImageBubbleTableViewCell *cell = (TAPMyImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                if (fullImage != nil && [fullImage class] == [UIImage class]) {
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
                if (fullImage != nil && [fullImage class] == [UIImage class]) {
                    [cell setFullImage:fullImage];
                }
                [cell animateFinishedDownloadingImage];
            }
        }
        else if (type == TAPChatMessageTypeFile) {
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
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
            if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
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

#pragma mark Profile Notification
- (void)userProfileDidChangeNotification:(NSNotification *)notification {
    NSDictionary *notificationParameterDictionary = (NSDictionary *)[notification object];
    TAPUserModel *obtainedUser = [notificationParameterDictionary objectForKey:@"user"];
    TAPRoomModel *obtainedRoom = [notificationParameterDictionary objectForKey:@"room"];
    
    TAPMessageModel *currentMessage = [self.messageArray objectAtIndex:0];
    currentMessage.room = obtainedRoom;
    
    TAPUserModel *currentUser = [TAPDataManager getActiveUser];
    if (![currentUser.userID isEqualToString:obtainedUser.userID]) {
        //update user data in message
        currentMessage.user = obtainedUser;
    }
    
    //upsert to message database
    [TAPDataManager updateOrInsertDatabaseMessageWithData:@[currentMessage] success:^{
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark App Lifecycle Notification
- (void)applicationDidBecomeActiveNotification:(NSNotification *)notification {
    [self checkAndRefreshOnlineStatus];
}

#pragma mark Attachment
- (IBAction)attachmentButtonDidTapped:(id)sender {
    
    //Hide unread message indicator top view
    if (self.topFloatingIndicatorViewType == TopFloatingIndicatorViewTypeUnreadMessage && self.topFloatingIndicatorView.alpha == 1.0f) {
        [TAPUtil performBlock:^{
            [self showTopFloatingIdentifierView:NO withType:TopFloatingIndicatorViewTypeUnreadMessage numberOfUnreadMessages:0 animated:YES];
        } afterDelay:1.0f];
    }
    
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
                                       [self checkAndShowInputAccessoryView];
                                       [self checkKeyboard];
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
    
    if ([[TapTalk sharedInstance] obtainGooglePlacesAPIInitializeState] &&
        [[TapUI sharedInstance] isLocationAttachmentEnabled]
    ) {
        //Only show when Google Places API Key is insert
        [alertController addAction:locationAction];
    }

    [alertController addAction:cancelAction];
    
    if (self.secondaryTextField.isFirstResponder || self.messageTextView.isFirstResponder) {
        self.isKeyboardWasShowed = YES;
    }
    else {
        self.isKeyboardWasShowed = NO;
    }
    
    [UIView animateWithDuration:0.2f animations:^{
        [self.messageTextView resignFirstResponder];
        [self.secondaryTextField resignFirstResponder];
        [self keyboardWillHideWithHeight:0.0f];
    } completion:^(BOOL finished) {
        [self presentViewController:alertController animated:YES completion:^{
            //after animation
        }];
    }];
}

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

- (void)fetchImageDataWithMessage:(TAPMessageModel *)message {
    [[TAPFileDownloadManager sharedManager] receiveImageDataWithMessage:message start:^(TAPMessageModel * _Nonnull receivedMessage) {
        //Already Handled via Notification
    } progress:^(CGFloat progress, CGFloat total, TAPMessageModel * _Nonnull receivedMessage) {
        //Already Handled via Notification
    } success:^(UIImage * _Nonnull fullImage, TAPMessageModel * _Nonnull receivedMessage) {
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

- (void)showImagePreviewControllerWithSelectedImage:(UIImage *)image {
    TAPImagePreviewViewController *imagePreviewViewController = [[TAPImagePreviewViewController alloc] init];
    imagePreviewViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    imagePreviewViewController.delegate = self;
    

    if (self.currentRoom.type != RoomTypeChannel) {
        imagePreviewViewController.isNotFromPersonalRoom = YES;
    }
    
    TAPMediaPreviewModel *imagePreview = [TAPMediaPreviewModel new];
    imagePreview.image = image;
    
    [imagePreviewViewController setMediaPreviewDataWithData:imagePreview];
    [imagePreviewViewController setParticipantListArray:self.currentRoom.participants];
    
    UINavigationController *imagePreviewNavigationController = [[UINavigationController alloc] initWithRootViewController:imagePreviewViewController];
    imagePreviewNavigationController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self.navigationController presentViewController:imagePreviewNavigationController animated:YES completion:nil];
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

#pragma mark Bubble Chat
- (void)handleLongPressedWithURL:(NSURL *)url originalString:(NSString *)originalString {
    [TAPUtil tapticImpactFeedbackGenerator];
    if ([url.scheme isEqualToString:@"mailto"]) {
        //handle email address
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *composeAction = [UIAlertAction
                                        actionWithTitle:NSLocalizedStringFromTableInBundle(@"Compose", nil, [TAPUtil currentBundle], @"")
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            [self checkAndShowInputAccessoryView];
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
                                         [self checkAndShowInputAccessoryView];
                                         UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                         [pasteboard setString:originalString];
                                     }];
        
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"")
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction * action) {
                                           [self checkAndShowInputAccessoryView];
                                           [self checkKeyboard];
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
        
        if (self.secondaryTextField.isFirstResponder || self.messageTextView.isFirstResponder) {
            self.isKeyboardWasShowed = YES;
        }
        else {
            self.isKeyboardWasShowed = NO;
        }
        
        [UIView animateWithDuration:0.2f animations:^{
            [self.messageTextView resignFirstResponder];
            [self.secondaryTextField resignFirstResponder];
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
                                         //CS TEMP - temporary open safari
                                         [self checkAndShowInputAccessoryView];
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
                                         [self checkAndShowInputAccessoryView];
                                         UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                         [pasteboard setString:originalString];
                                     }];
        
        UIAlertAction *cancelAction = [UIAlertAction
                                       actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"")
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction * action) {
                                           [self checkAndShowInputAccessoryView];
                                           [self checkKeyboard];
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
        
        if (self.secondaryTextField.isFirstResponder || self.messageTextView.isFirstResponder) {
            self.isKeyboardWasShowed = YES;
        }
        else {
            self.isKeyboardWasShowed = NO;
        }
        
        [UIView animateWithDuration:0.2f animations:^{
            [self.messageTextView resignFirstResponder];
            [self.secondaryTextField resignFirstResponder];
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
                                     [self checkAndShowInputAccessoryView];
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
                                    [self checkAndShowInputAccessoryView];
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
                                     [self checkAndShowInputAccessoryView];
                                     UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                     [pasteboard setString:phoneNumber];
                                 }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
                                       //Do some thing here
                                       [self checkAndShowInputAccessoryView];
                                       [self checkKeyboard];
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
    
    if (self.secondaryTextField.isFirstResponder || self.messageTextView.isFirstResponder) {
        self.isKeyboardWasShowed = YES;
    }
    else {
        self.isKeyboardWasShowed = NO;
    }
    
    [UIView animateWithDuration:0.2f animations:^{
        [self.messageTextView resignFirstResponder];
        [self.secondaryTextField resignFirstResponder];
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
                                                 //CS NOTE - add resign first responder before every pushVC to handle keyboard height
                                                 [self.messageTextView resignFirstResponder];
                                                 [self.secondaryTextField resignFirstResponder];
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

- (void)handleLongPressedWithMessage:(TAPMessageModel *)message {
#ifdef DEBUG
    NSLog(@"Message model: %@", [message toJSONString]);
#endif
    
    if (message.isDeleted || message.isSending || message.isFailedSend || (self.otherUser == nil && self.currentRoom.type == RoomTypePersonal)) {
        return;
    }
    
    [TAPUtil tapticImpactFeedbackGenerator];
    //handle message long pressed
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *replyAction = [UIAlertAction
                                  actionWithTitle:NSLocalizedStringFromTableInBundle(@"Reply", nil, [TAPUtil currentBundle], @"")
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                      //Reply Action Here
                                      
                                      [self checkAndShowInputAccessoryView];
                                      
                                      if (message.type == TAPChatMessageTypeText) {
                                          [self showInputAccessoryExtensionView:NO];
                                          [self setInputAccessoryExtensionType:inputAccessoryExtensionTypeReplyMessage];
                                          [self setReplyMessageWithMessage:message];
                                          [self showInputAccessoryExtensionView:YES];
                                          
                                          TAPMessageModel *quotedMessageModel = [message copy];
                                          [[TAPChatManager sharedManager] saveToQuotedMessage:message userInfo:nil roomID:self.currentRoom.roomID];
                                      }
                                      else if (message.type == TAPChatMessageTypeImage) {
                                          TAPMessageModel *quotedMessageModel = [message copy];
                                          
                                          [self showInputAccessoryExtensionView:NO];
                                          [self setInputAccessoryExtensionType:inputAccessoryExtensionTypeQuote];
                                          [self showInputAccessoryExtensionView:YES];
                                          
                                          //convert to quote model
                                          TAPQuoteModel *quote = [TAPQuoteModel constructFromMessageModel:quotedMessageModel];
                                          [self setQuoteWithQuote:quote userID:quotedMessageModel.user.userID];
                                          
                                          quotedMessageModel.quote = quote;
                                          
                                          [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessageModel userInfo:nil roomID:self.currentRoom.roomID];
                                      }
                                      else if (message.type == TAPChatMessageTypeVideo) {
                                          TAPMessageModel *quotedMessageModel = [message copy];
                                          
                                          [self showInputAccessoryExtensionView:NO];
                                          [self setInputAccessoryExtensionType:inputAccessoryExtensionTypeQuote];
                                          [self showInputAccessoryExtensionView:YES];
                                          
                                          //convert to quote model
                                          TAPQuoteModel *quote = [TAPQuoteModel constructFromMessageModel:quotedMessageModel];
                                          [self setQuoteWithQuote:quote userID:quotedMessageModel.user.userID];
                                          
                                          quotedMessageModel.quote = quote;
                                          
                                          [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessageModel userInfo:nil roomID:self.currentRoom.roomID];
                                      }
                                      else if (message.type == TAPChatMessageTypeLocation) {
                                          [self showInputAccessoryExtensionView:NO];
                                          [self setInputAccessoryExtensionType:inputAccessoryExtensionTypeReplyMessage];
                                          [self setReplyMessageWithMessage:message];
                                          [self showInputAccessoryExtensionView:YES];
                                          
                                          TAPMessageModel *quotedMessageModel = [message copy];
                                          [[TAPChatManager sharedManager] saveToQuotedMessage:message userInfo:nil roomID:self.currentRoom.roomID];
                                      }
                                      else if (message.type == TAPChatMessageTypeFile) {
                                          TAPMessageModel *quotedMessageModel = [message copy];
                                          
                                          [self showInputAccessoryExtensionView:NO];
                                          [self setInputAccessoryExtensionType:inputAccessoryExtensionTypeQuote];
                                          [self showInputAccessoryExtensionView:YES];
                                          
                                          NSString *fileName = [quotedMessageModel.data objectForKey:@"fileName"];
                                          fileName = [TAPUtil nullToEmptyString:fileName];
                                          
                                          NSString *fileExtension  = [[fileName pathExtension] uppercaseString];
                                          
                                          fileName = [fileName stringByDeletingPathExtension];
                                          
                                          if ([fileExtension isEqualToString:@""]) {
                                              fileExtension = [quotedMessageModel.data objectForKey:@"mediaType"];
                                              fileExtension = [TAPUtil nullToEmptyString:fileExtension];
                                              fileExtension = [fileExtension lastPathComponent];
                                              fileExtension = [fileExtension uppercaseString];
                                          }
                                          
                                          NSString *fileSize = [NSByteCountFormatter stringFromByteCount:[[quotedMessageModel.data objectForKey:@"size"] integerValue] countStyle:NSByteCountFormatterCountStyleBinary];
                                          
                                          //convert to quote model
                                          TAPQuoteModel *quote = [TAPQuoteModel constructFromMessageModel:quotedMessageModel];
                                          [self setQuoteWithQuote:quote userID:quotedMessageModel.user.userID];
                                          
                                          quotedMessageModel.quote = quote;
                                          
                                          [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessageModel userInfo:nil roomID:self.currentRoom.roomID];
                                      }
                                  }];
    
    UIAlertAction *forwardAction = [UIAlertAction
                                    actionWithTitle:NSLocalizedStringFromTableInBundle(@"Forward", nil, [TAPUtil currentBundle], @"")
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        [self checkAndShowInputAccessoryView];
                                        //Forward Action Here
                                        TAPForwardListViewController *forwardListViewController = [[TAPForwardListViewController alloc] init];
                                        forwardListViewController.currentNavigationController = self.navigationController;
                                        forwardListViewController.forwardedMessage = message;
                                        UINavigationController *forwardListNavigationController = [[UINavigationController alloc] initWithRootViewController:forwardListViewController];
                                        [self presentViewController:forwardListNavigationController animated:YES completion:nil];
                                    }];
    
    UIAlertAction *copyAction = [UIAlertAction
                                 actionWithTitle:NSLocalizedStringFromTableInBundle(@"Copy", nil, [TAPUtil currentBundle], @"")
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     [self checkAndShowInputAccessoryView];
                                     UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                     if (message.type == TAPChatMessageTypeText) {
                                         [pasteboard setString:message.body];
                                     }
                                 }];
    
    UIAlertAction *saveToGalleryAction = [UIAlertAction
                                          actionWithTitle:NSLocalizedStringFromTableInBundle(@"Save", nil, [TAPUtil currentBundle], @"")
                                          style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * action) {

        [self checkAndShowInputAccessoryView];
        // Save to gallery action here
        NSDictionary *dataDictionary = message.data;
        dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];
        
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
        
        if (![fileID isEqualToString:@""] || ![urlKey isEqualToString:@""]) {
            if (message.type == TAPChatMessageTypeImage) {
                // Save image to gallery
                [TAPImageView imageFromCacheWithKey:urlKey message:message
                success:^(UIImage * _Nullable savedImage, TAPMessageModel *resultMessage) {
                    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                } failure:^(TAPMessageModel *resultMessage) {
                    [TAPImageView imageFromCacheWithKey:fileID message:message
                    success:^(UIImage * _Nullable savedImage, TAPMessageModel *resultMessage) {
                        UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                    }];
                }];
            }
            else if (message.type == TAPChatMessageTypeVideo) {
                //Save video to gallery
                NSString *filePath = [[TAPFileDownloadManager sharedManager] getDownloadedFilePathWithRoomID:message.room.roomID fileID:urlKey];
                if ([filePath isEqualToString:@""] || filePath == nil) {
                    filePath = [[TAPFileDownloadManager sharedManager] getDownloadedFilePathWithRoomID:message.room.roomID fileID:fileID];
                }
                if (![filePath isEqualToString:@""] && filePath != nil) {
                    // Video done download, save to gallery
                    UISaveVideoAtPathToSavedPhotosAlbum(filePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                }
            }
        }
    }];
    
    UIAlertAction *deleteMessageAction = [UIAlertAction
                                          actionWithTitle:NSLocalizedStringFromTableInBundle(@"Delete", nil, [TAPUtil currentBundle], @"")
                                          style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * action) {
                                              [self checkAndShowInputAccessoryView];
                                              [self showDeleteMessageActionWithMessageArray:@[message.messageID]];
                                          }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
                                       //Do some thing here
                                       [self checkAndShowInputAccessoryView];
                                       [self checkKeyboard];
                                   }];
    
    UIImage *replyActionImage = [UIImage imageNamed:@"TAPIconReplyChatOrange" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    replyActionImage = [replyActionImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconActionSheetReply]]; //DV Temp Icon
    [replyAction setValue:[replyActionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];

    UIImage *forwardActionImage = [UIImage imageNamed:@"TAPIconForward" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    forwardActionImage = [forwardActionImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconActionSheetForward]];
    [forwardAction setValue:[forwardActionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];

    UIImage *copyActionImage = [UIImage imageNamed:@"TAPIconCopy" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    copyActionImage = [copyActionImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconActionSheetCopy]];
    [copyAction setValue:[copyActionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    UIImage *saveToGalleryActionImage = [UIImage imageNamed:@"TAPIconSaveOrange" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    saveToGalleryActionImage = [saveToGalleryActionImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconActionSheetGallery]]; //DV Temp Icon
    [saveToGalleryAction setValue:[saveToGalleryActionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    UIImage *deleteMessageActionImage = [UIImage imageNamed:@"TAPIconTrash" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    deleteMessageActionImage = [deleteMessageActionImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconActionSheetTrash]];
    [deleteMessageAction setValue:[deleteMessageActionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    [replyAction setValue:@0 forKey:@"titleTextAlignment"];
    [forwardAction setValue:@0 forKey:@"titleTextAlignment"];
    [copyAction setValue:@0 forKey:@"titleTextAlignment"];
    [saveToGalleryAction setValue:@0 forKey:@"titleTextAlignment"];
    [deleteMessageAction setValue:@0 forKey:@"titleTextAlignment"];
    
    UIColor *actionSheetDefaultColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorActionSheetDefaultLabel];
    UIColor *actionSheetCancelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorActionSheetCancelButtonLabel];
    UIColor *actionSheetDestructiveColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorActionSheetDestructiveLabel];
    
    [replyAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
    [forwardAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
    [copyAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
    [saveToGalleryAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
    [deleteMessageAction setValue:actionSheetDestructiveColor forKey:@"titleTextColor"];
    [cancelAction setValue:actionSheetCancelColor forKey:@"titleTextColor"];
    
    if ([[TapUI sharedInstance] isReplyMessageMenuEnabled] && self.isShowAccessoryView) {
        [alertController addAction:replyAction];
    }
    
    if ([[TapUI sharedInstance] isForwardMessageMenuEnabled] && ((message.type == TAPChatMessageTypeText || message.type == TAPChatMessageTypeLocation) && message.room.type != RoomTypeTransaction)) {
        //DV Temp
        //Show forward action for text and location only (temporary)
        [alertController addAction:forwardAction];
    }
    
    if ([[TapUI sharedInstance] isCopyMessageMenuEnabled] && message.type == TAPChatMessageTypeText) {
        //Show copy action for chat type text only
        [alertController addAction:copyAction];
    }
    
    if ([[TapUI sharedInstance] isSaveMediaToGalleryMenuEnabled] && message.type == TAPChatMessageTypeImage) {
        //check already downloaded or not
        UIImage *savedImage = nil;
        NSString *roomID = message.room.roomID;
        NSDictionary *dataDictionary = message.data;
        dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];
        
        NSString *key = [dataDictionary objectForKey:@"fileID"];
        key = [TAPUtil nullToEmptyString:key];
        
        savedImage = [TAPImageView imageFromCacheWithKey:key];
        
        if (savedImage == nil) {
            NSString *fileURL = [dataDictionary objectForKey:@"url"];
            if (fileURL == nil || [fileURL isEqualToString:@""]) {
                fileURL = [dataDictionary objectForKey:@"fileURL"];
            }
            fileURL = [TAPUtil nullToEmptyString:fileURL];
            
            if (![fileURL isEqualToString:@""]) {
                key = fileURL;
                key = [[key componentsSeparatedByCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]] componentsJoinedByString:@""];
            }
            
            savedImage = [TAPImageView imageFromCacheWithKey:key];
        }
        
        if (savedImage != nil) {
            //Image exist
            [alertController addAction:saveToGalleryAction];
        }
    }
    
    if ([[TapUI sharedInstance] isSaveMediaToGalleryMenuEnabled] && message.type == TAPChatMessageTypeVideo) {
        //check already downloaded or not
        NSString *roomID = message.room.roomID;
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
        
        if (filePath != nil && ![filePath isEqualToString:@""]) {
            //File exist
            [alertController addAction:saveToGalleryAction];
        }
    }
    
    if ([[TapUI sharedInstance] isDeleteMessageMenuEnabled] && [message.user.userID isEqualToString:[TAPDataManager getActiveUser].userID] && !message.isSending && self.isShowAccessoryView) {
        //Show delete message for our bubble (my bubble) only
        [alertController addAction:deleteMessageAction];
    }
    
    [alertController addAction:cancelAction];
    
    if (self.secondaryTextField.isFirstResponder || self.messageTextView.isFirstResponder) {
        self.isKeyboardWasShowed = YES;
    }
    else {
        self.isKeyboardWasShowed = NO;
    }
    
    [UIView animateWithDuration:0.2f animations:^{
        [self.messageTextView resignFirstResponder];
        [self.secondaryTextField resignFirstResponder];
        [self keyboardWillHideWithHeight:0.0f];
    } completion:^(BOOL finished) {
        [self presentViewController:alertController animated:YES completion:^{
            //after animation
        }];
    }];
}

- (void)setReplyMessageWithMessage:(TAPMessageModel *)message {
    
    TAPChatManagerQuoteActionType type = [[TAPChatManager sharedManager] getQuoteActionTypeWithRoomID:self.currentRoom.roomID];
    if (type == TAPChatManagerQuoteActionTypeForward) {
        if ([message.forwardFrom.localID isEqualToString:@""] && [message.forwardFrom.fullname isEqualToString:@""]) {
            
            if ([message.user.userID isEqualToString:[TAPDataManager getActiveUser].userID]) {
                self.replyMessageNameLabel.text = NSLocalizedStringFromTableInBundle(@"You", nil, [TAPUtil currentBundle], @"");
            }
            else {
                self.replyMessageNameLabel.text = [TAPUtil nullToEmptyString:message.user.fullname];
            }
        }
        else {
            //check id message sender is equal to active user id, if yes change the title to "You"
            if ([message.user.userID isEqualToString:[TAPDataManager getActiveUser].userID]) {
                self.replyMessageNameLabel.text = NSLocalizedStringFromTableInBundle(@"You", nil, [TAPUtil currentBundle], @"");
            }
            else {
                self.replyMessageNameLabel.text = [TAPUtil nullToEmptyString:message.forwardFrom.fullname];
            }
        }
        
        self.replyMessageMessageLabel.text = [TAPUtil nullToEmptyString:message.body];
    }
    else {
        
        //check id message sender is equal to active user id, if yes change the title to "You"
        if ([message.user.userID isEqualToString:[TAPDataManager getActiveUser].userID]) {
            self.replyMessageNameLabel.text = NSLocalizedStringFromTableInBundle(@"You", nil, [TAPUtil currentBundle], @"");
        }
        else {
            self.replyMessageNameLabel.text = [TAPUtil nullToEmptyString:message.user.fullname];
        }
        
        self.replyMessageMessageLabel.text = [TAPUtil nullToEmptyString:message.body];
    }
}

- (void)setQuoteWithQuote:(TAPQuoteModel *)quote userID:(NSString *)userID {
    //check id message sender is equal to active user id, if yes change the title to "You"
    if ([userID isEqualToString:[TAPDataManager getActiveUser].userID]) {
        self.quoteTitleLabel.text = NSLocalizedStringFromTableInBundle(@"You", nil, [TAPUtil currentBundle], @"");
    }
    else {
        self.quoteTitleLabel.text = quote.title;
    }
    
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
//        else if (quote.fileID != nil && ![quote.fileID isEqualToString:@""]) {
//            [self.quoteImageView setImageWithURLString:quote.fileID];
//        }
        
        if (quote.imageURL != nil && ![quote.imageURL isEqualToString:@""]) {
            [self.quoteImageView setImageWithURLString:quote.imageURL];
        }
        if (self.quoteImageView.image == nil && quote.fileID != nil && ![quote.fileID isEqualToString:@""]) {
            [self.quoteImageView setImageWithURLString:quote.fileID];
        }
        
        self.quoteFileView.alpha = 0.0f;
        self.quoteImageView.alpha = 1.0f;
    }
}

- (void)messageBubbleQuoteViewDidTapped:(TAPMessageModel *)tappedMessage {
    if ((![tappedMessage.replyTo.messageID isEqualToString:@"0"] && ![tappedMessage.replyTo.messageID isEqualToString:@""]) && ![tappedMessage.quote.title isEqualToString:@""] && tappedMessage.quote != nil && tappedMessage.replyTo != nil) {
        //reply to exists
        if ([TAPUtil isEmptyString:self.tappedMessageLocalID]) {
            //check if no reply message in loading / fetch to handle double tapped on waiting action
            //check if message is forwarded, do nothing on forwarded message
            if ([TAPUtil isEmptyString:tappedMessage.forwardFrom.fullname]) {
                [self scrollToMessageAndLoadDataWithLocalID:tappedMessage.replyTo.localID];
            }
        }
    }
    else if (![tappedMessage.quote.title isEqualToString:@""] && tappedMessage.quote != nil) {
        //quote exists
        if(tappedMessage.data) {
            NSDictionary *userInfoDictionary = [TAPUtil nullToEmptyDictionary:[tappedMessage.data objectForKey:@"userInfo"]];
            id<TapUIChatRoomDelegate> tapUIChatRoomDelegate = [TapUI sharedInstance].chatRoomDelegate;
            if ([tapUIChatRoomDelegate respondsToSelector:@selector(tapTalkMessageQuoteTappedWithUserInfo:)]) {
                [tapUIChatRoomDelegate tapTalkMessageQuoteTappedWithUserInfo:userInfoDictionary];
            }
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
    
    if (filePath == nil || [filePath isEqualToString:@""]) {
        return;
    }
    
    NSURL *url = [NSURL fileURLWithPath:filePath];
    AVAsset *asset = [AVAsset assetWithURL:url];
    
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

#pragma mark Input Accessory View
//Implement Input Accessory View
- (UIView *)inputAccessoryView {
    /*
     //Change to this if method if there are bug showing compose keyboard view, but this method causing another problem which compose view sometimes not appear because wrong detection of active view controller
     if ((self.isViewWillAppeared || self.isSwipeGestureEnded)  && ([[[[[TapUI sharedInstance] getCurrentTapTalkActiveViewController] class] description] isEqualToString:[[TapUIChatViewController class] description]] || [[[[[TapUI sharedInstance] getCurrentTapTalkActiveViewController] class] description] isEqualToString:[[TAPMediaDetailViewController class] description]])) {
     
    }
     */
    
    if ((self.isViewWillAppeared || self.isSwipeGestureEnded)) {
        if (self.isShowAccessoryView) {
            return self.inputMessageAccessoryView;
        }
        else {
            return nil;
        }
    }
    else {
        return nil;
    }
}

- (void)showInputAccessoryExtensionView:(BOOL)show {
    if (show) {
        _currentInputAccessoryExtensionHeight = kInputMessageAccessoryExtensionViewDefaultHeight;
        
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

- (void)setInputAccessoryExtensionType:(InputAccessoryExtensionType)inputAccessoryExtensionType {
    _inputAccessoryExtensionType = inputAccessoryExtensionType;
    if (inputAccessoryExtensionType == inputAccessoryExtensionTypeQuote) {
        self.quoteView.alpha = 1.0f;
        self.replyMessageView.alpha = 0.0f;
    }
    else if (inputAccessoryExtensionType == inputAccessoryExtensionTypeReplyMessage) {
        self.quoteView.alpha = 0.0f;
        self.replyMessageView.alpha = 1.0f;
    }
}

- (IBAction)inputAccessoryExtensionCloseButtonDidTapped:(id)sender {
    [self showInputAccessoryExtensionView:NO];
    [[TAPChatManager sharedManager] removeQuotedMessageObjectWithRoomID:self.currentRoom.roomID];
}

- (void)checkAndShowInputAccessoryView {
    [self checkAndShowRoomViewState];
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

#pragma mark Chat Data Flow
- (void)firstLoadData {
    TAPRoomModel *roomData = [TAPChatManager sharedManager].activeRoom;
    NSString *roomID = roomData.roomID;
    
    NSDate *date = [NSDate date];
    NSTimeInterval createdDate = [date timeIntervalSince1970] * 1000.0f; //Timestamp in miliseconds
    
    _isFirstLoadData = YES;
    
    [self fetchUnreadMessagesDataWithSuccess:^(NSArray *unreadMessages) {
        if ([unreadMessages count] != 0) {
            //Obtain earliest unread message index
            TAPMessageModel *earliestUnreadMessage = [unreadMessages firstObject];
            _unreadLocalID = earliestUnreadMessage.localID;
            _numberOfUnreadMessages = [unreadMessages count];
        }
        
        [TAPDataManager getMessageWithRoomID:roomID lastMessageTimeStamp:[NSNumber numberWithDouble:createdDate] limitData:TAP_NUMBER_OF_ITEMS_CHAT success:^(NSArray<TAPMessageModel *> *obtainedMessageArray) {
            
            //Handle mapping mention index to array
            NSArray *mentionIndexArray = [NSArray array];
            for (TAPMessageModel *currentMessage in obtainedMessageArray) {
                if (currentMessage.type == TAPChatMessageTypeText) {
                    NSString *messageContainString = currentMessage.body;
                    messageContainString = [TAPUtil nullToEmptyString:messageContainString];
                    mentionIndexArray = [TAPUtil getMentionIndexes:messageContainString];
                }
                else if (currentMessage.type == TAPChatMessageTypeImage || currentMessage.type == TAPChatMessageTypeVideo) {
                    NSString *messageContainString = [currentMessage.data objectForKey:@"caption"];
                    messageContainString = [TAPUtil nullToEmptyString:messageContainString];
                    mentionIndexArray = [TAPUtil getMentionIndexes:messageContainString];
                }
                
                if ([mentionIndexArray count] > 0) {
                    [self.mentionIndexesDictionary removeObjectForKey:currentMessage.localID];
                    [self.mentionIndexesDictionary setObject:mentionIndexArray forKey:currentMessage.localID];
                }
            }
            
            //DV Note - check method checkAndShowRoomViewState too if wants to update code below
            //Check if room is deleted or kicked
            TAPMessageModel *lastMessage = [obtainedMessageArray firstObject];
            
            if (lastMessage.room.isLocked) {
                [self showInputAccessoryExtensionView:NO];
                [[TAPChatManager sharedManager] removeQuotedMessageObjectWithRoomID:self.currentRoom.roomID];
                [self.messageTextView setText:@""];
                [self hideInputAccessoryView];
            }
            else {
                if (lastMessage.room.type == RoomTypePersonal && lastMessage.room.isDeleted) {
                    [self.view endEditing:YES];
                    [self showDeletedRoomView:YES isGroup:NO isGroupDeleted:NO];
                }
                else if (lastMessage.type == TAPChatMessageTypeSystemMessage && [lastMessage.action isEqualToString:@"room/removeParticipant"] && [lastMessage.target.targetID isEqualToString:[TAPDataManager getActiveUser].userID]) {
                    //Check if system message with action remove participant and target user is current user
                    //show deleted chat room view
                    [self.view endEditing:YES];
                    [self showDeletedRoomView:YES isGroup:YES isGroupDeleted:NO];
                }
                else if (lastMessage.type == TAPChatMessageTypeSystemMessage && [lastMessage.action isEqualToString:@"room/delete"]) {
                    [self.view endEditing:YES];
                    if (lastMessage.room.type == RoomTypePersonal) {
                        [self showDeletedRoomView:YES isGroup:NO isGroupDeleted:NO];
                    }
                    else if (lastMessage.room.type == RoomTypeGroup || lastMessage.room.type == RoomTypeTransaction) {
                        [self showDeletedRoomView:YES isGroup:YES isGroupDeleted:YES];
                    }
                }
                else if (lastMessage.type == TAPChatMessageTypeSystemMessage && [lastMessage.action isEqualToString:@"room/leave"] && [lastMessage.user.userID isEqualToString:[TAPDataManager getActiveUser].userID]) {
                    [self.view endEditing:YES];
                    [self showDeletedRoomView:YES isGroup:NO isGroupDeleted:NO];
                }
            }
            //END DV Note
            
            if ([obtainedMessageArray count] == 0) {
                //No chat history, first time chat
                [self checkEmptyState];
                
                //Reload View
                [self.tableView reloadData];
                
                //Obtain Current Timestamp
                NSNumber *currentMaxCreated = [NSNumber numberWithLong:createdDate];
                
                //Call API Before With Current Timestamp And Update UI
                [self fetchBeforeMessageFromAPIAndUpdateUIWithRoomID:roomID maxCreated:currentMaxCreated];
            }
            else {
                //Has existing chat
                [self updateMessageDataAndUIWithMessages:obtainedMessageArray checkFirstUnreadMessage:NO toTop:NO updateUserDetail:NO withCompletionHandler:^{
                    TAPMessageModel *earliestMessage = [obtainedMessageArray objectAtIndex:[obtainedMessageArray count] - 1];
                    NSNumber *minCreated = earliestMessage.created;  
                    _minCreatedMessage = minCreated;
                    
                    TAPMessageModel *latestMessage = [obtainedMessageArray objectAtIndex:0];
                    NSNumber *maxCreated = latestMessage.created;
                    
                    NSNumber *lastUpdated = [TAPDataManager getMessageLastUpdatedWithRoomID:roomID];
                    if ([lastUpdated longLongValue] == 0 || lastUpdated == nil) {
                        //First time call, set minCreated to lastUpdated preference
                        [TAPDataManager setMessageLastUpdatedWithRoomID:roomID lastUpdated:minCreated];
                    }
                    
                    if (![TAPUtil isEmptyString:self.scrollToMessageLocalIDString]) {
                        [self scrollToMessageAndLoadDataWithLocalID:self.scrollToMessageLocalIDString];
                    }
                    
                    //Call API Get After Message
                    //Obtain Last Updated Value
                    NSNumber *lastUpdatedFromPreference = [TAPDataManager getMessageLastUpdatedWithRoomID:roomID];
                    [TAPDataManager callAPIGetMessageAfterWithRoomID:roomID minCreated:minCreated lastUpdated:lastUpdatedFromPreference needToSaveLastUpdatedTimestamp:YES success:^(NSArray *messageArray) {
                        
                        //Delete physical files when isDeleted = 1 (message is deleted)
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                        dispatch_async(queue, ^{
                            for (TAPMessageModel *message in messageArray) {
                                
                                //Handle mapping mention index to array
                                NSArray *mentionIndexArray = [NSArray array];
                                if (message.type == TAPChatMessageTypeText) {
                                    NSString *messageContainString = message.body;
                                    messageContainString = [TAPUtil nullToEmptyString:messageContainString];
                                    mentionIndexArray = [TAPUtil getMentionIndexes:messageContainString];
                                }
                                else if (message.type == TAPChatMessageTypeImage || message.type == TAPChatMessageTypeVideo) {
                                    NSString *messageContainString = [message.data objectForKey:@"caption"];
                                    messageContainString = [TAPUtil nullToEmptyString:messageContainString];
                                    mentionIndexArray = [TAPUtil getMentionIndexes:messageContainString];
                                }
                                
                                if ([mentionIndexArray count] > 0) {
                                    [self.mentionIndexesDictionary setObject:mentionIndexArray forKey:message.localID];
                                }
                                
                     
                                if (message.isDeleted) {
                                    [TAPDataManager deletePhysicalFilesInBackgroundWithMessage:message success:^{
                                        
                                    } failure:^(NSError *error) {
                                        
                                    }];
                                }
                                
                                //Check if we got the mention and scroll position in on the top, add and show mention anchor badge
                                BOOL hasMention = [TAPUtil isActiveUserMentionedWithMessage:message activeUser:[TAPDataManager getActiveUser]];
                                if (hasMention && ![message.user.userID isEqualToString:[TAPDataManager getActiveUser].userID] && !message.isRead) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self addMessageToAnchorMentionArray:message];
                                    });
                                }
                            }
                        });
                        
                        //Show mention anchor button when position is not on the bottom
                        if(self.tableView.contentOffset.y > kShowChatAnchorOffset) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self showMentionAnchorView:YES];
                            });

                        }
                        
                        //Update View
                        [self updateMessageDataAndUIWithMessages:messageArray checkFirstUnreadMessage:YES toTop:YES updateUserDetail:YES withCompletionHandler:^{
                            
                            //Update leftover message status to delivered
                            if ([messageArray count] != 0) {
                                [[TAPMessageStatusManager sharedManager] filterAndUpdateBulkMessageStatusToDeliveredWithArray:messageArray];
                            }
                            
                            //Call API Before Message if count < 50
                            if ([self.messageArray count] < TAP_NUMBER_OF_ITEMS_CHAT) {
                                [self fetchBeforeMessageFromAPIAndUpdateUIWithRoomID:roomID maxCreated:minCreated];
                            }
                            else {
                                [self showTopFloatingIdentifierView:NO withType:TopFloatingIndicatorViewTypeLoading numberOfUnreadMessages:0 animated:YES];
                                _isFirstLoadData = NO;
                            }
                            
                            [self processAllPreviousMessageAsRead];
                            //check if last message is deleted room
                            [self checkAndShowRoomViewState];
                        }];
                    } failure:^(NSError *error) {
                        [self showTopFloatingIdentifierView:NO withType:TopFloatingIndicatorViewTypeLoading numberOfUnreadMessages:0 animated:YES];
                        
                        _isFirstLoadData = NO;
                        
                        //check if last message is deleted room
                        TAPMessageModel *lastMessage = [self.messageArray firstObject];
                        if (lastMessage.type == TAPChatMessageTypeSystemMessage && [lastMessage.action isEqualToString:@"room/removeParticipant"] && [lastMessage.target.targetID isEqualToString:[TAPDataManager getActiveUser].userID]) {
                            //Check if system message with action remove participant and target user is current user
                            //show deleted chat room view
                            [self.view endEditing:YES];
                            [self showDeletedRoomView:YES isGroup:YES isGroupDeleted:NO];
                        }
#ifdef DEBUG
                        //Note - this alert only shown at debug
                        NSString *errorMessage = [error.userInfo objectForKey:@"message"];
                        errorMessage = [TAPUtil nullToEmptyString:errorMessage];
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTableInBundle(@"Failed", nil, [TAPUtil currentBundle], @"") message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"OK", nil, [TAPUtil currentBundle], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        }];
                        
                        [alertController addAction:okAction];
                        [self presentViewController:alertController animated:YES completion:nil];
#endif
                        [self processAllPreviousMessageAsRead];
                    }];
                }];
            }
        } failure:^(NSError *error) {
            [self showTopFloatingIdentifierView:NO withType:TopFloatingIndicatorViewTypeLoading numberOfUnreadMessages:0 animated:YES];
            
            [self processAllPreviousMessageAsRead];
        }];
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)addIncomingMessageToArrayAndDictionaryWithMessage:(TAPMessageModel *)message atIndex:(NSInteger)index {
    
    //Add message to message pointer dictionary
    [self.messageDictionary setObject:message forKey:message.localID];
    
    //Add message to data array
    [self.messageArray insertObject:message atIndex:index];
}

- (void)removeMessageFromArrayAndDictionaryWithLocalID:(NSString *)localID {
    TAPMessageModel *currentRemovedMessage = [self.messageDictionary objectForKey:localID];
    [self.messageDictionary removeObjectForKey:localID];
    [self.messageArray removeObject:currentRemovedMessage];
}

- (void)handleMessageFromSocket:(TAPMessageModel *)message isUpdatedMessage:(BOOL)isUpdated {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //Handle mapping mention index to array
        NSArray *mentionIndexArray = [NSArray array];
        if (message.type == TAPChatMessageTypeText) {
            NSString *messageContainString = message.body;
            messageContainString = [TAPUtil nullToEmptyString:messageContainString];
            mentionIndexArray = [TAPUtil getMentionIndexes:messageContainString];
        }
        else if (message.type == TAPChatMessageTypeImage || message.type == TAPChatMessageTypeVideo) {
            NSString *messageContainString = [message.data objectForKey:@"caption"];
            messageContainString = [TAPUtil nullToEmptyString:messageContainString];
            mentionIndexArray = [TAPUtil getMentionIndexes:messageContainString];
        }
        
        if ([mentionIndexArray count] > 0) {
            [self.mentionIndexesDictionary removeObjectForKey:message.localID];
            [self.mentionIndexesDictionary setObject:mentionIndexArray forKey:message.localID];
        }
        
        //Check if message exist in Message Pointer Dictionary
        TAPMessageModel *currentMessage = [self.messageDictionary objectForKey:message.localID];
        if(currentMessage != nil) {
            //Message exist in dictionary
            
            //Update message into array and dictionary
            //Need to take message before data updated to get current sending state
            
            TAPUserModel *currentUser = [TAPDataManager getActiveUser];
            
            BOOL isSendingAnimation = NO;
            BOOL setAsDelivered = NO;
            BOOL setAsRead = NO;
            BOOL setAsDeleted = NO;
            
            
            if ([currentMessage.user.userID isEqualToString:currentUser.userID]) {
                //My Message
                if (currentMessage.isSending) {
                    //Message was sending
                    isSendingAnimation = YES;
                    NSInteger indexInArray = [self.messageArray indexOfObject:currentMessage];
                }
                
                if(!currentMessage.isDelivered && message.isDelivered && !currentMessage.isRead && !message.isRead) {
                    setAsDelivered = YES;
                    setAsDeleted = NO;
                }
                
                if(!currentMessage.isRead && message.isRead) {
                    setAsDelivered = NO;
                    setAsRead = YES;
                }
                
                //check if current message from socket is deleted, not from message in local array or dictionary
                if (message.isDeleted) {
                    setAsDeleted = YES;
                }
            }
            else {
                //Their Message
                //check if current message from socket is deleted, not from message in local array or dictionary
                if (message.isDeleted) {
                    setAsDeleted = YES;
                }
            }
            
            //Update message data
            [self updateMessageModelValueWithMessage:message];
            
            //Check need to update profile data or not
            [self checkUpdatedUserProfileWithMessage:message];
            
            //Update view
            NSInteger indexInArray = [self.messageArray indexOfObject:currentMessage];
            NSIndexPath *messageIndexPath = [NSIndexPath indexPathForRow:indexInArray inSection:0];
            
            if (setAsDeleted) {
                //Delete physical file if exist
                if (currentMessage.type == TAPChatMessageTypeImage || currentMessage.type == TAPChatMessageTypeVideo || currentMessage.type == TAPChatMessageTypeFile) {
                    [TAPDataManager deletePhysicalFilesWithMessage:currentMessage success:^{
                        
                    } failure:^(NSError *error) {
                        
                    }];
                }
                
                //Update cell to deleted message
                [self.tableView performBatchUpdates:^{
                    //changing beginUpdates and endUpdates with this because of deprecation
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:messageIndexPath, nil] withRowAnimation:UITableViewRowAnimationAutomatic];
                } completion:^(BOOL finished) {
                }];
            }
            else {
                if (currentMessage.type == TAPChatMessageTypeText) {
                    if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                        TAPMyChatBubbleTableViewCell *cell = [self.tableView cellForRowAtIndexPath:messageIndexPath];
                        
                        NSArray *mentionArray = [self.mentionIndexesDictionary objectForKey:message.localID];
                        if ([mentionArray count] > 0) {
                            cell.mentionIndexesArray = mentionArray;
                        }
                        
                        if (isSendingAnimation) {
                            [cell receiveSentEvent];
                        }
                        else if (setAsDelivered) {
                            [cell receiveDeliveredEvent];
                        }
                        else if (setAsRead) {
                            [cell receiveReadEvent];
                        }
                        else {
                            [cell setMessage:message];
                            
                            //        //RN Note - Remove reload data and change to set message locally to prevent blink on sending animation, change to reload data if find any bug related
                            //        [self.tableView reloadData];
                        }
                    }
                }
                else if (currentMessage.type == TAPChatMessageTypeImage) {
                    if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                        TAPMyImageBubbleTableViewCell *cell = [self.tableView cellForRowAtIndexPath:messageIndexPath];

                        NSArray *mentionArray = [self.mentionIndexesDictionary objectForKey:message.localID];
                        if ([mentionArray count] > 0) {
                            cell.mentionIndexesArray = mentionArray;
                        }
                        
                        if (isSendingAnimation) {
                            [cell receiveSentEvent];
                            
                            [TAPUtil performBlock:^{
                                [self fetchImageDataWithMessage:message];
                            } afterDelay:1.0f];
                        }
                        else if (setAsDelivered) {
                            [cell receiveDeliveredEvent];
                        }
                        else if (setAsRead) {
                            [cell receiveReadEvent];
                        }
                        else {
                            [cell setMessage:message];
                            
                            //        //RN Note - Remove reload data and change to set message locally to prevent blink on sending animation, change to reload data if find any bug related
                            //        [self.tableView reloadData];
                        }
                    }
                }
                else if (currentMessage.type == TAPChatMessageTypeVideo) {
                    if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                        //My Chat
                        TAPMyVideoBubbleTableViewCell *cell = [self.tableView cellForRowAtIndexPath:messageIndexPath];

                        NSArray *mentionArray = [self.mentionIndexesDictionary objectForKey:message.localID];
                        if ([mentionArray count] > 0) {
                            cell.mentionIndexesArray = mentionArray;
                        }

                        cell.message = currentMessage;
                        
                        if (isSendingAnimation) {
                            [cell receiveSentEvent];
                        }
                        else if (setAsDelivered) {
                            [cell receiveDeliveredEvent];
                        }
                        else if (setAsRead) {
                            [cell receiveReadEvent];
                        }
                        else {
                            [cell setMessage:message];
                            
                            //        //RN Note - Remove reload data and change to set message locally to prevent blink on sending animation, change to reload data if find any bug related
                            //        [self.tableView reloadData];
                        }
                    }
                }
                else if (currentMessage.type == TAPChatMessageTypeFile) {
                    if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                        TAPMyFileBubbleTableViewCell *cell = [self.tableView cellForRowAtIndexPath:messageIndexPath];
                        
                        if (isSendingAnimation) {
                            [cell receiveSentEvent];
                        }
                        else if (setAsDelivered) {
                            [cell receiveDeliveredEvent];
                        }
                        else if (setAsRead) {
                            [cell receiveReadEvent];
                        }
                        else {
                            [cell setMessage:message];
                            
                            //        //RN Note - Remove reload data and change to set message locally to prevent blink on sending animation, change to reload data if find any bug related
                            //        [self.tableView reloadData];
                        }
                    }
                }
                else if (currentMessage.type == TAPChatMessageTypeProduct) {
                    if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                        TAPProductListBubbleTableViewCell *cell = [self.tableView cellForRowAtIndexPath:messageIndexPath];
                        NSArray *productListArray = [currentMessage.data objectForKey:@"items"];
                        [cell setProductListBubbleCellWithData:productListArray];
                        if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                            [cell setProductListBubbleTableViewCellType:TAPProductListBubbleTableViewCellTypeSingleOption];
                        }
                        else {
                            [cell setProductListBubbleTableViewCellType:TAPProductListBubbleTableViewCellTypeTwoOption];
                        }
                    }
                }
                else if (currentMessage.type == TAPChatMessageTypeLocation) {
                    if ([currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                        TAPMyLocationBubbleTableViewCell *cell = [self.tableView cellForRowAtIndexPath:messageIndexPath];
                        
                        if (isSendingAnimation) {
                            [cell receiveSentEvent];
                        }
                        else if (setAsDelivered) {
                            [cell receiveDeliveredEvent];
                        }
                        else if (setAsRead) {
                            [cell receiveReadEvent];
                        }
                        else {
                            [cell setMessage:message];
                            
                            //        //RN Note - Remove reload data and change to set message locally to prevent blink on sending animation, change to reload data if find any bug related
                            //        [self.tableView reloadData];
                        }
                    }
                }
                else {
                    //check if custom bubble available
                    NSDictionary *cellDataDictionary = [[TAPCustomBubbleManager sharedManager] getCustomBubbleClassNameWithType:message.type];
                    
                    if([cellDataDictionary count] > 0 && cellDataDictionary != nil) {
                        //if custom bubble from client available
                        
                        TAPBaseGeneralBubbleTableViewCell *cell = [self.tableView cellForRowAtIndexPath:messageIndexPath];
                        [cell setMessage:message];
                        [self.tableView performBatchUpdates:^{
                            //changing beginUpdates and endUpdates with this because of deprecation
                        } completion:^(BOOL finished) {
                        }];
                    }
                }
            }
        }
        else {
            //Message not exist in dictionary
            if (!isUpdated) {
                //Only run when message is new message
                if(self.tableView.contentOffset.y > kShowChatAnchorOffset) {
                    //Bottom table view not seen, put message to holder array and insert the message when user scroll to bottom
                    [self.scrolledPendingMessageArray insertObject:message atIndex:0];
                    
                    //Add message to messageDictionary first to lower load time (pending message will be inserted to messageArray at scrollViewDidScroll and chatAnchorButtonDidTapped)
                    [self.messageDictionary setObject:message forKey:message.localID];
                    
                    [self addMessageToAnchorUnreadArray:message];
                    
                    //If new incoming message from emit and other user and also when scroll position in not in the bottom, add and show mention anchor
                    BOOL hasMention = [TAPUtil isActiveUserMentionedWithMessage:message activeUser:[TAPDataManager getActiveUser]];
                    if (hasMention && ![message.user.userID isEqualToString:[TAPDataManager getActiveUser].userID] && !message.isRead) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.scrolledPendingMentionArray addObject:message];
                            [self addMessageToAnchorMentionArray:message];
                            [self showMentionAnchorView:YES];
                        });
                    }
                }
                else {
                    //RN Note - If crash happen on opening room see updateMessageDataAndUIWithMessages method
                    //Bottom table view visible, insert message normally
                    [self addIncomingMessageToArrayAndDictionaryWithMessage:message atIndex:0];
                    NSIndexPath *insertAtIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    [self.tableView performBatchUpdates:^{
                        //changing beginUpdates and endUpdates with this because of deprecation
                        [self.tableView insertRowsAtIndexPaths:@[insertAtIndexPath] withRowAnimation:UITableViewRowAnimationTop];
                    } completion:^(BOOL finished) {
                    }];
                }
            }
        }
        [self checkEmptyState];
    });
}

- (void)destroySequence {
    //Save to draft
    [self saveMessageDraft];
        
    //Update badge count
    [[TAPNotificationManager sharedManager] updateApplicationBadgeCount];
    
    [[TAPChatManager sharedManager] stopTyping];
    
    [[TAPChatManager sharedManager] closeActiveRoom];
    
    //Remove ChatManager Delegate
    [[TAPChatManager sharedManager] removeDelegate:self];
}

- (void)addMessageToAnchorUnreadArray:(TAPMessageModel *)message {
    if (![self.anchorUnreadMessageArray containsObject:message]) {
        [self.anchorUnreadMessageArray addObject:message];
        [self checkAnchorUnreadLabel];
    }
}

- (void)removeMessageFromAnchorUnreadArray:(TAPMessageModel *)message {
    if ([self.anchorUnreadMessageArray containsObject:message]) {
        [self.anchorUnreadMessageArray removeObject:message];
        [self checkAnchorUnreadLabel];
    }
}

- (void)addMessageToAnchorMentionArray:(TAPMessageModel *)message {
    if (![self.anchorMentionMessageDictionary objectForKey:message.localID]) {
        [self.anchorMentionMessageDictionary setObject:message forKey:message.localID];
        [self.anchorMentionMessageArray addObject:message];
        [self checkAnchorMentionLabel];
    }
}

- (void)addMessageToAnchorMentionArrayWithMessageArray:(NSArray *)messageArray {
    for (TAPMessageModel *message in messageArray) {
        if (![self.anchorMentionMessageDictionary objectForKey:message.localID]) {
            [self.anchorMentionMessageDictionary setObject:message forKey:message.localID];
            [self.anchorMentionMessageArray addObject:message];
            [self checkAnchorMentionLabel];
        }
    }
}

- (void)removeMessageFromAnchorMention:(TAPMessageModel *)message {
    if ([self.anchorMentionMessageDictionary objectForKey:message.localID]) {
        [self.anchorMentionMessageDictionary removeObjectForKey:message.localID];
        [self.anchorMentionMessageArray removeObject:message];
        [self checkAnchorMentionLabel];
    }
    
    if ([self.anchorMentionMessageDictionary count] == 0) {
        [UIView animateWithDuration:0.2f animations:^{
            self.mentionAnchorBackgroundView.alpha = 0.0f;
            self.mentionAnchorBadgeView.alpha = 0.0f;
            self.mentionAnchorButton.alpha = 0.0f;
        }];
    }
 }

- (void)clearAnchorMentionDictionary {
    [self.anchorMentionMessageDictionary removeAllObjects];
    [self.anchorMentionMessageArray removeAllObjects];
}

- (void)retrieveExistingMessages {
    //Prevent retreive before message if already last page
    if (self.isLastPage) {
        [self showTopFloatingIdentifierView:NO withType:TopFloatingIndicatorViewTypeLoading numberOfUnreadMessages:0 animated:YES];
        return;
    }
    
    TAPMessageModel *lastMessage = [self.messageArray lastObject];
    
    if (self.apiBeforeLastCreated == [lastMessage.created longLongValue]) {
        return;
    }
    
    _apiBeforeLastCreated = [lastMessage.created longLongValue];
    
    [TAPDataManager getMessageWithRoomID:lastMessage.room.roomID lastMessageTimeStamp:lastMessage.created limitData:TAP_NUMBER_OF_ITEMS_CHAT success:^(NSArray<TAPMessageModel *> *obtainedMessageArray) {
        if ([obtainedMessageArray count] > 0) {
            [self updateMessageDataAndUIFromBeforeWithMessages:obtainedMessageArray withCompletionHandler:^{
                //if there's tapped reply message id, check and scroll to item
                if (![TAPUtil isEmptyString:self.tappedMessageLocalID]) {
                    //Add 0.5s delay to wait update table view UI  from previous update message
                    [TAPUtil performBlock:^{
                        [self scrollToMessageAndLoadDataWithLocalID:self.tappedMessageLocalID];
                    } afterDelay:0.5f];
                }
            }];
        }
        
        //Call API Before when message array less than limit (50)
        [TAPUtil performBlock:^{
            //Add 0.2s delay to wait update table view UI from previous update message
            if ([obtainedMessageArray count] < TAP_NUMBER_OF_ITEMS_CHAT && !self.isFirstLoadData) {
                [self fetchBeforeMessageFromAPIAndUpdateUIWithRoomID:lastMessage.room.roomID maxCreated:lastMessage.created];
            }
        } afterDelay:0.2f];
    
    } failure:^(NSError *error) {
        
    }];
}

- (void)fetchBeforeMessageFromAPIAndUpdateUIWithRoomID:(NSString *)roomID maxCreated:(NSNumber *)maxCreated {
    //Call API Get Before Message
    if ([self.loadedMaxCreated longLongValue] != [maxCreated longLongValue]) {
        _loadedMaxCreated = maxCreated;
        [self showLoadMessageCellLoading:YES];
        [TAPDataManager callAPIGetMessageBeforeWithRoomID:roomID maxCreated:maxCreated numberOfItems:[NSNumber numberWithInteger:TAP_NUMBER_OF_ITEMS_API_MESSAGE_BEFORE] success:^(NSArray *messageArray, BOOL hasMore) {
            if ([messageArray count] != 0) {
                
                //Handle mapping mention index to array
                NSArray *mentionIndexArray = [NSArray array];
                for (TAPMessageModel *message in messageArray) {
                    if (message.type == TAPChatMessageTypeText) {
                        NSString *messageContainString = message.body;
                        messageContainString = [TAPUtil nullToEmptyString:messageContainString];
                        mentionIndexArray = [TAPUtil getMentionIndexes:messageContainString];
                    }
                    else if (message.type == TAPChatMessageTypeImage || message.type == TAPChatMessageTypeVideo) {
                        NSString *messageContainString = [message.data objectForKey:@"caption"];
                        messageContainString = [TAPUtil nullToEmptyString:messageContainString];
                        mentionIndexArray = [TAPUtil getMentionIndexes:messageContainString];
                    }
                    
                    if ([mentionIndexArray count] > 0) {
                        [self.mentionIndexesDictionary removeObjectForKey:message.localID];
                        [self.mentionIndexesDictionary setObject:mentionIndexArray forKey:message.localID];
                    }
                }
                
                _isLastPage = !hasMore;
                
                [self showLoadMessageCellLoading:NO];
                
                //Update View
                [self updateMessageDataAndUIFromBeforeWithMessages:messageArray withCompletionHandler:^{
                    //if there's tapped reply message id, check and scroll to item
                    if (![TAPUtil isEmptyString:self.tappedMessageLocalID]) {
                        [self scrollToMessageAndLoadDataWithLocalID:self.tappedMessageLocalID];
                    }
                    
                    [self checkEmptyState];
                }];
            }
            else if ([messageArray count] == 0 && !hasMore) {
                [self showLoadMessageCellLoading:NO];
            }
            _isFirstLoadData = NO;
        } failure:^(NSError *error) {
            [self showLoadMessageCellLoading:NO];
            _isFirstLoadData = NO;
#ifdef DEBUG
            //Note - this alert only shown at debug
            NSString *errorMessage = [error.userInfo objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTableInBundle(@"Failed", nil, [TAPUtil currentBundle], @"") message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"OK", nil, [TAPUtil currentBundle], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
#endif
        }];
    }
}

- (void)updateMessageDataAndUIWithMessages:(NSArray *)messageArray checkFirstUnreadMessage:(BOOL)checkFirstUnreadMessage toTop:(BOOL)toTop updateUserDetail:(BOOL)updateUserDetail withCompletionHandler:(void(^)())completionHandler {
    //RN Note - If crash happen on opening room, this async might be the cause
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSInteger earliestUnreadMessageIndex = -1;
        long minCreatedUnreadMessage;
        
        for (NSInteger counter = 0; counter < [messageArray count]; counter++) {
            
            TAPMessageModel *message = [messageArray objectAtIndex:counter];
            TAPMessageModel *currentMessage = [self.messageDictionary objectForKey:message.localID];
            
            if (currentMessage != nil) {
                //Message exist in dictionary
                [self updateMessageModelValueWithMessage:message];
            }
            else {
                //Message not exist in dictionary
                NSInteger index = 0;
                
                if (!toTop) {
                    index = [self.messageArray count];
                }

                [self addIncomingMessageToArrayAndDictionaryWithMessage:message atIndex:index];
                if (checkFirstUnreadMessage && message.isRead == 0) {
                    //For checking unread message from API After
                    
                    if (self.unreadLocalID == nil || [self.unreadLocalID isEqualToString:@""]) {
                        //save first unread message localID if unreadLocalID is nil
                        self.unreadLocalID = message.localID;
                    }
                    
                    _numberOfUnreadMessages = self.numberOfUnreadMessages + 1;
                    
                    //Obtain smallest created of unread message
                    long currentMessageCreated = [message.created longValue];
                    if (counter == 0) {
                        minCreatedUnreadMessage = currentMessageCreated;
                        earliestUnreadMessageIndex = 0;
                    }
                    else {
                        if (currentMessageCreated < minCreatedUnreadMessage) {
                            //Set the smallest created timestamp
                            minCreatedUnreadMessage = currentMessageCreated;
                            earliestUnreadMessageIndex = counter;
                        }
                    }
                }
            }
            
            if (updateUserDetail) {
                //Check need to update profile data or not
                [self checkUpdatedUserProfileWithMessage:message];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //Check to show unread message identifier
            if (!self.isShowingUnreadMessageIdentifier) {
                if (checkFirstUnreadMessage) {
                    //From API After
                    if (earliestUnreadMessageIndex != -1) {
                        TAPMessageModel *smallestCreatedUnreadMessage = [messageArray objectAtIndex:earliestUnreadMessageIndex];
                        NSString *obtainedLocalID = smallestCreatedUnreadMessage.localID;
                        TAPMessageModel *obtainedMessage = [self.messageDictionary objectForKey:obtainedLocalID];
                        NSInteger unreadMessageIndex = [self.messageArray indexOfObject:obtainedMessage];
                        
                        if(NSNotFound != unreadMessageIndex) {
                            //Only run when index in found in message array
                            //Construct unread message identifier and add to view (messageIndex + 1 to add above earliest message)
                            NSInteger createdInteger = [obtainedMessage.created integerValue];
                            createdInteger = createdInteger - 1; //min 1 to set created earlier than the first obtained unread
                            TAPMessageModel *generatedMessage = [[TAPChatManager sharedManager] generateUnreadMessageIdentifierWithRoom:obtainedMessage.room created:[NSNumber numberWithInteger:createdInteger] indexPosition:unreadMessageIndex + 1];
                            [self addIncomingMessageToArrayAndDictionaryWithMessage:generatedMessage atIndex:unreadMessageIndex + 1];
                            _isShowingUnreadMessageIdentifier = YES;
                        }
                    }
                }
                else {
                    //From Database
                    NSString *unreadMessageLocalID = self.unreadLocalID;
                    TAPMessageModel *obtainedMessage = [self.messageDictionary objectForKey:unreadMessageLocalID];
                    NSInteger messageIndex = [self.messageArray indexOfObject:obtainedMessage];
                    
                    if(NSNotFound != messageIndex) {
                        //Only run when index in found in message array
                        //Construct unread message identifier and add to view (messageIndex + 1 to add above earliest message)
                        NSInteger createdInteger = [obtainedMessage.created integerValue];
                        createdInteger = createdInteger - 1; //min 1 to set created earlier than the first obtained unread
                        TAPMessageModel *generatedMessage = [[TAPChatManager sharedManager] generateUnreadMessageIdentifierWithRoom:obtainedMessage.room created:[NSNumber numberWithInteger:createdInteger] indexPosition:messageIndex + 1];
                        [self addIncomingMessageToArrayAndDictionaryWithMessage:generatedMessage atIndex:messageIndex + 1];
                        _isShowingUnreadMessageIdentifier = YES;
                    }
                }
            }
    
            [self sortAndFilterMessageArray];
            
            [self.tableView reloadData];
            
            //Check to show top unread button
            [self checkAndShowUnreadButton];
            
            if (toTop) {
                //RN To Do - Scroll to "Unread Message" marker after implemented
                [self.tableView scrollsToTop];
            }
            
            [self checkEmptyState];
            
            completionHandler();
        });
    });
}

- (void)updateMessageDataAndUIFromBeforeWithMessages:(NSArray *)messageArray
                               withCompletionHandler:(void(^)())completionHandler {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSMutableArray *currentAddedMessageArray = [NSMutableArray array];
        NSMutableDictionary *currentAddedMessageDictionary = [NSMutableDictionary dictionary];

        NSInteger index = 0;
        index = [self.messageArray count];
        
        for (NSInteger counter = 0; counter < [messageArray count]; counter++) {
            TAPMessageModel *message = [messageArray objectAtIndex:counter];
            TAPMessageModel *currentMessage = [self.messageDictionary objectForKey:message.localID];
            if (currentMessage != nil) {
                //Message exist in dictionary
                [self updateMessageModelValueWithMessage:message];
            }
            else {
                //Message not exist in dictionary
                [currentAddedMessageArray addObject:[NSString stringWithFormat:@"%ld", index]];
                [currentAddedMessageDictionary setObject:message forKey:[NSString stringWithFormat:@"%ld", index]];
                index++;
            }
        }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                for (NSString *key in currentAddedMessageArray) {
                    TAPMessageModel *currentMessage = [currentAddedMessageDictionary objectForKey:key];
                    [self addIncomingMessageToArrayAndDictionaryWithMessage:currentMessage atIndex:[key integerValue]];
                }
                
                [self.tableView reloadData]; //This logic might affect performance load when load before API, see and fix below implementation for better performance
                
//                //RN Notes - RN Debt - Uncommand this method to insert the message to table view without reload data, might cause crash when open room and load api before, and directly send message
//                NSMutableArray *indexPathArray = [NSMutableArray array];
//                NSInteger currentCount = [self.messageArray count] - [currentAddedMessageArray count];
//                for (int count = currentCount; count < [self.messageArray count]; count++) {
//                    [indexPathArray addObject:[NSIndexPath indexPathForRow:count inSection:0]];
//                }
//
//                if([indexPathArray count] > 0) {
//                    [self.tableView beginUpdates];
//                    [self.tableView insertRowsAtIndexPaths:indexPathArray withRowAnimation:UITableViewRowAnimationAutomatic];
//                    [self.tableView endUpdates];
//                    [self.tableView scrollsToTop];
//                }
                
                completionHandler();
            });
    });
}

- (void)sortAndFilterMessageArray {
    NSMutableArray *currentMessageArray = [NSMutableArray arrayWithArray:self.messageArray];
    
    NSMutableArray *sortedArray;
    
    sortedArray = [currentMessageArray sortedArrayUsingComparator:^NSComparisonResult(id message1, id message2) {
        TAPMessageModel *messageModel1 = (TAPMessageModel *)message1;
        TAPMessageModel *messageModel2 = (TAPMessageModel *)message2;
        
        NSNumber *message1CreatedDate = messageModel1.created;
        NSNumber *message2CreatedDate = messageModel2.created;
        
        return [message2CreatedDate compare:message1CreatedDate];
    }];
    
    _messageArray = [NSMutableArray arrayWithArray:sortedArray];
}

- (void)callAPIAfterAndUpdateUIAndScrollToTop:(BOOL)scrollToTop {
    TAPRoomModel *roomData = [TAPChatManager sharedManager].activeRoom;
    NSString *roomID = roomData.roomID;
    
    [self showTopFloatingIdentifierView:YES withType:TopFloatingIndicatorViewTypeLoading numberOfUnreadMessages:0 animated:YES];
    
    //Obtain Last Updated Value
    NSNumber *lastUpdatedFromPreference = [TAPDataManager getMessageLastUpdatedWithRoomID:roomID];
    [TAPDataManager callAPIGetMessageAfterWithRoomID:roomID minCreated:self.minCreatedMessage lastUpdated:lastUpdatedFromPreference needToSaveLastUpdatedTimestamp:YES success:^(NSArray *messageArray) {
        
        //Delete physical files when isDeleted = 1 (message is deleted)
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{

            for (TAPMessageModel *message in messageArray) {
                
                //Check if we got the mention and scroll position in on the top, add and show mention anchor badge
                BOOL hasMention = [TAPUtil isActiveUserMentionedWithMessage:message activeUser:[TAPDataManager getActiveUser]];
                if (hasMention && ![message.user.userID isEqualToString:[TAPDataManager getActiveUser].userID] && !message.isRead) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self addMessageToAnchorMentionArray:message];
                    });
                }
                
                //Handle mapping mention index to array
                NSArray *mentionIndexArray = [NSArray array];
                if (message.type == TAPChatMessageTypeText) {
                    NSString *messageContainString = message.body;
                    messageContainString = [TAPUtil nullToEmptyString:messageContainString];
                    mentionIndexArray = [TAPUtil getMentionIndexes:messageContainString];
                }
                else if (message.type == TAPChatMessageTypeImage || message.type == TAPChatMessageTypeVideo) {
                    NSString *messageContainString = [message.data objectForKey:@"caption"];
                    messageContainString = [TAPUtil nullToEmptyString:messageContainString];
                    mentionIndexArray = [TAPUtil getMentionIndexes:messageContainString];
                }
                
                if ([mentionIndexArray count] > 0) {
                    [self.mentionIndexesDictionary removeObjectForKey:message.localID];
                    [self.mentionIndexesDictionary setObject:mentionIndexArray forKey:message.localID];
                }
                
                if (message.isDeleted) {
                    [TAPDataManager deletePhysicalFilesInBackgroundWithMessage:message success:^{
                        
                    } failure:^(NSError *error) {
                        
                    }];
                }
            }
        });
        
        if (!scrollToTop && self.tableView.contentOffset.y > kShowChatAnchorOffset) {
            //Show mention anchor button when position is not on the bottom
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showMentionAnchorView:YES];
            });
        }
        
        //Update View
        [self updateMessageDataAndUIWithMessages:messageArray checkFirstUnreadMessage:YES toTop:scrollToTop updateUserDetail:YES withCompletionHandler:^{
            //Update leftover message status to delivered
            if ([messageArray count] != 0) {
                [[TAPMessageStatusManager sharedManager] filterAndUpdateBulkMessageStatusToDeliveredWithArray:messageArray];
            }
        }];
        [self showTopFloatingIdentifierView:NO withType:TopFloatingIndicatorViewTypeLoading numberOfUnreadMessages:0 animated:YES];
        //check if last message is deleted room
        [self checkAndShowRoomViewState];
        
    } failure:^(NSError *error) {
        [self showTopFloatingIdentifierView:NO withType:TopFloatingIndicatorViewTypeLoading numberOfUnreadMessages:0 animated:YES];
        //check if last message is deleted room
        TAPMessageModel *lastMessage = [self.messageArray firstObject];
        if (lastMessage.type == TAPChatMessageTypeSystemMessage && [lastMessage.action isEqualToString:@"room/removeParticipant"] && [lastMessage.target.targetID isEqualToString:[TAPDataManager getActiveUser].userID]) {
            //Check if system message with action remove participant and target user is current user
            //show deleted chat room view
            [self.view endEditing:YES];
            [self showDeletedRoomView:YES isGroup:YES isGroupDeleted:NO];
        }
    }];
}

- (void)updateMessageModelValueWithMessage:(TAPMessageModel *)message {
    TAPMessageModel *currentMessage = [self.messageDictionary objectForKey:message.localID];
    currentMessage.messageID = message.messageID;
    currentMessage.localID = message.localID;
    currentMessage.type = message.type;
    currentMessage.body = message.body;
    currentMessage.room = message.room;
    currentMessage.recipientID = message.recipientID;
    currentMessage.created = message.created;
    currentMessage.user = message.user;
    currentMessage.isHidden = message.isHidden;
    currentMessage.isDeleted = message.isDeleted;
    currentMessage.isSending = message.isSending;
    currentMessage.isFailedSend = message.isFailedSend;
    currentMessage.data = message.data;
    
    if(!currentMessage.isDelivered) {
        //Update only when ui data is not delivered yet
        currentMessage.isDelivered = message.isDelivered;
    }
    
    if(!currentMessage.isRead) {
        //Update only when ui data is not read yet
        currentMessage.isRead = message.isRead;
    }
    
    if(!currentMessage.isDeleted) {
        //Update only when ui data is not deleted yet
        currentMessage.isDeleted = message.isDeleted;
    }
}

- (void)saveMessageDraft {
    //Save message draft to chat manager if exist
    NSString *messageString = self.messageTextView.textView.text;
    messageString = [messageString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    TAPRoomModel *room = [TAPChatManager sharedManager].activeRoom;
    NSString *roomID = room.roomID;
    roomID = [TAPUtil nullToEmptyString:roomID];
    [[TAPChatManager sharedManager] saveMessageToDraftWithMessage:messageString roomID:roomID];
}

- (void)processMessageAsRead:(TAPMessageModel *)message forceMarkAsRead:(BOOL)force {
    BOOL isRead = message.isRead;
    
    if(!self.isViewDidAppeared && !force) {
        //Do not process mark as read if from first view layout, visible message will be processed at processVisibleMessageAsRead
        return;
    }
    
    if(isRead) {
        //Do not process if message has been read
        return;
    }
    
    //Remove local notification and send read status to server
    message.isRead = YES;
    
    //Call Message Status Manager mark as read call API
    [[TAPMessageStatusManager sharedManager] markMessageAsReadWithMessage:message];
}

- (void)processVisibleMessageAsRead {
    NSArray *visibleCellIndexPathArray = [self.tableView indexPathsForVisibleRows];
    
    for(NSIndexPath *indexPath in visibleCellIndexPathArray) {
        if (indexPath.row >= [self.messageArray count]) {
            continue;
        }
        
        TAPMessageModel *currentMessage = [self.messageArray objectAtIndex:indexPath.row];
        
        if (![currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
            //Their chat
            [self processMessageAsRead:currentMessage forceMarkAsRead:NO];
        }
    }
}

- (void)processAllPreviousMessageAsRead {
    if ([self.delegate respondsToSelector:@selector(chatViewControllerShouldClearUnreadBubbleForRoomID:)]) {
        [self.delegate chatViewControllerShouldClearUnreadBubbleForRoomID:self.currentRoom.roomID];
    }
    
    [TAPDataManager getDatabaseUnreadMessagesInRoomWithRoomID:[TAPChatManager sharedManager].activeRoom.roomID
                                                 activeUserID:[TAPChatManager sharedManager].activeUser.userID
                                                      success:^(NSArray *unreadMessages) {
                                                          for(TAPMessageModel *currentMessageModel in unreadMessages) {
                                                              //Find current message model object in dictionary
                                                              TAPMessageModel *messageModel = [self.messageDictionary objectForKey:currentMessageModel.localID];
                                                              
                                                              if(messageModel != nil) {
                                                                  //Use object in dictionary if exist
                                                                  //Mark as read
                                                                  [self processMessageAsRead:messageModel forceMarkAsRead:YES];
                                                              }
                                                              else {
                                                                  //Message is not loaded yet in room, use current message model
                                                                  //Mark as read
                                                                  [self processMessageAsRead:currentMessageModel forceMarkAsRead:YES];
                                                              }
                                                          }
                                                      } failure:^(NSError *error) {
                                                          
                                                      }];
}

#pragma mark Keyboard
- (void)keyboardWillShowWithHeight:(CGFloat)keyboardHeight {
    if(!self.isKeyboardShowedForFirstTime) {
        _isKeyboardShowedForFirstTime = YES;
        
        return;
    }
    
    keyboardHeight = CGRectGetHeight([UIScreen mainScreen].bounds) - [self.inputMessageAccessoryView.superview convertPoint:self.inputMessageAccessoryView.frame.origin toView:nil].y;
    
    if (keyboardHeight < 0) {
        return;
    }
    
    if (self.isKeyboardOptionTapped && self.isKeyboardShowed) {
        _keyboardHeight = keyboardHeight;
        CGFloat tableViewYContentInset = self.keyboardHeight - [TAPUtil safeAreaBottomPadding] - kInputMessageAccessoryViewHeight;
        
        [UIView animateWithDuration:0.2f animations:^{
            self.chatAnchorButtonBottomConstrait.constant = kChatAnchorDefaultBottomConstraint + self.keyboardHeight - kInputMessageAccessoryViewHeight;
            self.chatAnchorBackgroundViewBottomConstrait.constant = kChatAnchorDefaultBottomConstraint + self.keyboardHeight - kInputMessageAccessoryViewHeight;
            
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
            self.mentionListTableViewBottomConstraint.constant = mentionListTableViewBottomValue;
            
        } completion:^(BOOL finished) {
            //Do something after animation completed.
        }];
        
        return;
    }
    
    CGFloat accessoryViewAndSafeAreaHeight = self.safeAreaBottomPadding + kInputMessageAccessoryViewHeight + self.currentInputAccessoryExtensionHeight;
    
    //set initial keyboard height to prevent wrong keyboard height usage
    if (self.initialKeyboardHeight == 0.0f && keyboardHeight !=  accessoryViewAndSafeAreaHeight && keyboardHeight != kInputMessageAccessoryViewHeight + self.safeAreaBottomPadding && keyboardHeight != kInputMessageAccessoryViewHeight) {
        _initialKeyboardHeight = keyboardHeight - self.currentInputAccessoryExtensionHeight;
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
        [self.keyboardViewController setKeyboardHeight:keyHeight];
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
    CGFloat mentionListTableViewBottomValue = self.keyboardHeight;
    if (IS_IPHONE_X_FAMILY) {
        mentionListTableViewBottomValue = mentionListTableViewBottomValue - safeAreaGap;
    }
    self.mentionListTableViewBottomConstraint.constant = mentionListTableViewBottomValue;
    
    [UIView animateWithDuration:0.2f animations:^{
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
        
        CGFloat messageViewHeightDifference = self.messageViewHeightConstraint.constant - kInputMessageAccessoryViewHeight;
        if (messageViewHeightDifference < 0) {
            messageViewHeightDifference = 0.0f;
        }
        
        CGFloat newYContentOffset = self.tableView.contentOffset.y - self.keyboardHeight + self.safeAreaBottomPadding + kInputMessageAccessoryViewHeight + self.currentInputAccessoryExtensionHeight + messageViewHeightDifference;
        
        if (fabs(tableViewYContentInset - lastTableViewYContentInset) == kInputMessageAccessoryExtensionViewDefaultHeight) {
            newYContentOffset = self.tableView.contentOffset.y + lastTableViewYContentInset - tableViewYContentInset;
        }
        
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
            [self.keyboardViewController setKeyboardHeight:keyHeight];
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
    self.mentionListTableViewBottomConstraint.constant = mentionListTableViewBottomValue;
    
    [UIView animateWithDuration:0.2f animations:^{
        if(self.isCustomKeyboardAvailable) {
            self.keyboardOptionButtonView.alpha = 1.0f;
            self.keyboardOptionButton.alpha = 1.0f;
            self.keyboardOptionButton.userInteractionEnabled = YES;
            self.messageViewLeftConstraint.constant = 4.0f;
            self.keyboardOptionViewRightConstraint.constant = 16.0f;
            [self.inputMessageAccessoryView layoutIfNeeded];
        }
        
        self.chatAnchorButtonBottomConstrait.constant = kChatAnchorDefaultBottomConstraint + self.safeAreaBottomPadding + self.currentInputAccessoryExtensionHeight + messageViewHeightDifference;
        self.chatAnchorBackgroundViewBottomConstrait.constant = kChatAnchorDefaultBottomConstraint + self.safeAreaBottomPadding + self.currentInputAccessoryExtensionHeight + messageViewHeightDifference;
        
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

- (void)checkKeyboard {
    //WK Note - To check if the keyboard was showed before attachment button tapped.
    if (self.isKeyboardWasShowed) {
        if (self.keyboardState == keyboardStateDefault) {
            [self.messageTextView becameFirstResponder];
        }
        else {
            [self.secondaryTextField becomeFirstResponder];
        }
    }
}

- (void)setKeyboardStateDefault {
    _keyboardState = keyboardStateDefault;    
    self.keyboardOptionButtonView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChatComposerBurgerMenuBackground];
    UIImage *hamburgerIconImage = [UIImage imageNamed:@"TAPIconHamburger" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    self.keyboardOptionButtonImageView.image = [hamburgerIconImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChatComposerBurgerMenu]];
}

- (void)setKeyboardStateOption {
    _keyboardState = keyboardStateOptions;

    self.keyboardOptionButtonView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChatComposerShowKeyboardBackground];
    UIImage *keyboardIconImage = [UIImage imageNamed:@"TAPIconKeyboard" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    self.keyboardOptionButtonImageView.image = [keyboardIconImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChatComposerShowKeyboard]];
}

- (IBAction)keyboardOptionButtonDidTapped:(id)sender {
        
    _isKeyboardOptionTapped = YES;
    
    //Hide unread message indicator top view
    if (self.topFloatingIndicatorViewType == TopFloatingIndicatorViewTypeUnreadMessage && self.topFloatingIndicatorView.alpha == 1.0f) {
        [TAPUtil performBlock:^{
            [self showTopFloatingIdentifierView:NO withType:TopFloatingIndicatorViewTypeUnreadMessage numberOfUnreadMessages:0 animated:YES];
        } afterDelay:1.0f];
    }
    
    if (self.keyboardState == keyboardStateDefault) {
        [self setKeyboardStateOption];

        //DV Note - 12 Mar 2020
        //adding validation to check if keyHeight is minus
        //    [self.keyboardViewController setKeyboardHeight:self.initialKeyboardHeight - kInputMessageAccessoryViewHeight];
        CGFloat keyHeight = self.initialKeyboardHeight - kInputMessageAccessoryViewHeight;
        if (keyHeight < 0.0f) {
            keyHeight = 0.0f;
        }
        [self.keyboardViewController setKeyboardHeight:keyHeight];
        //END DV Note
        
        self.secondaryTextField.inputView = self.keyboardViewController.inputView;
        if (IS_IPHONE_X_FAMILY) {
            if (self.isKeyboardShowed) {
                [UIView performWithoutAnimation:^{
                    [self.messageTextView resignFirstResponder];
                    [self keyboardWillHideWithHeight:0.0f];
                    [self.secondaryTextField becomeFirstResponder];
                }];
            }
            else {
                [self.secondaryTextField becomeFirstResponder];
            }
        }
        else {
            [self.secondaryTextField becomeFirstResponder];
        }
    }
    else {
        [self setKeyboardStateDefault];
        
        if (IS_IPHONE_X_FAMILY) {
            if (self.isKeyboardShowed) {
                [UIView performWithoutAnimation:^{
                    [self.secondaryTextField resignFirstResponder];
                    [self keyboardWillHideWithHeight:0.0f];
                    [self.messageTextView becameFirstResponder];
                }];
            }
            else {
                [self.messageTextView becameFirstResponder];
            }
        }
        else {
            [self.messageTextView becameFirstResponder];
        }
    }
    
    _isKeyboardOptionTapped = NO;
}

#pragma mark Mentions
- (IBAction)mentionLoadingCancelButtonDidTapped:(id)sender {
    
}

- (void)showMentionLoadingView:(BOOL)isShow {
    if (isShow) {
        //Add Animation
        if ([self.mentionLoadingImageView.layer animationForKey:@"SpinAnimation"] == nil) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            animation.fromValue = [NSNumber numberWithFloat:0.0f];
            animation.toValue = [NSNumber numberWithFloat: 2 * M_PI];
            animation.duration = 1.5f;
            animation.repeatCount = INFINITY;
            animation.removedOnCompletion = NO;
            [self.mentionLoadingImageView.layer addAnimation:animation forKey:@"SpinAnimation"];
        }

        [UIView animateWithDuration:0.2f animations:^{
            self.mentionLoadingBackgroundView.alpha = 1.0f;
            self.mentionLoadingImageView.alpha = 1.0f;
            self.mentionLoadingCancelLabel.alpha = 0.0f;
            self.mentionLoadingCancelButton.alpha = 0.0f;
            self.mentionLoadingCancelButton.userInteractionEnabled = NO;
        }];
        
        [TAPUtil performBlock:^{
            self.mentionLoadingCancelLabel.alpha = 1.0f;
            self.mentionLoadingCancelButton.alpha = 1.0f;
            self.mentionLoadingCancelButton.userInteractionEnabled = YES;
        } afterDelay:1.0f];

    }
    else {
        //REMOVE ANIMATION
        if ([self.mentionLoadingImageView.layer animationForKey:@"SpinAnimation"] != nil) {
            [self.mentionLoadingImageView.layer removeAnimationForKey:@"SpinAnimation"];
        }
        
        [UIView animateWithDuration:0.2f animations:^{
            self.mentionLoadingBackgroundView.alpha = 0.0f;
            self.mentionLoadingImageView.alpha = 0.0f;
            self.mentionLoadingCancelLabel.alpha = 0.0f;
            self.mentionLoadingCancelButton.alpha = 0.0f;
            self.mentionLoadingCancelButton.userInteractionEnabled = NO;
        }];
    }
}

- (void)sendMessageFromLongPressMentionWithUsername:(NSString *)username message:(TAPMessageModel *)message {
    NSString *prefixToRemove = @"@";
    if ([username hasPrefix:prefixToRemove]) {
        username = [username substringFromIndex:[prefixToRemove length]];
    }
    
    [self.messageTextView resignFirstResponder];
    [self.secondaryTextField resignFirstResponder];
    [self keyboardWillHideWithHeight:0.0f];
    [self hideInputAccessoryView];
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
        [self showMentionLoadingView:YES];
        [TAPDataManager callAPIGetUserByUsername:username success:^(TAPUserModel *user) {
            //User found, send message
            [[TapUI sharedInstance] createRoomWithOtherUser:user success:^(TapUIChatViewController * _Nonnull chatViewController) {
                chatViewController.hidesBottomBarWhenPushed = YES;
                [[[TapUI sharedInstance] roomListViewController].navigationController pushViewController:chatViewController animated:YES];
            }];
            
            [self showMentionLoadingView:NO];
        } failure:^(NSError *error) {
           //User not found show error
            [self showMentionLoadingView:NO];
            [TAPUtil performBlock:^{
                NSString *errorMessageString = NSLocalizedStringFromTableInBundle(@"User not found", nil, [TAPUtil currentBundle], @"");
                [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"User Not Found" title:NSLocalizedStringFromTableInBundle(@"Failed", nil, [TAPUtil currentBundle], @"") detailInformation:errorMessageString leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
            } afterDelay:0.1f];
        }];
    }
}

- (void)showMentionAnchorView:(BOOL)show {
    if (show) {
        if (self.mentionAnchorBackgroundView.alpha != 1.0f) {
            if ([self.anchorMentionMessageDictionary count] > 0) {
                [UIView animateWithDuration:0.2f animations:^{
                    self.mentionAnchorBackgroundView.alpha = 1.0f;
                    self.mentionAnchorBadgeView.alpha = 1.0f;
                    self.mentionAnchorButton.alpha = 1.0f;
                }];
                [self checkAnchorMentionLabel];
            }
            else {
                [UIView animateWithDuration:0.2f animations:^{
                    self.mentionAnchorBackgroundView.alpha = 0.0f;
                    self.mentionAnchorBadgeView.alpha = 0.0f;
                    self.mentionAnchorButton.alpha = 0.0f;
                }];
            }
        }
    }
    else {
        if (self.mentionAnchorBackgroundView.alpha != 0.0f) {
            [UIView animateWithDuration:0.2f animations:^{
                self.mentionAnchorBackgroundView.alpha = 0.0f;
                self.mentionAnchorBadgeView.alpha = 0.0f;
                self.mentionAnchorButton.alpha = 0.0f;
            }];
        }
    }
}

//- (void)filterMentionListWithKeyword:(NSString *)keyword {
//    _filteredMentionListArray = [[NSMutableArray alloc] init];
//
//    if ([keyword length] == 0 || ![keyword hasPrefix:@"@"]) {
//        return;
//    }
//
//    if ([keyword hasPrefix:@"@"] && [keyword length] != 1) {
//        keyword = [keyword substringFromIndex:1];
//    }
//
//
//    if ([keyword isEqualToString:@"@"]) {
//        NSString *currentUserID = [TAPDataManager getActiveUser].userID;
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.userID != %@", currentUserID];
//        NSArray *resultArray = [self.currentRoom.participants filteredArrayUsingPredicate:predicate];
//        self.filteredMentionListArray = [resultArray mutableCopy];
//    }
//    else {
//
//        NSString *currentUserID = [TAPDataManager getActiveUser].userID;
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF.fullname contains[cd] %@ OR SELF.username contains[cd] %@) AND SELF.userID != %@",keyword, keyword, currentUserID];
//        NSArray *resultArray = [self.currentRoom.participants filteredArrayUsingPredicate:predicate];
//        self.filteredMentionListArray = [resultArray mutableCopy];
//    }
//
//    if ([self.filteredMentionListArray count] > 0) {
//        CGFloat tableViewHeight = 0.0f;
//        if ([self.filteredMentionListArray count] >= 4) {
//            tableViewHeight = 4 * 54.0f;
//        }
//        else {
//            tableViewHeight = [self.filteredMentionListArray count] * 54.0f;
//        }
//
//        self.mentionListTableViewHeightConstraint.constant = tableViewHeight + 10.0f; //10.0f for table view header height
//
//        self.mentionListTableView.clipsToBounds = YES;
//        self.mentionListTableView.layer.cornerRadius = 15.0f;
//        self.mentionListTableView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
//
//        self.mentionTableBackgroundView.clipsToBounds = YES;
//        self.mentionTableBackgroundView.layer.cornerRadius = 15.0f;
//        self.mentionTableBackgroundView.layer.shadowRadius = 20.0f;
//        self.mentionTableBackgroundView.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f].CGColor;
//        self.mentionTableBackgroundView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
//        self.mentionTableBackgroundView.layer.shadowOpacity = 1.0f;
//        self.mentionTableBackgroundView.layer.masksToBounds = NO;
//    }
//}

- (void)showMentionListView:(BOOL)show animated:(BOOL)animated {
    if (![[TapUI sharedInstance] isMentionUsernameEnabled]) {
        return;
    }
    if (show) {
        if (animated) {
            [UIView animateWithDuration:0.2f animations:^{
                self.mentionTableBackgroundView.alpha = 1.0f;
                self.mentionListTableView.alpha = 1.0f;
                [self.mentionListTableView setContentOffset:CGPointZero animated:YES];
            }];
        }
        else {
            self.mentionTableBackgroundView.alpha = 1.0f;
            self.mentionListTableView.alpha = 1.0f;
            [self.mentionListTableView setContentOffset:CGPointZero animated:YES];
        }
    }
    else {
        if (animated) {
            [UIView animateWithDuration:0.2f animations:^{
                self.mentionTableBackgroundView.alpha = 0.0f;
                self.mentionListTableView.alpha = 0.0f;
            }];
        }
        else {
            self.mentionTableBackgroundView.alpha = 0.0f;
            self.mentionListTableView.alpha = 0.0f;
        }
        _mentionLoopIndex = 0;
        _mentionCursorIndex = 0;
    }
    [self.mentionListTableView reloadData];
}

- (void)checkAndSearchUserMentionList:(NSString *)text isErasing:(BOOL)isErasing {
    if (![[TapUI sharedInstance] isMentionUsernameEnabled] || [self.participantListDictionary count] == 0) {
        [self showMentionListView:NO animated:YES];
        [self.mentionListTableView reloadData];
        return;
    }
    
    if (![text containsString:@"@"]) {
        // Return if text does not contain @
        [self showMentionListView:NO animated:YES];
        return;
    }
    
    NSInteger cursorIndex = [self.messageTextView.textView selectedRange].location + 1 - (isErasing * 2);
    NSInteger loopIndex = [self.messageTextView.textView selectedRange].location + 1 - (isErasing * 2);
    
    while (loopIndex > 0) {
        // Loop text from cursor index to the left
        loopIndex--;
        char c = [text characterAtIndex:loopIndex];
        if (c == ' ' || c == '\n') {
            // Found space before @, return
            [self showMentionListView:NO animated:YES];
            return;
        }
        if (c == '@') {
            // Found @, start searching user
            if (cursorIndex - loopIndex <= 1) {
//            if ([keyword length] == 0) {
                // Show all participants
                NSString *currentUserID = [TAPDataManager getActiveUser].userID;
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.userID != %@", currentUserID];
                NSArray *resultArray = [self.currentRoom.participants filteredArrayUsingPredicate:predicate];
                self.filteredMentionListArray = [resultArray mutableCopy];
            }
            else {
                // Search participants from keyword
                NSString *keyword = [[text substringWithRange:NSMakeRange(loopIndex + 1, cursorIndex - loopIndex - 1)] lowercaseString];
                NSString *currentUserID = [TAPDataManager getActiveUser].userID;
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(SELF.fullname contains[cd] %@ OR SELF.username contains[cd] %@) AND SELF.userID != %@",keyword, keyword, currentUserID];
                NSArray *resultArray = [self.currentRoom.participants filteredArrayUsingPredicate:predicate];
                self.filteredMentionListArray = [resultArray mutableCopy];
            }
            if ([self.filteredMentionListArray count] > 0) {
            [self showMentionListView:YES animated:YES];
                _mentionLoopIndex = loopIndex;
                _mentionCursorIndex = cursorIndex;
            }
            else {
                [self showMentionListView:NO animated:YES];
            }
            return;
        }
    }
    [self showMentionListView:NO animated:YES];
}

- (void)tapTalkUserMentionTappedWithRoom:(TAPRoomModel *)room
                                   message:(TAPMessageModel *)message
                            usernameString:(NSString *)username {
    //reject if deletedRoomView exist
    if (self.deletedRoomView.alpha == 1.0f || self.kickedGroupRoomBackgroundView.alpha == 1.0f) {
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
            [tapUIChatRoomDelegate tapTalkUserMentionTappedWithRoom:room mentionedUser:user isRoomParticipant:isParticipant message:message currentViewController:self currentShownNavigationController:self.navigationController];
            return;
        }
        
        //Show default open profile
        [TAPUtil performBlock:^{
            [self showTopFloatingIdentifierView:NO withType:TopFloatingIndicatorViewTypeUnreadMessage numberOfUnreadMessages:0 animated:YES];
        } afterDelay:1.0f];

        [self setKeyboardStateDefault];

        //CS NOTE - add resign first responder before every pushVC to handle keyboard height
        [self.messageTextView resignFirstResponder];
        [self.secondaryTextField resignFirstResponder];
        [self keyboardWillHideWithHeight:0.0f];
        [self hideInputAccessoryView];
        
        TAPProfileViewController *profileViewController = [[TAPProfileViewController alloc] init];
        profileViewController.room = self.currentRoom;
        profileViewController.user = user;
        profileViewController.delegate = self;
        profileViewController.tapProfileViewControllerType = TAPProfileViewControllerTypeGroupMemberProfile;
        [self.navigationController pushViewController:profileViewController animated:YES];
    }
    else {
        //User not found in participant
        //Check if user is exist
        id<TapUIChatRoomDelegate> tapUIChatRoomDelegate = [TapUI sharedInstance].chatRoomDelegate;
        if ([tapUIChatRoomDelegate respondsToSelector:@selector(tapTalkUserMentionTappedWithRoom:mentionedUser:isRoomParticipant:message:currentViewController:currentShownNavigationController:)]) {
            [self showMentionLoadingView:NO];
        }
        else {
            //Show default open profile
            [TAPUtil performBlock:^{
                [self showTopFloatingIdentifierView:NO withType:TopFloatingIndicatorViewTypeUnreadMessage numberOfUnreadMessages:0 animated:YES];
            } afterDelay:1.0f];

            [self setKeyboardStateDefault];

            //CS NOTE - add resign first responder before every pushVC to handle keyboard height
            [self.messageTextView resignFirstResponder];
            [self.secondaryTextField resignFirstResponder];
            [self keyboardWillHideWithHeight:0.0f];
            [self hideInputAccessoryView];
            
            [self showMentionLoadingView:YES];
        }
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
            
            [self showMentionLoadingView:NO];
        } failure:^(NSError *error) {
           //User not found show error
            [self showMentionLoadingView:NO];
            [TAPUtil performBlock:^{
                NSString *errorMessageString = NSLocalizedStringFromTableInBundle(@"User not found", nil, [TAPUtil currentBundle], @"");
                [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"User Not Found" title:NSLocalizedStringFromTableInBundle(@"Failed", nil, [TAPUtil currentBundle], @"") detailInformation:errorMessageString leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
            } afterDelay:0.1f];
        }];
    }
}

- (IBAction)mentionAnchorButtonDidTapped:(id)sender {
    TAPMessageModel *messageWithMention = [self.anchorMentionMessageArray firstObject];
    [self scrollToMessageAndLoadDataWithLocalID:messageWithMention.localID];
    
//    NSInteger numberOfPendingArray = [self.scrolledPendingMessageArray count];
//    if (numberOfPendingArray > 0) {
//        //Add pending message to messageArray (pending message has previously inserted in messageDictionary in didReceiveNewMessage)
//        [self.messageArray insertObjects:self.scrolledPendingMessageArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, numberOfPendingArray)]];
//
//        [self.scrolledPendingMessageArray removeAllObjects];
//        [self.tableView reloadData];
//    }
//
//    TAPMessageModel *obtainedMentionMessage = [self.scrolledPendingMentionArray firstObject];
//    NSInteger rowIndex = [self.messageArray indexOfObject:obtainedMentionMessage];
//
//    if (rowIndex != NSNotFound) {
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
//        [self.scrolledPendingMentionArray removeObjectAtIndex:0];
//    }
//
////    NSString *currentMesageLocalID = [self.anchorMentionMessageLocalIDArray firstObject];
////    currentMesageLocalID = [TAPUtil nullToEmptyString:currentMesageLocalID];
////
////    if (![currentMesageLocalID isEqualToString:@""]) {
////        [self scrollToMessageAndLoadDataWithLocalID:currentMesageLocalID];
////    }
}

#pragma mark Others
- (void)setChatViewControllerType:(TapUIChatViewControllerType)chatViewControllerType {
    _chatViewControllerType = chatViewControllerType;
    
    if (self.chatViewControllerType == TapUIChatViewControllerTypePeek) {
        //Hide accessory view when peek 3D touch
        self.inputMessageAccessoryView.alpha = 0.0f;
        self.dummyNavigationBarView.alpha = 1.0f;
        self.dummyNavigationBarTitleLabel.alpha = 1.0f;
    }
    else {
        self.inputMessageAccessoryView.alpha = 1.0f;
        self.dummyNavigationBarView.alpha = 0.0f;
        self.dummyNavigationBarTitleLabel.alpha = 0.0f;
    }
}

- (void)applicationWillEnterForegroundNotification:(NSNotification *)notification {
    if ([self.messageArray count] > 0 && self.minCreatedMessage != nil && [self.minCreatedMessage integerValue] != 0) {
        [self callAPIAfterAndUpdateUIAndScrollToTop:YES];
    }
}

- (void)reachabilityStatusChange:(NSNotification *)notification {
    if ([AFNetworkReachabilityManager sharedManager].reachable) {
        if (self.isNeedRefreshOnNetworkDown) {
            //Update data from API when network down and reconnect
            [self callAPIAfterAndUpdateUIAndScrollToTop:NO];
            
            _isNeedRefreshOnNetworkDown = NO;
        }
    }
    else {
        _isNeedRefreshOnNetworkDown = YES;
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)checkEmptyState {
    if ([self.messageArray count] == 0) {
        if (self.emptyView.alpha == 1.0f) {
            return;
        }
        
        //Show empty chat welcome message
        TAPUserModel *activeUser = [TAPDataManager getActiveUser];
        
        TAPRoomModel *room = [TAPChatManager sharedManager].activeRoom;
        NSString *roomName = room.name;
        roomName = [TAPUtil nullToEmptyString:roomName];
        
        NSString *otherUserRoleCode = self.otherUser.userRole.code;
        otherUserRoleCode = [TAPUtil nullToEmptyString:otherUserRoleCode];
        
        UIFont *emptyTitleLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontInfoLabelSubtitle];
        UIColor *emptyTitleLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorInfoLabelSubtitle];
        UIFont *emptyTitleLabelBoldFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontInfoLabelSubtitleBold];
        UIColor *emptyTitleLabelBoldColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorInfoLabelSubtitleBold];
        UIFont *emptyDescriptionLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontInfoLabelBody];
        UIColor *emptyDescriptionLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorInfoLabelBody];
        
        self.emptyTitleLabel.font = emptyTitleLabelFont;
        self.emptyTitleLabel.textColor = emptyTitleLabelColor;
        
        self.emptyDescriptionLabel.font = emptyDescriptionLabelFont;
        self.emptyDescriptionLabel.textColor = emptyDescriptionLabelColor;

        NSString *emptyTitleString;
        NSString *emptyDescriptionString;

        if (self.currentRoom.type == RoomTypePersonal) {
            //Personal
            NSString *emptyTitleInitialString = NSLocalizedStringFromTableInBundle(@"Start a conversation with ", nil, [TAPUtil currentBundle], @"");
            emptyTitleString = [NSString stringWithFormat:@"%@%@",emptyTitleInitialString, self.otherUser.fullname];

            NSString *emptyDescriptionInitialString = NSLocalizedStringFromTableInBundle(@"Say hi to ", nil, [TAPUtil currentBundle], @"");
            NSString *emptyDescriptionEndingString = NSLocalizedStringFromTableInBundle(@" and start a conversation", nil, [TAPUtil currentBundle], @"");
            emptyDescriptionString = [NSString stringWithFormat:@"%@%@%@",emptyDescriptionInitialString, self.otherUser.fullname, emptyDescriptionEndingString];
        }
        else {
            //Group or Channel
            NSString *emptyTitleInitialString = NSLocalizedStringFromTableInBundle(@"It seems to be quiet in ", nil, [TAPUtil currentBundle], @"");
            emptyTitleString = [NSString stringWithFormat:@"%@%@",emptyTitleInitialString, self.currentRoom.name];
            emptyDescriptionString = NSLocalizedStringFromTableInBundle(@"Say hi to the group and start the conversation", nil, [TAPUtil currentBundle], @"");
        }
        
        self.emptyTitleLabel.text = emptyTitleString;
        //set attributed string
        NSMutableDictionary *emptyTitleAttributesDictionary = [NSMutableDictionary dictionary];
        [emptyTitleAttributesDictionary setObject:emptyTitleLabelBoldFont forKey:NSFontAttributeName];
        [emptyTitleAttributesDictionary setObject:emptyTitleLabelBoldColor forKey:NSForegroundColorAttributeName];
        NSMutableAttributedString *emptyTitleAttributedString = [[NSMutableAttributedString alloc] initWithString:self.emptyTitleLabel.text];
        
        if(self.emptyTitleLabel.text != nil && ![self.emptyTitleLabel.text isEqualToString:@""]) {
            NSRange roomNameRange = [self.emptyTitleLabel.text rangeOfString:roomName];
            [emptyTitleAttributedString addAttributes:emptyTitleAttributesDictionary
                                                range:roomNameRange];
            self.emptyTitleLabel.attributedText = emptyTitleAttributedString;
        }
        
        self.emptyDescriptionLabel.text = emptyDescriptionString;
        
        
        NSString *senderImageURL = activeUser.imageURL.thumbnail;
        NSString *recipientImageURL = room.imageURL.thumbnail;
        if (senderImageURL == nil || [senderImageURL isEqualToString:@""]) {
            //No image found, show initial view
            self.senderInitialNameView.alpha = 1.0f;
            self.senderImageView.alpha = 0.0f;
            self.senderInitialNameView.backgroundColor = [[TAPStyleManager sharedManager] getRandomDefaultAvatarBackgroundColorWithName:activeUser.fullname];
            self.senderInitialNameLabel.text = [[TAPStyleManager sharedManager] getInitialsWithName:activeUser.fullname isGroup:NO];
        }
        else {
            self.senderInitialNameView.alpha = 0.0f;
            self.senderImageView.alpha = 1.0f;
            [self.senderImageView setImageWithURLString:senderImageURL];
        }
        
        if (recipientImageURL == nil || [recipientImageURL isEqualToString:@""]) {
            self.recipientInitialNameView.alpha = 1.0f;
            self.recipientImageView.alpha = 0.0f;

            BOOL isGroup = NO;
            if (self.currentRoom.type == RoomTypeGroup || self.currentRoom.type == RoomTypeTransaction) {
                isGroup = YES;
            }
            self.recipientInitialNameView.backgroundColor = [[TAPStyleManager sharedManager] getRandomDefaultAvatarBackgroundColorWithName:room.name];
            self.recipientInitialNameLabel.text = [[TAPStyleManager sharedManager] getInitialsWithName:room.name isGroup:isGroup];
        }
        else {
            self.recipientInitialNameView.alpha = 0.0f;
            self.recipientImageView.alpha = 1.0f;
            [self.recipientImageView setImageWithURLString:recipientImageURL];
        }
        
        self.senderImageView.layer.borderWidth = 4.0f;
        self.senderImageView.layer.borderColor = [TAPUtil getColor:@"F8F8F8"].CGColor;
        self.senderImageView.layer.cornerRadius = CGRectGetHeight(self.senderImageView.frame) / 2.0f;
        self.senderImageView.backgroundColor = [UIColor clearColor];
        self.senderImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        self.recipientImageView.layer.borderWidth = 4.0f;
        self.recipientImageView.layer.borderColor = [TAPUtil getColor:@"F8F8F8"].CGColor;
        self.recipientImageView.layer.cornerRadius = CGRectGetHeight(self.senderImageView.frame) / 2.0f;
        self.recipientImageView.backgroundColor = [UIColor clearColor];
        self.recipientImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        self.senderInitialNameView.layer.borderWidth = 4.0f;
        self.senderInitialNameView.layer.borderColor = [TAPUtil getColor:@"F8F8F8"].CGColor;
        self.senderInitialNameView.layer.cornerRadius = CGRectGetWidth(self.senderInitialNameView.frame) / 2.0f;
        self.senderInitialNameView.clipsToBounds = YES;

        UIFont *initialNameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontRoomAvatarLargeLabel];
        UIColor *initialNameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRoomAvatarLargeLabel];
        
        self.senderInitialNameLabel.textColor = initialNameLabelColor;
        self.senderInitialNameLabel.font = initialNameLabelFont;
        
        self.recipientInitialNameView.layer.borderWidth = 4.0f;
        self.recipientInitialNameView.layer.borderColor = [TAPUtil getColor:@"F8F8F8"].CGColor;
        self.recipientInitialNameView.layer.cornerRadius = CGRectGetWidth(self.recipientInitialNameView.frame) / 2.0f;
        self.recipientInitialNameView.clipsToBounds = YES;

        self.recipientInitialNameLabel.textColor = initialNameLabelColor;
        self.recipientInitialNameLabel.font = initialNameLabelFont;
        
        [UIView animateWithDuration:0.0f animations:^{
            self.emptyView.alpha = 1.0f;
        }];
    }
    else {
        if (self.emptyView.alpha == 0.0f) {
            return;
        }
        
        //hide empty chat
        [UIView animateWithDuration:0.2f animations:^{
            self.emptyView.alpha = 0.0f;
        }];
    }
}

- (void)popUpInfoTappedSingleButtonOrRightButtonWithIdentifier:(NSString *)popupIdentifier {
    [super popUpInfoTappedSingleButtonOrRightButtonWithIdentifier:popupIdentifier];
    
    if ([popupIdentifier isEqualToString:@"Error File Size Excedeed"]) {
        [self checkAndShowInputAccessoryView];
    }
    else if ([popupIdentifier isEqualToString:@"Error Delete Message"]) {
        [self checkAndShowInputAccessoryView];
    }
    else if ([popupIdentifier isEqualToString:@"Long Press Save Image"]) {
        //Do nothing because hide popup handled when we press the button
        [self checkAndShowInputAccessoryView];
    }
    else if ([popupIdentifier isEqualToString:@"Long Press Save Video"]) {
        //Do nothing because hide popup handled when we press the button
        [self checkAndShowInputAccessoryView];
    }
    else if ([popupIdentifier isEqualToString:@"User Not Found"]) {
        [self checkAndShowInputAccessoryView];
    }
}

- (IBAction)sendButtonDidTapped:(id)sender {
    if ([self.messageArray count] != 0) {
        [self chatAnchorButtonDidTapped:[[UIButton alloc] init]]; //Scroll table view to top with pending message logic
    }
    
    //Remove unread button
    [TAPUtil performBlock:^{
        [self showTopFloatingIdentifierView:NO withType:TopFloatingIndicatorViewTypeUnreadMessage numberOfUnreadMessages:0 animated:YES];
    } afterDelay:1.0f];
    
    //Hide unread message indicator top view
    if (self.topFloatingIndicatorViewType == TopFloatingIndicatorViewTypeUnreadMessage && self.topFloatingIndicatorView.alpha == 1.0f) {
        [TAPUtil performBlock:^{
            [self showTopFloatingIdentifierView:NO withType:TopFloatingIndicatorViewTypeUnreadMessage numberOfUnreadMessages:0 animated:YES];
        } afterDelay:1.0f];
    }
    
    //Remove highlighted message.
    NSInteger messageIndex = [self.messageArray indexOfObject:self.selectedMessage];
    NSIndexPath *selectedMessageIndexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
    id cell = [self.tableView cellForRowAtIndexPath:selectedMessageIndexPath];
    
    //Remove mention list
    [self showMentionListView:NO animated:YES];
    
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
        //animation
        if ([cell isKindOfClass:[TAPMyChatBubbleTableViewCell class]]) {
            TAPMyChatBubbleTableViewCell *myChatCell = cell;
            [myChatCell showStatusLabel:NO animated:YES updateStatusIcon:YES message:self.selectedMessage];
        }
        else if ([cell isKindOfClass:[TAPYourChatBubbleTableViewCell class]]) {
            TAPYourChatBubbleTableViewCell *yourChatCell = cell;
            [yourChatCell showStatusLabel:NO animated:YES];
        }
        [cell layoutIfNeeded];
    } completion:^(BOOL finished) {
        //completion
    }];
    
    //remove selectedMessage
    self.selectedMessage = [TAPMessageModel new];
    
    NSString *currentMessage = [TAPUtil nullToEmptyString:self.messageTextView.text];
    currentMessage = [currentMessage stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (![currentMessage isEqualToString:@""]) {
        [[TAPChatManager sharedManager] sendTextMessage:currentMessage];
        self.messageTextView.text = @"";
    }
    else {
        //Check if forward message exist, send forward message
        TAPChatManagerQuoteActionType quoteActionType =  [[TAPChatManager sharedManager] getQuoteActionTypeWithRoomID:self.currentRoom.roomID];
        
        if (quoteActionType == TAPChatManagerQuoteActionTypeForward) {
            [[TAPChatManager sharedManager] checkAndSendForwardedMessageWithRoom:self.currentRoom];
        }
        
        self.messageTextView.text = @"";
    }
    
            //DV Note - 12 Mar 2020
            //Done with debt because if called showInputAccessoryExtensionView, after send, table view can scroll to bottom, error tableview inset
        //    [self showInputAccessoryExtensionView:NO];
            
            _currentInputAccessoryExtensionHeight = 0.0f;
            _keyboardHeight = kInputMessageAccessoryViewHeight + self.safeAreaBottomPadding + self.currentInputAccessoryExtensionHeight;
            
            [UIView animateWithDuration:0.2f animations:^{
                self.inputAccessoryExtensionHeightConstraint.constant = 0.0f;
                [self.inputMessageAccessoryView layoutIfNeeded];
                [[[self.inputAccessoryView superview] superview] layoutIfNeeded];
            }];

            if (self.isInputAccessoryExtensionShowedFirstTimeOpen) {
                _initialKeyboardHeight = 0.0f;
                _isInputAccessoryExtensionShowedFirstTimeOpen = NO;
            }
            //END DV Note
    
    [self showInputAccessoryExtensionView:NO];
    [[TAPChatManager sharedManager] removeQuotedMessageObjectWithRoomID:self.currentRoom.roomID];
    
    if(self.tableView.contentOffset.y != 0 && [self.messageArray count] != 0) {
        //        Only scroll if table view is at bottom
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    self.lastNumberOfWordArrayForShowMention = 0;
    self.lastTypingWordArrayStartIndex = 0;
    self.lastTypingWordString = @"";
    [self.filteredMentionListArray removeAllObjects];
    
    [self checkEmptyState];
    [[TAPChatManager sharedManager] stopTyping];
}

- (void)backButtonDidTapped {
    [self.lastSeenTimer invalidate];
    _lastSeenTimer = nil;
    [self destroySequence];
    
    if ([self.delegate respondsToSelector:@selector(chatViewControllerDidPressCloseButton)]) {
        [self.delegate chatViewControllerDidPressCloseButton];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)profileImageDidTapped {
    
    //reject if deletedRoomView exist
    if (self.deletedRoomView.alpha == 1.0f || self.kickedGroupRoomBackgroundView.alpha == 1.0f) {
        return;
    }
    
    [TAPUtil performBlock:^{
        [self showTopFloatingIdentifierView:NO withType:TopFloatingIndicatorViewTypeUnreadMessage numberOfUnreadMessages:0 animated:YES];
    } afterDelay:1.0f];
    
    [self setKeyboardStateDefault];
    
    NSString *otherUserID = [[TAPChatManager sharedManager] getOtherUserIDWithRoomID:self.currentRoom.roomID];
    TAPUserModel *otherUser = [[TAPContactManager sharedManager] getUserWithUserID:otherUserID];
    //CS NOTE - add resign first responder before every pushVC to handle keyboard height
    [self.messageTextView resignFirstResponder];
    [self.secondaryTextField resignFirstResponder];
    [self keyboardWillHideWithHeight:0.0f];
    
    if (self.currentRoom.type == RoomTypePersonal) {
        id<TapUIChatRoomDelegate> tapUIChatRoomDelegate = [TapUI sharedInstance].chatRoomDelegate;
        if ([tapUIChatRoomDelegate respondsToSelector:@selector(tapTalkChatRoomProfileButtonTapped:otherUser:room:currentShownNavigationController:)]) {
            [tapUIChatRoomDelegate tapTalkChatRoomProfileButtonTapped:self otherUser:otherUser room:self.currentRoom currentShownNavigationController:self.navigationController];
        }
        else {
            TAPProfileViewController *profileViewController = [[TAPProfileViewController alloc] init];
            profileViewController.room = self.currentRoom;
            profileViewController.otherUserID = otherUser.userID;
            profileViewController.delegate = self;
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
            profileViewController.otherUserID = otherUser.userID;
            profileViewController.delegate = self;
            [self.navigationController pushViewController:profileViewController animated:YES];
        }
    }
}

- (void)openUserProfileFromGroupChatWithMessage:(TAPMessageModel *)tappedMessage {

    //reject if deletedRoomView exist
    if (self.deletedRoomView.alpha == 1.0f || self.kickedGroupRoomBackgroundView.alpha == 1.0f) {
        return;
    }
    
    //Client implement the delegate for handle tap profile user
    id<TapUIChatRoomDelegate> tapUIChatRoomDelegate = [TapUI sharedInstance].chatRoomDelegate;
    if ([tapUIChatRoomDelegate respondsToSelector:@selector(tapTalkGroupMemberAvatarTappedWithRoom:user:currentShownNavigationController:)]) {
        [tapUIChatRoomDelegate tapTalkGroupMemberAvatarTappedWithRoom:tappedMessage.room user:tappedMessage.user currentShownNavigationController:self.navigationController];
        return;
    }
    
    TAPUserModel *otherUser = tappedMessage.user;
    
    [TAPUtil performBlock:^{
        [self showTopFloatingIdentifierView:NO withType:TopFloatingIndicatorViewTypeUnreadMessage numberOfUnreadMessages:0 animated:YES];
    } afterDelay:1.0f];
    
    [self setKeyboardStateDefault];
    
    //CS NOTE - add resign first responder before every pushVC to handle keyboard height
    [self.messageTextView resignFirstResponder];
    [self.secondaryTextField resignFirstResponder];
    [self keyboardWillHideWithHeight:0.0f];
    
   if ([tapUIChatRoomDelegate respondsToSelector:@selector(tapTalkChatRoomProfileButtonTapped:otherUser:room:currentShownNavigationController:)]) {
       [tapUIChatRoomDelegate tapTalkChatRoomProfileButtonTapped:self otherUser:otherUser room:self.currentRoom currentShownNavigationController:self.navigationController];
   }
   else {
       TAPProfileViewController *profileViewController = [[TAPProfileViewController alloc] init];
       profileViewController.room = self.currentRoom;
       profileViewController.user = otherUser;
       profileViewController.delegate = self;
       profileViewController.tapProfileViewControllerType = TAPProfileViewControllerTypeGroupMemberProfile;
       [self.navigationController pushViewController:profileViewController animated:YES];
   }
}

- (IBAction)topFloatingIndicatorButtonDidTapped:(id)sender {
    if (self.isTopFloatingIndicatorLoading || self.topFloatingIndicatorViewType == TopFloatingIndicatorViewTypeLoading) {
        return;
    }
    
    _isTopFloatingIndicatorLoading = YES;
    if (self.topFloatingIndicatorViewType == TopFloatingIndicatorViewTypeUnreadMessage) {
        [self showTopFloatingIdentifierView:YES withType:TopFloatingIndicatorViewTypeLoading numberOfUnreadMessages:0 animated:NO];
        [self scrollToFirstUnreadMessage];
    }
}

- (IBAction)handleTapOnTableView:(UITapGestureRecognizer *)gestureRecognizer {
    [self.keyboardViewController setKeyboardHeight:0.0f];
    [UIView animateWithDuration:0.2f animations:^{
        self.secondaryTextField.inputView.frame = CGRectMake(CGRectGetMinX(self.secondaryTextField.inputView.frame), 0.0f, CGRectGetWidth(self.secondaryTextField.inputView.frame), CGRectGetHeight(self.secondaryTextField.inputView.frame));
    }];
    
    //set keyboard state to default
    [self setKeyboardStateDefault];
    
    [self.messageTextView resignFirstResponder];
    [self.secondaryTextField resignFirstResponder];
    [self keyboardWillHideWithHeight:0.0f];
    [self.view endEditing:YES];
    [self.view layoutIfNeeded];
}

- (IBAction)chatAnchorButtonDidTapped:(id)sender {
    NSInteger numberOfPendingArray = [self.scrolledPendingMessageArray count];
    
    if (numberOfPendingArray > 0) {
        //Add pending message to messageArray (pending message has previously inserted in messageDictionary in didReceiveNewMessage)
        [self.messageArray insertObjects:self.scrolledPendingMessageArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, numberOfPendingArray)]];
        
        [self.scrolledPendingMessageArray removeAllObjects];
        [self.tableView reloadData];
        
        //        //Uncommand to scroll to top unread message (and command scroll to index 0 below) - have some glitch if scrolled pending message height is bigger than current y offset
        //        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:numberOfPendingArray - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    else {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    [self clearAnchorMentionDictionary];
}

- (void)checkAnchorUnreadLabel {
    if ([self.anchorUnreadMessageArray count] <= 0) {
        if (self.chatAnchorBadgeView.alpha != 0.0f) {
            [UIView animateWithDuration:0.2f animations:^{
                self.chatAnchorBadgeView.alpha = 0.0f;
            }];
        }
        
        self.chatAnchorBadgeLabel.text = @"0";
    }
    else {
        if (self.chatAnchorBadgeView.alpha != 1.0f && self.chatAnchorBackgroundView.alpha == 1.0f) {
                        
            [UIView animateWithDuration:0.2f animations:^{
                self.chatAnchorBadgeView.alpha = 1.0f;
            }];
        }
        
        self.chatAnchorBadgeLabel.text = [NSString stringWithFormat:@"%li", [self.anchorUnreadMessageArray count]];
    }
}

- (void)checkAnchorMentionLabel {
    if ([self.anchorMentionMessageDictionary count] <= 0) {
        if (self.mentionAnchorBadgeView.alpha != 0.0f) {
            [UIView animateWithDuration:0.2f animations:^{
                self.mentionAnchorBadgeView.alpha = 0.0f;
            }];
        }
        
        self.mentionAnchorBadgeLabel.text = @"0";
    }
    else {
        if (self.mentionAnchorBadgeView.alpha != 1.0f && self.mentionAnchorBackgroundView.alpha == 1.0f) {
                        
            [UIView animateWithDuration:0.2f animations:^{
                self.mentionAnchorBadgeView.alpha = 1.0f;
            }];
        }
        
        self.mentionAnchorBadgeLabel.text = [NSString stringWithFormat:@"%li", [self.anchorMentionMessageDictionary count]];
    }
}

- (void)timerRefreshLastSeen {
    NSTimeInterval currentLastSeen = (double)self.onlineStatus.lastActive.doubleValue/1000.0f;
    [self updateLastSeenWithTimestamp:currentLastSeen];
}

- (void)updateLastSeenWithTimestamp:(NSTimeInterval)timestamp {
    
    if (self.currentRoom.type != RoomTypePersonal) {
        return;
    }
    
    NSDate *date = [NSDate date];
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    
    NSTimeInterval timeGap = timeInterval - timestamp;
    
    NSDateFormatter *midnightDateFormatter = [[NSDateFormatter alloc] init];
    midnightDateFormatter.dateFormat = @"dd-MMM-yyyy";
    NSString *midnightFormattedCreatedDate = [midnightDateFormatter stringFromDate:date];
    
    NSDate *todayMidnightDate = [midnightDateFormatter dateFromString:midnightFormattedCreatedDate];
    NSTimeInterval midnightTimeInterval = [todayMidnightDate timeIntervalSince1970];
    
    NSTimeInterval midnightTimeGap = timeInterval - midnightTimeInterval;
    
    NSString *lastSeenString = @"";
    
    [self isShowOnlineDotStatus:NO];
    
    if (self.onlineStatus.isOnline) {
        lastSeenString = NSLocalizedStringFromTableInBundle(@"Active now", nil, [TAPUtil currentBundle], @"");
        [self isShowOnlineDotStatus:YES];
    }
    else if (timestamp == 0) {
        lastSeenString = @"";
    }
    else if (timeGap <= midnightTimeGap) {
        if (timeGap < 60.0f) {
            //Set recently
            lastSeenString = NSLocalizedStringFromTableInBundle(@"Active recently", nil, [TAPUtil currentBundle], @"");
        }
        else if (timeGap < 3600.0f) {
            //Set minutes before
            NSInteger numberOfMinutes = floor(timeGap/60.0f);
            
            NSString *minuteString = NSLocalizedStringFromTableInBundle(@"minutes", nil, [TAPUtil currentBundle], @"");
            
            if (timeGap < 120.0f) {
                minuteString = NSLocalizedStringFromTableInBundle(@"minute", nil, [TAPUtil currentBundle], @"");
            }
        
            NSString *initialLastSeenAppendedString = NSLocalizedStringFromTableInBundle(@"Active ", nil, [TAPUtil currentBundle], @"");
            NSString *endingLastSeenAppendedString = NSLocalizedStringFromTableInBundle(@" ago", nil, [TAPUtil currentBundle], @"");
            lastSeenString = [NSString stringWithFormat:@"%@%li %@%@", initialLastSeenAppendedString, (long)numberOfMinutes, minuteString, endingLastSeenAppendedString];
        }
        else {
            //Set hour before
            NSInteger numberOfHours = round(timeGap/3600.0f);
            
            NSString *hourString = NSLocalizedStringFromTableInBundle(@"hours", nil, [TAPUtil currentBundle], @"");
            
            if (timeGap < 120.0f) {
                hourString = NSLocalizedStringFromTableInBundle(@"hour", nil, [TAPUtil currentBundle], @"");
            }
            
            NSString *initialLastSeenAppendedString = NSLocalizedStringFromTableInBundle(@"Active ", nil, [TAPUtil currentBundle], @"");
            NSString *endingLastSeenAppendedString = NSLocalizedStringFromTableInBundle(@" ago", nil, [TAPUtil currentBundle], @"");
            lastSeenString = [NSString stringWithFormat:@"%@%li %@%@", initialLastSeenAppendedString, (long)numberOfHours, hourString, endingLastSeenAppendedString];
        }
    }
    else if (timeGap <= 86400.0f + midnightTimeGap) {
        //Set yesterday
        lastSeenString = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Active yesterday", nil, [TAPUtil currentBundle], @"")];
    }
    else if (timeGap <= 86400.0f * 6 + midnightTimeGap) {
        //Set days ago
        
        NSInteger numberOfDays = floor(timeGap/86400.0f);
        
        if (numberOfDays == 0) {
            numberOfDays = 1;
        }
        
        NSString *dayString = NSLocalizedStringFromTableInBundle(@"days", nil, [TAPUtil currentBundle], @"");
        
        NSString *initialLastSeenAppendedString = NSLocalizedStringFromTableInBundle(@"Active ", nil, [TAPUtil currentBundle], @"");
        NSString *endingLastSeenAppendedString = NSLocalizedStringFromTableInBundle(@" ago", nil, [TAPUtil currentBundle], @"");
        lastSeenString = [NSString stringWithFormat:@"%@%li %@%@", initialLastSeenAppendedString, (long)numberOfDays, dayString, endingLastSeenAppendedString];
        
        if (timeGap <= 86400.0f || numberOfDays == 1) {
            lastSeenString = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Active yesterday", nil, [TAPUtil currentBundle], @"")];
        }
    }
    else if (timeGap <= 86400.0f*7 + midnightTimeGap) {
        //Set a week ago
        lastSeenString = NSLocalizedStringFromTableInBundle(@"Active a week ago", nil, [TAPUtil currentBundle], @"");
    }
    else {
        //Set date
        NSDate *lastLoginDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd MMM YYYY";
        NSString *formattedCreatedDate = [dateFormatter stringFromDate:lastLoginDate];
        
        NSString *headerString = NSLocalizedStringFromTableInBundle(@"Last active", nil, [TAPUtil currentBundle], @"");
        lastSeenString = [NSString stringWithFormat:@"%@ %@", headerString, formattedCreatedDate];
    }
    
    self.userStatusLabel.text = lastSeenString;
    [self.userStatusLabel sizeToFit];
    self.userStatusLabel.frame = CGRectMake(CGRectGetMinX(self.userStatusLabel.frame), CGRectGetMinY(self.userStatusLabel.frame), CGRectGetWidth(self.userStatusLabel.frame), 16.0f);
    CGFloat userStatusViewWidth = CGRectGetWidth(self.userStatusLabel.frame) + CGRectGetWidth(self.userStatusView.frame) + 4.0f;
    self.userDescriptionView.frame = CGRectMake(0.0f, CGRectGetMaxY(self.nameLabel.frame), userStatusViewWidth, 16.0f);
    self.userDescriptionView.center = CGPointMake(self.nameLabel.center.x, self.userDescriptionView.center.y);
}

- (void)isShowOnlineDotStatus:(BOOL)isShow {
    if (isShow) {
//        self.userStatusView.frame = CGRectMake(0.0f, (16.0f - 7.0f) / 2.0f + 1.6f, 7.0f, 7.0f);
        self.userStatusView.frame = CGRectMake(0.0f, (CGRectGetHeight(self.userStatusLabel.frame) - 7.0f) / 2.0f - 1.0f + 1.6f, 7.0f, 7.0f);
        self.userStatusView.alpha = 1.0f;
        self.userStatusLabel.frame = CGRectMake(CGRectGetMaxX(self.userStatusView.frame) + 4.0f, 0.0f, 0.0f, 16.0f);
    }
    else {
        self.userStatusView.frame = CGRectZero;
        self.userStatusView.alpha = 0.0f;
        self.userStatusLabel.frame = CGRectMake(0.0f, 0.0f, 0.0f, 16.0f);
    }
}

- (void)setAsTyping:(BOOL)typing {
    if(typing) {
        [self refreshTypingLabelState];
        self.userTypingView.alpha = 1.0f;
        self.userDescriptionView.alpha = 0.0f;
        [self performSelector:@selector(setAsTypingNoAfterDelay) withObject:nil afterDelay:15.0f];
    }
    else {
        self.userTypingView.alpha = 0.0f;
        self.userDescriptionView.alpha = 1.0f;
    }
}

- (void)setAsTypingNoAfterDelay {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setAsTypingNoAfterDelay) object:nil];
    self.userTypingView.alpha = 0.0f;
    self.userDescriptionView.alpha = 1.0f;
}

- (void)showLoadMoreMessageLoadingView:(BOOL)show
                              withType:(LoadMoreMessageViewType)type {
    
    if (show) {
        self.loadMoreMessageViewHeight = 20.0f;
        
        if (type == LoadMoreMessageViewTypeOlderMessage) {
            self.loadMoreMessageLoadingLabel.text = NSLocalizedStringFromTableInBundle(@"Loading Older Messages", nil, [TAPUtil currentBundle], @"");
        }
        else if (type == LoadMoreMessageViewTypeNewMessage) {
            self.loadMoreMessageLoadingLabel.text = NSLocalizedStringFromTableInBundle(@"Loading New Messages", nil, [TAPUtil currentBundle], @"");
        }
        
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
    
    [UIView animateWithDuration:0.2f animations:^{
        //change frame
        self.tableViewTopConstraint.constant = currentHeight - 50.0f;
        [self.view layoutIfNeeded];
    }];
}

- (void)showTopFloatingIdentifierView:(BOOL)show
                             withType:(TopFloatingIndicatorViewType)type
               numberOfUnreadMessages:(NSInteger)numberOfUnreadMessages
                             animated:(BOOL)animated {
    _topFloatingIndicatorViewType = type;
    _isShowingTopFloatingIdentifier = show;
    if (type == TopFloatingIndicatorViewTypeUnreadMessage) {
        if (numberOfUnreadMessages != 0) {
            NSString *unreadMessagesString = @"";
            if (numberOfUnreadMessages > 99) {
                unreadMessagesString = @"99+";
            }
            else {
                unreadMessagesString = [NSString stringWithFormat:@"%ld", (long)numberOfUnreadMessages];
            }
            
            self.topFloatingIndicatorLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"%@ unread messages", nil, [TAPUtil currentBundle], @""), unreadMessagesString];
            self.topFloatingIndicatorImageView.image = [UIImage imageNamed:@"TAPIconUnreadMessageTop" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
            self.topFloatingIndicatorImageView.image = [self.topFloatingIndicatorImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconChatRoomFloatingUnreadButton]];
        }
    }
    else if (type == TopFloatingIndicatorViewTypeLoading) {
        self.topFloatingIndicatorLabel.text = NSLocalizedStringFromTableInBundle(@"Loading", nil, [TAPUtil currentBundle], @"");
        self.topFloatingIndicatorImageView.image = [UIImage imageNamed:@"TAPIconLoaderProgress" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.topFloatingIndicatorImageView.image = [self.topFloatingIndicatorImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconLoadingProgressPrimary]];
    }
    
    CGSize labelSize = [self.topFloatingIndicatorLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, 16.0f)];
    self.topFloatingIndicatorWidthConstraint.constant = labelSize.width;
    
    if (animated) {
        if (show) {
            [UIView animateWithDuration:0.2f animations:^{
                self.topFloatingIndicatorView.alpha = 1.0f;
                
                if (type == TopFloatingIndicatorViewTypeLoading) {
                    //Remove Existing Animation
                    if ([self.topFloatingIndicatorImageView.layer animationForKey:@"SpinAnimation"] != nil) {
                        [self.topFloatingIndicatorImageView.layer removeAnimationForKey:@"SpinAnimation"];
                    }
                    //Add Animation
                    if ([self.topFloatingIndicatorImageView.layer animationForKey:@"SpinAnimation"] == nil) {
                        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
                        animation.fromValue = [NSNumber numberWithFloat:0.0f];
                        animation.toValue = [NSNumber numberWithFloat: 2 * M_PI];
                        animation.duration = 1.5f;
                        animation.repeatCount = INFINITY;
                        animation.removedOnCompletion = NO;
                        [self.topFloatingIndicatorImageView.layer addAnimation:animation forKey:@"SpinAnimation"];
                    }
                }
            }];
        }
        else {
            _isTopFloatingIndicatorLoading = NO;
            [UIView animateWithDuration:0.2f animations:^{
                self.topFloatingIndicatorView.alpha = 0.0f;
                
                if (type == TopFloatingIndicatorViewTypeLoading) {
                    //Remove Animation
                    if ([self.topFloatingIndicatorImageView.layer animationForKey:@"SpinAnimation"] != nil) {
                        [self.topFloatingIndicatorImageView.layer removeAnimationForKey:@"SpinAnimation"];
                    }
                }
            }];
        }
    }
    else {
        if (show) {
            self.topFloatingIndicatorView.alpha = 1.0f;
            
            if (type == TopFloatingIndicatorViewTypeLoading) {
                //Remove Existing Animation
                if ([self.topFloatingIndicatorImageView.layer animationForKey:@"SpinAnimation"] != nil) {
                    [self.topFloatingIndicatorImageView.layer removeAnimationForKey:@"SpinAnimation"];
                }
                //Add Animation
                if ([self.topFloatingIndicatorImageView.layer animationForKey:@"SpinAnimation"] == nil) {
                    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
                    animation.fromValue = [NSNumber numberWithFloat:0.0f];
                    animation.toValue = [NSNumber numberWithFloat: 2 * M_PI];
                    animation.duration = 1.5f;
                    animation.repeatCount = INFINITY;
                    animation.removedOnCompletion = NO;
                    [self.topFloatingIndicatorImageView.layer addAnimation:animation forKey:@"SpinAnimation"];
                }
            }
        }
        else {
            _isTopFloatingIndicatorLoading = NO;
            self.topFloatingIndicatorView.alpha = 0.0f;
            
            if (type == TopFloatingIndicatorViewTypeLoading) {
                //Remove Animation
                if ([self.topFloatingIndicatorImageView.layer animationForKey:@"SpinAnimation"] != nil) {
                    [self.topFloatingIndicatorImageView.layer removeAnimationForKey:@"SpinAnimation"];
                }
            }
        }
    }
}

- (void)checkAndRefreshOnlineStatus {
    if([[TAPChatManager sharedManager] checkShouldRefreshOnlineStatus]) {
        [self setAsTyping:NO];
        NSString *otherUserID = [[TAPChatManager sharedManager] getOtherUserIDWithRoomID:self.currentRoom.roomID];
        
        if (self.currentRoom.type == RoomTypePersonal) {
            [TAPDataManager callAPIGetUserByUserID:otherUserID success:^(TAPUserModel *user) {
                
                self.inputMessageAccessoryView.alpha = 1.0f;
                
                //Upsert User to Contact Manager
                [[TAPContactManager sharedManager] addContactWithUserModel:user saveToDatabase:NO saveActiveUser:YES];
                
                BOOL isTyping = [[TAPChatManager sharedManager] checkIsTypingWithRoomID:self.currentRoom.roomID];
                [self setAsTyping:isTyping];
                
                TAPOnlineStatusModel *onlineStatus = [TAPOnlineStatusModel new];
                onlineStatus.isOnline = user.isOnline;
                onlineStatus.lastActive = user.lastActivity;
                
                _onlineStatus = onlineStatus;
                
                NSTimeInterval currentLastSeen = (double)self.onlineStatus.lastActive.doubleValue/1000.0f;
                [self updateLastSeenWithTimestamp:currentLastSeen];
                
                //Used to check if need to show add to contact view or not
                _otherUser = user;
                _isOtherUserIsContact = user.isContact;
                [self checkAndSetupAddToContactsView];
                
            } failure:^(NSError *error) {
                if (error.code == 40401) {
                    //user not found
                    //hide textview
                    self.inputMessageAccessoryView.alpha = 0.0f;
                    [self showDeletedRoomView:YES isGroup:NO isGroupDeleted:NO];
                }
            }];
        }
        else {
            BOOL isTyping = [[TAPChatManager sharedManager] checkIsTypingWithRoomID:self.currentRoom.roomID];
            [self setAsTyping:isTyping];
            
            TAPRoomModel *room = [[TAPGroupManager sharedManager] getRoomWithRoomID:self.currentRoom.roomID];
            if (room != nil) {
                _currentRoom = room;
                self.participantListDictionary = [NSMutableDictionary dictionary];
                for (TAPUserModel *user in self.currentRoom.participants) {
                    [self.participantListDictionary setObject:user forKey:user.username];
                }
                [self refreshRoomStatusUIInfo];
            }
            
            [TAPDataManager callAPIGetRoomWithRoomID:self.currentRoom.roomID success:^(TAPRoomModel *room) {
                _currentRoom = room;
                self.participantListDictionary = [NSMutableDictionary dictionary];
                for (TAPUserModel *user in room.participants) {
                    [self.participantListDictionary setObject:user forKey:user.username];
                }
                [self refreshRoomStatusUIInfo];
            } failure:^(NSError *error) {
                if (error.code == 40401) {
                    //user not found
                    //hide textview
                    self.inputMessageAccessoryView.alpha = 0.0f;
                    [self showDeletedRoomView:YES isGroup:YES isGroupDeleted:YES];
                }
            }];
        }
    }
}

- (void)fetchUnreadMessagesDataWithSuccess:(void (^)(NSArray *unreadMessages))success
                                   failure:(void (^)(NSError *error))failure {
    [TAPDataManager getDatabaseUnreadMessagesInRoomWithRoomID:[TAPChatManager sharedManager].activeRoom.roomID
                                                 activeUserID:[TAPChatManager sharedManager].activeUser.userID
                                                      success:^(NSArray *unreadMessages) {
                                                          success(unreadMessages);
                                                      } failure:^(NSError *error) {
                                                          failure(error);
                                                      }];
}

- (void)scrollToFirstUnreadMessage {
    NSString *localID = self.unreadLocalID;
    localID = [TAPUtil nullToEmptyString:localID];
    if (![localID isEqualToString:@""]) {
        TAPMessageModel *currentMessage = [self.messageDictionary objectForKey:localID];
        NSArray *messageArray = [self.messageArray copy];
        NSInteger currentRowIndex = [messageArray indexOfObject:currentMessage];
        
        if (!currentMessage.isDeleted && !currentMessage.isHidden) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
        [self showTopFloatingIdentifierView:NO withType:TopFloatingIndicatorViewTypeLoading numberOfUnreadMessages:0 animated:YES];
    }
}

- (void)scrollToMessageAndLoadDataWithLocalID:(NSString *)localID {
    self.tappedMessageLocalID = localID;
    TAPMessageModel *currentMessage = [self.messageDictionary objectForKey:localID];
    if (currentMessage) {
        NSArray *messageArray = [self.messageArray copy];
        NSInteger currentRowIndex = [messageArray indexOfObject:currentMessage];
//        self.tappedMessageLocalID = @"";
        
        if (!currentMessage.isDeleted && !currentMessage.isHidden) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentRowIndex inSection:0];
            [TAPUtil performBlock:^{
                [self.tableView reloadData];
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
            } afterDelay:0.2f];
        }
        else {
            self.tappedMessageLocalID = @"";
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedStringFromTableInBundle(@"Could not find message.", nil, [TAPUtil currentBundle], @"") preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"OK", nil, [TAPUtil currentBundle], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];

            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        [TAPUtil performBlock:^{
             [self showTopFloatingIdentifierView:NO withType:TopFloatingIndicatorViewTypeLoading numberOfUnreadMessages:0 animated:YES];
        } afterDelay:0.2f];
       
    }
    else {
        if ([TAPUtil isEmptyString:self.tappedMessageLocalID]) {
            [self showTopFloatingIdentifierView:YES withType:TopFloatingIndicatorViewTypeLoading numberOfUnreadMessages:0 animated:YES];
        }
        
        [self retrieveExistingMessages];
    }
}
-(BOOL)checkIsRowVisibleWithRowIndex:(NSInteger)rowIndex {
    NSArray *indexes = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *index in indexes) {
        if (index.row == rowIndex) {
            return YES;
        }
    }
    return NO;
}

- (void)checkAndShowUnreadButton {
    if (!self.isUnreadButtonShown) {
        _isUnreadButtonShown = YES;
        [self performSelector:@selector(showUnreadButton) withObject:nil afterDelay:1.0f];
    }
}

- (void)showUnreadButton {
    if (self.numberOfUnreadMessages != 0) {
        //Show unread message view
        NSString *obtainedLocalID = self.unreadLocalID;
        TAPMessageModel *obtainedMessage = [self.messageDictionary objectForKey:obtainedLocalID];
        NSInteger unreadMessageIndex = [self.messageArray indexOfObject:obtainedMessage];
        if(NSNotFound != unreadMessageIndex) {
            NSInteger rowIndex = unreadMessageIndex + 1; // +1 because unread identifier cell is above earliest unread message
            BOOL isVisible = [self checkIsRowVisibleWithRowIndex:rowIndex];
            if (!isVisible) {
                //Show top floating unread identifier only if unread message bar is not visible
                [self showTopFloatingIdentifierView:YES withType:TopFloatingIndicatorViewTypeUnreadMessage numberOfUnreadMessages:self.numberOfUnreadMessages animated:NO];
            }
        }
        else {
            //Unread not found
            _isUnreadButtonShown = NO;
        }
    }
    else {
        //Unread not found
        _isUnreadButtonShown = NO;
    }
}

- (void)showLoadMessageCellLoading:(BOOL)show {
    if (show) {
        if (self.isLoadingOldMessageFromAPI || [self.messageArray count] == 0 || self.isShowingTopFloatingIdentifier) {
            return;
        }
        _lastLoadingCellRowPosition = [self.messageArray count];
        //insert cell at last row
        _isLoadingOldMessageFromAPI = YES;
        NSIndexPath *insertAtIndexPath = [NSIndexPath indexPathForRow:self.lastLoadingCellRowPosition inSection:0];
        [self.tableView performBatchUpdates:^{
            //changing beginUpdates and endUpdates with this because of deprecation
            [self.tableView insertRowsAtIndexPaths:@[insertAtIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        } completion:^(BOOL finished) {
        }];
    }
    else {
        if (!self.isLoadingOldMessageFromAPI || [self.messageArray count] == 0 || self.isShowingTopFloatingIdentifier) {
            return;
        }
        //remove cell at last row
        _isLoadingOldMessageFromAPI = NO;
        NSIndexPath *deleteAtIndexPath = [NSIndexPath indexPathForRow:self.lastLoadingCellRowPosition inSection:0];
        if (self.lastLoadingCellRowPosition >= [self.messageArray count]) {
            [self.tableView performBatchUpdates:^{
                //changing beginUpdates and endUpdates with this because of deprecation
                [self.tableView deleteRowsAtIndexPaths:@[deleteAtIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            } completion:^(BOOL finished) {
            }];
        }
    }
}

//Override completionSelector method of save image to gallery
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (error != nil) {
        if (status == PHAuthorizationStatusDenied) {
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
    else {
            [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeSuccessMessage popupIdentifier:@"Long Press Save Image"  title:NSLocalizedStringFromTableInBundle(@"Success", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"Image saved successfully", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
    }
}

//Override completionSelector method of save video to gallery
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (error != nil) {
        if (status == PHAuthorizationStatusDenied) {
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
    else {
        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeSuccessMessage popupIdentifier:@"Long Press Save Video"  title:NSLocalizedStringFromTableInBundle(@"Success", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"Video saved successfully", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
    }
}

- (void)showDeleteMessageActionWithMessageArray:(NSString *)deletedMessageIDArray {

    [self checkAndShowInputAccessoryView];
    //Temporary delete for everyone
    //Delete For Everyone
    [TAPDataManager callAPIDeleteMessageWithMessageIDs:deletedMessageIDArray roomID:[TAPChatManager sharedManager].activeRoom.roomID isDeletedForEveryone:YES success:^(NSArray *deletedMessageIDArray) {
        
    } failure:^(NSError *error) {
        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Delete Message"  title:NSLocalizedStringFromTableInBundle(@"Sorry", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"Failed to delete message, please try again.", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
    }];
    
    //DV Note - Uncomment this section later to show delete for me or everyone
    //    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    //    UIAlertAction *deleteForMeAction = [UIAlertAction
    //                                        actionWithTitle:@"Delete for Me"
    //                                        style:UIAlertActionStyleDestructive
    //                                        handler:^(UIAlertAction * action) {
    //                                            //Delete For Me
    //                                            [TAPDataManager callAPIDeleteMessageWithMessageIDs:deletedMessageIDArray roomID:[TAPChatManager sharedManager].activeRoom.roomID isDeletedForEveryone:NO success:^(NSArray *deletedMessageIDArray) {
    //
    //                                            } failure:^(NSError *error) {
    //                                                [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Delete Message"  title:NSLocalizedStringFromTableInBundle(@"Sorry", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"Failed to delete message, please try again.", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
    //                                            }];
    //                                        }];
    //
    //    UIAlertAction *deleteForEveryoneAction = [UIAlertAction
    //                                              actionWithTitle:@"Delete For Everyone"
    //                                              style:UIAlertActionStyleDestructive
    //                                              handler:^(UIAlertAction * action) {
    //                                                  //Delete For Everyone
    //                                                  [TAPDataManager callAPIDeleteMessageWithMessageIDs:deletedMessageIDArray roomID:[TAPChatManager sharedManager].activeRoom.roomID isDeletedForEveryone:YES success:^(NSArray *deletedMessageIDArray) {
    //                                                      NSLog(@"DELETE MESSAGE ID ARRAY: %@", [deletedMessageIDArray description]);
    //                                                  } failure:^(NSError *error) {
    //                                                      [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Delete Message"  title:NSLocalizedStringFromTableInBundle(@"Sorry", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"Failed to delete message, please try again.", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
    //
    //                                                  }];
    //                                              }];
    //
    //    UIAlertAction *cancelAction = [UIAlertAction
    //                                   actionWithTitle:@"Cancel"
    //                                   style:UIAlertActionStyleCancel
    //                                   handler:^(UIAlertAction * action) {
    //
    //                                   }];
    //    [cancelAction setValue:[TAPUtil getColor:TAP_COLOR_PRIMARY_COLOR_1] forKey:@"titleTextColor"];
    //
    //    [alertController addAction:deleteForMeAction];
    //    [alertController addAction:deleteForEveryoneAction];
    //    [alertController addAction:cancelAction];
    //
    //    [self presentViewController:alertController animated:YES completion:nil];
}

//DV NOTE - Uncomment this to use API download thumbnail image
//- (void)fetchImageDataWithMessage:(TAPMessageModel *)message {
//
//    [[TAPFileDownloadManager sharedManager] receiveImageDataWithMessage:message progress:^(CGFloat progress, CGFloat total, TAPMessageModel * _Nonnull receivedMessage) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            TAPRoomModel *currentRoom = [TAPChatManager sharedManager].activeRoom;
//            NSString *currentActiveRoomID = currentRoom.roomID;
//            currentActiveRoomID = [TAPUtil nullToEmptyString:currentActiveRoomID];
//
//            NSString *roomID = receivedMessage.room.roomID;
//            roomID = [TAPUtil nullToEmptyString:roomID];
//
//            NSString *localID = receivedMessage.localID;
//            localID = [TAPUtil nullToEmptyString:localID];
//
//            if (![roomID isEqualToString:currentActiveRoomID]) {
//                return;
//            }
//
//            TAPMessageModel *currentMessage = [self.messageDictionary objectForKey:localID];
//NSArray *messageArray = [self.messageArray copy];
//NSInteger currentRowIndex = [messageArray indexOfObject:currentMessage];//
//            TAPChatMessageType type = currentMessage.type;
//            if (type == TAPChatMessageTypeImage) {
//
//                if ([message.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
//                    //My Chat
//                    TAPMyImageBubbleTableViewCell *cell = (TAPMyImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
//                    [cell animateProgressUploadingImageWithProgress:progress total:total];
//                }
//                else {
//                    //Their Chat
//                    TAPYourImageBubbleTableViewCell *cell = (TAPYourImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
//                    [cell animateProgressDownloadingImageWithProgress:progress total:total];
//                }
//            }
//        });
//    } successThumbnailImage:^(UIImage * _Nonnull thumbnailImage, TAPMessageModel * _Nonnull receivedMessage) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            TAPRoomModel *currentRoom = [TAPChatManager sharedManager].activeRoom;
//            NSString *currentActiveRoomID = currentRoom.roomID;
//            currentActiveRoomID = [TAPUtil nullToEmptyString:currentActiveRoomID];
//
//            NSString *roomID = receivedMessage.room.roomID;
//            roomID = [TAPUtil nullToEmptyString:roomID];
//
//            NSString *localID = receivedMessage.localID;
//            localID = [TAPUtil nullToEmptyString:localID];
//
//            if (![roomID isEqualToString:currentActiveRoomID]) {
//                return;
//            }
//
//            TAPMessageModel *currentMessage = [self.messageDictionary objectForKey:localID];
//NSArray *messageArray = [self.messageArray copy];
//NSInteger currentRowIndex = [messageArray indexOfObject:currentMessage];//
//            TAPChatMessageType type = currentMessage.type;
//            if (type == TAPChatMessageTypeImage) {
//                if ([message.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
//                    //My Chat
//                    TAPMyImageBubbleTableViewCell *cell = (TAPMyImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
//                    if (thumbnailImage != nil) {
//                        [cell setThumbnailImage:thumbnailImage];
//                    }
//                    [cell animateFinishedUploadingImage];
//                }
//                else {
//                    //Their Chat
//                    TAPYourImageBubbleTableViewCell *cell = (TAPYourImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
//                    if (thumbnailImage != nil) {
//                        [cell setThumbnailImage:thumbnailImage];
//                    }
//                    [cell animateFinishedDownloadingImage];
//                }
//            }
//        });
//    } successFullImage:^(UIImage * _Nonnull fullImage, TAPMessageModel * _Nonnull receivedMessage) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            TAPRoomModel *currentRoom = [TAPChatManager sharedManager].activeRoom;
//            NSString *currentActiveRoomID = currentRoom.roomID;
//            currentActiveRoomID = [TAPUtil nullToEmptyString:currentActiveRoomID];
//
//            NSString *roomID = receivedMessage.room.roomID;
//            roomID = [TAPUtil nullToEmptyString:roomID];
//
//            NSString *localID = receivedMessage.localID;
//            localID = [TAPUtil nullToEmptyString:localID];
//
//            if (![roomID isEqualToString:currentActiveRoomID]) {
//                return;
//            }
//
//            TAPMessageModel *currentMessage = [self.messageDictionary objectForKey:localID];
//NSArray *messageArray = [self.messageArray copy];
//NSInteger currentRowIndex = [messageArray indexOfObject:currentMessage];//
//            TAPChatMessageType type = currentMessage.type;
//            if (type == TAPChatMessageTypeImage) {
//                if ([message.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
//                    //My Chat
//                    TAPMyImageBubbleTableViewCell *cell = (TAPMyImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
//                    if (fullImage != nil && [fullImage class] == [UIImage class]) {
//                        [cell setFullImage:fullImage];
//                    }
//                    [cell animateFinishedUploadingImage];
//                }
//                else {
//                    //Their Chat
//                    TAPYourImageBubbleTableViewCell *cell = (TAPYourImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
//                    if (fullImage != nil && [fullImage class] == [UIImage class]) {
//                        [cell setFullImage:fullImage];
//                    }
//                    [cell animateFinishedDownloadingImage];
//                }
//            }
//        });
//    } failureThumbnailImage:^(NSError * _Nonnull error, TAPMessageModel * _Nonnull receivedMessage) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            TAPRoomModel *currentRoom = [TAPChatManager sharedManager].activeRoom;
//            NSString *currentActiveRoomID = currentRoom.roomID;
//            currentActiveRoomID = [TAPUtil nullToEmptyString:currentActiveRoomID];
//
//            NSString *roomID = receivedMessage.room.roomID;
//            roomID = [TAPUtil nullToEmptyString:roomID];
//
//            NSString *localID = receivedMessage.localID;
//            localID = [TAPUtil nullToEmptyString:localID];
//
//            if (![roomID isEqualToString:currentActiveRoomID]) {
//                return;
//            }
//
//            TAPMessageModel *currentMessage = [self.messageDictionary objectForKey:localID];
//            NSInteger currentRowIndex = [self.messageArray indexOfObject:currentMessage];
//
//            TAPChatMessageType type = currentMessage.type;
//            if (type == TAPChatMessageTypeImage) {
//
//                if ([message.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
//                    //My Chat
//                    TAPMyImageBubbleTableViewCell *cell = (TAPMyImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
//                    [cell animateFailedUploadingImage];
//                }
//                else {
//                    //Their Chat
//                    TAPYourImageBubbleTableViewCell *cell = (TAPYourImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
//                    [cell animateFailedDownloadingImage];
//                }
//            }
//        });
//    } failureFullImage:^(NSError * _Nonnull error, TAPMessageModel * _Nonnull receivedMessage) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            TAPRoomModel *currentRoom = [TAPChatManager sharedManager].activeRoom;
//            NSString *currentActiveRoomID = currentRoom.roomID;
//            currentActiveRoomID = [TAPUtil nullToEmptyString:currentActiveRoomID];
//
//            NSString *roomID = receivedMessage.room.roomID;
//            roomID = [TAPUtil nullToEmptyString:roomID];
//
//            NSString *localID = receivedMessage.localID;
//            localID = [TAPUtil nullToEmptyString:localID];
//
//            if (![roomID isEqualToString:currentActiveRoomID]) {
//                return;
//            }
//
//            TAPMessageModel *currentMessage = [self.messageDictionary objectForKey:localID];
//            NSInteger currentRowIndex = [self.messageArray indexOfObject:currentMessage];
//
//            TAPChatMessageType type = currentMessage.type;
//            if (type == TAPChatMessageTypeImage) {
//
//                if ([message.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
//                    //My Chat
//                    TAPMyImageBubbleTableViewCell *cell = (TAPMyImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
//                    [cell animateFailedUploadingImage];
//                }
//                else {
//                    //Their Chat
//                    TAPYourImageBubbleTableViewCell *cell = (TAPYourImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
//                    [cell animateFailedDownloadingImage];
//                }
//            }
//        });
//    }];
//}
//END DV NOTE

- (void)refreshRoomStatusUIInfo {
    TAPRoomModel *room = self.currentRoom;
    self.nameLabel.text = room.name;
    
    NSString *profileImageURL = room.imageURL.thumbnail;
    if (profileImageURL == nil || [profileImageURL isEqualToString:@""]) {
        BOOL isGroup = NO;
        if (self.currentRoom.type == RoomTypeGroup || self.currentRoom.type == RoomTypeTransaction) {
            isGroup = YES;
        }
        self.rightBarInitialNameView.alpha = 1.0f;
        self.rightBarImageView.alpha = 0.0f;
        self.rightBarInitialNameView.backgroundColor = [[TAPStyleManager sharedManager] getRandomDefaultAvatarBackgroundColorWithName:room.name];
        self.rightBarInitialNameLabel.text = [[TAPStyleManager sharedManager] getInitialsWithName:room.name isGroup:isGroup];
    }
    else {
        self.rightBarInitialNameView.alpha = 0.0f;
        self.rightBarImageView.alpha = 1.0f;
        [self.rightBarImageView setImageWithURLString:profileImageURL];
    }
    
    self.userStatusLabel.text = [NSString stringWithFormat:@"%ld Members", [self.currentRoom.participants count]];
    if ([self.currentRoom.participants count] == 0) {
        self.userStatusLabel.text = @"";
    }
    [self.userStatusLabel sizeToFit];
    self.userStatusLabel.frame = CGRectMake(CGRectGetMinX(self.userStatusLabel.frame), CGRectGetMinY(self.userStatusLabel.frame), CGRectGetWidth(self.userStatusLabel.frame), 16.0f);
    CGFloat userStatusViewWidth = CGRectGetWidth(self.userStatusLabel.frame) + CGRectGetWidth(self.userStatusView.frame) + 4.0f;
    self.userDescriptionView.frame = CGRectMake(0.0f, CGRectGetMaxY(self.nameLabel.frame), userStatusViewWidth, 16.0f);
    self.userDescriptionView.center = CGPointMake(self.nameLabel.center.x, self.userDescriptionView.center.y);
}

- (void)refreshTypingLabelState {
    if (self.currentRoom.type == RoomTypePersonal) {
        self.typingLabel.text = NSLocalizedStringFromTableInBundle(@"typing", nil, [TAPUtil currentBundle], @"");
    }
    else {
        NSDictionary *typingUserDictionary = [[TAPChatManager sharedManager] getTypingUsersWithRoomID:self.currentRoom.roomID];
        if ([typingUserDictionary count] == 0) {
            [self setAsTyping:NO];
        }
        else if ([typingUserDictionary count] == 1) {
            NSArray *values = [typingUserDictionary allValues];
            TAPUserModel *user = [values firstObject];
            NSString *fullName = user.fullname;
            NSArray *eachWordArray = [fullName componentsSeparatedByString:@" "];
            NSString *firstName = [eachWordArray objectAtIndex:0];
            self.typingLabel.text = [NSString stringWithFormat:@"%@ is typing", firstName];
        }
        else if ([typingUserDictionary count] > 1){
            self.typingLabel.text = [NSString stringWithFormat:@"%ld people are typing", [typingUserDictionary count]];
        }
    }
    [self.typingLabel sizeToFit];
    CGFloat typingLabelWidth = CGRectGetWidth(self.typingLabel.frame);
    if (typingLabelWidth > CGRectGetWidth([UIScreen mainScreen].bounds) - 64.0f - 64.0f) {
        typingLabelWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - 64.0f - 64.0f;
    }
    self.typingLabel.frame = CGRectMake(20.0f, 0.0f, CGRectGetWidth(self.typingLabel.frame), 16.0f);
    
    self.userTypingView.frame = CGRectMake(CGRectGetMinX(self.userTypingView.frame), CGRectGetMinY(self.userTypingView.frame), CGRectGetMaxX(self.typingLabel.frame), CGRectGetHeight(self.userTypingView.frame));
    self.userTypingView.center = CGPointMake(self.nameLabel.center.x, self.userTypingView.center.y);
}

- (void)setDeleteRoomButtonAsLoading:(BOOL)loading animated:(BOOL)animated {
    if (loading) {
        
        self.navigationItem.leftBarButtonItem.enabled = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
        
        if (animated) {
            [UIView animateWithDuration:0.2f animations:^{
                self.deleteRoomButtonLabel.alpha = 0.0f;
                self.deleteRoomButtonIconImageView.alpha = 0.0f;
                self.deleteRoomButton.userInteractionEnabled = NO;
                
                self.deleteRoomButtonLoadingImageView.alpha = 1.0f;
            }];
            
            //ADD ANIMATION
            if ([self.deleteRoomButtonLoadingImageView.layer animationForKey:@"SpinAnimation"] == nil) {
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
                animation.fromValue = [NSNumber numberWithFloat:0.0f];
                animation.toValue = [NSNumber numberWithFloat:(2*M_PI)];
                animation.duration = 1.5f;
                animation.repeatCount = INFINITY;
                animation.cumulative = YES;
                animation.removedOnCompletion = NO;
                [self.deleteRoomButtonLoadingImageView.layer addAnimation:animation forKey:@"SpinAnimation"];
            }
        }
        else {
            self.deleteRoomButtonLabel.alpha = 0.0f;
            self.deleteRoomButtonIconImageView.alpha = 0.0f;
            self.deleteRoomButton.userInteractionEnabled = NO;
            
            self.deleteRoomButtonLoadingImageView.alpha = 1.0f;
            
            //ADD ANIMATION
            if ([self.deleteRoomButtonLoadingImageView.layer animationForKey:@"SpinAnimation"] == nil) {
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
                animation.fromValue = [NSNumber numberWithFloat:0.0f];
                animation.toValue = [NSNumber numberWithFloat:(2*M_PI)];
                animation.duration = 1.5f;
                animation.repeatCount = INFINITY;
                animation.cumulative = YES;
                animation.removedOnCompletion = NO;
                [self.deleteRoomButtonLoadingImageView.layer addAnimation:animation forKey:@"SpinAnimation"];
            }
        }
    }
    else {
        
        self.navigationItem.leftBarButtonItem.enabled = YES;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
        
        if (animated) {
            [UIView animateWithDuration:0.2f animations:^{
                self.deleteRoomButtonLabel.alpha = 1.0f;
                self.deleteRoomButtonIconImageView.alpha = 1.0f;
                self.deleteRoomButton.userInteractionEnabled = YES;
                
                self.deleteRoomButtonLoadingImageView.alpha = 0.0f;
            }];
            
            //REMOVE ANIMATION
            if ([self.deleteRoomButtonLoadingImageView.layer animationForKey:@"SpinAnimation"] != nil) {
                [self.deleteRoomButtonLoadingImageView.layer removeAnimationForKey:@"SpinAnimation"];
            }
        }
        else {
            self.deleteRoomButtonLabel.alpha = 1.0f;
            self.deleteRoomButtonIconImageView.alpha = 1.0f;
            self.deleteRoomButton.userInteractionEnabled = YES;
            
            self.deleteRoomButtonLoadingImageView.alpha = 0.0f;
            
            //REMOVE ANIMATION
            if ([self.deleteRoomButtonLoadingImageView.layer animationForKey:@"SpinAnimation"] != nil) {
                [self.deleteRoomButtonLoadingImageView.layer removeAnimationForKey:@"SpinAnimation"];
            }
        }
    }
}

- (IBAction)deleteGroupButtonDidTapped:(id)sender {
    //add sequence to delete message and physical files
    [self setDeleteRoomButtonAsLoading:YES animated:YES];
    [TAPDataManager deleteAllMessageAndPhysicalFilesInRoomWithRoomID:self.currentRoom.roomID success:^{
        
        if ([self.delegate respondsToSelector:@selector(chatViewControllerDidLeaveOrDeleteGroupWithRoom:)]) {
            [self.delegate chatViewControllerDidLeaveOrDeleteGroupWithRoom:self.currentRoom];
        }
        
        //Throw view to room list
        [TAPUtil performBlock:^{
            [self setDeleteRoomButtonAsLoading:NO animated:YES];
            [self.navigationController popToRootViewControllerAnimated:YES];
        } afterDelay:1.2f];
        
    } failure:^(NSError *error) {
        [self setDeleteRoomButtonAsLoading:NO animated:YES];
        NSString *errorMessage = [error.userInfo objectForKey:@"message"];
        errorMessage = [TAPUtil nullToEmptyString:errorMessage];
        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Delete Group Manually" title:NSLocalizedStringFromTableInBundle(@"Failed", nil, [TAPUtil currentBundle], @"") detailInformation:errorMessage leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
    }];
}

- (void)showTapTalkMessageComposerView {
    [self checkAndShowInputAccessoryView];
}

- (void)hideTapTalkMessageComposerView {
    [self.view endEditing:YES];
    [self hideInputAccessoryView];
}

- (void)checkAndShowRoomViewState {
    //check if last message is deleted room
    TAPMessageModel *lastMessage = [self.messageArray firstObject];
    
    if (lastMessage.room.isLocked) {
        [self showInputAccessoryExtensionView:NO];
        [[TAPChatManager sharedManager] removeQuotedMessageObjectWithRoomID:self.currentRoom.roomID];
        [self.messageTextView setText:@""];
        [self hideInputAccessoryView];
    }
    else {
        if (lastMessage.room.type == RoomTypePersonal && lastMessage.room.isDeleted) {
            [self.view endEditing:YES];
            [self showDeletedRoomView:YES isGroup:NO isGroupDeleted:NO];
        }
        else if (lastMessage.type == TAPChatMessageTypeSystemMessage && [lastMessage.action isEqualToString:@"room/removeParticipant"] && [lastMessage.target.targetID isEqualToString:[TAPDataManager getActiveUser].userID]) {
            //Check if system message with action remove participant and target user is current user
            //show deleted chat room view
            [self.view endEditing:YES];
            [self showDeletedRoomView:YES isGroup:YES isGroupDeleted:NO];
        }
        else if (lastMessage.type == TAPChatMessageTypeSystemMessage && [lastMessage.action isEqualToString:@"room/delete"]) {
            [self.view endEditing:YES];
            if (lastMessage.room.type == RoomTypePersonal) {
                [self showDeletedRoomView:YES isGroup:NO isGroupDeleted:NO];
            }
            else if (lastMessage.room.type == RoomTypeGroup || lastMessage.room.type == RoomTypeTransaction) {
                [self showDeletedRoomView:YES isGroup:YES isGroupDeleted:YES];
            }
        }
        else if (lastMessage.type == TAPChatMessageTypeSystemMessage && [lastMessage.action isEqualToString:@"room/leave"] && [lastMessage.user.userID isEqualToString:[TAPDataManager getActiveUser].userID]) {
            [self.view endEditing:YES];
            [self showDeletedRoomView:YES isGroup:NO isGroupDeleted:NO];
        }
        else {
            [self showInputAccessoryView];
        }
    }
}

//Add to Contacts View
- (IBAction)blockUserButtonDidTapped:(id)sender {
    //DV TODO - Add block user method here
}

- (IBAction)addContactButtonDidTapped:(id)sender {
    [TAPDataManager callAPIAddContactWithUserID:self.otherUser.userID success:^(NSString *message, TAPUserModel *user) {
        NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
        [dataDictionary setObject:[NSNumber numberWithBool:YES] forKey:self.currentRoom.roomID];
        [[NSUserDefaults standardUserDefaults] setSecureObject:dataDictionary forKey:TAP_PREFS_USER_IGNORE_ADD_CONTACT_POPUP_DICTIONARY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.addToContactsViewHeightConstraint.constant = 0.0f;
        [UIView animateWithDuration:0.2f animations:^{
            self.addToContactContainerView.alpha = 0.0f;
        }];
    } failure:^(NSError *error) {
#ifdef DEBUG
        NSLog(@"%@", error);
#endif
        self.addToContactsViewHeightConstraint.constant = 0.0f;
        [UIView animateWithDuration:0.2f animations:^{
            self.addToContactContainerView.alpha = 0.0f;
        }];
    }];
}

- (IBAction)closeAddContactButtonDidTapped:(id)sender {
    NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
    [dataDictionary setObject:[NSNumber numberWithBool:YES] forKey:self.currentRoom.roomID];
    [[NSUserDefaults standardUserDefaults] setSecureObject:dataDictionary forKey:TAP_PREFS_USER_IGNORE_ADD_CONTACT_POPUP_DICTIONARY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.addToContactsViewHeightConstraint.constant = 0.0f;
    [UIView animateWithDuration:0.2f animations:^{
        self.addToContactContainerView.alpha = 0.0f;
    }];
}

- (void)checkUpdatedUserProfileWithMessage:(TAPMessageModel *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (message.type == TAPChatMessageTypeSystemMessage && ([message.action isEqualToString:@"user/update"] || [message.action isEqualToString:@"room/update"])) {
             TAPRoomModel *room = [TAPChatManager sharedManager].activeRoom;
             NSString *updatedImageURLString = message.room.imageURL.thumbnail;
             NSString *currentImageURLString = room.imageURL.thumbnail;
             if (![updatedImageURLString isEqualToString:currentImageURLString]) {
                 if (updatedImageURLString == nil || [updatedImageURLString isEqualToString:@""]) {
                     BOOL isGroup = NO;
                     if (message.room.type == RoomTypeGroup || message.room.type == RoomTypeTransaction) {
                         isGroup = YES;
                     }
                     
                     self.rightBarInitialNameView.alpha = 1.0f;
                     self.rightBarImageView.alpha = 0.0f;
                     self.rightBarInitialNameView.backgroundColor = [[TAPStyleManager sharedManager] getRandomDefaultAvatarBackgroundColorWithName:message.room.name];
                     self.rightBarInitialNameLabel.text = [[TAPStyleManager sharedManager] getInitialsWithName:message.room.name isGroup:isGroup];
                 }
                 else {
                     self.rightBarInitialNameView.alpha = 0.0f;
                     self.rightBarImageView.alpha = 1.0f;
                     [self.rightBarImageView setImageWithURLString:updatedImageURLString];
                 }
                 
                 self.nameLabel.text = message.room.name;
             }
         }
    });
}

- (void)processSwipeToReplyWithMessage:(TAPMessageModel *)message {
    if (self.otherUser == nil && self.currentRoom.type == RoomTypePersonal) {
           return;
    }
    
    if (message.type == TAPChatMessageTypeText || message.type == TAPChatMessageTypeLocation) {
        //Type Text and Location
        [self showInputAccessoryExtensionView:NO];
        [self setInputAccessoryExtensionType:inputAccessoryExtensionTypeReplyMessage];
        [self setReplyMessageWithMessage:message];
        [self showInputAccessoryExtensionView:YES];
           
        TAPMessageModel *quotedMessageModel = [message copy];
        [[TAPChatManager sharedManager] saveToQuotedMessage:message userInfo:nil roomID:self.currentRoom.roomID];
    }
    else if (message.type == TAPChatMessageTypeFile) {
        //Type File
        TAPMessageModel *quotedMessageModel = [message copy];

        [self showInputAccessoryExtensionView:NO];
        [self setInputAccessoryExtensionType:inputAccessoryExtensionTypeQuote];
        [self showInputAccessoryExtensionView:YES];
           
        NSString *fileName = [quotedMessageModel.data objectForKey:@"fileName"];
        fileName = [TAPUtil nullToEmptyString:fileName];
        
        NSString *fileExtension  = [[fileName pathExtension] uppercaseString];
        fileName = [fileName stringByDeletingPathExtension];
           
        if ([fileExtension isEqualToString:@""]) {
           fileExtension = [quotedMessageModel.data objectForKey:@"mediaType"];
           fileExtension = [TAPUtil nullToEmptyString:fileExtension];
           fileExtension = [fileExtension lastPathComponent];
           fileExtension = [fileExtension uppercaseString];
        }
        
        NSString *fileSize = [NSByteCountFormatter stringFromByteCount:[[quotedMessageModel.data objectForKey:@"size"] integerValue] countStyle:NSByteCountFormatterCountStyleBinary];
           
        //convert to quote model
        TAPQuoteModel *quote = [TAPQuoteModel constructFromMessageModel:quotedMessageModel];
        [self setQuoteWithQuote:quote userID:quotedMessageModel.user.userID];
           
       quotedMessageModel.quote = quote;
       
       [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessageModel userInfo:nil roomID:self.currentRoom.roomID];
    }
    else if (message.type == TAPChatMessageTypeImage || message.type == TAPChatMessageTypeVideo) {
        //Type Video and Image
        TAPMessageModel *quotedMessageModel = [message copy];
        
        [self showInputAccessoryExtensionView:NO];
        [self setInputAccessoryExtensionType:inputAccessoryExtensionTypeQuote];
        [self showInputAccessoryExtensionView:YES];
        
        //convert to quote model
        TAPQuoteModel *quote = [TAPQuoteModel constructFromMessageModel:quotedMessageModel];
        [self setQuoteWithQuote:quote userID:quotedMessageModel.user.userID];
        
        quotedMessageModel.quote = quote;
        
        [[TAPChatManager sharedManager] saveToQuotedMessage:quotedMessageModel userInfo:nil roomID:self.currentRoom.roomID];
    }
    
    //DV Note
    //Add another type here for later
}

@end

