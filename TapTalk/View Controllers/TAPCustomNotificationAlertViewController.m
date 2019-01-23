//
//  TAPCustomNotificationAlertViewController.m
//  TapTalk
//
//  Created by Dominic Vedericho on 23/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPCustomNotificationAlertViewController.h"
#import "TAPCustomNotificationAlertView.h"

@interface TAPCustomNotificationAlertViewController ()

@property (strong, nonatomic) TAPCustomNotificationAlertView *customNotificationAlertView;
@property (strong, nonatomic) NSMutableArray *messageQueueArray;

@property (strong, nonatomic) TAPMessageModel *currentFirstShownMessage;
@property (strong, nonatomic) TAPMessageModel *currentSecondaryShownMessage;

@property (nonatomic) BOOL isOnShowAnimation;
@property (nonatomic) BOOL isTappedFirstNotificationButton;
@property (nonatomic) BOOL isTappedSecondNotificationButton;
@property (nonatomic) NSInteger messageShownCounter;

- (void)hideAfterDelay;
- (void)checkMessageQueue;
- (void)fillDataWithMessage:(TAPMessageModel *)message;
- (void)notificationButtonDidTapped;
- (void)secondaryNotificationButtonDidTapped;

@end

@implementation TAPCustomNotificationAlertViewController

#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    
    CGFloat additionalSpacing = 20.0f;
    if (IS_IPHONE_X_FAMILY) {
        additionalSpacing = 44.0f;
    }
    
    _customNotificationAlertView = [[TAPCustomNotificationAlertView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 66.0f + additionalSpacing)];
    [self.view addSubview:self.customNotificationAlertView];
    
    self.view.backgroundColor = [UIColor clearColor];
//    self.view.frame = CGRectMake(0.0f, -CGRectGetHeight(self.view.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    
    self.customNotificationAlertView.firstNotificationView.frame = CGRectMake(CGRectGetMinX(self.customNotificationAlertView.firstNotificationView.frame), -CGRectGetHeight(self.customNotificationAlertView.firstNotificationView.frame), CGRectGetWidth(self.customNotificationAlertView.firstNotificationView.frame), CGRectGetHeight(self.customNotificationAlertView.firstNotificationView.frame));
    
    self.customNotificationAlertView.secondNotificationView.frame = CGRectMake(CGRectGetMinX(self.customNotificationAlertView.secondNotificationView.frame), -CGRectGetHeight(self.customNotificationAlertView.secondNotificationView.frame), CGRectGetWidth(self.customNotificationAlertView.secondNotificationView.frame), CGRectGetHeight(self.customNotificationAlertView.secondNotificationView.frame));
    
    self.view.alpha = 0.0f;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.customNotificationAlertView.notificationButton addTarget:self action:@selector(notificationButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.customNotificationAlertView.secondaryNotificationButton addTarget:self action:@selector(secondaryNotificationButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];

    _messageQueueArray = [[NSMutableArray alloc] init];
}

#pragma mark - Custom Method

- (void)checkMessageQueue {
    if ([self.messageQueueArray count] > 0) {
        TAPMessageModel *message = [self.messageQueueArray firstObject];
//        [self.messageQueueArray removeObject:message];
        [self.messageQueueArray removeObjectAtIndex:0];
        
        [self animateShowMessage:message];
    }
    else {
        [self performSelector:@selector(hideAfterDelay) withObject:nil afterDelay:2.0f];
    }
}

- (void)showWithMessage:(TAPMessageModel *)message {
    
    if ([message.user.userID isEqualToString:[TAPDataManager getActiveUser].userID]) {
        return;
    }
    
    if ([self.messageQueueArray count] != 0) {
        //Put message in queue
        [self.messageQueueArray addObject:message];
    }
    else {
        //Show message
        [self animateShowMessage:message];
    }
}

- (void)animateShowMessage:(TAPMessageModel *)message {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideAfterDelay) object:nil];
    
