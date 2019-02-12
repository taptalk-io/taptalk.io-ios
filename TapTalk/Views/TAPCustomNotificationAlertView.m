//
//  TAPCustomNotificationAlertView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 23/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPCustomNotificationAlertView.h"

@implementation TAPCustomNotificationAlertView

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        
        CGFloat contentViewYPosition = 20.0f;
        if (IS_IPHONE_X_FAMILY) {
            contentViewYPosition = 44.0f;
        }
        
        self.backgroundColor = [UIColor clearColor];
        
        _firstNotificationView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        self.firstNotificationView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.firstNotificationView];
        
        _shadowView = [[UIView alloc] initWithFrame:CGRectMake(16.0f, contentViewYPosition, CGRectGetWidth(self.frame) - 32.0f, CGRectGetHeight(self.frame) - contentViewYPosition)];
        self.shadowView.backgroundColor = [UIColor whiteColor];
        self.shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.shadowView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        self.shadowView.layer.shadowOpacity = 0.4f;
        self.shadowView.layer.shadowRadius = 4.0f;
        self.shadowView.layer.cornerRadius = 6.0f;
        [self.firstNotificationView addSubview:self.shadowView];
        
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(16.0f, contentViewYPosition, CGRectGetWidth(self.frame) - 32.0f, CGRectGetHeight(self.frame) - contentViewYPosition)];
        self.contentView.backgroundColor = [UIColor whiteColor];
//        self.contentView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.3f]; //DV Temp
        self.contentView.layer.cornerRadius = 6.0f;
        self.contentView.clipsToBounds = YES;
        [self.firstNotificationView addSubview:self.contentView];
        
        _profilePictureImage = [[TAPImageView alloc] initWithFrame:CGRectMake(8.0f, (CGRectGetHeight(self.contentView.frame) - 52.0f) / 2.0f, 52.0f, 52.0f)];
        self.profilePictureImage.layer.cornerRadius = CGRectGetHeight(self.profilePictureImage.frame)/2.0f;
        self.profilePictureImage.clipsToBounds = YES;
        self.profilePictureImage.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.profilePictureImage];
        
        _contentImageView = [[TAPImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.contentView.frame) - 52.0f - 8.0f, (CGRectGetHeight(self.contentView.frame) - 52.0f) / 2.0f, 52.0f, 52.0f)];
        self.contentImageView.layer.cornerRadius = 6.0f;
        self.contentImageView.clipsToBounds = YES;
        self.contentImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.contentImageView];
        
        CGFloat profilePictureImageRightGap = 8.0f;
        CGFloat nameLabelRightGap = 8.0f;
        CGFloat paddingRight = 8.0f;
        
        CGFloat nameLabelWidth = CGRectGetWidth(self.contentView.frame) - CGRectGetMaxX(self.profilePictureImage.frame) - profilePictureImageRightGap - nameLabelRightGap - CGRectGetWidth(self.contentImageView.frame) - paddingRight;
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.profilePictureImage.frame) + profilePictureImageRightGap, 15.0f, nameLabelWidth, 18.0f)];
        self.nameLabel.font = [UIFont fontWithName:TAP_FONT_NAME_BOLD size:14.0f];
        self.nameLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
        [self.contentView addSubview:self.nameLabel];
        
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.nameLabel.frame), CGRectGetMaxY(self.nameLabel.frame), CGRectGetWidth(self.nameLabel.frame), 18.0f)];
        self.messageLabel.font = [UIFont fontWithName:TAP_FONT_LATO_REGULAR size:13.0f];
        self.messageLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_2C];
        [self.contentView addSubview:self.messageLabel];
        
        _notificationButton = [[UIButton alloc] initWithFrame:self.contentView.frame];
        self.notificationButton.backgroundColor = [UIColor clearColor];
        [self.firstNotificationView addSubview:self.notificationButton];
        
        _secondNotificationView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        self.secondNotificationView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.secondNotificationView];
        
        _secondaryShadowView = [[UIView alloc] initWithFrame:CGRectMake(16.0f, contentViewYPosition, CGRectGetWidth(self.frame) - 32.0f, CGRectGetHeight(self.frame) - contentViewYPosition)];
        self.secondaryShadowView.backgroundColor = [UIColor whiteColor];
        self.secondaryShadowView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.secondaryShadowView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        self.secondaryShadowView.layer.shadowOpacity = 0.4f;
        self.secondaryShadowView.layer.shadowRadius = 4.0f;
        self.secondaryShadowView.layer.cornerRadius = 6.0f;
        [self.secondNotificationView addSubview:self.secondaryShadowView];
        
        _secondaryContentView = [[UIView alloc] initWithFrame:CGRectMake(16.0f, contentViewYPosition, CGRectGetWidth(self.frame) - 32.0f, CGRectGetHeight(self.frame) - contentViewYPosition)];
        self.secondaryContentView.backgroundColor = [UIColor whiteColor];
//        self.secondaryContentView.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.3]; //DV Temp
        self.secondaryContentView.layer.cornerRadius = 6.0f;
        self.secondaryContentView.clipsToBounds = YES;
        [self.secondNotificationView addSubview:self.secondaryContentView];
        
        _secondaryProfilePictureImage = [[TAPImageView alloc] initWithFrame:CGRectMake(8.0f, (CGRectGetHeight(self.contentView.frame) - 52.0f) / 2.0f, 52.0f, 52.0f)];
        self.secondaryProfilePictureImage.layer.cornerRadius = CGRectGetHeight(self.profilePictureImage.frame)/2.0f;
        self.secondaryProfilePictureImage.clipsToBounds = YES;
        self.secondaryProfilePictureImage.contentMode = UIViewContentModeScaleAspectFill;
        [self.secondaryContentView addSubview:self.secondaryProfilePictureImage];
        
        _secondaryContentImageView = [[TAPImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.secondaryContentView.frame) - 52.0f - 8.0f, (CGRectGetHeight(self.contentView.frame) - 52.0f) / 2.0f, 52.0f, 52.0f)];
        self.secondaryContentImageView.layer.cornerRadius = 6.0f;
        self.secondaryContentImageView.clipsToBounds = YES;
        self.secondaryContentImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.secondaryContentView addSubview:self.secondaryContentImageView];
        
        _secondaryNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.secondaryProfilePictureImage.frame) + profilePictureImageRightGap, 15.0f, nameLabelWidth, 18.0f)];
        self.secondaryNameLabel.font = [UIFont fontWithName:TAP_FONT_NAME_BOLD size:14.0f];
        self.secondaryNameLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
        [self.secondaryContentView addSubview:self.secondaryNameLabel];
        
        _secondaryMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.secondaryNameLabel.frame), CGRectGetMaxY(self.secondaryNameLabel.frame), CGRectGetWidth(self.secondaryNameLabel.frame), 18.0f)];
        self.secondaryMessageLabel.font = [UIFont fontWithName:TAP_FONT_LATO_REGULAR size:13.0f];
        self.secondaryMessageLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_2C];
        [self.secondaryContentView addSubview:self.secondaryMessageLabel];
        
        _secondaryNotificationButton = [[UIButton alloc] initWithFrame:self.secondaryContentView.frame];
        self.secondaryNotificationButton.backgroundColor = [UIColor clearColor];
        [self.secondNotificationView addSubview:self.secondaryNotificationButton];
    }
    
    return self;
}

#pragma mark - Custom Method

@end
