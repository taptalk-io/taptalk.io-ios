//
//  TAPChatViewController.m
//  TapTalk
//
//  Created by Dominic Vedericho on 10/08/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPChatViewController.h"

#import <AFNetworking/AFNetworking.h>
#import <Photos/Photos.h>

#import "TAPMyChatBubbleTableViewCell.h"
#import "TAPYourChatBubbleTableViewCell.h"
#import "TAPMyImageBubbleTableViewCell.h"
#import "TAPYourImageBubbleTableViewCell.h"
#import "TAPConnectionStatusViewController.h"
#import "TAPKeyboardViewController.h"
#import "TAPProfileViewController.h"
#import "TAPImagePreviewViewController.h"
#import "TAPPhotoAlbumListViewController.h"

#import "TAPGradientView.h"
#import "TAPCustomAccessoryView.h"

#import "TAPProductListBubbleTableViewCell.h" //DV Temp
#import "TAPOrderCardBubbleTableViewCell.h" //CS Temp

#import "TAPQuoteModel.h"

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

@interface TAPChatViewController () <UIGestureRecognizerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, TAPChatManagerDelegate, TAPGrowingTextViewDelegate, TAPMyChatBubbleTableViewCellDelegate, TAPYourChatBubbleTableViewCellDelegate, TAPConnectionStatusViewControllerDelegate, TAPKeyboardViewControllerDelegate, UIImagePickerControllerDelegate, TAPImagePreviewViewControllerDelegate, TAPPhotoAlbumListViewControllerDelegate, TAPMyImageBubbleTableViewCellDelegate>

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *messageViewHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *messageViewLeftConstraint;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet UIButton *keyboardOptionButton;
@property (strong, nonatomic) IBOutlet UIView *textViewBorderView;
@property (strong, nonatomic) IBOutlet TAPGrowingTextView *messageTextView;
@property (strong, nonatomic) IBOutlet UITextField *secondaryTextField;
@property (strong, nonatomic) IBOutlet UIView *emptyView;
@property (strong, nonatomic) IBOutlet TAPCustomAccessoryView *inputMessageAccessoryView;
@property (strong, nonatomic) IBOutlet UILabel *emptyTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *emptyDescriptionLabel;
@property (strong, nonatomic) IBOutlet TAPImageView *senderImageView;
@property (strong, nonatomic) IBOutlet TAPImageView *recipientImageView;

@property (strong, nonatomic) UIView *titleView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIView *userDescriptionView;
@property (strong, nonatomic) UIView *userStatusView;
@property (strong, nonatomic) UILabel *userStatusLabel;
@property (strong, nonatomic) NSTimer *lastSeenTimer;
@property (strong, nonatomic) UIView *userTypingView;

@property (strong, nonatomic) TAPConnectionStatusViewController *connectionStatusViewController;
@property (strong, nonatomic) TAPKeyboardViewController *keyboardViewController;

@property (strong, nonatomic) NSMutableArray *messageArray;
@property (strong, nonatomic) NSMutableDictionary *messageDictionary;
@property (strong, nonatomic) TAPMessageModel *selectedMessage;
@property (strong, nonatomic) TAPOnlineStatusModel *onlineStatus;

@property (strong, nonatomic) NSNumber *minCreatedMessage;
@property (strong, nonatomic) NSNumber *loadedMaxCreated;

@property (nonatomic) CGFloat messageTextViewHeight;
@property (nonatomic) CGFloat safeAreaBottomPadding;
@property (nonatomic) CGFloat keyboardHeight;
@property (nonatomic) CGFloat initialKeyboardHeight;
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

@property (nonatomic) CGFloat connectionStatusHeight;

@property (strong, nonatomic) IBOutlet UIButton *chatAnchorButton;
@property (strong, nonatomic) IBOutlet TAPGradientView *chatAnchorBadgeView;
@property (strong, nonatomic) IBOutlet UILabel *chatAnchorBadgeLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *chatAnchorButtonBottomConstrait;

//Input Accessory Extension
@property (strong, nonatomic) IBOutlet UIView *quoteView;
@property (strong, nonatomic) IBOutlet UILabel *quoteTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *quoteSubtitleLabel;
@property (strong, nonatomic) IBOutlet TAPImageView *quoteImageView;
@property (strong, nonatomic) IBOutlet UIView *replyMessageView;
@property (strong, nonatomic) IBOutlet UIView *replyMessageInnerContainerView;
@property (strong, nonatomic) IBOutlet UILabel *replyMessageNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *replyMessageMessageLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *inputAccessoryExtensionHeightConstraint;
@property (nonatomic) InputAccessoryExtensionType inputAccessoryExtensionType;

@property (strong, nonatomic) NSMutableArray *anchorUnreadMessageArray;
@property (strong, nonatomic) NSMutableArray *scrolledPendingMessageArray;

@property (nonatomic) BOOL isOnScrollPendingChecking;
@property (nonatomic) BOOL isNeedRefreshOnNetworkDown;
    

- (IBAction)sendButtonDidTapped:(id)sender;
- (IBAction)handleTapOnTableView:(UITapGestureRecognizer *)gestureRecognizer;
- (IBAction)chatAnchorButtonDidTapped:(id)sender;
- (IBAction)inputAccessoryExtensionCloseButtonDidTapped:(id)sender;

- (void)backButtonDidTapped;
- (void)addIncomingMessageToArrayAndDictionaryWithMessage:(TAPMessageModel *)message atIndex:(NSInteger)index;
- (void)removeMessageFromArrayAndDictionaryWithLocalID:(NSString *)localID;
- (void)handleMessageFromSocket:(TAPMessageModel *)message;
- (void)destroySequence;
- (void)firstLoadData;
- (void)fetchBeforeMessageFromAPIAndUpdateUIWithRoomID:(NSString *)roomID maxCreated:(NSNumber *)maxCreated;
- (void)retrieveExistingMessages;
- (void)updateMessageDataAndUIWithMessages:(NSArray *)messageArray toTop:(BOOL)toTop;
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
- (void)processMessageAsRead:(TAPMessageModel *)message;
- (void)processVisibleMessageAsRead;
- (void)setAsTyping:(BOOL)typing;
- (NSString *)getOtherUserIDWithRoomID:(NSString *)roomID;
- (void)setAsTypingNoAfterDelay;
- (void)showInputAccessoryExtensionView:(BOOL)show;
- (void)setInputAccessoryExtensionType:(InputAccessoryExtensionType)inputAccessoryExtensionType;
- (void)setReplyMessageWithMessage:(TAPMessageModel *)message;
- (void)setQuoteWithQuote:(TAPQuoteModel *)quote;
- (void)showImagePreviewControllerWithSelectedImage:(UIImage *)image;
- (void)fileUploadManagerProgressNotification:(NSNotification *)notification;
- (void)fileUploadManagerStartNotification:(NSNotification *)notification;
- (void)fileUploadManagerFinishNotification:(NSNotification *)notification;
- (void)fileUploadManagerFailureNotification:(NSNotification *)notification;
- (void)fetchImageDataWithMessage:(TAPMessageModel *)message;

@end

@implementation TAPChatViewController