//    _messageShownCounter++;
    
    if (self.view.alpha == 0.0f) {
        _messageShownCounter++;
        //Show animation
        [self fillDataWithMessage:message];
        
        self.view.alpha = 1.0f;
        _isOnShowAnimation = YES;
        
        [UIView animateWithDuration:0.3f animations:^{
            if (self.messageShownCounter % 2 == 1) {
                //Odd Message, show first notification view
                self.customNotificationAlertView.firstNotificationView.frame = CGRectMake(CGRectGetMinX(self.customNotificationAlertView.firstNotificationView.frame), 0.0f, CGRectGetWidth(self.customNotificationAlertView.firstNotificationView.frame), CGRectGetHeight(self.customNotificationAlertView.firstNotificationView.frame));
            }
            else {
                //Even Message, show secondary notification view
                self.customNotificationAlertView.secondNotificationView.frame = CGRectMake(CGRectGetMinX(self.customNotificationAlertView.secondNotificationView.frame), 0.0f, CGRectGetWidth(self.customNotificationAlertView.secondNotificationView.frame), CGRectGetHeight(self.customNotificationAlertView.secondNotificationView.frame));
            }
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _isOnShowAnimation = NO;
                [self checkMessageQueue];
            });
        }];
    }
    else {
        //Alert already shown, proceed queue
        if (!self.isOnShowAnimation) {
            
            _messageShownCounter++;
            
            [self fillDataWithMessage:message];
            
            [UIView animateWithDuration:0.3f animations:^{
                if (self.messageShownCounter % 2 == 1) {
                    //Odd Message, show first notification view
//                    [self.view bringSubviewToFront:self.customNotificationAlertView.firstNotificationView];
                    self.customNotificationAlertView.firstNotificationView.layer.zPosition = 1;
                    
                    self.customNotificationAlertView.firstNotificationView.frame = CGRectMake(CGRectGetMinX(self.customNotificationAlertView.firstNotificationView.frame), 0.0f, CGRectGetWidth(self.customNotificationAlertView.firstNotificationView.frame), CGRectGetHeight(self.customNotificationAlertView.firstNotificationView.frame));
                    
                    self.customNotificationAlertView.secondNotificationView.frame = CGRectMake(CGRectGetMinX(self.customNotificationAlertView.secondNotificationView.frame), -CGRectGetHeight(self.customNotificationAlertView.secondNotificationView.frame), CGRectGetWidth(self.customNotificationAlertView.secondNotificationView.frame), CGRectGetHeight(self.customNotificationAlertView.secondNotificationView.frame));
                }
                else {
                    //Even Message, show secondary notification view
//                    [self.view bringSubviewToFront:self.customNotificationAlertView.secondNotificationView];
                    self.customNotificationAlertView.secondNotificationView.layer.zPosition = 1;
                    
                    self.customNotificationAlertView.secondNotificationView.frame = CGRectMake(CGRectGetMinX(self.customNotificationAlertView.secondNotificationView.frame), 0.0f, CGRectGetWidth(self.customNotificationAlertView.secondNotificationView.frame), CGRectGetHeight(self.customNotificationAlertView.secondNotificationView.frame));
                    
                    self.customNotificationAlertView.firstNotificationView.frame = CGRectMake(CGRectGetMinX(self.customNotificationAlertView.firstNotificationView.frame), -CGRectGetHeight(self.customNotificationAlertView.firstNotificationView.frame), CGRectGetWidth(self.customNotificationAlertView.firstNotificationView.frame), CGRectGetHeight(self.customNotificationAlertView.firstNotificationView.frame));
                }
            } completion:^(BOOL finished) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    _isOnShowAnimation = NO;
                    [self checkMessageQueue];
                });
            }];
        }
        else {
            //Put message in queue
            [self.messageQueueArray addObject:message];
        }
    }
}

