//
//  TAPSetupRoomListView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 02/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPSetupRoomListView.h"

@interface TAPSetupRoomListView ()

@property (strong, nonatomic) UIView *firstLoadOverlayView;
@property (strong, nonatomic) UIView *firstLoadView;
@property (strong, nonatomic) UIImageView *firstLoadImageView;
@property (strong, nonatomic) UILabel *titleFirstLoadLabel;
@property (strong, nonatomic) UIView *descriptionFirstLoadView;
@property (strong, nonatomic) UILabel *descriptionFirstLoadLabel;
@property (strong, nonatomic) UIImageView *descriptionFirstLoadImageView;

@end

@implementation TAPSetupRoomListView
#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        _firstLoadOverlayView = [[UIView alloc] initWithFrame:self.frame];
        self.firstLoadOverlayView.backgroundColor = [[TAPUtil getColor:@"04040F"] colorWithAlphaComponent:0.4f];
        [self addSubview:self.firstLoadOverlayView];
        
        _firstLoadView = [[UIView alloc] initWithFrame:CGRectMake(16.0f, (CGRectGetHeight(self.frame) - 350.0f) / 2.0f, CGRectGetWidth(self.frame) - 16.0f - 16.0f, 350.0f)];
        self.firstLoadView.backgroundColor = [UIColor whiteColor];
        self.firstLoadView.layer.cornerRadius = 8.0f;
        self.firstLoadView.clipsToBounds = YES;
        [self.firstLoadOverlayView addSubview:self.firstLoadView];
        
        _firstLoadImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.firstLoadView.frame) - 220.0f) / 2.0f, 27.0f, 220.0f, 220.0f)];
        self.firstLoadImageView.image = [UIImage imageNamed:@"TAPIconSettingUpChatroom" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.firstLoadView addSubview:self.firstLoadImageView];
        
        _titleFirstLoadLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.firstLoadImageView.frame) + 24.0f, CGRectGetWidth(self.firstLoadView.frame) - 16.0f - 16.0f, 24.0f)];
        self.titleFirstLoadLabel.text = NSLocalizedString(@"Setting up Your Chat Room", @"");
        self.titleFirstLoadLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
        self.titleFirstLoadLabel.font = [UIFont fontWithName:TAP_FONT_NAME_BOLD size:16.0f];
        NSMutableDictionary *titleFirstLoadAttributesDictionary = [NSMutableDictionary dictionary];
        CGFloat titleFirstLoadLetterSpacing = -0.4f;
        [titleFirstLoadAttributesDictionary setObject:@(titleFirstLoadLetterSpacing) forKey:NSKernAttributeName];
        NSMutableAttributedString *titleFirstLoadAttributedString = [[NSMutableAttributedString alloc] initWithString:self.titleFirstLoadLabel.text];
        [titleFirstLoadAttributedString addAttributes:titleFirstLoadAttributesDictionary
                                                range:NSMakeRange(0, [self.titleFirstLoadLabel.text length])];
        self.titleFirstLoadLabel.attributedText = titleFirstLoadAttributedString;
        self.titleFirstLoadLabel.textAlignment = NSTextAlignmentCenter;
        [self.firstLoadView addSubview:self.titleFirstLoadLabel];
        
        //WK Note: This must be on the front
        _descriptionFirstLoadView = [[UIView alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.titleFirstLoadLabel.frame) + 6.0f, CGRectGetWidth(self.firstLoadView.frame) - 16.0f - 16.0f, 20.0f)];
        [self.firstLoadView addSubview:self.descriptionFirstLoadView];
        
        _descriptionFirstLoadLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 20.0f)];
        self.descriptionFirstLoadLabel.text = NSLocalizedString(@"Make sure you have a stable conection", @"");
        self.descriptionFirstLoadLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
        self.descriptionFirstLoadLabel.font = [UIFont fontWithName:TAP_FONT_NAME_REGULAR size:13.0f];
        NSMutableDictionary *descriptionFirstLoadAttributesDictionary = [NSMutableDictionary dictionary];
        CGFloat descriptionFirstLoadLetterSpacing = -0.2f;
        [descriptionFirstLoadAttributesDictionary setObject:@(descriptionFirstLoadLetterSpacing) forKey:NSKernAttributeName];
        NSMutableAttributedString *descriptionFirstLoadAttributedString = [[NSMutableAttributedString alloc] initWithString:self.descriptionFirstLoadLabel.text];
        [descriptionFirstLoadAttributedString addAttributes:descriptionFirstLoadAttributesDictionary
                                                      range:NSMakeRange(0, [self.descriptionFirstLoadLabel.text length])];
        self.descriptionFirstLoadLabel.attributedText = descriptionFirstLoadAttributedString;
        [self.descriptionFirstLoadLabel sizeToFit];
        self.descriptionFirstLoadLabel.frame = CGRectMake(CGRectGetMinX(self.descriptionFirstLoadLabel.frame), CGRectGetMinY(self.descriptionFirstLoadLabel.frame), CGRectGetWidth(self.descriptionFirstLoadLabel.frame), 20.0f);
        [self.descriptionFirstLoadView addSubview:self.descriptionFirstLoadLabel];
        
        _descriptionFirstLoadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.descriptionFirstLoadLabel.frame) + 4.0f, 0.0f, 20.0f, 20.0f)];
        self.descriptionFirstLoadImageView.image = [UIImage imageNamed:@"TAPIconSettingUp" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.descriptionFirstLoadView addSubview:self.descriptionFirstLoadImageView];
        
        self.descriptionFirstLoadView.frame = CGRectMake((CGRectGetWidth(self.firstLoadView.frame) - (CGRectGetWidth(self.descriptionFirstLoadLabel.frame) + 4.0f + CGRectGetWidth(self.descriptionFirstLoadImageView.frame))) / 2.0f, CGRectGetMinY(self.descriptionFirstLoadView.frame), CGRectGetWidth(self.descriptionFirstLoadLabel.frame) + 4.0f + CGRectGetWidth(self.descriptionFirstLoadImageView.frame), CGRectGetHeight(self.descriptionFirstLoadView.frame));
        
        self.firstLoadOverlayView.alpha = 0.0f;
        self.alpha = 0.0f;
    }
    return self;
}

- (void)showFirstLoadingView:(BOOL)isVisible {
    if (isVisible) {
        self.alpha = 1.0f;
        self.firstLoadOverlayView.alpha = 1.0f;
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.fromValue = [NSNumber numberWithFloat:0.0f];
        animation.toValue = [NSNumber numberWithFloat: 2 * M_PI];
        animation.duration = 1.5f;
        animation.repeatCount = INFINITY;
        animation.removedOnCompletion = NO;
        [self.descriptionFirstLoadImageView.layer addAnimation:animation forKey:@"FirstLoadSpinAnimation"];
    }
    else {
        [UIView animateWithDuration:0.2f animations:^{
            self.firstLoadOverlayView.alpha = 0.0f;
            self.alpha = 0.0f;
            [self.descriptionFirstLoadImageView.layer removeAnimationForKey:@"FirstLoadSpinAnimation"];
        }];
    }
}

@end
