//
//  TAPCustomButtonView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 01/04/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPCustomButtonView.h"

@interface TAPCustomButtonView ()

@property (strong, nonatomic) UIView *shadowView;
@property (strong, nonatomic) UIView *buttonContainerView;
@property (strong, nonatomic) UILabel *buttonTitleLabel;
@property (strong, nonatomic) UIImageView *buttonLoadingImageView;
@property (strong, nonatomic) UIImageView *buttonIconImageView;

- (void)buttonDidTapped;

@end

@implementation TAPCustomButtonView
#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _shadowView = [[UIView alloc] initWithFrame:CGRectMake(16.0f, 0.0f, CGRectGetWidth(self.frame) - 16.0f - 16.0f, CGRectGetHeight(self.frame))];
        self.shadowView.backgroundColor = [UIColor whiteColor];
        self.shadowView.layer.cornerRadius = 8.0f;
        self.shadowView.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
        self.shadowView.layer.shadowOpacity = 1.0f;
        self.shadowView.layer.masksToBounds = NO;
        [self addSubview:self.shadowView];
        
        _buttonContainerView = [[UIView alloc] initWithFrame:CGRectMake(16.0f, 0.0f, CGRectGetWidth(self.frame) - 16.0f - 16.0f, CGRectGetHeight(self.frame))];
        self.buttonContainerView.backgroundColor = [UIColor clearColor];
        self.buttonContainerView.clipsToBounds = YES;
        self.buttonContainerView.layer.cornerRadius = 8.0f;
        self.buttonContainerView.layer.borderWidth = 1.0f;
        [self addSubview:self.buttonContainerView];
        
        _buttonIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
        self.buttonIconImageView.image = [self.buttonIconImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonIcon]];
        [self.buttonContainerView addSubview:self.buttonIconImageView];
        
        UIFont *buttonFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontButtonLabel];
        UIColor *buttonColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorButtonLabel];
        _buttonTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.buttonContainerView.frame), CGRectGetHeight(self.buttonContainerView.frame))];
        self.buttonTitleLabel.textAlignment = NSTextAlignmentCenter;
        self.buttonTitleLabel.font = buttonFont;
        self.buttonTitleLabel.textColor = buttonColor;
        [self.buttonContainerView addSubview:self.buttonTitleLabel];
        
        _button = [[UIButton alloc] initWithFrame:self.buttonContainerView.frame];
        [self.button addTarget:self action:@selector(buttonDidTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button];
        
        _buttonLoadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.buttonContainerView.frame) - 20.0f) / 2.0f, (CGRectGetHeight(self.buttonContainerView.frame) - 20.0f) / 2.0f, 20.0f, 20.0f)];
        self.buttonLoadingImageView.alpha = 0.0f;
        [self.buttonLoadingImageView setImage:[UIImage imageNamed:@"TAPIconLoadingWhite" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil]];
        [self.buttonContainerView addSubview:self.buttonLoadingImageView];
    }
    
    return self;
}

