//
//  TAPPinLocationView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 15/02/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPPinLocationView.h"

@interface TAPPinLocationView ()

@property (strong, nonatomic) UIView *sendLocationView;
@property (strong, nonatomic) UIView *sendIconView;
@property (strong, nonatomic) UILabel *sendLocationLabel;
@property (strong, nonatomic) UIImageView *sendIconImageView;
@property (strong, nonatomic) UIImageView *triangleImageView;

@end

@implementation TAPPinLocationView
#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _sendLocationView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - 15.0f)];
        self.sendLocationView.backgroundColor = [UIColor whiteColor];
        self.sendLocationView.layer.cornerRadius = 2.0f;
        self.sendLocationView.layer.shadowOffset = CGSizeMake(6.0f, 6.0f);
        self.sendLocationView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.sendLocationView.layer.shadowOpacity = 0.1f;
        self.sendLocationView.layer.shadowRadius = 6.0f;
        [self addSubview:self.sendLocationView];
        
        _sendIconView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.sendLocationView.frame) - 30.0f, 0.0f, 30.0f, 30.0f)];
        self.sendIconView.backgroundColor = [[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary];
        [self.sendLocationView addSubview:self.sendIconView];
        
        _sendIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
        self.sendIconImageView.image = [UIImage imageNamed:@"TapIconSend" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.sendIconView addSubview:self.sendIconImageView];
        
        UIFont *sendLocationLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontLocationPickerSendLocationButton];
        UIColor *sendLocationLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorLocationPickerSendLocationButton];
        _sendLocationLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0f, 8.0f, CGRectGetMinX(self.sendIconView.frame) - 8.0f - 8.0f, 14.0f)];
        self.sendLocationLabel.font = sendLocationLabelFont;
        self.sendLocationLabel.text = NSLocalizedString(@"Send Location", @"");
        self.sendLocationLabel.textColor = sendLocationLabelColor;
        self.sendLocationLabel.textAlignment = NSTextAlignmentCenter;
        [self.sendLocationView addSubview:self.sendLocationLabel];
        
        _triangleImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.sendLocationView.frame) - 23.0f) / 2.0f, CGRectGetMaxY(self.sendLocationView.frame) - 1.0f, 26.0f, 23.0f)];
        self.triangleImageView.image = [UIImage imageNamed:@"TAPIconLocationBottomTriangle" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self addSubview:self.triangleImageView];
    }
    
    return self;
}

#pragma mark - Custom Method
- (void)hideSendLocationView:(BOOL)isHidden {
    if (isHidden) {
        self.sendLocationView.frame = CGRectMake(-CGRectGetWidth(self.sendLocationView.frame) / 2.0f, -CGRectGetHeight(self.sendLocationView.frame), CGRectGetWidth(self.sendLocationView.frame), CGRectGetHeight(self.sendLocationView.frame));
        self.triangleImageView.frame = CGRectMake((CGRectGetWidth(self.sendLocationView.frame) - 23.0f) / 2.0f + CGRectGetMinX(self.sendLocationView.frame), CGRectGetMaxY(self.sendLocationView.frame) - 1.0f, CGRectGetWidth(self.triangleImageView.frame), CGRectGetHeight(self.triangleImageView.frame));
    }
    else {
        self.sendLocationView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.sendLocationView.frame), CGRectGetHeight(self.sendLocationView.frame));
        self.triangleImageView.frame = CGRectMake((CGRectGetWidth(self.sendLocationView.frame) - 23.0f) / 2.0f, CGRectGetMaxY(self.sendLocationView.frame) - 1.0f, CGRectGetWidth(self.triangleImageView.frame), CGRectGetHeight(self.triangleImageView.frame));
    }
}

@end
