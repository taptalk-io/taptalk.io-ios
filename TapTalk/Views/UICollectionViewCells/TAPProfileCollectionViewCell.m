//
//  TAPProfileCollectionViewCell.m
//  TapTalk
//
//  Created by Welly Kencana on 31/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPProfileCollectionViewCell.h"

@interface TAPProfileCollectionViewCell ()

@property (strong, nonatomic) UIImageView *iconImageView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UISwitch *switchButton;
@property (strong, nonatomic) UIView *separatorView;

@end

@implementation TAPProfileCollectionViewCell

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8.0f, (CGRectGetHeight(frame) - 32.0f) / 2.0f, 32.0f, 32.0f)];
        [self.contentView addSubview:self.iconImageView];
        
        CGFloat rightPadding = 16.0f;
        CGFloat switchWidth = 51.0f;
        CGFloat switchHeight = 31.0f;
        _switchButton = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame) - rightPadding - switchWidth, (CGRectGetHeight(frame) - switchHeight) / 2.0f, switchWidth, switchHeight)];
        self.switchButton.onTintColor = [TAPUtil getColor:TAP_COLOR_MOSELO_GREEN];
        self.switchButton.layer.cornerRadius = CGRectGetHeight(self.switchButton.frame) / 2.0f;
        self.switchButton.layer.borderWidth = 1.0f;
        [self.switchButton addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:self.switchButton];
        
        CGFloat titleXPosition = CGRectGetMaxX(self.iconImageView.frame) + 4.0f; //4.0f is left padding of title
        CGFloat titleWidth = CGRectGetMinX(self.switchButton.frame) - 4.0f - titleXPosition; //4.0f is right padding of title
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleXPosition, 0.0f, titleWidth, CGRectGetHeight(frame))];
        self.titleLabel.font = [UIFont fontWithName:TAP_FONT_LATO_REGULAR size:15.0f];
        self.titleLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
        [self.contentView addSubview:self.titleLabel];
        
        _separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(frame) - 1.0f, CGRectGetWidth(frame), 1.0f)];
        self.separatorView.backgroundColor = [TAPUtil getColor:@"E4E4E4"];
        [self.contentView addSubview:self.separatorView];
    }
    
    return self;
}

#pragma mark - Custom Method
- (void)showSeparatorView:(BOOL)isShowed {
    if (isShowed) {
        self.separatorView.alpha = 1.0f;
    }
    else {
        self.separatorView.alpha = 0.0f;
    }
}

- (void)setProfileCollectionViewCellType:(TAPProfileCollectionViewCellType)type {
    //WK Temp
    BOOL isMute = NO;
    BOOL isBlocked = YES;
    //End Temp
    
    if (type == profileCollectionViewCellTypeNotification) {
        self.titleLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
        self.titleLabel.text = NSLocalizedString(@"Notification", @"");
        
        self.switchButton.alpha = 1.0f;
        
        if (isMute) {
            [self.switchButton setOn:NO];
            self.switchButton.layer.borderColor = [TAPUtil getColor:@"D9D9D9"].CGColor;
            
            [self.iconImageView setImage:[UIImage imageNamed:@"TAPIconNotificationInactive" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil]];
        }
        else {
            [self.switchButton setOn:YES];
            self.switchButton.layer.borderColor = [TAPUtil getColor:TAP_COLOR_GREENBLUE_93].CGColor;
            
            [self.iconImageView setImage:[UIImage imageNamed:@"TAPIconNotificationActive" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil]];
        }
    }
    else if (type == profileCollectionViewCellTypeBlock) {
        [self.iconImageView setImage:[UIImage imageNamed:@"TAPIconBlockUser" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil]];
        
        self.titleLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
        
        self.switchButton.alpha = 0.0f;
        
        if (isBlocked) {
            self.titleLabel.text = NSLocalizedString(@"Unblock User", @"");
        }
        else {
            self.titleLabel.text = NSLocalizedString(@"Block User", @"");
        }
    }
    else if (type == profileCollectionViewCellTypeConversationColor) {
        [self.iconImageView setImage:[UIImage imageNamed:@"TAPIconConversationColor" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil]];
        
        self.titleLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
        self.titleLabel.text = NSLocalizedString(@"Conversation Color", @"");
        
        self.switchButton.alpha = 0.0f;
    }
    else if (type == profileCollectionViewCellTypeClearChat) {
        [self.iconImageView setImage:[UIImage imageNamed:@"TAPIconTrashBin" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil]];
        
        self.titleLabel.textColor = [TAPUtil getColor:@"EC2C2B"];
        self.titleLabel.text = NSLocalizedString(@"Clear Chat", @"");
        
        self.switchButton.alpha = 0.0f;
    }
}

- (void)switchValueChanged:(id)sender {
    if ([sender isOn]) {
        //CHANGED TO ON
        self.switchButton.layer.borderColor = [TAPUtil getColor:TAP_COLOR_GREENBLUE_93].CGColor;
        [self.iconImageView setImage:[UIImage imageNamed:@"TAPIconNotificationActive" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil]];
    }
    else {
        //CHANGED TO OFF
        self.switchButton.layer.borderColor = [TAPUtil getColor:@"D9D9D9"].CGColor;
        [self.iconImageView setImage:[UIImage imageNamed:@"TAPIconNotificationInactive" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil]];
    }
    
    //WK Temp - maybe delegate to view controller here.
}

@end