#pragma mark - Custom Method
- (void)setCustomButtonViewType:(TAPCustomButtonViewType)customButtonViewType {
    _customButtonViewType = customButtonViewType;
    
    if (self.customButtonViewType == TAPCustomButtonViewTypeActive) {
        if (self.customButtonViewStyleType == TAPCustomButtonViewStyleTypePlain || self.customButtonViewStyleType == TAPCustomButtonViewStyleTypeWithIcon) {
            //orange gradient background
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = self.buttonContainerView.bounds;
            gradient.colors = [NSArray arrayWithObjects:(id)[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonActiveBackgroundGradientLight].CGColor, (id)[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonActiveBackgroundGradientDark].CGColor, nil];
            gradient.startPoint = CGPointMake(0.0f, 0.0f);
            gradient.endPoint = CGPointMake(0.0f, 1.0f);
            [self.buttonContainerView.layer insertSublayer:gradient atIndex:0];
            
            self.buttonContainerView.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonActiveBorder].CGColor;
            self.button.userInteractionEnabled = YES;
            
            if (self.customButtonViewStyleType == TAPCustomButtonViewStyleTypeWithIcon) {
                self.shadowView.layer.shadowColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonInactiveBorder].CGColor;
            }
            else {
                UIColor *shadowColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonInactiveBorder];
                self.shadowView.layer.shadowColor = [shadowColor colorWithAlphaComponent:0.5f].CGColor;
            }
            self.shadowView.alpha = 1.0f;
        }
        else {
            //destructive type, no button background
            self.buttonContainerView.layer.borderColor = [UIColor clearColor].CGColor;
            self.button.userInteractionEnabled = YES;
            self.shadowView.layer.shadowColor = [UIColor clearColor].CGColor;
            self.shadowView.alpha = 0.0f;
        }
    }
    else if (self.customButtonViewType == TAPCustomButtonViewTypeInactive) {
        if (self.customButtonViewStyleType == TAPCustomButtonViewStyleTypePlain || self.customButtonViewStyleType == TAPCustomButtonViewStyleTypeWithIcon) {
            //grey gradient background
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = self.buttonContainerView.bounds;
            gradient.colors = [NSArray arrayWithObjects:(id)[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonInactiveBackgroundGradientLight].CGColor, (id)[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonInactiveBackgroundGradientDark].CGColor, nil];
            gradient.startPoint = CGPointMake(0.0f, 0.0f);
            gradient.endPoint = CGPointMake(0.0f, 1.0f);
            [self.buttonContainerView.layer insertSublayer:gradient atIndex:0];
            
            self.buttonContainerView.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonInactiveBorder].CGColor;
            self.button.userInteractionEnabled = NO;
            
            self.shadowView.layer.shadowColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonInactiveBorder].CGColor;
            self.shadowView.alpha = 1.0f;
        }
        else {
            //destructive type, no button background
            self.buttonContainerView.layer.borderColor = [UIColor clearColor].CGColor;
            self.button.userInteractionEnabled = NO;
            self.shadowView.layer.shadowColor = [UIColor clearColor].CGColor;
            self.shadowView.alpha = 0.0f;
        }
        
    }
}