#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    
    id quotedMessage = [[TAPChatManager sharedManager] getQuotedMessageObjectWithRoomID:self.currentRoom.roomID];
    CGFloat extensionHeight = 0.0f;
    if(quotedMessage) {
        extensionHeight = kInputMessageAccessoryExtensionViewDefaultHeight;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityStatusChange:) name:TAP_NOTIFICATION_REACHABILITY_STATUS_CHANGED object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadManagerProgressNotification:) name:TAP_NOTIFICATION_UPLOAD_FILE_PROGRESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadManagerStartNotification:) name:TAP_NOTIFICATION_UPLOAD_FILE_START object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadManagerFinishNotification:) name:TAP_NOTIFICATION_UPLOAD_FILE_FINISH object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadManagerFailureNotification:) name:TAP_NOTIFICATION_UPLOAD_FILE_FAILURE object:nil];
    
    self.navigationController.delegate = self;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    if (IS_IPHONE_X_FAMILY) {
        self.chatAnchorButtonBottomConstrait.constant = kChatAnchorDefaultBottomConstraint + self.safeAreaBottomPadding;
    }
    
    self.chatAnchorBadgeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.chatAnchorBadgeView.layer.colors = @[ (__bridge id)[TAPUtil getColor:@"9954C2"].CGColor, (__bridge id)[TAPUtil getColor:TAP_COLOR_MOSELO_PURPLE].CGColor];
    self.chatAnchorBadgeView.layer.borderColor = [TAPUtil getColor:TAP_COLOR_MOSELO_PURPLE].CGColor;
    self.chatAnchorBadgeView.layer.borderWidth = 1.0f;
    self.chatAnchorBadgeView.layer.cornerRadius = CGRectGetHeight(self.chatAnchorBadgeView.frame)/2.0f;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForegroundNotification:) name:TAP_NOTIFICATION_APPLICATION_WILL_ENTER_FOREGROUND object:nil];
    
    _messageArray = [[NSMutableArray alloc] init];
    _messageDictionary = [[NSMutableDictionary alloc] init];
    _anchorUnreadMessageArray = [[NSMutableArray alloc] init];
    _scrolledPendingMessageArray = [[NSMutableArray alloc] init];
    
    [[TAPChatManager sharedManager] addDelegate:self];
    
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
    
    self.view.backgroundColor = [TAPUtil getColor:TAP_COLOR_WHITE_F3];
    
    //TitleView
    _titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - 56.0f - 56.0f, 43.0f)];
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 6.0f, CGRectGetWidth(self.titleView.frame), 18.0f)];
    
    TAPRoomModel *room = [TAPChatManager sharedManager].activeRoom;
    
    self.nameLabel.text = room.name;
    self.nameLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
    self.nameLabel.font = [UIFont fontWithName:TAP_FONT_NAME_BOLD size:15.0f];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.titleView addSubview:self.nameLabel];
    
    _userStatusView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, (16.0f - 7.0f) / 2.0f + 1.6f, 7.0f, 7.0f)];
    self.userStatusView.backgroundColor = [TAPUtil getColor:@"19C700"];
    self.userStatusView.layer.cornerRadius = CGRectGetHeight(self.userStatusView.frame) / 2.0f;
    self.userStatusView.alpha = 0.0f;
    self.userStatusView.clipsToBounds = YES;
    
    _userStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.userStatusView.frame) + 4.0f, 0.0f, 0.0f, 16.0f)];
    self.userStatusLabel.textColor = [TAPUtil getColor:TAP_COLOR_GREY_9B];
    self.userStatusLabel.font = [UIFont fontWithName:TAP_FONT_LATO_REGULAR size:13.0f];
    self.userStatusLabel.textAlignment = NSTextAlignmentCenter;
    [self.userStatusLabel sizeToFit];
    self.userStatusLabel.frame = CGRectMake(CGRectGetMinX(self.userStatusLabel.frame), CGRectGetMinY(self.userStatusLabel.frame), CGRectGetWidth(self.userStatusLabel.frame), 16.0f);
    
    CGFloat userStatusViewWidth = CGRectGetWidth(self.userStatusLabel.frame) + CGRectGetWidth(self.userStatusView.frame) + 4.0f;
    
    _userDescriptionView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.nameLabel.frame), userStatusViewWidth, 16.0f)];
    self.userDescriptionView.center = CGPointMake(self.nameLabel.center.x, self.userDescriptionView.center.y);
    [self.userDescriptionView addSubview:self.userStatusView];
    [self.userDescriptionView addSubview:self.userStatusLabel];
    [self.titleView addSubview:self.userDescriptionView];
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
    
    UILabel *typingLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(typingAnimationImageView.frame) + 4.0f, 0.0f, 100.0f, 16.0f)];
    typingLabel.text = NSLocalizedString(@"typing", @"");
    typingLabel.font = [UIFont fontWithName:TAP_FONT_LATO_REGULAR size:13.0f];
    typingLabel.textColor = [TAPUtil getColor:TAP_COLOR_GREY_9B];
    [typingLabel sizeToFit];
    typingLabel.frame = CGRectMake(CGRectGetMaxX(typingAnimationImageView.frame) + 4.0f, 0.0f, CGRectGetWidth(typingLabel.frame), 16.0f);
    [self.userTypingView addSubview:typingLabel];
    
    self.userTypingView.frame = CGRectMake(CGRectGetMinX(self.userTypingView.frame), CGRectGetMinY(self.userTypingView.frame), CGRectGetMaxX(typingLabel.frame), CGRectGetHeight(self.userTypingView.frame));
    self.userTypingView.center = CGPointMake(self.nameLabel.center.x, self.userTypingView.center.y);
    
    [self setAsTyping:NO];
    [self isShowOnlineDotStatus:NO];
    
    //RightBarButton
    UIView *rightBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 28.0f, 28.0f)];
    TAPImageView *rightBarImageView = [[TAPImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 28.0f, 28.0f)];
    
    NSString *profileImageURL = room.imageURL.thumbnail;
    if (profileImageURL == nil || [profileImageURL isEqualToString:@""]) {
        rightBarImageView.image = [UIImage imageNamed:@"TAPIconDefaultAvatar" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    }
    else {
         [rightBarImageView setImageWithURLString:profileImageURL];
    }
    
    rightBarImageView.layer.cornerRadius = CGRectGetHeight(rightBarImageView.frame) / 2.0f;
    rightBarImageView.clipsToBounds = YES;
    [rightBarView addSubview:rightBarImageView];
    
//    UIImageView *expertIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(rightBarImageView.frame) - 13.0f, CGRectGetMaxY(rightBarImageView.frame) - 13.0f, 13.0f, 13.0f)];
//    expertIconImageView.image = [UIImage imageNamed:@"TAPIconExpertSmall" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
//    [rightBarView addSubview:expertIconImageView];
    
    UIButton *rightBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(rightBarView.frame), CGRectGetHeight(rightBarView.frame))];
    [rightBarButton addTarget:self action:@selector(profileImageDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [rightBarView addSubview:rightBarButton];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarView];
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
    [self showCustomBackButton];
    
    self.messageTextViewHeight = 32.0f;
    self.messageTextView.delegate = self;
    self.textViewBorderView.layer.cornerRadius = 18.0f;
    self.textViewBorderView.layer.borderColor = [TAPUtil getColor:@"E4E4E4"].CGColor;
    self.textViewBorderView.layer.borderWidth = 1.0f;
    self.textViewBorderView.clipsToBounds = YES;
    self.messageTextView.minimumHeight = 32.0f;
    self.messageTextView.maximumHeight = 64.0f;
    self.messageTextView.tintColor = [TAPUtil getColor:@"2ECCAD"];
    
    _safeAreaBottomPadding = [TAPUtil safeAreaBottomPadding];
    _selectedMessage = nil;
    
    _keyboardState = keyboardStateDefault;
    _keyboardHeight = 0.0f;
    _initialKeyboardHeight = 0.0f;
    
    //Connection status view
    _connectionStatusViewController = [[TAPConnectionStatusViewController alloc] init];
    [self addChildViewController:self.connectionStatusViewController];
    [self.connectionStatusViewController didMoveToParentViewController:self];
    self.connectionStatusViewController.delegate = self;
    [self.view addSubview:self.connectionStatusViewController.view];
    _connectionStatusHeight = CGRectGetHeight(self.connectionStatusViewController.view.frame);
    
    //Custom Keyboard
    _keyboardViewController = [[TAPKeyboardViewController alloc] initWithNibName:@"TAPKeyboardViewController" bundle:[TAPUtil currentBundle]];
    self.keyboardViewController.delegate = self;
    
    TAPUserModel *currentUser = [TAPDataManager getActiveUser];
    TAPUserModel *otherUser = [[TAPContactManager sharedManager] getUserWithUserID:[self getOtherUserIDWithRoomID:self.currentRoom.roomID]];
    
    if([[[TAPCustomKeyboardManager sharedManager] getCustomKeyboardWithSender:currentUser recipient:currentUser] count] > 0) {
        //There's custom keyboard for this type
        NSArray *keyboardArray = [[TAPCustomKeyboardManager sharedManager] getCustomKeyboardWithSender:currentUser recipient:currentUser];
        
        [self.keyboardViewController setCustomKeyboardArray:keyboardArray sender:currentUser recipient:otherUser];
        _isCustomKeyboardAvailable = YES;
    }
    else {
        //There's no custom keyboard for this type
        _isCustomKeyboardAvailable = NO;
        self.keyboardOptionButton.alpha = 0.0f;
        self.messageViewLeftConstraint.constant = -38.0f;
    }
    //END Custom Keyboard
    
    _isKeyboardWasShowed = NO;
    _isKeyboardShowed = NO;
    
    _lastSeenTimer = [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(timerRefreshLastSeen) userInfo:nil repeats:YES];
    
    [self firstLoadData];
    
    //Input Accessory Extension View
    self.inputMessageAccessoryView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    [[TAPChatManager sharedManager] refreshShouldRefreshOnlineStatus];
    
    self.replyMessageInnerContainerView.layer.cornerRadius = 4.0f;
    self.quoteImageView.layer.cornerRadius = 4.0f;
    self.quoteImageView.clipsToBounds = YES;
    
    id quotedMessage = [[TAPChatManager sharedManager] getQuotedMessageObjectWithRoomID:self.currentRoom.roomID];
    if (quotedMessage) {
        [self showInputAccessoryExtensionView:YES];
        if ([quotedMessage isKindOfClass:[TAPMessageModel class]]) {
            TAPMessageModel *quoteMessageModel = (TAPMessageModel *)quotedMessage;
            
            //if reply exists check if image in quote exists
            //if image exists  change view to Quote View
            if((quoteMessageModel.quote.fileID && ![quoteMessageModel.quote.fileID isEqualToString:@""]) || (quoteMessageModel.quote.imageURL && ![quoteMessageModel.quote.imageURL isEqualToString:@""])) {
                [self setInputAccessoryExtensionType:inputAccessoryExtensionTypeQuote];
                [self setQuoteWithQuote:quoteMessageModel.quote];
            }
            else {
                [self setInputAccessoryExtensionType:inputAccessoryExtensionTypeReplyMessage];
                [self setReplyMessageWithMessage:quoteMessageModel];
            }
        }
        else if ([quotedMessage isKindOfClass:[TAPQuoteModel class]]) {
            TAPQuoteModel *quoteModel = (TAPQuoteModel *)quotedMessage;
            [self setInputAccessoryExtensionType:inputAccessoryExtensionTypeQuote];
            [self setQuoteWithQuote:quoteModel];
        }
    }
    else {
        [self showInputAccessoryExtensionView:NO];
    }
    
//    //CS TEMP - Test Reply Message View
//    [self setInputAccessoryExtensionType:inputAccessoryExtensionTypeReplyMessage];
//    TAPMessageModel *testMessage = [TAPMessageModel new];
//    testMessage.user = [[TAPContactManager sharedManager] getUserWithUserID:[self getOtherUserIDWithRoomID:self.currentRoom.roomID]];
//    testMessage.body = @"This is sample message body for reply view, this is just a temporary message. Remember to remove this later";
//    [self setReplyMessageWithMessage:testMessage];
//    //END CS TEMP
    
    //CS TEMP - Test Custom Quote View
//    [self setInputAccessoryExtensionType:inputAccessoryExtensionTypeQuote];
//    TAPQuoteModel *quote = [TAPQuoteModel new];
//    quote.title = @"Custom Title";
//    quote.content = @"Rp 50000";
//    quote.imageURL = TAP_DUMMY_IMAGE_URL;
//    [self setQuoteWithQuote:quote];
    //END CS TEMP
    
    //END Input Accessory Extension View
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _isViewWillAppeared = YES;
    self.connectionStatusViewController.isChatViewControllerAppear = self.isViewWillAppeared;
    
    self.connectionStatusViewController.view.frame = CGRectMake(CGRectGetMinX(self.connectionStatusViewController.view.frame), CGRectGetMinY(self.connectionStatusViewController.view.frame), CGRectGetWidth(self.connectionStatusViewController.view.frame), self.connectionStatusHeight);
    //    self.view.backgroundColor = [UIColor redColor];
    [self.tableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    //    [self checkEmptyState];
    
    //Check chat room contains mesage draft or not
    TAPRoomModel *room = [TAPChatManager sharedManager].activeRoom;
    NSString *roomID = room.roomID;
    roomID = [TAPUtil nullToEmptyString:roomID];
    NSString *draftMessage = [[TAPChatManager sharedManager] getMessageFromDraftWithRoomID:roomID];
    draftMessage = [TAPUtil nullToEmptyString:draftMessage];
    
    [self.messageTextView setInitialText:draftMessage];
    if (![self.messageTextView.text isEqualToString:@""]) {
        [self.sendButton setImage:[UIImage imageNamed:@"TAPIconSendMessageActive" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        self.sendButton.userInteractionEnabled = YES;
        if(self.isCustomKeyboardAvailable) {
            self.keyboardOptionButton.alpha = 0.0f;
            self.messageViewLeftConstraint.constant = -38.0f;          
        }
    }
    
    if([[TAPChatManager sharedManager] checkShouldRefreshOnlineStatus]) {
        [self setAsTyping:NO];
        [TAPDataManager callAPIGetUserByUserID:[self getOtherUserIDWithRoomID:self.currentRoom.roomID] success:^(TAPUserModel *user) {
            
            BOOL isTyping = [[TAPChatManager sharedManager] checkIsTypingWithRoomID:self.currentRoom.roomID];
            [self setAsTyping:isTyping];
            
            TAPOnlineStatusModel *onlineStatus = [TAPOnlineStatusModel new];
            onlineStatus.isOnline = user.isOnline;
            onlineStatus.lastActive = user.lastActivity;
            
            _onlineStatus = onlineStatus;
            
            NSTimeInterval currentLastSeen = (double)self.onlineStatus.lastActive.doubleValue/1000.0f;
            [self updateLastSeenWithTimestamp:currentLastSeen];
            
        } failure:^(NSError *error) {
            
        }];
    }
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
        }];
        _isKeyboardShowed = NO;
    }
    
    [self processVisibleMessageAsRead];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    _isViewWillAppeared = NO;
    self.connectionStatusViewController.isChatViewControllerAppear = self.isViewWillAppeared;
    
    if([self.delegate respondsToSelector:@selector(chatViewControllerShouldUpdateUnreadBubbleForRoomID:)]) {
        [self.delegate chatViewControllerShouldUpdateUnreadBubbleForRoomID:self.currentRoom.roomID];
    }
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


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_APPLICATION_WILL_ENTER_FOREGROUND object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_REACHABILITY_STATUS_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_UPLOAD_FILE_PROGRESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_UPLOAD_FILE_START object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_UPLOAD_FILE_FINISH object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TAP_NOTIFICATION_UPLOAD_FILE_FAILURE object:nil];
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
    
    //DV Note - For product list height
    //    Collection view height (347.0f) + 16.0f gap
    //    return 363.0f;
    
    TAPMessageModel *currentMessage = [self.messageArray objectAtIndex:indexPath.row];
    if (currentMessage != nil) {
        BOOL isHidden = currentMessage.isHidden;
        if (isHidden) {
            //Set height = 0 for hidden message
            return 0.0f;
        }
    }
    
    tableView.estimatedRowHeight = 70.0f;
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return FLT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
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
    
    if ([self.messageArray count] != 0) {
        TAPMessageModel *message = [self.messageArray objectAtIndex:indexPath.row];
        
        //CS Note - For order card bubble
        //CS Temp
        
        //        [tableView registerNib:[TAPOrderCardBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPOrderCardBubbleTableViewCell description]];
        //        TAPOrderCardBubbleTableViewCell *cell = (TAPOrderCardBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPOrderCardBubbleTableViewCell description] forIndexPath:indexPath];
        //        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //        return cell;
        //END CS Temp
        
        if ([message.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
            //My Chat
            if (message.type == TAPChatMessageTypeText) {
                [tableView registerNib:[TAPMyChatBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPMyChatBubbleTableViewCell description]];
                TAPMyChatBubbleTableViewCell *cell = (TAPMyChatBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPMyChatBubbleTableViewCell description] forIndexPath:indexPath];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.tag = indexPath.row;
                cell.userInteractionEnabled = YES;
                cell.contentView.userInteractionEnabled = YES;
                cell.delegate = self;
                
                [cell setMessage:message];
                
                if (self.selectedMessage != nil && [self.selectedMessage.localID isEqualToString:message.localID]) {
                    [cell showStatusLabel:YES animated:NO updateStatusIcon:NO];
                }
                else {
                    [cell showStatusLabel:NO animated:NO updateStatusIcon:NO];
                }
                
                return cell;
            }
            else if (message.type == TAPChatMessageTypeImage) {
                [tableView registerNib:[TAPMyImageBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPMyImageBubbleTableViewCell description]];
                TAPMyImageBubbleTableViewCell *cell = (TAPMyImageBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPMyImageBubbleTableViewCell description] forIndexPath:indexPath];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.tag = indexPath.row;
                cell.userInteractionEnabled = YES;
                cell.contentView.userInteractionEnabled = YES;
                cell.delegate = self;
                
                [cell setMessage:message];
                [cell showStatusLabel:YES animated:NO updateStatusIcon:NO];
                
                if (message.isFailedSend) {
                    //Update view to failed send
                    
                    // Fetch image data, get from cache or download if needed
                    [self fetchImageDataWithMessage:message];
                    [cell setInitialAnimateUploadingImageWithType:TAPMyImageBubbleTableViewCellStateTypeFailed];
                }
                else {
                    NSInteger status = [[TAPFileUploadManager sharedManager] obtainImageUploadStatusWithMessage:message];
                    // 0 is not found
                    // 1 is uploading
                    // 2 is waiting for upload
                    if (status != 0) {
                        [cell showProgressUploadView:YES];
                        
                        //Set current progress
                        NSDictionary *uploadProgressDictionary = [[TAPFileUploadManager sharedManager] getUploadProgressWithLocalID:message.localID];
                        if (uploadProgressDictionary == nil) {
                            CGFloat progress = [[uploadProgressDictionary objectForKey:@"progress"] floatValue];
                            CGFloat total = [[uploadProgressDictionary objectForKey:@"total"] floatValue];
                            
                            [cell setInitialAnimateUploadingImageWithType:TAPMyImageBubbleTableViewCellStateTypeUploading];
        
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
            else if (message.type == TAPChatMessageTypeOrderCard) {
                [tableView registerNib:[TAPOrderCardBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPOrderCardBubbleTableViewCell description]];
                TAPOrderCardBubbleTableViewCell *cell = (TAPOrderCardBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPOrderCardBubbleTableViewCell description] forIndexPath:indexPath];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell setOrderCardWithType:13];//CS Temp
                return cell;
            }
            else if (message.type == TAPChatMessageTypeProduct) {
                [tableView registerNib:[TAPProductListBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPProductListBubbleTableViewCell description]];
                TAPProductListBubbleTableViewCell *cell = (TAPProductListBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPProductListBubbleTableViewCell description] forIndexPath:indexPath];
                NSArray *productListArray = [message.data objectForKey:@"items"];
                [cell setProductListBubbleCellWithData:productListArray];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
            else {
                //WK Temp - Where message.type is not 1001 or 1002, set empty chat message
                [tableView registerNib:[TAPMyChatBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPMyChatBubbleTableViewCell description]];
                TAPMyChatBubbleTableViewCell *cell = (TAPMyChatBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPMyChatBubbleTableViewCell description] forIndexPath:indexPath];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.tag = indexPath.row;
                cell.userInteractionEnabled = YES;
                cell.contentView.userInteractionEnabled = YES;
                cell.delegate = self;
                
                //WK Temp
                TAPMessageModel *editedMessage = message;
                editedMessage.body = @"";
                
                [cell setMessage:editedMessage];
                //End Temp
                
                if (self.selectedMessage != nil && [self.selectedMessage.localID isEqualToString:message.localID]) {
                    [cell showStatusLabel:YES animated:NO updateStatusIcon:NO];
                }
                else {
                    [cell showStatusLabel:NO animated:NO updateStatusIcon:NO];
                }
                
                return cell;
            }
        }
        else {
            //Their Chat
            
            //            //DV Temp
            //            NSInteger type = 3001;
            //            NSDictionary *cellDataDictionary = [[TAPCustomBubbleManager sharedManager] getCustomBubbleClassNameWithType:type];
            //            NSString *cellName = [cellDataDictionary objectForKey:@"name"];
            //            id userDelegate = [cellDataDictionary objectForKey:@"delegate"];
            //
            //            UINib *cellNib = [UINib nibWithNibName:cellName bundle:[NSBundle mainBundle]];
            //            [tableView registerNib:cellNib forCellReuseIdentifier:cellName];
            //
            //            TAPBaseGeneralBubbleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName forIndexPath:indexPath];
            //            cell.delegate = userDelegate;
            //            return cell;
            //            //END DV Temp
            
            //            //DV Temp
            //            NSInteger type = 3002;
            //            NSString *cellName = [[TAPCustomBubbleManager sharedManager] getCustomBubbleClassNameWithType:type];
            //            UINib *cellNib = [UINib nibWithNibName:cellName bundle:[NSBundle mainBundle]];
            //            [tableView registerNib:cellNib forCellReuseIdentifier:cellName];
            //
            //            id cell = [tableView dequeueReusableCellWithIdentifier:cellName forIndexPath:indexPath];
            //
            //            return cell;
            //            //END DV Temp
            
            if (message.type == TAPChatMessageTypeText) {
                [tableView registerNib:[TAPYourChatBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPYourChatBubbleTableViewCell description]];
                TAPYourChatBubbleTableViewCell *cell = (TAPYourChatBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPYourChatBubbleTableViewCell description] forIndexPath:indexPath];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.tag = indexPath.row;
                cell.userInteractionEnabled = YES;
                cell.contentView.userInteractionEnabled = YES;
                cell.delegate = self;
                
                [cell setMessage:message];
                
                if (self.selectedMessage != nil && [self.selectedMessage.localID isEqualToString:message.localID]) {
                    [cell showStatusLabel:YES animated:NO];
                }
                else {
                    [cell showStatusLabel:NO animated:NO];
                }
                
                return cell;
            }
            else if (message.type == TAPChatMessageTypeImage) {
                [tableView registerNib:[TAPYourImageBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPYourImageBubbleTableViewCell description]];
                TAPYourImageBubbleTableViewCell *cell = (TAPYourImageBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPYourImageBubbleTableViewCell description] forIndexPath:indexPath];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.tag = indexPath.row;
                cell.userInteractionEnabled = YES;
                cell.contentView.userInteractionEnabled = YES;
                cell.delegate = self;
                [cell setMessage:message];
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
            else if (message.type == TAPChatMessageTypeProduct) {
                [tableView registerNib:[TAPProductListBubbleTableViewCell cellNib] forCellReuseIdentifier:[TAPProductListBubbleTableViewCell description]];
                TAPProductListBubbleTableViewCell *cell = (TAPProductListBubbleTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPProductListBubbleTableViewCell description] forIndexPath:indexPath];
                NSArray *productListArray = [message.data objectForKey:@"items"];
                [cell setProductListBubbleCellWithData:productListArray];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
        }
        
    }
    
