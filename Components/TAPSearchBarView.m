//
//  TAPSearchBarView.m
//  TapTalk
//
//  Created by Welly Kencana on 3/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPSearchBarView.h"

@interface TAPSearchBarView()
@property (strong, nonatomic) UIView *bgView;
@end

@implementation TAPSearchBarView
#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        self.bgView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.bgView];
        
        _searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bgView.frame), CGRectGetHeight(self.bgView.frame))];
        self.searchTextField.backgroundColor = [UIColor whiteColor];
        self.searchTextField.tintColor = [TAPUtil getColor:TAP_COLOR_MOSELO_GREEN];
        self.searchTextField.clearButtonMode = YES;
        UIImageView *leftViewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8.0f, 0.0f, 14.0, 14.0f)];
        leftViewImageView.image = [UIImage imageNamed:@"TAPIconSearch" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(leftViewImageView.frame) + 8.0f + 8.0f, CGRectGetHeight(leftViewImageView.frame))];
        [leftView addSubview:leftViewImageView];
        self.searchTextField.leftView = leftView;
        self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
        NSMutableAttributedString *placeHolderAttributedString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Search", @"")];
        [placeHolderAttributedString addAttribute:NSFontAttributeName
                                            value:[UIFont fontWithName:TAP_FONT_LATO_REGULAR size:13.0f]
                                            range:NSMakeRange(0, [NSLocalizedString(@"Search", @"") length])];
        [placeHolderAttributedString addAttribute:NSForegroundColorAttributeName
                                            value:[TAPUtil getColor:TAP_COLOR_GREY_9B]
                                            range:NSMakeRange(0, [NSLocalizedString(@"Search", @"") length])];
        self.searchTextField.attributedPlaceholder = placeHolderAttributedString;
        self.searchTextField.layer.cornerRadius = CGRectGetHeight(self.searchTextField.frame) / 2.0f;
        self.searchTextField.layer.borderWidth = 1.0f;
        self.searchTextField.layer.borderColor = [TAPUtil getColor:@"E4E4E4"].CGColor;
        self.searchTextField.font = [UIFont fontWithName:TAP_FONT_LATO_REGULAR size:13.0f];
        self.searchTextField.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
        self.searchTextField.clipsToBounds = YES;
        UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, -1.0f, CGRectGetWidth(self.searchTextField.frame), 0.3f)];
        shadowView.backgroundColor = [UIColor whiteColor];
        shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
        shadowView.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
        shadowView.layer.shadowOpacity = 0.3f;
        shadowView.layer.shadowRadius = 2.0f;
        [self.searchTextField addSubview:shadowView];
        [self.bgView addSubview:self.searchTextField];
    }
    
    return self;
}

#pragma mark - Custom Method
- (void)setCustomPlaceHolderString:(NSString *)customPlaceHolderString {
    _customPlaceHolderString = customPlaceHolderString;
    
    NSMutableAttributedString *placeHolderAttributedString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(self.customPlaceHolderString, @"")];
    [placeHolderAttributedString addAttribute:NSFontAttributeName
                                        value:[UIFont fontWithName:TAP_FONT_LATO_REGULAR size:13.0f]
                                        range:NSMakeRange(0, [self.customPlaceHolderString length])];
    [placeHolderAttributedString addAttribute:NSForegroundColorAttributeName
                                        value:[TAPUtil getColor:TAP_COLOR_GREY_9B]
                                        range:NSMakeRange(0, [self.customPlaceHolderString length])];
    self.searchTextField.attributedPlaceholder = placeHolderAttributedString;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    self.bgView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame));
    self.searchTextField.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bgView.frame), CGRectGetHeight(self.bgView.frame));
}

@end
