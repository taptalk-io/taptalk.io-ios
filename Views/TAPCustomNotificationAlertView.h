//
//  TAPCustomNotificationAlertView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 23/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseView.h"
#import "RNImageView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPCustomNotificationAlertView : TAPBaseView

@property (strong, nonatomic) UIView *firstNotificationView;
@property (strong, nonatomic) UIView *shadowView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) RNImageView *profilePictureImage;
@property (strong, nonatomic) RNImageView *contentImageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UIButton *notificationButton;

@property (strong, nonatomic) UIView *secondNotificationView;
@property (strong, nonatomic) UIView *secondaryShadowView;
@property (strong, nonatomic) UIView *secondaryContentView;
@property (strong, nonatomic) RNImageView *secondaryProfilePictureImage;
@property (strong, nonatomic) RNImageView *secondaryContentImageView;
@property (strong, nonatomic) UILabel *secondaryNameLabel;
@property (strong, nonatomic) UILabel *secondaryMessageLabel;
@property (strong, nonatomic) UIButton *secondaryNotificationButton;

@end

NS_ASSUME_NONNULL_END
