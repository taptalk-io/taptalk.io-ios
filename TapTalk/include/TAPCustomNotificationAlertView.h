//
//  TAPCustomNotificationAlertView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 23/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseView.h"
#import "TAPImageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPCustomNotificationAlertView : TAPBaseView

@property (strong, nonatomic) UIView *firstNotificationView;
@property (strong, nonatomic) UIView *shadowView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) TAPImageView *profilePictureImage;
@property (strong, nonatomic) TAPImageView *contentImageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UIButton *notificationButton;

@property (strong, nonatomic) UIView *secondNotificationView;
@property (strong, nonatomic) UIView *secondaryShadowView;
@property (strong, nonatomic) UIView *secondaryContentView;
@property (strong, nonatomic) TAPImageView *secondaryProfilePictureImage;
@property (strong, nonatomic) TAPImageView *secondaryContentImageView;
@property (strong, nonatomic) UILabel *secondaryNameLabel;
@property (strong, nonatomic) UILabel *secondaryMessageLabel;
@property (strong, nonatomic) UIButton *secondaryNotificationButton;

@end

NS_ASSUME_NONNULL_END
