//
//  TAPCustomLabelView.m
//  TapTalk
//
//  Created by TapTalk.io on 17/02/22.
//

#import "TAPCustomLabelView.h"

@interface TAPCustomLabelView ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIView *separatorView;

@end

@implementation TAPCustomLabelView
#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        UIFont *titleLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontChatProfileTitleLabelStyle];
        UIColor *titleLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorChatProfileDetailTitleLabel];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(24.0f, 9.0f, CGRectGetWidth(self.frame) - 24.0f - 24.0f, 16.0f)];
        self.titleLabel.font = titleLabelFont;
        self.titleLabel.textColor = titleLabelColor;
        [self addSubview:self.titleLabel];
        
        UIFont *descriptionFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontChatProfileMenuLabel];
        UIColor *descriptionLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorChatProfileMenuLabel];
        _infoDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(24.0f, CGRectGetMaxY(self.titleLabel.frame) + 4.0f, CGRectGetWidth(frame) - 24.0f - 24.0f, 24.0f)];
        self.infoDescriptionLabel.font = descriptionFont;
        self.infoDescriptionLabel.textColor = descriptionLabelColor;
        self.infoDescriptionLabel.numberOfLines = 0;
        
        [self addSubview:self.infoDescriptionLabel];
        
        _separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(frame) - 1.0f, CGRectGetWidth(frame), 1.0f)];
        self.separatorView.backgroundColor = [TAPUtil getColor:TAP_COLOR_GREY_DC];
        [self addSubview:self.separatorView];
                
    }
    
    return self;
}

#pragma mark - Custom Method
- (void)showSeparatorView:(BOOL)isShowed {
    if (isShowed) {
        self.separatorView.alpha = 1.0f;
        self.separatorView.frame = CGRectMake(0.0f, CGRectGetHeight(self.frame) - 1.0f, CGRectGetWidth(self.frame), 1.0f);
    }
    else {
        self.separatorView.alpha = 0.0f;
    }
}

- (void)setInfoDesciption:(NSString *)descp{
    self.infoDescriptionLabel.text = descp;
    [self.infoDescriptionLabel sizeToFit];
    self.frame = CGRectMake(0.0f, 24.0f, CGRectGetWidth(self.frame), 62.0f - 24.0f + CGRectGetHeight(self.infoDescriptionLabel.frame) + 6.0f);
}

- (void)setAccountDetailFieldString:(NSString *)title description:(NSString *)description{
    self.titleLabel.text = title;
    self.infoDescriptionLabel.text = description;
}

@end