- (void)hideAfterDelay {
    [UIView animateWithDuration:0.3f animations:^{
        if (self.messageShownCounter % 2 == 1) {
            //Odd Message, show first notification view
            self.customNotificationAlertView.firstNotificationView.frame = CGRectMake(CGRectGetMinX(self.customNotificationAlertView.firstNotificationView.frame), -CGRectGetHeight(self.customNotificationAlertView.firstNotificationView.frame), CGRectGetWidth(self.customNotificationAlertView.firstNotificationView.frame), CGRectGetHeight(self.customNotificationAlertView.firstNotificationView.frame));
        }
        else {
            //Even Message, show secondary notification view
            self.customNotificationAlertView.secondNotificationView.frame = CGRectMake(CGRectGetMinX(self.customNotificationAlertView.secondNotificationView.frame), -CGRectGetHeight(self.customNotificationAlertView.secondNotificationView.frame), CGRectGetWidth(self.customNotificationAlertView.secondNotificationView.frame), CGRectGetHeight(self.customNotificationAlertView.secondNotificationView.frame));
        }
    } completion:^(BOOL finished) {
        self.view.alpha = 0.0f;
        _messageShownCounter = 0;
        
        if (self.messageShownCounter % 2 == 1) {
            _isTappedFirstNotificationButton = NO;
        }
        else {
            _isTappedSecondNotificationButton = NO;
        }
    }];
}

- (void)fillDataWithMessage:(TAPMessageModel *)message {
    
    if (self.messageShownCounter == 0) {
        return;
    }
    
    TAPUserModel *user = message.user;
    NSString *profilePictureURL = user.imageURL.thumbnail;
//    NSString *profilePictureURL = TAP_DUMMY_IMAGE_URL; //DV Temp
    NSString *nameString = message.user.fullname;
    NSString *messageString = message.body;
    NSString *contentImageURL = @""; //DV Temp
    
    BOOL isShowProfilePicture = NO;
    BOOL isShowContentImage = NO; //DV Temp
    
    if (profilePictureURL == nil || [profilePictureURL isEqualToString:@""]) {
        //Hide profile picture
        isShowProfilePicture = NO;
    }
    else {
        isShowProfilePicture = YES;
    }
    
    if (contentImageURL == nil || [contentImageURL isEqualToString:@""]) {
        //Hide content image
        isShowContentImage = NO;
    }
    else {
        isShowContentImage = YES;
    }
    
    if (self.messageShownCounter % 2 == 1) {
        //Odd message, show first notification view
        _currentFirstShownMessage = message;
        self.customNotificationAlertView.nameLabel.text = nameString;
        self.customNotificationAlertView.messageLabel.text = messageString;
        [self showFirstAnimationWithProfileImage:isShowProfilePicture contentImage:isShowContentImage profilePictureURL:profilePictureURL contentImageURL:contentImageURL];
    }
    else {
        //Even message, show secondary notification view
        _currentSecondaryShownMessage = message;
        self.customNotificationAlertView.secondaryNameLabel.text = nameString;
        self.customNotificationAlertView.secondaryMessageLabel.text = messageString;
        [self showSecondaryAnimationWithProfileImage:isShowProfilePicture contentImage:isShowContentImage profilePictureURL:profilePictureURL contentImageURL:contentImageURL];
    }
}