//    [tableView registerNib:[TAPBaseXIBRotatedTableViewCell cellNib] forCellReuseIdentifier:[TAPBaseXIBRotatedTableViewCell description]];
//    TAPBaseXIBRotatedTableViewCell *cell = (TAPBaseXIBRotatedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPBaseXIBRotatedTableViewCell description] forIndexPath:indexPath];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.messageArray count] == 0) {
        return;
    }
    
    //Process message as Read, remove local notification and call API read
    TAPMessageModel *message = [self.messageArray objectAtIndex:indexPath.row];
    if (![message.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
        //Their chat
        [self processMessageAsRead:message];
    }
    
    //Check and remove unread count message array
    if ([self.anchorUnreadMessageArray count] > 0) {
        TAPMessageModel *message = [self.messageArray objectAtIndex:indexPath.row];
        [self removeMessageFromAnchorUnreadArray:message];
    }
    
    //Retreive before message
    if (indexPath.row == [self.messageArray count] - 5) {
        [self retrieveExistingMessages];
    }
}

#pragma mark - Delegate
#pragma mark UITableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark UIScrollView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _isScrollViewDragged = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    _isScrollViewDragged = NO;
    
    //move chat anchor button position to default position according to keyboard height
    [UIView animateWithDuration:0.2f animations:^{
        self.chatAnchorButtonBottomConstrait.constant = kChatAnchorDefaultBottomConstraint + self.keyboardHeight - kInputMessageAccessoryViewHeight;
        
        CGFloat tableViewYContentInset = self.keyboardHeight - [TAPUtil safeAreaBottomPadding] - kInputMessageAccessoryViewHeight;
        
        self.tableView.contentInset = UIEdgeInsetsMake(tableViewYContentInset, self.tableView.contentInset.left, self.tableView.contentInset.bottom, self.tableView.contentInset.right);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(tableViewYContentInset, self.tableView.scrollIndicatorInsets.left, self.tableView.scrollIndicatorInsets.bottom, self.tableView.scrollIndicatorInsets.right);
        
        [self.view layoutIfNeeded];
        
        if (tableViewYContentInset <= self.safeAreaBottomPadding + kInputMessageAccessoryViewHeight) {
            //set keyboard state to default
            _keyboardState = keyboardStateDefault;
            [self.keyboardOptionButton setImage:[UIImage imageNamed:@"TAPIconHamburger" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        }
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y > kShowChatAnchorOffset) {
        if (self.chatAnchorButton.alpha != 1.0f) {
            [UIView animateWithDuration:0.2f animations:^{
                self.chatAnchorButton.alpha = 1.0f;
            }];
            
            [self checkAnchorUnreadLabel];
        }
    }
    else {
        if (self.chatAnchorButton.alpha != 0.0f) {
            [UIView animateWithDuration:0.2f animations:^{
                self.chatAnchorButton.alpha = 0.0f;
                self.chatAnchorBadgeView.alpha = 0.0f;
            }];
        }
        
        //Check scrolled pending array
        if (!self.isOnScrollPendingChecking) {
            _isOnScrollPendingChecking = YES;
            
            NSInteger numberOfPendingArray = [self.scrolledPendingMessageArray count];
            
            if (numberOfPendingArray > 0) {
                //Add pending message to messageArray (pending message has previously inserted in messageDictionary in didReceiveNewMessage)
                [self.messageArray insertObjects:self.scrolledPendingMessageArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, numberOfPendingArray)]];
                
                [self.scrolledPendingMessageArray removeAllObjects];
                [self.tableView reloadData];
                
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:numberOfPendingArray - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
            
            _isOnScrollPendingChecking = NO;
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
        
        if (chatAnchorBottomConstraint < kChatAnchorDefaultBottomConstraint + self.currentInputAccessoryExtensionHeight + self.safeAreaBottomPadding) {
            chatAnchorBottomConstraint = kChatAnchorDefaultBottomConstraint + self.currentInputAccessoryExtensionHeight + self.safeAreaBottomPadding;
        }
        self.chatAnchorButtonBottomConstrait.constant = chatAnchorBottomConstraint;
    }
}

#pragma mark UINavigationController
- (void)handleNavigationPopGesture:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self performSelector:@selector(checkIfNeedCloseRoomAfterDelay) withObject:nil afterDelay:0.5f];
    }
}