- (void)setCustomButtonViewStyleType:(TAPCustomButtonViewStyleType)customButtonViewStyleType {
    _customButtonViewStyleType = customButtonViewStyleType;
    if (customButtonViewStyleType == TAPCustomButtonViewStyleTypePlain) {
        self.buttonIconImageView.alpha = 0.0f;
        //Left and Right gap is 16.0f
        self.shadowView.frame =  CGRectMake(16.0f, 0.0f, CGRectGetWidth(self.frame) - 16.0f - 16.0f, CGRectGetHeight(self.frame));
        self.buttonContainerView.frame = CGRectMake(16.0f, 0.0f, CGRectGetWidth(self.frame) - 16.0f - 16.0f, CGRectGetHeight(self.frame));
        self.buttonTitleLabel.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.buttonContainerView.frame), CGRectGetHeight(self.buttonContainerView.frame));
        self.button.frame = self.buttonContainerView.frame;
        self.buttonLoadingImageView.frame = CGRectMake((CGRectGetWidth(self.buttonContainerView.frame) - 20.0f) / 2.0f, (CGRectGetHeight(self.buttonContainerView.frame) - 20.0f) / 2.0f, 20.0f, 20.0f);
    }
    else if (customButtonViewStyleType == TAPCustomButtonViewStyleTypeWithIcon) {
        self.buttonIconImageView.alpha = 1.0f;
        //Left and Right gap is 10.0f
        self.shadowView.frame =  CGRectMake(10.0f, 0.0f, CGRectGetWidth(self.frame) - 10.0f - 10.0f, CGRectGetHeight(self.frame));
        self.buttonContainerView.frame = CGRectMake(10.0f, 0.0f, CGRectGetWidth(self.frame) - 10.0f - 10.0f, CGRectGetHeight(self.frame));
        self.buttonTitleLabel.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.buttonContainerView.frame), CGRectGetHeight(self.buttonContainerView.frame));
        self.button.frame = self.buttonContainerView.frame;
        self.buttonLoadingImageView.frame = CGRectMake((CGRectGetWidth(self.buttonContainerView.frame) - 20.0f) / 2.0f, (CGRectGetHeight(self.buttonContainerView.frame) - 20.0f) / 2.0f, 20.0f, 20.0f);
        
        //Set icon tint color
       self.buttonIconImageView.image = [self.buttonIconImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonIcon]];
    }
    else if (customButtonViewStyleType == TAPCustomButtonViewStyleTypeDestructivePlain) {
        self.buttonIconImageView.alpha = 0.0f;
        //Left and Right gap is 16.0f
        self.shadowView.frame =  CGRectMake(16.0f, 0.0f, CGRectGetWidth(self.frame) - 16.0f - 16.0f, CGRectGetHeight(self.frame));
        self.buttonContainerView.frame = CGRectMake(16.0f, 0.0f, CGRectGetWidth(self.frame) - 16.0f - 16.0f, CGRectGetHeight(self.frame));
        self.buttonTitleLabel.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.buttonContainerView.frame), CGRectGetHeight(self.buttonContainerView.frame));
        self.button.frame = self.buttonContainerView.frame;
        self.buttonLoadingImageView.frame = CGRectMake((CGRectGetWidth(self.buttonContainerView.frame) - 20.0f) / 2.0f, (CGRectGetHeight(self.buttonContainerView.frame) - 20.0f) / 2.0f, 20.0f, 20.0f);
        UIColor *clickableDestructiveButtonLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorClickableDestructiveLabel];
        self.buttonTitleLabel.textColor = clickableDestructiveButtonLabelColor;
    }
    else if (customButtonViewStyleType == TAPCustomButtonViewStyleTypeDestructiveWithIcon) {
        self.buttonIconImageView.alpha = 1.0f;
        //Left and Right gap is 10.0f
        self.shadowView.frame =  CGRectMake(10.0f, 0.0f, CGRectGetWidth(self.frame) - 10.0f - 10.0f, CGRectGetHeight(self.frame));
        self.buttonContainerView.frame = CGRectMake(10.0f, 0.0f, CGRectGetWidth(self.frame) - 10.0f - 10.0f, CGRectGetHeight(self.frame));
        self.buttonTitleLabel.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.buttonContainerView.frame), CGRectGetHeight(self.buttonContainerView.frame));
        self.button.frame = self.buttonContainerView.frame;
        self.buttonLoadingImageView.frame = CGRectMake((CGRectGetWidth(self.buttonContainerView.frame) - 20.0f) / 2.0f, (CGRectGetHeight(self.buttonContainerView.frame) - 20.0f) / 2.0f, 20.0f, 20.0f);
        UIColor *clickableDestructiveButtonLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorClickableDestructiveLabel];
        self.buttonTitleLabel.textColor = clickableDestructiveButtonLabelColor;
        
        //Set icon tint color
        self.buttonIconImageView.image = [self.buttonIconImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonIconDestructive]];
    }
}

