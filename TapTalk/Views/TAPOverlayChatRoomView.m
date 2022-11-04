//
//  TAPOverlayChatRoomView.m
//  TapTalk
//
//  Created by TapTalk.io on 05/10/22.
//

#import "TAPOverlayChatRoomView.h"

@interface TAPOverlayChatRoomView ()
@property (strong, nonatomic) UIView *scheduleMessageContainerView;
@property (strong, nonatomic) UIButton *scheduleMessageButton;
@property (strong, nonatomic) UILabel *scheduleMessageLabel;
@property (strong, nonatomic) UIImageView *scheduleMessageImageView;
@property (strong, nonatomic) UIButton *backgroundButton;
@end

@implementation TAPOverlayChatRoomView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2f];
    
    CGFloat scheduleContainerWidth = 165.0f;
    CGFloat scheduleContainerHeight = 44.0f;
    
    _backgroundButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [self.backgroundButton addTarget:self action:@selector(backgroundButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.backgroundButton];
    
    _scheduleMessageContainerView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.frame) - scheduleContainerWidth - 16.0f, CGRectGetMaxY(self.frame) - scheduleContainerHeight - 110.0f, scheduleContainerWidth, scheduleContainerHeight)];
    self.scheduleMessageContainerView.layer.cornerRadius = 8.0f;
    self.scheduleMessageContainerView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.scheduleMessageContainerView];
    
    _scheduleMessageImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12.0f, (scheduleContainerHeight - 18.0f) /2, 18.0f,18.0f)];
    self.scheduleMessageImageView.image = [UIImage imageNamed:@"TAPIconReschedule" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    [self.scheduleMessageContainerView addSubview:self.scheduleMessageImageView];
    
    _scheduleMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.scheduleMessageImageView.frame) + 8.0f, (scheduleContainerHeight - 20.0f) /2, 130.0f, 20.0f)];
    self.scheduleMessageLabel.text = @"Schedule Message";
    self.scheduleMessageLabel.font = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontDeletedChatRoomInfoContentLabel];
    [self.scheduleMessageContainerView addSubview:self.scheduleMessageLabel];
    
    _scheduleMessageButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.scheduleMessageContainerView.frame), CGRectGetHeight(self.scheduleMessageContainerView.frame))];
    [self.scheduleMessageContainerView addSubview:self.scheduleMessageButton];
    
    [self.scheduleMessageButton addTarget:self action:@selector(scheduleMessageButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    
    self.alpha = 0.0f;
    
    return self;
}

- (void)scheduleMessageButtonDidTapped {
    if ([self.delegate respondsToSelector:@selector(overlayScheduleMessageButtonDidTapped)]) {
        [self.delegate overlayScheduleMessageButtonDidTapped];
    }
}

- (void)backgroundButtonDidTapped {
    if ([self.delegate respondsToSelector:@selector(overlayBackgroundButtonDidTapped)]) {
        [self.delegate overlayBackgroundButtonDidTapped];
    }
}

- (void)showOverlay:(BOOL)isShow {
    if(isShow) {
        self.alpha = 1.0f;
    }
    else {
        self.alpha = 0.0f;
    }
}

@end