- (void)checkIfNeedCloseRoomAfterDelay {
    if (!self.isViewWillAppeared) {
        [self.lastSeenTimer invalidate];
        _lastSeenTimer = nil;
        [self destroySequence];
    }
}

#pragma mark TAPChatManager
- (void)chatManagerDidSendNewMessage:(TAPMessageModel *)message {
    [self addIncomingMessageToArrayAndDictionaryWithMessage:message atIndex:0];
    NSIndexPath *insertAtIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:@[insertAtIndexPath] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
    [self.tableView scrollsToTop];
}

- (void)chatManagerDidReceiveNewMessageInActiveRoom:(TAPMessageModel *)message {
    if (![message.room.roomID isEqualToString:self.currentRoom.roomID]) {
        //If message don't have the same room id, reject message
        return;
    }
    [self handleMessageFromSocket:message];
}

- (void)chatManagerDidReceiveUpdateMessageInActiveRoom:(TAPMessageModel *)message {
    if (![message.room.roomID isEqualToString:self.currentRoom.roomID]) {
        //If message don't have the same room id, reject message
        return;
    }
    
    [self handleMessageFromSocket:message];
}

- (void)chatManagerDidReceiveDeleteMessageInActiveRoom:(TAPMessageModel *)message {
    if (![message.room.roomID isEqualToString:self.currentRoom.roomID]) {
        //If message don't have the same room id, reject message
        return;
    }
    
    [self handleMessageFromSocket:message];
}

- (void)chatManagerDidReceiveOnlineStatus:(TAPOnlineStatusModel *)onlineStatus {
    _onlineStatus = onlineStatus;
    NSTimeInterval currentLastSeen = (double)self.onlineStatus.lastActive.doubleValue/1000.0f;
    [self updateLastSeenWithTimestamp:currentLastSeen];
}

- (void)chatManagerDidReceiveStartTyping:(TAPTypingModel *)typing {
    NSLog(@"USER IS START TYPING"); //DV Temp
    [self setAsTyping:YES];
}

- (void)chatManagerDidReceiveStopTyping:(TAPTypingModel *)typing {
    NSLog(@"USER IS STOP TYPING"); //DV Temp
    [self setAsTyping:NO];
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
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[deleteAtIndexPath] withRowAnimation:UITableViewRowAnimationTop];
            [self.tableView endUpdates];
            [[TAPChatManager sharedManager] sendTextMessage:currentMessageString];
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
                [self.tableView beginUpdates];
                [cell showStatusLabel:NO animated:YES updateStatusIcon:YES];
                [cell layoutIfNeeded];
                [self.tableView endUpdates];
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
                    [self.tableView beginUpdates];
                    [cell showStatusLabel:YES animated:YES updateStatusIcon:YES];
                    [cell layoutIfNeeded];
                    [self.tableView endUpdates];
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
                        [previousCell showStatusLabel:NO animated:YES updateStatusIcon:YES];
                    }
                    else {
                        [previousCell showStatusLabel:NO animated:YES];
                    }
                    [previousCell layoutIfNeeded];
                    
                    [cell showStatusLabel:YES animated:YES updateStatusIcon:YES];
                    [cell layoutIfNeeded];
                    [self.tableView beginUpdates];
                    [self.tableView endUpdates];
                } completion:^(BOOL finished) {
                    //completion
                }];
            }
        }
    }
}

- (void)myChatReplyDidTapped {
    //set selected message to chat field
    NSInteger messageIndex = [self.messageArray indexOfObject:self.selectedMessage];
    NSIndexPath *selectedMessageIndexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
    //WK Note : Do reply here later.
    [self showInputAccessoryExtensionView:YES];
    [self setInputAccessoryExtensionType:inputAccessoryExtensionTypeReplyMessage];
    [self setReplyMessageWithMessage:self.selectedMessage];
    
    [[TAPChatManager sharedManager] saveToQuotedMessage:self.selectedMessage userInfo:nil roomID:self.currentRoom.roomID];
    
    //remove selectedMessage
    self.selectedMessage = nil;
    
    TAPMyChatBubbleTableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedMessageIndexPath];
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
        //animation
        [cell showStatusLabel:NO animated:YES updateStatusIcon:YES];
        [cell layoutIfNeeded];
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    } completion:^(BOOL finished) {
        //completion
    }];
}

- (void)myChatQuoteViewDidTapped:(TAPMessageModel *)tappedMessage {
    if ((![tappedMessage.replyTo.messageID isEqualToString:@"0"] && ![tappedMessage.replyTo.messageID isEqualToString:@""]) && ![tappedMessage.quote.title isEqualToString:@""] && tappedMessage.quote != nil && tappedMessage.replyTo != nil) {
        //reply to exists
 
    }
    else if (![tappedMessage.quote.title isEqualToString:@""] && tappedMessage.quote != nil) {
        //quote exists
        if(tappedMessage.data) {
            [[TapTalk sharedInstance] quoteDidTappedWithUserInfo:[TAPUtil nullToEmptyDictionary:[tappedMessage.data objectForKey:@"userInfo"]]];
        }
    }
}

#pragma mark TAPMyImageBubbleTableViewCell
- (void)myImageCancelDidTappedWithMessage:(TAPMessageModel *)message {
    
    //Cancel uploading task
    [[TAPFileUploadManager sharedManager] cancelUploadingImageWithMessage:message];
    
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
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[deleteAtIndexPath] withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
}

- (void)myImageReplyDidTappedWithMessage:(TAPMessageModel *)message {
    NSInteger messageIndex = [self.messageArray indexOfObject:self.selectedMessage];
    NSIndexPath *selectedMessageIndexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
    
    //WK Note : Do reply here later.
    [self showInputAccessoryExtensionView:YES];
    [self setInputAccessoryExtensionType:inputAccessoryExtensionTypeQuote];
    
    //convert to quote model
    TAPQuoteModel *quote = [TAPQuoteModel new];
    quote.fileID = [TAPUtil nullToEmptyString:[message.data objectForKey:@"fileID"]];
    quote.title = message.user.fullname;
    quote.content = message.body;
    [self setQuoteWithQuote:quote];
    
    message.quote = quote;

    [[TAPChatManager sharedManager] saveToQuotedMessage:message userInfo:nil roomID:self.currentRoom.roomID];
    
    //remove selectedMessage
    self.selectedMessage = nil;
    
    TAPYourChatBubbleTableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedMessageIndexPath];
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
        //animation
        [cell showStatusLabel:NO animated:YES];
        [cell layoutIfNeeded];
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    } completion:^(BOOL finished) {
        //completion
    }];
}

- (void)myImageQuoteDidTappedWithMessage:(TAPMessageModel *)message {
    if ((![message.replyTo.messageID isEqualToString:@"0"] && ![message.replyTo.messageID isEqualToString:@""]) && ![message.quote.title isEqualToString:@""] && message.quote != nil && message.replyTo != nil) {
        //reply to exists
        
    }
    else if (![message.quote.title isEqualToString:@""] && message.quote != nil) {
        //quote exists
        if(message.data) {
            [[TapTalk sharedInstance] quoteDidTappedWithUserInfo:[TAPUtil nullToEmptyDictionary:[message.data objectForKey:@"userInfo"]]];
        }
    }
}

- (void)myImageRetryDidTappedWithMessage:(TAPMessageModel *)message {
    NSInteger messageIndex = [self.messageArray indexOfObject:message];

    [TAPDataManager deleteDatabaseMessageWithData:@[message] success:^{
        [self.messageArray removeObjectAtIndex:messageIndex];
        [self.messageDictionary removeObjectForKey:message.localID];
        NSIndexPath *deleteAtIndexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[deleteAtIndexPath] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
        
     [TAPImageView imageFromCacheWithKey:message.localID message:message success:^(UIImage *savedImage, TAPMessageModel *resultMessage) {
         
         NSDictionary *dataDictionary = resultMessage.data;
         NSString *currentCaption = [dataDictionary objectForKey:@"caption"];
         currentCaption = [TAPUtil nullToEmptyString:currentCaption];
         
         [[TAPChatManager sharedManager] sendImageMessage:savedImage caption:currentCaption];
     }];
    } failure:^(NSError *error) {
        
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
                [self.tableView beginUpdates];
                [self.tableView endUpdates];
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
                    [self.tableView beginUpdates];
                    [self.tableView endUpdates];
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
                        [previousCell showStatusLabel:NO animated:YES updateStatusIcon:YES];
                    }
                    else {
                        [previousCell showStatusLabel:NO animated:YES];
                    }
                    [previousCell layoutIfNeeded];
                    
                    [cell showStatusLabel:YES animated:YES];
                    [cell layoutIfNeeded];
                    [self.tableView beginUpdates];
                    [self.tableView endUpdates];
                } completion:^(BOOL finished) {
                    //completion
                }];
            }
        }
    }
}

- (void)yourChatReplyDidTapped {
    //set selected message to chat field
    NSInteger messageIndex = [self.messageArray indexOfObject:self.selectedMessage];
    NSIndexPath *selectedMessageIndexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
    //WK Note : Do reply here later.
    [self showInputAccessoryExtensionView:YES];
    [self setInputAccessoryExtensionType:inputAccessoryExtensionTypeReplyMessage];
    [self setReplyMessageWithMessage:self.selectedMessage];
    
    [[TAPChatManager sharedManager] saveToQuotedMessage:self.selectedMessage userInfo:nil roomID:self.currentRoom.roomID];

    //remove selectedMessage
    self.selectedMessage = nil;
    
    TAPYourChatBubbleTableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedMessageIndexPath];
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
        //animation
        [cell showStatusLabel:NO animated:YES];
        [cell layoutIfNeeded];
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    } completion:^(BOOL finished) {
        //completion
    }];
}

- (void)yourChatQuoteViewDidTapped:(TAPMessageModel *)tappedMessage {
    if ((![tappedMessage.replyTo.messageID isEqualToString:@"0"] && ![tappedMessage.replyTo.messageID isEqualToString:@""]) && ![tappedMessage.quote.title isEqualToString:@""] && tappedMessage.quote != nil && tappedMessage.replyTo != nil) {
        //reply to exists
        
    }
    else if (![tappedMessage.quote.title isEqualToString:@""] && tappedMessage.quote != nil) {
        //quote exists
        if(tappedMessage.data) {
            [[TapTalk sharedInstance] quoteDidTappedWithUserInfo:[TAPUtil nullToEmptyDictionary:[tappedMessage.data objectForKey:@"userInfo"]]];
        }
    }
}

#pragma mark TAPYourImageBubbleTableViewCell
- (void)yourImageReplyDidTappedWithMessage:(TAPMessageModel *)message {
    NSInteger messageIndex = [self.messageArray indexOfObject:self.selectedMessage];
    NSIndexPath *selectedMessageIndexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
    
    //WK Note : Do reply here later.
    [self showInputAccessoryExtensionView:YES];
    [self setInputAccessoryExtensionType:inputAccessoryExtensionTypeQuote];
    
    //convert to quote model
    TAPQuoteModel *quote = [TAPQuoteModel new];
    quote.fileID = [TAPUtil nullToEmptyString:[message.data objectForKey:@"fileID"]];
    quote.title = message.user.fullname;
    quote.content = message.body;
    [self setQuoteWithQuote:quote];
    
    message.quote = quote;
    
    [[TAPChatManager sharedManager] saveToQuotedMessage:message userInfo:nil roomID:self.currentRoom.roomID];
    
    //remove selectedMessage
    self.selectedMessage = nil;
    
    TAPYourChatBubbleTableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedMessageIndexPath];
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
        //animation
        [cell showStatusLabel:NO animated:YES];
        [cell layoutIfNeeded];
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    } completion:^(BOOL finished) {
        //completion
    }];
}