- (void)setAsActiveState:(BOOL)active animated:(BOOL)animated {
    if (animated) {
        if (active) {
            [UIView animateWithDuration:0.2f animations:^{
                CAGradientLayer *gradient = [CAGradientLayer layer];
                gradient.frame = self.buttonContainerView.bounds;
                gradient.colors = [NSArray arrayWithObjects:(id)[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonActiveBackgroundGradientLight].CGColor, (id)[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonActiveBackgroundGradientDark].CGColor, nil];
                gradient.startPoint = CGPointMake(0.0f, 0.0f);
                gradient.endPoint = CGPointMake(0.0f, 1.0f);
                [self.buttonContainerView.layer replaceSublayer:[self.buttonContainerView.layer.sublayers objectAtIndex:0] with:gradient];
                
                self.buttonContainerView.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonActiveBorder].CGColor;
                self.button.userInteractionEnabled = YES;
                
                self.shadowView.layer.shadowColor = [[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonActiveBorder] colorWithAlphaComponent:0.5f].CGColor;            }];
        }
        else {
            [UIView animateWithDuration:0.2f animations:^{
                CAGradientLayer *gradient = [CAGradientLayer layer];
                gradient.frame = self.buttonContainerView.bounds;
                gradient.colors = [NSArray arrayWithObjects:(id)[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonInactiveBackgroundGradientLight].CGColor, (id)[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonInactiveBackgroundGradientDark].CGColor, nil];
                gradient.startPoint = CGPointMake(0.0f, 0.0f);
                gradient.endPoint = CGPointMake(0.0f, 1.0f);
                [self.buttonContainerView.layer replaceSublayer:[self.buttonContainerView.layer.sublayers objectAtIndex:0] with:gradient];
                
                self.buttonContainerView.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonInactiveBorder].CGColor;
                self.button.userInteractionEnabled = NO;
                
                self.shadowView.layer.shadowColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonInactiveBorder].CGColor;
            }];
        }
    }
    else {
        if (active) {
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = self.buttonContainerView.bounds;
            gradient.colors = [NSArray arrayWithObjects:(id)[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonActiveBackgroundGradientLight].CGColor, (id)[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonActiveBackgroundGradientDark].CGColor, nil];
            gradient.startPoint = CGPointMake(0.0f, 0.0f);
            gradient.endPoint = CGPointMake(0.0f, 1.0f);
            [self.buttonContainerView.layer replaceSublayer:[self.buttonContainerView.layer.sublayers objectAtIndex:0] with:gradient];
            
            self.buttonContainerView.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonActiveBorder].CGColor;
            self.button.userInteractionEnabled = YES;
            
            self.shadowView.layer.shadowColor = [[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonActiveBorder] colorWithAlphaComponent:0.5f].CGColor;
        }
        else {
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = self.buttonContainerView.bounds;
            gradient.colors = [NSArray arrayWithObjects:(id)[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonInactiveBackgroundGradientLight].CGColor, (id)[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonInactiveBackgroundGradientDark].CGColor, nil];
            gradient.startPoint = CGPointMake(0.0f, 0.0f);
            gradient.endPoint = CGPointMake(0.0f, 1.0f);
            [self.buttonContainerView.layer replaceSublayer:[self.buttonContainerView.layer.sublayers objectAtIndex:0] with:gradient];
            
            self.buttonContainerView.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonInactiveBorder].CGColor;
            self.button.userInteractionEnabled = NO;
            
            self.shadowView.layer.shadowColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonInactiveBorder].CGColor;
        }
    }
}

- (void)setButtonWithTitle:(NSString *)title {
    self.buttonTitleLabel.text = title;
}

- (void)setButtonWithTitle:(NSString *)title andIcon:(NSString *)imageName iconPosition:(TAPCustomButtonViewIconPosititon)tapCustomButtonViewIconPosititon {
    self.buttonTitleLabel.text = title;
    self.buttonIconImageView.image = [UIImage imageNamed:imageName inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    
    CGSize size = [self.buttonTitleLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, 20.0f)];
    CGFloat maximumLabelWidth = CGRectGetWidth(self.frame) - 10.0f - 10.0f - 4.0f - 32.0f; //10 - left&right gap, 4 - gap to image view, 32 image view width
    CGFloat newWidth = size.width;
    if (newWidth > maximumLabelWidth) {
        newWidth = maximumLabelWidth;
    }
    CGFloat newMinX = (CGRectGetWidth(self.buttonContainerView.frame) - (newWidth + 4.0f + 32.0f))/2.0f;
    
    if (tapCustomButtonViewIconPosititon == TAPCustomButtonViewIconPosititonLeft) {
        self.buttonIconImageView.frame = CGRectMake(newMinX, 5.0f, 32.0f, CGRectGetHeight(self.buttonIconImageView.frame));
        self.buttonTitleLabel.frame = CGRectMake(CGRectGetMaxX(self.buttonIconImageView.frame) + 4.0f, CGRectGetMinY(self.buttonTitleLabel.frame), newWidth, CGRectGetHeight(self.buttonTitleLabel.frame));
    }
    else {
        self.buttonTitleLabel.frame = CGRectMake(newMinX, CGRectGetMinY(self.buttonTitleLabel.frame), newWidth, CGRectGetHeight(self.buttonTitleLabel.frame));
        self.buttonIconImageView.frame = CGRectMake(CGRectGetMaxX(self.buttonTitleLabel.frame) + 4.0f, 5.0f, 32.0f, CGRectGetHeight(self.buttonIconImageView.frame));
    }
}