- (void)showFirstAnimationWithProfileImage:(BOOL)hasProfileImage contentImage:(BOOL)hasContentImage profilePictureURL:(NSString *)profilePictureURL contentImageURL:(NSString *)contentImageURL {
    if (!hasProfileImage && !hasContentImage) {
        //Hide profile picture & content image
        self.customNotificationAlertView.profilePictureImage.alpha = 0.0f;
        self.customNotificationAlertView.contentImageView.alpha = 0.0f;
        
        CGFloat nameLabelWidth = CGRectGetWidth(self.customNotificationAlertView.contentView.frame) - 8.0f - 8.0f;
        
        self.customNotificationAlertView.nameLabel.frame = CGRectMake(8.0f, CGRectGetMinY(self.customNotificationAlertView.nameLabel.frame), nameLabelWidth, CGRectGetHeight(self.customNotificationAlertView.nameLabel.frame));
        
        self.customNotificationAlertView.messageLabel.frame = CGRectMake(CGRectGetMinX(self.customNotificationAlertView.nameLabel.frame), CGRectGetMaxY(self.customNotificationAlertView.nameLabel.frame), CGRectGetWidth(self.customNotificationAlertView.nameLabel.frame), CGRectGetHeight(self.customNotificationAlertView.messageLabel.frame));
        
        self.customNotificationAlertView.profilePictureImage.image = nil;
        self.customNotificationAlertView.contentImageView.image = nil;
    }
    else if (!hasProfileImage) {
        //Hide profile picture
        self.customNotificationAlertView.profilePictureImage.alpha = 0.0f;
        self.customNotificationAlertView.contentImageView.alpha = 1.0f;
        
        CGFloat nameLabelRightGap = 8.0f;
        CGFloat paddingRight = 8.0f;
        
        CGFloat nameLabelWidth = CGRectGetWidth(self.customNotificationAlertView.contentView.frame) - nameLabelRightGap - CGRectGetWidth(self.customNotificationAlertView.contentImageView.frame) - paddingRight;
        
        self.customNotificationAlertView.nameLabel.frame = CGRectMake(8.0, CGRectGetMinY(self.customNotificationAlertView.nameLabel.frame), nameLabelWidth, CGRectGetHeight(self.customNotificationAlertView.nameLabel.frame));
        
        self.customNotificationAlertView.messageLabel.frame = CGRectMake(CGRectGetMinX(self.customNotificationAlertView.nameLabel.frame), CGRectGetMaxY(self.customNotificationAlertView.nameLabel.frame), CGRectGetWidth(self.customNotificationAlertView.nameLabel.frame), CGRectGetHeight(self.customNotificationAlertView.messageLabel.frame));
        
        self.customNotificationAlertView.profilePictureImage.image = nil;
        [self.customNotificationAlertView.contentImageView setImageWithURLString:contentImageURL];
    }
    else if (!hasContentImage) {
        //Hide Content Image
        self.customNotificationAlertView.contentImageView.alpha = 0.0f;
        self.customNotificationAlertView.profilePictureImage.alpha = 1.0f;
        
        CGFloat profilePictureImageRightGap = 8.0f;
        CGFloat paddingRight = 8.0f;
        
        CGFloat nameLabelWidth = CGRectGetWidth(self.customNotificationAlertView.contentView.frame) - CGRectGetMaxX(self.customNotificationAlertView.profilePictureImage.frame) - profilePictureImageRightGap - paddingRight;
        
        self.customNotificationAlertView.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.customNotificationAlertView.profilePictureImage.frame) + profilePictureImageRightGap, CGRectGetMinY(self.customNotificationAlertView.nameLabel.frame), nameLabelWidth, CGRectGetHeight(self.customNotificationAlertView.nameLabel.frame));
        
        self.customNotificationAlertView.messageLabel.frame = CGRectMake(CGRectGetMinX(self.customNotificationAlertView.nameLabel.frame), CGRectGetMaxY(self.customNotificationAlertView.nameLabel.frame), CGRectGetWidth(self.customNotificationAlertView.nameLabel.frame), CGRectGetHeight(self.customNotificationAlertView.messageLabel.frame));
        
        self.customNotificationAlertView.contentImageView.image = nil;
        [self.customNotificationAlertView.profilePictureImage setImageWithURLString:profilePictureURL];
    }
    else {
        //Show profile picture & content image
        self.customNotificationAlertView.profilePictureImage.alpha = 1.0f;
        self.customNotificationAlertView.contentImageView.alpha = 1.0f;
        
        CGFloat profilePictureImageRightGap = 8.0f;
        CGFloat nameLabelRightGap = 8.0f;
        CGFloat paddingRight = 8.0f;
        
        CGFloat nameLabelWidth = CGRectGetWidth(self.customNotificationAlertView.contentView.frame) - CGRectGetMaxX(self.customNotificationAlertView.profilePictureImage.frame) - profilePictureImageRightGap - nameLabelRightGap - CGRectGetWidth(self.customNotificationAlertView.contentImageView.frame) - paddingRight;
        
        
        self.customNotificationAlertView.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.customNotificationAlertView.profilePictureImage.frame) + 13.0f, 14.0f, nameLabelWidth, 17.0f);
        
        self.customNotificationAlertView.messageLabel.frame = CGRectMake(CGRectGetMinX(self.customNotificationAlertView.nameLabel.frame), CGRectGetMaxY(self.customNotificationAlertView.nameLabel.frame), CGRectGetWidth(self.customNotificationAlertView.nameLabel.frame), 17.0f);
        
        [self.customNotificationAlertView.profilePictureImage setImageWithURLString:profilePictureURL];
        [self.customNotificationAlertView.contentImageView setImageWithURLString:contentImageURL];
    }
}