- (void)yourImageQuoteDidTappedWithMessage:(TAPMessageModel *)message {
    if ((![message.replyTo.messageID isEqualToString:@"0"] && ![message.replyTo.messageID isEqualToString:@""]) && ![message.quote.title isEqualToString:@""] && message.quote != nil && message.replyTo != nil) {
        //reply to exists
        
    }
    else if (![message.quote.title isEqualToString:@""] && message.quote != nil) {
        //quote exists
        if(message.data) {
            [[TapTalk sharedInstance] quoteDidTappedWithUserInfo:[TAPUtil nullToEmptyDictionary:[message.data objectForKey:@"userInfo"]]];
        }
    }
}

#pragma mark TAPGrowingTextView
- (void)growingTextView:(TAPGrowingTextView *)textView shouldChangeHeight:(CGFloat)height {
    [UIView animateWithDuration:0.1f animations:^{
        self.messageTextViewHeight = height;
        self.messageTextViewHeightConstraint.constant = height;
        self.messageViewHeightConstraint.constant = self.messageTextViewHeight + 16.0f + 4.0f;
        [self.messageTextView layoutIfNeeded];
        [self.inputMessageAccessoryView layoutIfNeeded];
        [self.view layoutIfNeeded];
    }];
}

- (void)growingTextViewDidBeginEditing:(TAPGrowingTextView *)textView {
    _keyboardState = keyboardStateDefault;
    
    [self.keyboardOptionButton setImage:[UIImage imageNamed:@"TAPIconHamburger" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    
    if (textView.text != nil) {
        if (![textView.text isEqualToString:@""]) {
            if(self.isCustomKeyboardAvailable) {
                [UIView animateWithDuration:0.2f animations:^{
                    self.keyboardOptionButton.alpha = 0.0f;
                    self.messageViewLeftConstraint.constant = -38.0f;
                    [self.messageTextView layoutIfNeeded];
                    [self.inputMessageAccessoryView layoutIfNeeded];
                    [self.view layoutIfNeeded];
                }];
            }
        }
    }
}

- (void)growingTextViewDidStartTyping:(TAPGrowingTextView *)textView {
    [self.sendButton setImage:[UIImage imageNamed:@"TAPIconSendMessageActive" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    self.sendButton.userInteractionEnabled = YES;
    if(self.isCustomKeyboardAvailable) {
        [UIView animateWithDuration:0.2f animations:^{
            self.keyboardOptionButton.alpha = 0.0f;
            self.messageViewLeftConstraint.constant = -38.0f;
            [self.messageTextView layoutIfNeeded];
            [self.inputMessageAccessoryView layoutIfNeeded];
        }];
    }
    [[TAPChatManager sharedManager] startTyping];
}

- (void)growingTextViewDidStopTyping:(TAPGrowingTextView *)textView {
    [self.sendButton setImage:[UIImage imageNamed:@"TAPIconSendMessage" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    self.sendButton.userInteractionEnabled = NO;
    if(self.isCustomKeyboardAvailable) {
        [UIView animateWithDuration:0.2f animations:^{
            self.keyboardOptionButton.alpha = 1.0f;
            self.messageViewLeftConstraint.constant = 4.0f;
            [self.messageTextView layoutIfNeeded];
            [self.inputMessageAccessoryView layoutIfNeeded];
            [self.view layoutIfNeeded];
        }];
    }
    [[TAPChatManager sharedManager] stopTyping];
}

#pragma mark TAPConnectionStatusViewController
- (void)connectionStatusViewControllerDelegateHeightChange:(CGFloat)height {
    self.connectionStatusHeight = height;
    [UIView animateWithDuration:0.2f animations:^{
        //change frame
        self.tableViewTopConstraint.constant = height - 50.0f;
        [self.view layoutIfNeeded];
    }];
}

#pragma mark TAPKeyboardViewController
- (void)keyboardViewControllerDidSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"===> %ld", indexPath.row); //WK Temp
    if(indexPath.row == 3) {
        //Create Order Card
        //CS Temp - Add Order Card Type Dummy Model
        TAPMessageModel *message = [TAPMessageModel createMessageWithUser:[TAPChatManager sharedManager].activeUser room:[TAPChatManager sharedManager].activeRoom body:@"" type:TAPChatMessageTypeOrderCard];
        
        [self addIncomingMessageToArrayAndDictionaryWithMessage:message atIndex:0];
        
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        //End Temp
    }
}

#pragma mark TAPImagePreviewViewController
- (void)imagePreviewDidTapSendButtonWithData:(NSArray *)dataArray {
    
    //hide empty chat
    [UIView animateWithDuration:0.2f animations:^{
        if (self.emptyView.alpha != 0.0f) {
            self.emptyView.alpha = 0.0f;
        }
    }];
    
    for (TAPImagePreviewModel *imagePreview in dataArray) {
        UIImage *selectedImage = imagePreview.image;
        NSString *caption = imagePreview.caption;
        caption = [TAPUtil nullToEmptyString:caption];
        
        [[TAPChatManager sharedManager] sendImageMessage:selectedImage caption:caption];
    }
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
        [self checkKeyboard];
    }];
}

#pragma mark TAPPhotoAlbumListViewController
- (void)photoAlbumListViewControllerSelectImageWithDataArray:(NSArray *)dataArray {
    
}

- (void)photoAlbumListViewControllerDidFinishAndSendImageWithDataArray:(NSArray *)dataArray {
    //Handle send image from gallery
    
    if(self.currentInputAccessoryExtensionHeight > 0.0f) {
        [self showInputAccessoryExtensionView:NO];
    }
    
    //hide empty chat
    [UIView animateWithDuration:0.2f animations:^{
        if (self.emptyView.alpha != 0.0f) {
            self.emptyView.alpha = 0.0f;
        }
    }];
    
    for (TAPImagePreviewModel *imagePreview in dataArray) {
        UIImage *selectedImage = imagePreview.image;
        NSString *caption = imagePreview.caption;
        caption = [TAPUtil nullToEmptyString:caption];
        
        [[TAPChatManager sharedManager] sendImageMessage:selectedImage caption:caption];
    }
}

#pragma mark - Custom Method
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

- (void)handleMessageFromSocket:(TAPMessageModel *)message {
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
        
        if ([currentMessage.user.userID isEqualToString:currentUser.userID]) {
            //My Message
            if (currentMessage.isSending) {
                //Message was sending
                isSendingAnimation = YES;
                NSInteger indexInArray = [self.messageArray indexOfObject:currentMessage];
            }
            
            if(!currentMessage.isDelivered && message.isDelivered && !currentMessage.isRead && !message.isRead) {
                setAsDelivered = YES;
            }
            
            if(!currentMessage.isRead && message.isRead) {
                setAsDelivered = NO;
                setAsRead = YES;
            }
        }
        
        //Update message data
        [self updateMessageModelValueWithMessage:message];
        
        //Update view
        NSInteger indexInArray = [self.messageArray indexOfObject:currentMessage];
        NSIndexPath *messageIndexPath = [NSIndexPath indexPathForRow:indexInArray inSection:0];
        TAPMyChatBubbleTableViewCell *cell = [self.tableView cellForRowAtIndexPath:messageIndexPath];
        
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
    else {
        //Message not exist in dictionary
        if(self.tableView.contentOffset.y > kShowChatAnchorOffset) {
            //Bottom table view not seen, put message to holder array and insert the message when user scroll to bottom
            [self.scrolledPendingMessageArray insertObject:message atIndex:0];
            
            //Add message to messageDictionary first to lower load time (pending message will be inserted to messageArray at scrollViewDidScroll and chatAnchorButtonDidTapped)
            [self.messageDictionary setObject:message forKey:message.localID];
            
            [self addMessageToAnchorUnreadArray:message];
        }
        else {
            //Bottom table view visible, insert message normally
            [self addIncomingMessageToArrayAndDictionaryWithMessage:message atIndex:0];
            
            NSIndexPath *insertAtIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[insertAtIndexPath] withRowAnimation:UITableViewRowAnimationTop];
            [self.tableView endUpdates];
        }
    }
    
    [self checkEmptyState];
}

- (void)keyboardWillShowWithHeight:(CGFloat)keyboardHeight {
    
    if(!self.isKeyboardShowedForFirstTime) {
        _isKeyboardShowedForFirstTime = YES;
    }

    if (self.isKeyboardOptionTapped && self.isKeyboardShowed) {
        return;
    }
    
    CGFloat accessoryViewAndSafeAreaHeight = self.safeAreaBottomPadding + kInputMessageAccessoryViewHeight + self.currentInputAccessoryExtensionHeight;
    
    //set initial keyboard height to prevent wrong keyboard height usage
    if (self.initialKeyboardHeight == 0.0f && keyboardHeight !=  accessoryViewAndSafeAreaHeight && keyboardHeight != kInputMessageAccessoryViewHeight + self.safeAreaBottomPadding && keyboardHeight != kInputMessageAccessoryViewHeight) {
        _initialKeyboardHeight = keyboardHeight;
    }
    
    if (self.keyboardHeight == 0.0f) {
        //set keyboardHeight if height != accessoryViewAndSafeAreaHeight && keyboardHeight == initialKeyboardHeight
        if (keyboardHeight != accessoryViewAndSafeAreaHeight && keyboardHeight == self.initialKeyboardHeight) {
            _keyboardHeight = keyboardHeight;
        }
    }
    CGFloat tempHeight = 0.0f;
    if (keyboardHeight > self.keyboardHeight) {
        //set keyboardHeight if height != accessoryViewAndSafeAreaHeight && keyboardHeight == initialKeyboardHeight
        if (keyboardHeight != accessoryViewAndSafeAreaHeight && keyboardHeight == self.initialKeyboardHeight) {
            tempHeight = self.keyboardHeight;
            _keyboardHeight = keyboardHeight;
        }
    }
    
    //handle change keyboard height if keyboard is change to emoji
    if (keyboardHeight > self.initialKeyboardHeight && keyboardHeight != accessoryViewAndSafeAreaHeight) {
        _keyboardHeight = keyboardHeight;
    }
    
    //set keyboard height to initial height
    if (keyboardHeight == self.initialKeyboardHeight && self.isKeyboardShowed) {
        _keyboardHeight = self.initialKeyboardHeight;
    }
    
    if (self.isKeyboardShowed) {
        [self.keyboardViewController setKeyboardHeight:self.initialKeyboardHeight - kInputMessageAccessoryViewHeight];
    }
    
    //reject if scrollView is being dragged
    if (self.isScrollViewDragged) {
        return;
    }
    
    CGFloat tableViewYContentInset = self.keyboardHeight - [TAPUtil safeAreaBottomPadding] - kInputMessageAccessoryViewHeight;

    CGFloat lastTableViewYContentInset = self.tableView.contentInset.top;
    
    self.tableView.contentInset = UIEdgeInsetsMake(tableViewYContentInset, self.tableView.contentInset.left, self.tableView.contentInset.bottom, self.tableView.contentInset.right);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(tableViewYContentInset, self.tableView.scrollIndicatorInsets.left, self.tableView.scrollIndicatorInsets.bottom, self.tableView.scrollIndicatorInsets.right);
    NSLog(@"--KEYBOARDHEIGHT %f", keyboardHeight);
    NSLog(@"--CONTENTINSETTT %f", lastTableViewYContentInset);
    NSLog(@"--CONTENTINSENEW %f", tableViewYContentInset);
    [UIView animateWithDuration:0.2f animations:^{
        self.chatAnchorButtonBottomConstrait.constant = kChatAnchorDefaultBottomConstraint + self.keyboardHeight - kInputMessageAccessoryViewHeight;
        
        CGFloat newYContentOffset = self.tableView.contentOffset.y - self.keyboardHeight + self.safeAreaBottomPadding + kInputMessageAccessoryViewHeight + self.currentInputAccessoryExtensionHeight;
        
        
        if (fabs(tableViewYContentInset - lastTableViewYContentInset) == kInputMessageAccessoryExtensionViewDefaultHeight) {
            newYContentOffset = self.tableView.contentOffset.y + lastTableViewYContentInset - tableViewYContentInset;
        }
        
        if(self.tableView.contentOffset.y == 0.0f) {
            newYContentOffset = 0.0f;
        }
        
        if (newYContentOffset < tableViewYContentInset) {
            newYContentOffset = -tableViewYContentInset;
        }
        
        [self.tableView setContentOffset:CGPointMake(0.0f, newYContentOffset)];
        [self.view layoutIfNeeded];
        
        if (!self.isKeyboardShowed) {
            [self.keyboardViewController setKeyboardHeight:self.initialKeyboardHeight - kInputMessageAccessoryViewHeight];
        }
    } completion:^(BOOL finished) {
        //Do something after animation completed.
        //set keyboardHeight if height != accessoryViewAndSafeAreaHeight && keyboardHeight == initialKeyboardHeight
        if (tempHeight != 0.0f && tempHeight != accessoryViewAndSafeAreaHeight && keyboardHeight == self.initialKeyboardHeight) {
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
    _keyboardHeight = kInputMessageAccessoryViewHeight + self.safeAreaBottomPadding + self.currentInputAccessoryExtensionHeight;
    
    //reject if scrollView is being dragged
    if (self.isScrollViewDragged) {
        _isKeyboardShowed = NO;
        return;
    }
    
    self.tableView.contentInset = UIEdgeInsetsMake(self.currentInputAccessoryExtensionHeight, self.tableView.contentInset.left, self.tableView.contentInset.bottom, self.tableView.contentInset.right);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.currentInputAccessoryExtensionHeight, self.tableView.scrollIndicatorInsets.left, self.tableView.scrollIndicatorInsets.bottom, self.tableView.scrollIndicatorInsets.right);
    
    [UIView animateWithDuration:0.2f animations:^{
        if(self.isCustomKeyboardAvailable) {
            self.keyboardOptionButton.alpha = 1.0f;
            self.messageViewLeftConstraint.constant = 4.0f;
        }
        
        if (IS_IPHONE_X_FAMILY) {
            self.chatAnchorButtonBottomConstrait.constant = kChatAnchorDefaultBottomConstraint + self.safeAreaBottomPadding + self.currentInputAccessoryExtensionHeight;
        }
        else {
            self.chatAnchorButtonBottomConstrait.constant = kChatAnchorDefaultBottomConstraint + self.currentInputAccessoryExtensionHeight;
        }
        
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        //Do something after animation completed.
    }];
    
    _isKeyboardShowed = NO;
}

- (IBAction)sendButtonDidTapped:(id)sender {
    if ([self.messageArray count] != 0) {
        [self chatAnchorButtonDidTapped:[[UIButton alloc] init]]; //Scroll table view to top with pending message logic
    }
    
    //Remove highlighted message.
    NSInteger messageIndex = [self.messageArray indexOfObject:self.selectedMessage];
    NSIndexPath *selectedMessageIndexPath = [NSIndexPath indexPathForRow:messageIndex inSection:0];
    TAPMyChatBubbleTableViewCell *cell = [self.tableView cellForRowAtIndexPath:selectedMessageIndexPath];
    
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionTransitionNone animations:^{
        //animation
        [cell showStatusLabel:NO animated:YES updateStatusIcon:YES];
        [cell layoutIfNeeded];
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
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
        self.messageTextView.text = @"";
    }
    
    if(self.currentInputAccessoryExtensionHeight > 0.0f) {
        [self showInputAccessoryExtensionView:NO];
    }
    else if(self.tableView.contentOffset.y != 0 && [self.messageArray count] != 0) {
//        Only scroll if table view is at bottom
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    [self checkEmptyState];
    [[TAPChatManager sharedManager] stopTyping];
}

- (IBAction)keyboardOptionButtonDidTapped:(id)sender {
    
    _isKeyboardOptionTapped = YES;
    
    if (self.keyboardState == keyboardStateDefault) {
        _keyboardState = keyboardStateOptions;
        
        [self.keyboardOptionButton setImage:[UIImage imageNamed:@"TAPIconKeyboard" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self.keyboardViewController setKeyboardHeight:self.initialKeyboardHeight - kInputMessageAccessoryViewHeight];
        
        self.secondaryTextField.inputView = self.keyboardViewController.inputView;
        if (IS_IPHONE_X_FAMILY) {
            if (self.isKeyboardShowed) {
                [UIView performWithoutAnimation:^{
                    [self.messageTextView resignFirstResponder];
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
        _keyboardState = keyboardStateDefault;
        
        [self.keyboardOptionButton setImage:[UIImage imageNamed:@"TAPIconHamburger" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        if (IS_IPHONE_X_FAMILY) {
            if (self.isKeyboardShowed) {
                [UIView performWithoutAnimation:^{
                    [self.secondaryTextField resignFirstResponder];
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

- (IBAction)attachmentButtonDidTapped:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    //    NSMutableAttributedString *documentsAttributedString = [[NSMutableAttributedString alloc] initWithString:@"Documents"];
    //    [documentsAttributedString addAttribute:NSFontAttributeName
    //                                      value:[UIFont fontWithName:TAP_FONT_LATO_REGULAR size:18.0f]
    //                                      range:NSMakeRange(0, documentsAttributedString.length)];
    
    UIAlertAction *documentsAction = [UIAlertAction
                                      actionWithTitle:@"Documents"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          //Do some thing here
                                      }];
    
    UIAlertAction *cameraAction = [UIAlertAction
                                   actionWithTitle:@"Camera"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       [self performSelector:@selector(openCamera) withObject:nil];
                                   }];
    
    UIAlertAction *galleryAction = [UIAlertAction
                                    actionWithTitle:@"Gallery"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        [self performSelector:@selector(openGallery) withObject:nil];
                                    }];
    
    UIAlertAction *audioAction = [UIAlertAction
                                  actionWithTitle:@"Audio"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                      //Do some thing here
                                  }];
    
    UIAlertAction *locationAction = [UIAlertAction
                                     actionWithTitle:@"Location"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
                                         //Do some thing here
                                     }];
    
    UIAlertAction *contactAction = [UIAlertAction
                                    actionWithTitle:@"Contact"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //Do some thing here
                                    }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
                                       //Do some thing here
                                       [self checkKeyboard];
                                   }];
    
    [documentsAction setValue:[[UIImage imageNamed:@"TAPIconDocuments" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [cameraAction setValue:[[UIImage imageNamed:@"TAPIconPhoto" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [galleryAction setValue:[[UIImage imageNamed:@"TAPIconGallery" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [audioAction setValue:[[UIImage imageNamed:@"TAPIconVoice" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [locationAction setValue:[[UIImage imageNamed:@"TAPIconLocation" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    [contactAction setValue:[[UIImage imageNamed:@"TAPIconContact" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    [documentsAction setValue:@0 forKey:@"titleTextAlignment"];
    [cameraAction setValue:@0 forKey:@"titleTextAlignment"];
    [galleryAction setValue:@0 forKey:@"titleTextAlignment"];
    [audioAction setValue:@0 forKey:@"titleTextAlignment"];
    [locationAction setValue:@0 forKey:@"titleTextAlignment"];
    [contactAction setValue:@0 forKey:@"titleTextAlignment"];
    
    [documentsAction setValue:[TAPUtil getColor:TAP_COLOR_BLACK_2C] forKey:@"titleTextColor"];
    [cameraAction setValue:[TAPUtil getColor:TAP_COLOR_BLACK_2C] forKey:@"titleTextColor"];
    [galleryAction setValue:[TAPUtil getColor:TAP_COLOR_BLACK_2C] forKey:@"titleTextColor"];
    [audioAction setValue:[TAPUtil getColor:TAP_COLOR_BLACK_2C] forKey:@"titleTextColor"];
    [locationAction setValue:[TAPUtil getColor:TAP_COLOR_BLACK_2C] forKey:@"titleTextColor"];
    [contactAction setValue:[TAPUtil getColor:TAP_COLOR_BLACK_2C] forKey:@"titleTextColor"];
    [cancelAction setValue:[TAPUtil getColor:TAP_COLOR_GREENBLUE_93] forKey:@"titleTextColor"];
    
    [alertController addAction:documentsAction];
    [alertController addAction:cameraAction];
    [alertController addAction:galleryAction];
    [alertController addAction:audioAction];
    [alertController addAction:locationAction];
    [alertController addAction:contactAction];
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
    } completion:^(BOOL finished) {
        [self presentViewController:alertController animated:YES completion:^{
            //after animation
        }];
    }];
    
}

- (void)backButtonDidTapped {
    [self.lastSeenTimer invalidate];
    _lastSeenTimer = nil;
    [self destroySequence];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)destroySequence {
    [self saveMessageDraft];
    [[TAPChatManager sharedManager] closeActiveRoom];
    
    //Remove ChatManager Delegate
    [[TAPChatManager sharedManager] removeDelegate:self];
}

- (void)checkEmptyState {
    if ([self.messageArray count] == 0) {
        if (self.emptyView.alpha == 1.0f) {
            return;
        }
        
        //show empty chat
        //WK Temp
        TAPUserModel *activeUser = [TAPDataManager getActiveUser];
        
        TAPRoomModel *room = [TAPChatManager sharedManager].activeRoom;
        NSString *roomName = room.name;
        roomName = [TAPUtil nullToEmptyString:roomName];
        NSString *emptyTitleString = [NSString stringWithFormat:@"%@ is an expert\ndon’t forget to check out her services!", roomName];
        self.emptyTitleLabel.text = NSLocalizedString(emptyTitleString, @"");
        //set attributed string
        NSMutableDictionary *emptyTitleAttributesDictionary = [NSMutableDictionary dictionary];
        [emptyTitleAttributesDictionary setObject:[UIFont fontWithName:TAP_FONT_NAME_BOLD size:15.0f] forKey:NSFontAttributeName];
        [emptyTitleAttributesDictionary setObject:[TAPUtil getColor:TAP_COLOR_MOSELO_PURPLE] forKey:NSForegroundColorAttributeName];
        NSMutableAttributedString *emptyTitleAttributedString = [[NSMutableAttributedString alloc] initWithString:self.emptyTitleLabel.text];
        
        if(self.emptyTitleLabel.text != nil && ![self.emptyTitleLabel.text isEqualToString:@""]) {
            NSRange roomNameRange = [self.emptyTitleLabel.text rangeOfString:roomName];
            [emptyTitleAttributedString addAttributes:emptyTitleAttributesDictionary
                                                range:roomNameRange];
            self.emptyTitleLabel.attributedText = emptyTitleAttributedString;
        }
        //End Temp
        
        self.emptyDescriptionLabel.text = @"Hey there! If you are looking for handmade gifts\nto give to someone special, please check out\nmy list of services and pricing below!";
        
        self.senderImageView.layer.borderWidth = 4.0f;
        self.senderImageView.layer.borderColor = [TAPUtil getColor:@"F8F8F8"].CGColor;
        self.senderImageView.layer.cornerRadius = CGRectGetHeight(self.senderImageView.frame) / 2.0f;
        [self.senderImageView setImageWithURLString:activeUser.imageURL.thumbnail];
        self.senderImageView.backgroundColor = [UIColor clearColor];
        
        self.recipientImageView.layer.borderWidth = 4.0f;
        self.recipientImageView.layer.borderColor = [TAPUtil getColor:@"F8F8F8"].CGColor;
        self.recipientImageView.layer.cornerRadius = CGRectGetHeight(self.senderImageView.frame) / 2.0f;
        [self.recipientImageView setImageWithURLString:room.imageURL.thumbnail];
        self.recipientImageView.backgroundColor = [UIColor clearColor];
        
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

- (void)firstLoadData {
    TAPRoomModel *roomData = [TAPChatManager sharedManager].activeRoom;
    NSString *roomID = roomData.roomID;
    
    NSDate *date = [NSDate date];
    NSTimeInterval createdDate = [date timeIntervalSince1970] * 1000.0f;
    
    [TAPDataManager getMessageWithRoomID:roomID lastMessageTimeStamp:[NSNumber numberWithDouble:createdDate] limitData:TAP_NUMBER_OF_ITEMS_CHAT success:^(NSArray<TAPMessageModel *> *messageArray) {
        if ([messageArray count] == 0) {
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
            [self updateMessageDataAndUIWithMessages:messageArray toTop:NO];
            
            TAPMessageModel *earliestMessage = [messageArray objectAtIndex:[messageArray count] - 1];
            NSNumber *minCreated = earliestMessage.created;
            _minCreatedMessage = minCreated;
            
            TAPMessageModel *latestMessage = [messageArray objectAtIndex:0];
            NSNumber *maxCreated = latestMessage.created;
            
            NSNumber *lastUpdated = [TAPDataManager getMessageLastUpdatedWithRoomID:roomID];
            if ([lastUpdated longLongValue] == 0 || lastUpdated == nil) {
                //First time call, set minCreated to lastUpdated preference
                [TAPDataManager setMessageLastUpdatedWithRoomID:roomID lastUpdated:minCreated];
            }
            
            //Call API Get After Message
            [TAPDataManager callAPIGetMessageAfterWithRoomID:roomID minCreated:minCreated success:^(NSArray *messageArray) {
                
                //Update View
                [self updateMessageDataAndUIWithMessages:messageArray toTop:YES];
                
                //Update leftover message status to delivered
                if ([messageArray count] != 0) {
                    [[TAPMessageStatusManager sharedManager] filterAndUpdateBulkMessageStatusToDeliveredWithArray:messageArray];
                }
                
                //Call API Before Message if count < 50
                if ([messageArray count] < TAP_NUMBER_OF_ITEMS_CHAT) {
                    [self fetchBeforeMessageFromAPIAndUpdateUIWithRoomID:roomID maxCreated:minCreated];
                }
                
            } failure:^(NSError *error) {
#ifdef DEBUG
                //Note - this alert only shown at debug
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Failed", @"") message:error.domain preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
                
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];
#endif
            }];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)retrieveExistingMessages {
    //Prevent retreive before message if already last page
    if (self.isLastPage) {
        return;
    }
    
    TAPMessageModel *lastMessage = [self.messageArray lastObject];
    
    if (self.apiBeforeLastCreated == [lastMessage.created longLongValue]) {
        return;
    }
    
    _apiBeforeLastCreated = [lastMessage.created longLongValue];
    
    [TAPDataManager getMessageWithRoomID:lastMessage.room.roomID lastMessageTimeStamp:lastMessage.created limitData:TAP_NUMBER_OF_ITEMS_CHAT success:^(NSArray<TAPMessageModel *> *messageArray) {
        if ([messageArray count] > 0) {
            [self updateMessageDataAndUIWithMessages:messageArray toTop:NO];
        }
        
        //Call API Before when message array less than limit (50)
        if ([messageArray count] < TAP_NUMBER_OF_ITEMS_CHAT) {
            [self fetchBeforeMessageFromAPIAndUpdateUIWithRoomID:lastMessage.room.roomID maxCreated:lastMessage.created];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)fetchBeforeMessageFromAPIAndUpdateUIWithRoomID:(NSString *)roomID maxCreated:(NSNumber *)maxCreated {
    //Call API Get Before Message
    if ([self.loadedMaxCreated longLongValue] != [maxCreated longLongValue]) {
        _loadedMaxCreated = maxCreated;
        [TAPDataManager callAPIGetMessageBeforeWithRoomID:roomID maxCreated:maxCreated success:^(NSArray *messageArray, BOOL hasMore) {
            if ([messageArray count] != 0) {
                
                _isLastPage = !hasMore;
                
                //Update View
                [self updateMessageDataAndUIWithMessages:messageArray toTop:NO];
            }
        } failure:^(NSError *error) {
#ifdef DEBUG
            //Note - this alert only shown at debug
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Failed", @"") message:error.domain preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
#endif
        }];
    }
}

- (void)updateMessageDataAndUIWithMessages:(NSArray *)messageArray toTop:(BOOL)toTop {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        for (TAPMessageModel *message in messageArray) {
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
            }
        }
        
        [self sortAndFilterMessageArray];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            
            if (toTop) {
                //RN To Do - Scroll to "Unread Message" marker after implemented
                [self.tableView scrollsToTop];
            }
            
            [self checkEmptyState];
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
    
    currentMessage.isHidden = message.isHidden;
}

- (IBAction)handleTapOnTableView:(UITapGestureRecognizer *)gestureRecognizer {
    [self.keyboardViewController setKeyboardHeight:0.0f];
    [UIView animateWithDuration:0.2f animations:^{
        self.secondaryTextField.inputView.frame = CGRectMake(CGRectGetMinX(self.secondaryTextField.inputView.frame), 0.0f, CGRectGetWidth(self.secondaryTextField.inputView.frame), CGRectGetHeight(self.secondaryTextField.inputView.frame));
    }];
    
    //set keyboard state to default
    _keyboardState = keyboardStateDefault;
    [self.keyboardOptionButton setImage:[UIImage imageNamed:@"TAPIconHamburger" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    
    [self.messageTextView resignFirstResponder];
    [self.secondaryTextField resignFirstResponder];
}

- (void)callAPIAfterAndUpdateUIAndScrollToTop:(BOOL)scrollToTop {
    TAPRoomModel *roomData = [TAPChatManager sharedManager].activeRoom;
    NSString *roomID = roomData.roomID;
    
    [TAPDataManager callAPIGetMessageAfterWithRoomID:roomID minCreated:self.minCreatedMessage success:^(NSArray *messageArray) {
        //Update View
        [self updateMessageDataAndUIWithMessages:messageArray toTop:scrollToTop];
        
        //Update leftover message status to delivered
        if ([messageArray count] != 0) {
            [[TAPMessageStatusManager sharedManager] filterAndUpdateBulkMessageStatusToDeliveredWithArray:messageArray];
        }
        
    } failure:^(NSError *error) {
        
    }];
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

- (void)applicationWillEnterForegroundNotification:(NSNotification *)notification {
    [self callAPIAfterAndUpdateUIAndScrollToTop:YES];
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
        if (self.chatAnchorBadgeView.alpha != 1.0f && self.chatAnchorButton.alpha == 1.0f) {
            [UIView animateWithDuration:0.2f animations:^{
                self.chatAnchorBadgeView.alpha = 1.0f;
            }];
        }
        
        self.chatAnchorBadgeLabel.text = [NSString stringWithFormat:@"%li", [self.anchorUnreadMessageArray count]];
    }
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

- (void)profileImageDidTapped {
    TAPProfileViewController *profileViewController = [[TAPProfileViewController alloc] init];
    profileViewController.room = [TAPChatManager sharedManager].activeRoom;
    [self.navigationController pushViewController:profileViewController animated:YES];
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
//        photoAlbumListViewController.currentTotalImageData = [self.imageDataArray count];
        [photoAlbumListViewController setPhotoAlbumListViewControllerType:TAPPhotoAlbumListViewControllerTypeDefault];
        photoAlbumListViewController.delegate = self;
        UINavigationController *photoAlbumListNavigationController = [[UINavigationController alloc] initWithRootViewController:photoAlbumListViewController];
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

- (void)timerRefreshLastSeen {
    NSTimeInterval currentLastSeen = (double)self.onlineStatus.lastActive.doubleValue/1000.0f;
    [self updateLastSeenWithTimestamp:currentLastSeen];
}

- (void)updateLastSeenWithTimestamp:(NSTimeInterval)timestamp {
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
        lastSeenString = NSLocalizedString(@"Active now", @"");
        [self isShowOnlineDotStatus:YES];
    }
    else if (timestamp == 0) {
        lastSeenString = @"";
    }
    else if (timeGap <= midnightTimeGap) {
        if (timeGap < 60.0f) {
            //Set recently
            lastSeenString = NSLocalizedString(@"Last seen recently", @"");
        }
        else if (timeGap < 3600.0f) {
            //Set minutes before
            NSInteger numberOfMinutes = floor(timeGap/60.0f);
            
            NSString *minuteString = NSLocalizedString(@"minutes", @"");
            
            if (timeGap < 120.0f) {
                minuteString = NSLocalizedString(@"minute", @"");
            }
            
            lastSeenString = [NSString stringWithFormat:NSLocalizedString(@"Last seen %li %@ ago", @""), (long)numberOfMinutes, minuteString];
        }
        else {
            //Set hour before
            NSInteger numberOfHours = round(timeGap/3600.0f);
            
            NSString *hourString = NSLocalizedString(@"hours", @"");
            
            if (timeGap < 120.0f) {
                hourString = NSLocalizedString(@"hour", @"");
            }
            
            lastSeenString = [NSString stringWithFormat:NSLocalizedString(@"Last seen %li %@ ago", @""), (long)numberOfHours, hourString];
        }
    }
    else if (timeGap <= 86400.0f * 6 + midnightTimeGap) {
        //Set days ago
        
        NSInteger numberOfDays = floor(timeGap/86400.0f);
        
        if (numberOfDays == 0) {
            numberOfDays = 1;
        }
        
        NSString *dayString = NSLocalizedString(@"days", @"");
        
        if (timeGap <= 86400.0f) {
            dayString = NSLocalizedString(@"day", @"");
        }
        
        lastSeenString = [NSString stringWithFormat:NSLocalizedString(@"Last seen %li %@ ago", @""), (long)numberOfDays, dayString];
    }
    else if (timeGap <= 86400.0f*7 + midnightTimeGap) {
        //Set a week ago
        lastSeenString = @"Last seen a week ago";
    }
    else {
        //Set date
        NSDate *lastLoginDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd/MM/YY";
        NSString *formattedCreatedDate = [dateFormatter stringFromDate:lastLoginDate];
        
        lastSeenString = [NSString stringWithFormat:@"Last seen %@", formattedCreatedDate];
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
        self.userStatusView.frame = CGRectMake(0.0f, (16.0f - 7.0f) / 2.0f + 1.6f, 7.0f, 7.0f);
        self.userStatusView.alpha = 1.0f;
        self.userStatusLabel.frame = CGRectMake(CGRectGetMaxX(self.userStatusView.frame) + 4.0f, 0.0f, 0.0f, 16.0f);
    }
    else {
        self.userStatusView.frame = CGRectZero;
        self.userStatusView.alpha = 0.0f;
        self.userStatusLabel.frame = CGRectMake(0.0f, 0.0f, 0.0f, 16.0f);
    }
}

//Implement Input Accessory View
- (UIView *)inputAccessoryView {
    return self.inputMessageAccessoryView;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)processMessageAsRead:(TAPMessageModel *)message {
    BOOL isRead = message.isRead;
    
    if(!self.isViewDidAppeared) {
        //Do not process mark as read if from first view layout, visible message will be processed at processVisibleMessageAsRead
        return;
    }
    
    if(isRead) {
        //Do not process if message has been read
        return;
    }
    
    //Remove local notification and send read status to server
    NSLog(@"READ MESSAGE: %@", message.body);
    
    message.isRead = YES;
    
    //Call Message Status Manager mark as read call API
    [[TAPMessageStatusManager sharedManager] markMessageAsReadWithMessage:message];
    
    //Call Notification Manager remove local notification
    [[TAPNotificationManager sharedManager] removeReadLocalNotificationWithMessage:message];
}

- (void)processVisibleMessageAsRead {
    NSArray *visibleCellIndexPathArray = [self.tableView indexPathsForVisibleRows];
    
    for(NSIndexPath *indexPath in visibleCellIndexPathArray) {
        TAPMessageModel *currentMessage = [self.messageArray objectAtIndex:indexPath.row];
        
        if (![currentMessage.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
            //Their chat
            [self processMessageAsRead:currentMessage];
        }
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

- (void)setAsTyping:(BOOL)typing {
    if(typing) {
        self.userTypingView.alpha = 1.0f;
        self.userDescriptionView.alpha = 0.0f;
        [self performSelector:@selector(setAsTypingNoAfterDelay) withObject:nil afterDelay:15.0f];
    }
    else {
        self.userTypingView.alpha = 0.0f;
        self.userDescriptionView.alpha = 1.0f;
    }
}

- (NSString *)getOtherUserIDWithRoomID:(NSString *)roomID {
    NSArray *roomIDArray = [roomID componentsSeparatedByString:@"-"];
    if([roomIDArray count] > 0) {
        for (NSString *userID in roomIDArray) {
            if(![userID isEqualToString:[TAPDataManager getActiveUser].userID]) {
                return userID;
            }
        }
    }
    
    return @"";
}

- (void)setAsTypingNoAfterDelay {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setAsTypingNoAfterDelay) object:nil];
    self.userTypingView.alpha = 0.0f;
    self.userDescriptionView.alpha = 1.0f;
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
    }
    else {
        _currentInputAccessoryExtensionHeight = 0.0f;

        if (self.isKeyboardShowed) {
            _keyboardHeight = kInputMessageAccessoryViewHeight + self.safeAreaBottomPadding + self.currentInputAccessoryExtensionHeight + self.initialKeyboardHeight;
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
    
        [[TAPChatManager sharedManager] removeQuotedMessageObjectWithRoomID:self.currentRoom.roomID];
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

- (void)setReplyMessageWithMessage:(TAPMessageModel *)message {
    self.replyMessageNameLabel.text = [TAPUtil nullToEmptyString:message.user.fullname];;
    self.replyMessageMessageLabel.text = [TAPUtil nullToEmptyString:message.body];
}

- (void)setQuoteWithQuote:(TAPQuoteModel *)quote {
    self.quoteTitleLabel.text = quote.title;
    self.quoteSubtitleLabel.text = quote.content;
    if (quote.imageURL != nil && ![quote.imageURL isEqualToString:@""]) {
        [self.quoteImageView setImageWithURLString:quote.imageURL];
    }
    else if (quote.fileID != nil && ![quote.fileID isEqualToString:@""]) {
        [self.quoteImageView setImageWithURLString:quote.fileID];
    }
}

- (IBAction)inputAccessoryExtensionCloseButtonDidTapped:(id)sender {
    [self showInputAccessoryExtensionView:NO];
}

- (void)showImagePreviewControllerWithSelectedImage:(UIImage *)image {
    TAPImagePreviewViewController *imagePreviewViewController = [[TAPImagePreviewViewController alloc] init];
    imagePreviewViewController.delegate = self;
    
    TAPImagePreviewModel *imagePreview = [TAPImagePreviewModel new];
    imagePreview.image = image;
    
    [imagePreviewViewController setImagePreviewData:@[imagePreview]];
    UINavigationController *imagePreviewNavigationController = [[UINavigationController alloc] initWithRootViewController:imagePreviewViewController];
    [self.navigationController presentViewController:imagePreviewNavigationController animated:YES completion:nil];
}

- (void)fileUploadManagerProgressNotification:(NSNotification *)notification {
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
    
    TAPMessageModel *currentMessage = [self.messageDictionary objectForKey:localID];
    NSInteger currentRowIndex = [self.messageArray indexOfObject:currentMessage];
    
    TAPChatMessageType type = currentMessage.type;
    if (type == TAPChatMessageTypeImage) {
        TAPMyImageBubbleTableViewCell *cell = (TAPMyImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
        [cell animateProgressUploadingImageWithProgress:progress total:total];
    }
}

- (void)fileUploadManagerStartNotification:(NSNotification *)notification {
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
    
    TAPMessageModel *currentMessage = [self.messageDictionary objectForKey:localID];
    NSInteger currentRowIndex = [self.messageArray indexOfObject:currentMessage];
    
    TAPChatMessageType type = currentMessage.type;
    if (type == TAPChatMessageTypeImage) {
        
        TAPMyImageBubbleTableViewCell *cell = (TAPMyImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
        
        [cell setInitialAnimateUploadingImageWithType:TAPMyImageBubbleTableViewCellStateTypeUploading];
    }
}

- (void)fileUploadManagerFinishNotification:(NSNotification *)notification {
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
    
    TAPMessageModel *currentMessage = [self.messageDictionary objectForKey:localID];
    NSInteger currentRowIndex = [self.messageArray indexOfObject:currentMessage];
    
    TAPChatMessageType type = currentMessage.type;
    if (type == TAPChatMessageTypeImage) {
        
        TAPMyImageBubbleTableViewCell *cell = (TAPMyImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
        [cell animateFinishedUploadingImage];
    }
}

- (void)fileUploadManagerFailureNotification:(NSNotification *)notification {
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
    
    TAPMessageModel *currentMessage = [self.messageDictionary objectForKey:localID];
    NSInteger currentRowIndex = [self.messageArray indexOfObject:currentMessage];
    
    //Update message status to array and dictionary
    currentMessage.isFailedSend = YES;
    currentMessage.isSending = NO;
    
    TAPChatMessageType type = currentMessage.type;
    if (type == TAPChatMessageTypeImage) {
        
        TAPMyImageBubbleTableViewCell *cell = (TAPMyImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
        [cell animateFailedUploadingImage];
    }

}

- (void)fetchImageDataWithMessage:(TAPMessageModel *)message {
    [[TAPFileDownloadManager sharedManager] receiveImageFileWithMessage:message start:^(TAPMessageModel * _Nonnull receivedMessage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            TAPRoomModel *currentRoom = [TAPChatManager sharedManager].activeRoom;
            NSString *currentActiveRoomID = currentRoom.roomID;
            currentActiveRoomID = [TAPUtil nullToEmptyString:currentActiveRoomID];
            
            NSString *roomID = receivedMessage.room.roomID;
            roomID = [TAPUtil nullToEmptyString:roomID];
            
            NSString *localID = receivedMessage.localID;
            localID = [TAPUtil nullToEmptyString:localID];
            
            if (![roomID isEqualToString:currentActiveRoomID]) {
                return;
            }
            
            TAPMessageModel *currentMessage = [self.messageDictionary objectForKey:localID];
            NSInteger currentRowIndex = [self.messageArray indexOfObject:currentMessage];
            
            TAPChatMessageType type = currentMessage.type;
            if (type == TAPChatMessageTypeImage) {
                
                if ([message.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                    //My Chat
                    TAPMyImageBubbleTableViewCell *cell = (TAPMyImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                    
                    if (message.isFailedSend) {
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
        });
    } progress:^(CGFloat progress, CGFloat total, TAPMessageModel * _Nonnull receivedMessage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            TAPRoomModel *currentRoom = [TAPChatManager sharedManager].activeRoom;
            NSString *currentActiveRoomID = currentRoom.roomID;
            currentActiveRoomID = [TAPUtil nullToEmptyString:currentActiveRoomID];
            
            NSString *roomID = receivedMessage.room.roomID;
            roomID = [TAPUtil nullToEmptyString:roomID];
            
            NSString *localID = receivedMessage.localID;
            localID = [TAPUtil nullToEmptyString:localID];
            
            if (![roomID isEqualToString:currentActiveRoomID]) {
                return;
            }
            
            TAPMessageModel *currentMessage = [self.messageDictionary objectForKey:localID];
            NSInteger currentRowIndex = [self.messageArray indexOfObject:currentMessage];
            
            TAPChatMessageType type = currentMessage.type;
            if (type == TAPChatMessageTypeImage) {
                
                if ([message.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
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
        });
    } success:^(UIImage * _Nonnull fullImage, TAPMessageModel * _Nonnull receivedMessage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            TAPRoomModel *currentRoom = [TAPChatManager sharedManager].activeRoom;
            NSString *currentActiveRoomID = currentRoom.roomID;
            currentActiveRoomID = [TAPUtil nullToEmptyString:currentActiveRoomID];
            
            NSString *roomID = receivedMessage.room.roomID;
            roomID = [TAPUtil nullToEmptyString:roomID];
            
            NSString *localID = receivedMessage.localID;
            localID = [TAPUtil nullToEmptyString:localID];
            
            if (![roomID isEqualToString:currentActiveRoomID]) {
                return;
            }
            
            TAPMessageModel *currentMessage = [self.messageDictionary objectForKey:localID];
            NSInteger currentRowIndex = [self.messageArray indexOfObject:currentMessage];
            
            TAPChatMessageType type = currentMessage.type;
            if (type == TAPChatMessageTypeImage) {
                if ([message.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
                    //My Chat
                    TAPMyImageBubbleTableViewCell *cell = (TAPMyImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                    if (fullImage != nil) {
                        [cell setFullImage:fullImage];
                    }
                    [cell animateFinishedUploadingImage];
                }
                else {
                    //Their Chat
                    TAPYourImageBubbleTableViewCell *cell = (TAPYourImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
                    if (fullImage != nil) {
                        [cell setFullImage:fullImage];
                    }
                    [cell animateFinishedDownloadingImage];
                }
            }
        });
    } failure:^(NSError * _Nonnull error, TAPMessageModel * _Nonnull receivedMessage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            TAPRoomModel *currentRoom = [TAPChatManager sharedManager].activeRoom;
            NSString *currentActiveRoomID = currentRoom.roomID;
            currentActiveRoomID = [TAPUtil nullToEmptyString:currentActiveRoomID];
            
            NSString *roomID = receivedMessage.room.roomID;
            roomID = [TAPUtil nullToEmptyString:roomID];
            
            NSString *localID = receivedMessage.localID;
            localID = [TAPUtil nullToEmptyString:localID];
            
            if (![roomID isEqualToString:currentActiveRoomID]) {
                return;
            }
            
            TAPMessageModel *currentMessage = [self.messageDictionary objectForKey:localID];
            NSInteger currentRowIndex = [self.messageArray indexOfObject:currentMessage];
            
            TAPChatMessageType type = currentMessage.type;
            if (type == TAPChatMessageTypeImage) {
                
                if ([message.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
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
        });
    }];
}
    
//DV NOTE - Uncomment this to use API download thumbnail image
//- (void)fetchImageDataWithMessage:(TAPMessageModel *)message {
//
//    [[TAPFileDownloadManager sharedManager] receiveImageFileWithMessage:message progress:^(CGFloat progress, CGFloat total, TAPMessageModel * _Nonnull receivedMessage) {
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
//            NSInteger currentRowIndex = [self.messageArray indexOfObject:currentMessage];
//
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
//            NSInteger currentRowIndex = [self.messageArray indexOfObject:currentMessage];
//
//            TAPChatMessageType type = currentMessage.type;
//            if (type == TAPChatMessageTypeImage) {
//                if ([message.user.userID isEqualToString:[TAPChatManager sharedManager].activeUser.userID]) {
//                    //My Chat
//                    TAPMyImageBubbleTableViewCell *cell = (TAPMyImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
//                    if (fullImage != nil) {
//                        [cell setFullImage:fullImage];
//                    }
//                    [cell animateFinishedUploadingImage];
//                }
//                else {
//                    //Their Chat
//                    TAPYourImageBubbleTableViewCell *cell = (TAPYourImageBubbleTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentRowIndex inSection:0]];
//                    if (fullImage != nil) {
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

@end