- (void)setAsLoading:(BOOL)loading animated:(BOOL)animated {
    if (loading) {
        if (animated) {
            [UIView animateWithDuration:0.2f animations:^{
                self.buttonLoadingImageView.alpha = 1.0f;
                self.buttonTitleLabel.alpha = 0.0f;
                
                if (self.customButtonViewStyleType == TAPCustomButtonViewStyleTypeWithIcon) {
                    self.buttonIconImageView.alpha = 0.0f;
                }
                
                self.button.userInteractionEnabled = NO;
            }];
            
            //ADD ANIMATION
            if ([self.buttonLoadingImageView.layer animationForKey:@"SpinAnimation"] == nil) {
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
                animation.fromValue = [NSNumber numberWithFloat:0.0f];
                animation.toValue = [NSNumber numberWithFloat:(2*M_PI)];
                animation.duration = 1.5f;
                animation.repeatCount = INFINITY;
                animation.cumulative = YES;
                animation.removedOnCompletion = NO;
                [self.buttonLoadingImageView.layer addAnimation:animation forKey:@"SpinAnimation"];
            }
        }
        else {
            self.buttonLoadingImageView.alpha = 1.0f;
            self.buttonTitleLabel.alpha = 0.0f;
            if (self.customButtonViewStyleType == TAPCustomButtonViewStyleTypeWithIcon) {
                self.buttonIconImageView.alpha = 0.0f;
            }
            self.button.userInteractionEnabled = NO;
            
            //ADD ANIMATION
            if ([self.buttonLoadingImageView.layer animationForKey:@"SpinAnimation"] == nil) {
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
                animation.fromValue = [NSNumber numberWithFloat:0.0f];
                animation.toValue = [NSNumber numberWithFloat:(2*M_PI)];
                animation.duration = 1.5f;
                animation.repeatCount = INFINITY;
                animation.cumulative = YES;
                animation.removedOnCompletion = NO;
                [self.buttonLoadingImageView.layer addAnimation:animation forKey:@"SpinAnimation"];
            }
        }
    }
    else {
        if (animated) {
            [UIView animateWithDuration:0.2f animations:^{
                self.buttonLoadingImageView.alpha = 0.0f;
                self.buttonTitleLabel.alpha = 1.0f;
                self.button.userInteractionEnabled = YES;
                
                if (self.customButtonViewStyleType == TAPCustomButtonViewStyleTypeWithIcon) {
                    self.buttonIconImageView.alpha = 1.0f;
                }

            }];
            
            //REMOVE ANIMATION
            if ([self.buttonLoadingImageView.layer animationForKey:@"SpinAnimation"] != nil) {
                [self.buttonLoadingImageView.layer removeAnimationForKey:@"SpinAnimation"];
            }
        }
        else {
            self.buttonLoadingImageView.alpha = 0.0f;
            self.buttonTitleLabel.alpha = 1.0f;
            
            if (self.customButtonViewStyleType == TAPCustomButtonViewStyleTypeWithIcon) {
                self.buttonIconImageView.alpha = 1.0f;
            }
            
            self.button.userInteractionEnabled = YES;

            
            //REMOVE ANIMATION
            if ([self.buttonLoadingImageView.layer animationForKey:@"SpinAnimation"] != nil) {
                [self.buttonLoadingImageView.layer removeAnimationForKey:@"SpinAnimation"];
            }
        }
    }
}

- (void)buttonDidTapped {
    if ([self.delegate respondsToSelector:@selector(customButtonViewDidTappedButton)]) {
        [self.delegate customButtonViewDidTappedButton];
    }
}

@end