- (void)showSecondaryAnimationWithProfileImage:(BOOL)hasProfileImage contentImage:(BOOL)hasContentImage profilePictureURL:(NSString *)profilePictureURL contentImageURL:(NSString *)contentImageURL {
    if (!hasProfileImage && !hasContentImage) {
        //Hide profile picture & content image
        self.customNotificationAlertView.secondaryProfilePictureImage.alpha = 0.0f;
        self.customNotificationAlertView.secondaryContentImageView.alpha = 0.0f;
        
        CGFloat nameLabelWidth = CGRectGetWidth(self.customNotificationAlertView.secondaryContentView.frame) - 8.0f - 8.0f;
        
        self.customNotificationAlertView.secondaryNameLabel.frame = CGRectMake(8.0f, CGRectGetMinY(self.customNotificationAlertView.secondaryNameLabel.frame), nameLabelWidth, CGRectGetHeight(self.customNotificationAlertView.secondaryNameLabel.frame));
        
        self.customNotificationAlertView.secondaryMessageLabel.frame = CGRectMake(CGRectGetMinX(self.customNotificationAlertView.secondaryNameLabel.frame), CGRectGetMaxY(self.customNotificationAlertView.secondaryNameLabel.frame), CGRectGetWidth(self.customNotificationAlertView.secondaryNameLabel.frame), CGRectGetHeight(self.customNotificationAlertView.secondaryMessageLabel.frame));
        
        self.customNotificationAlertView.secondaryProfilePictureImage.image = nil;
        self.customNotificationAlertView.secondaryContentImageView.image = nil;
    }
    else if (!hasProfileImage) {
        //Hide profile picture
        self.customNotificationAlertView.secondaryProfilePictureImage.alpha = 0.0f;
        self.customNotificationAlertView.secondaryContentImageView.alpha = 1.0f;
        
        CGFloat nameLabelRightGap = 8.0f;
        CGFloat paddingRight = 8.0f;
        
        CGFloat nameLabelWidth = CGRectGetWidth(self.customNotificationAlertView.secondaryContentView.frame) - nameLabelRightGap - CGRectGetWidth(self.customNotificationAlertView.secondaryContentImageView.frame) - paddingRight;
        
        self.customNotificationAlertView.secondaryNameLabel.frame = CGRectMake(8.0, CGRectGetMinY(self.customNotificationAlertView.secondaryNameLabel.frame), nameLabelWidth, CGRectGetHeight(self.customNotificationAlertView.secondaryNameLabel.frame));
        
        self.customNotificationAlertView.secondaryMessageLabel.frame = CGRectMake(CGRectGetMinX(self.customNotificationAlertView.secondaryNameLabel.frame), CGRectGetMaxY(self.customNotificationAlertView.secondaryNameLabel.frame), CGRectGetWidth(self.customNotificationAlertView.secondaryNameLabel.frame), CGRectGetHeight(self.customNotificationAlertView.secondaryMessageLabel.frame));
        
        self.customNotificationAlertView.secondaryProfilePictureImage.image = nil;
        [self.customNotificationAlertView.secondaryContentImageView setImageWithURLString:contentImageURL];
    }
    else if (!hasContentImage) {
        //Hide Content Image
        self.customNotificationAlertView.secondaryContentImageView.alpha = 0.0f;
        self.customNotificationAlertView.secondaryProfilePictureImage.alpha = 1.0f;
        
        CGFloat profilePictureImageRightGap = 8.0f;
        CGFloat paddingRight = 8.0f;
        
        CGFloat nameLabelWidth = CGRectGetWidth(self.customNotificationAlertView.secondaryContentView.frame) - CGRectGetMaxX(self.customNotificationAlertView.secondaryProfilePictureImage.frame) - profilePictureImageRightGap - paddingRight;
        
        self.customNotificationAlertView.secondaryNameLabel.frame = CGRectMake(CGRectGetMaxX(self.customNotificationAlertView.secondaryProfilePictureImage.frame) + profilePictureImageRightGap, CGRectGetMinY(self.customNotificationAlertView.secondaryNameLabel.frame), nameLabelWidth, CGRectGetHeight(self.customNotificationAlertView.secondaryNameLabel.frame));
        
        self.customNotificationAlertView.secondaryMessageLabel.frame = CGRectMake(CGRectGetMinX(self.customNotificationAlertView.secondaryNameLabel.frame), CGRectGetMaxY(self.customNotificationAlertView.secondaryNameLabel.frame), CGRectGetWidth(self.customNotificationAlertView.secondaryNameLabel.frame), CGRectGetHeight(self.customNotificationAlertView.secondaryMessageLabel.frame));
        
        self.customNotificationAlertView.secondaryContentImageView.image = nil;
        [self.customNotificationAlertView.secondaryProfilePictureImage setImageWithURLString:profilePictureURL];
    }
    else {
        //Show profile picture & content image
        self.customNotificationAlertView.secondaryProfilePictureImage.alpha = 1.0f;
        self.customNotificationAlertView.secondaryContentImageView.alpha = 1.0f;
        
        self.customNotificationAlertView.secondaryNameLabel.frame = CGRectMake(CGRectGetMaxX(self.customNotificationAlertView.secondaryProfilePictureImage.frame) + 13.0f, 14.0f, CGRectGetWidth(self.customNotificationAlertView.frame) - (CGRectGetMaxX(self.customNotificationAlertView.secondaryProfilePictureImage.frame) + 13.0f) - 16.0f, 17.0f);
        
        self.customNotificationAlertView.secondaryMessageLabel.frame = CGRectMake(CGRectGetMinX(self.customNotificationAlertView.secondaryNameLabel.frame), CGRectGetMaxY(self.customNotificationAlertView.secondaryNameLabel.frame), CGRectGetWidth(self.customNotificationAlertView.secondaryNameLabel.frame), 17.0f);
        
        [self.customNotificationAlertView.secondaryProfilePictureImage setImageWithURLString:profilePictureURL];
        [self.customNotificationAlertView.secondaryContentImageView setImageWithURLString:contentImageURL];
    }
}


- (void)notificationButtonDidTapped {
    if (self.isTappedFirstNotificationButton == YES) {
        return;
    }
    
    _isTappedFirstNotificationButton = YES;
    if ([self.delegate respondsToSelector:@selector(customNotificationAlertViewControllerNotificationButtonDidTappedWithMessage:)]) {
        [self.delegate customNotificationAlertViewControllerNotificationButtonDidTappedWithMessage:self.currentFirstShownMessage];
    }
    _isTappedFirstNotificationButton = NO;
    
}

- (void)secondaryNotificationButtonDidTapped {
    if (self.isTappedSecondNotificationButton == YES) {
        return;
    }
    
    _isTappedSecondNotificationButton = YES;
    if ([self.delegate respondsToSelector:@selector(secondaryCustomNotificationAlertViewControllerNotificationButtonDidTappedWithMessage:)]) {
        [self.delegate secondaryCustomNotificationAlertViewControllerNotificationButtonDidTappedWithMessage:self.currentSecondaryShownMessage];
    }
    _isTappedSecondNotificationButton = NO;
    
}

@end
