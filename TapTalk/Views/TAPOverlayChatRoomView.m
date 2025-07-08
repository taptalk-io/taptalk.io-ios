//
//  TAPOverlayChatRoomView.m
//  TapTalk
//
//  Created by TapTalk.io on 05/10/22.
//

#import "TAPOverlayChatRoomView.h"

@interface TAPOverlayChatRoomView ()
@property (strong, nonatomic) UIButton *backgroundButton;
@property (strong, nonatomic) TapHighlightCustomButtonView *scheduleMessageHighlightButton;
@end

@implementation TAPOverlayChatRoomView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2f];
    
    CGFloat scheduleContainerWidth = 165.0f;
    CGFloat scheduleContainerHeight = 44.0f;
    
    _backgroundButton = [[UIButton alloc] initWithFrame:CGRectMake(
        0.0f,
        0.0f,
        CGRectGetWidth(self.frame),
        CGRectGetHeight(self.frame)
    )];
    [self.backgroundButton addTarget:self action:@selector(backgroundButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.backgroundButton];
    
    _scheduleMessageHighlightButton = [[TapHighlightCustomButtonView alloc] initWithFrame:CGRectMake(
        CGRectGetMaxX(self.frame) - scheduleContainerWidth - 16.0f,
        CGRectGetMaxY(self.frame) - scheduleContainerHeight - 110.0f,
        scheduleContainerWidth,
        scheduleContainerHeight
    )];
    [self.scheduleMessageHighlightButton setType:TapHighlightCustomButtonViewTypeSecondaryGrayBorder];
    [self.scheduleMessageHighlightButton setContainerViewRadius:8.0f];
    [self.scheduleMessageHighlightButton setContainerViewBackgroundColor:[UIColor whiteColor]];
    [self.scheduleMessageHighlightButton setLeftIconImage:[UIImage imageNamed:@"TAPIconReschedule" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil]];
    [self.scheduleMessageHighlightButton setLeftIconSize:18.0f];
    [self.scheduleMessageHighlightButton setLabelText:NSLocalizedStringFromTableInBundle(@"Schedule Message", nil, [TAPUtil currentBundle], @"")];
    [self.scheduleMessageHighlightButton setLabelFont:[[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontDeletedChatRoomInfoContentLabel]];
    [self.scheduleMessageHighlightButton setLabelColor:[TAPUtil getColor:TAP_COLOR_TEXT_DARK]];
    [self.scheduleMessageHighlightButton setHighlightColor:[[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary] colorWithAlphaComponent:0.18f]];
    [self.scheduleMessageHighlightButton setClickAction:@selector(scheduleMessageButtonDidTapped)  target:self];
    [self addSubview:self.scheduleMessageHighlightButton];
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
    if (isShow) {
        self.alpha = 1.0f;
    }
    else {
        self.alpha = 0.0f;
    }
}

@end
