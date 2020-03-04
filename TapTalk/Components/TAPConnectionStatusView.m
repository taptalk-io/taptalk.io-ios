//
//  TAPConnectionStatusView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 24/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPConnectionStatusView.h"

@interface TAPConnectionStatusView()
@property (strong, nonatomic) UIView *connectionStatusView;
@property (strong, nonatomic) UIView *connectionStatusLabelView;
@property (strong, nonatomic) UILabel *connectionStatusLabel;
@property (strong, nonatomic) UIImageView *connectionStatusImageView;

@property (nonatomic) TAPConnectionStatusType type;
@end

@implementation TAPConnectionStatusView
#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initialization];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initialization];
    }
    
    return self;
}

- (void)initialization {
    _connectionStatusView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 20.0f)];
    self.connectionStatusView.backgroundColor = [UIColor clearColor];
    self.connectionStatusView.clipsToBounds = YES;
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.connectionStatusView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColor whiteColor].CGColor, nil];
    gradient.startPoint = CGPointMake(0.0f, 0.0f);
    gradient.endPoint = CGPointMake(0.0f, 1.0f);
    [self.connectionStatusView.layer insertSublayer:gradient atIndex:0];
    [self addSubview:self.connectionStatusView];
    
    _connectionStatusLabelView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, CGRectGetHeight(self.connectionStatusView.frame))];
    _connectionStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, CGRectGetHeight(self.connectionStatusLabelView.frame))];
    
    UIFont *obtainedFont = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
    obtainedFont = [obtainedFont fontWithSize:12.0f];
    self.connectionStatusLabel.font = obtainedFont;
    self.connectionStatusLabel.textColor = [UIColor whiteColor];
    self.connectionStatusLabel.textAlignment = NSTextAlignmentCenter;
    [self.connectionStatusLabelView addSubview:self.connectionStatusLabel];
    
    _connectionStatusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.connectionStatusLabel.frame) + 4.0f, 7.0f, 9.0f, 9.0f)];
    self.connectionStatusImageView.center = self.connectionStatusView.center;
    [self.connectionStatusLabelView addSubview:self.connectionStatusImageView];
    [self.connectionStatusView addSubview:self.connectionStatusLabelView];
    
}

#pragma mark - Custom Method
- (void)setConnectionStatusType:(TAPConnectionStatusType)connectionStatusType {
    _type = connectionStatusType;
    if (self.type == TAPConnectionStatusTypeNone) {
        //Remove Animation
        if ([self.connectionStatusImageView.layer animationForKey:@"SpinAnimation"] != nil) {
            [self.connectionStatusImageView.layer removeAnimationForKey:@"SpinAnimation"];
        }
    }
    else if (self.type == TAPConnectionStatusTypeConnecting) {
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.connectionStatusView.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[TAPUtil getColor:@"FFB438"].CGColor, [TAPUtil getColor:@"FFA107"].CGColor, [TAPUtil getColor:@"FF9F00"].CGColor, nil];
        gradient.startPoint = CGPointMake(0.0f, 0.0f);
        gradient.endPoint = CGPointMake(0.0f, 1.0f);
        [self.connectionStatusView.layer replaceSublayer:[self.connectionStatusView.layer.sublayers objectAtIndex:0] with:gradient];
        
        self.connectionStatusLabel.text = NSLocalizedStringFromTableInBundle(@"Connecting", nil, [TAPUtil currentBundle], @"");
        NSMutableDictionary *connectionStatusAttributesDictionary = [NSMutableDictionary dictionary];
        CGFloat connectionStatusLetterSpacing = -0.2f;
        [connectionStatusAttributesDictionary setObject:@(connectionStatusLetterSpacing) forKey:NSKernAttributeName];
        NSMutableAttributedString *connectionStatusAttributedString = [[NSMutableAttributedString alloc] initWithString:self.connectionStatusLabel.text];
        [connectionStatusAttributedString addAttributes:connectionStatusAttributesDictionary
                                                  range:NSMakeRange(0, [self.connectionStatusLabel.text length])];
        self.connectionStatusLabel.attributedText = connectionStatusAttributedString;
        [self.connectionStatusLabel sizeToFit];
        self.connectionStatusLabel.frame = CGRectMake(CGRectGetMinX(self.connectionStatusLabel.frame), CGRectGetMinY(self.connectionStatusLabel.frame), CGRectGetWidth(self.connectionStatusLabel.frame), 20.0f);
        
        self.connectionStatusImageView.frame = CGRectMake(CGRectGetMaxX(self.connectionStatusLabel.frame) + 4.0f, CGRectGetMinY(self.connectionStatusImageView.frame), CGRectGetWidth(self.connectionStatusImageView.frame), CGRectGetHeight(self.connectionStatusImageView.frame));
        self.connectionStatusImageView.image = [UIImage imageNamed:@"TAPIconConnecting" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        
        self.connectionStatusLabelView.frame = CGRectMake(CGRectGetMinX(self.connectionStatusLabelView.frame), CGRectGetMinY(self.connectionStatusLabelView.frame), CGRectGetWidth(self.connectionStatusLabel.frame) + 4.0f + CGRectGetWidth(self.connectionStatusImageView.frame), CGRectGetHeight(self.connectionStatusLabelView.frame));
        self.connectionStatusLabelView.center = CGPointMake(self.connectionStatusView.center.x, self.connectionStatusLabelView.center.y);
        
        //Add Animation
        if ([self.connectionStatusImageView.layer animationForKey:@"SpinAnimation"] == nil) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            animation.fromValue = [NSNumber numberWithFloat:0.0f];
            animation.toValue = [NSNumber numberWithFloat: 2*M_PI];
            animation.duration = 1.5f;
            animation.repeatCount = INFINITY;
            animation.removedOnCompletion = NO;
            [self.connectionStatusImageView.layer addAnimation:animation forKey:@"SpinAnimation"];
        }
    }
    else if (self.type == TAPConnectionStatusTypeNetworkError) {
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.connectionStatusView.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[TAPUtil getColor:@"9B9B9B"].CGColor, [TAPUtil getColor:@"9B9B9B"].CGColor, nil];
        gradient.startPoint = CGPointMake(0.0f, 0.0f);
        gradient.endPoint = CGPointMake(0.0f, 1.0f);
        [self.connectionStatusView.layer replaceSublayer:[self.connectionStatusView.layer.sublayers objectAtIndex:0] with:gradient];
        
        self.connectionStatusLabel.text = NSLocalizedStringFromTableInBundle(@"Waiting for Network", nil, [TAPUtil currentBundle], @"");
        NSMutableDictionary *connectionStatusAttributesDictionary = [NSMutableDictionary dictionary];
        CGFloat connectionStatusLetterSpacing = -0.2f;
        [connectionStatusAttributesDictionary setObject:@(connectionStatusLetterSpacing) forKey:NSKernAttributeName];
        NSMutableAttributedString *connectionStatusAttributedString = [[NSMutableAttributedString alloc] initWithString:self.connectionStatusLabel.text];
        [connectionStatusAttributedString addAttributes:connectionStatusAttributesDictionary
                                                  range:NSMakeRange(0, [self.connectionStatusLabel.text length])];
        self.connectionStatusLabel.attributedText = connectionStatusAttributedString;
        [self.connectionStatusLabel sizeToFit];
        self.connectionStatusLabel.frame = CGRectMake(CGRectGetMinX(self.connectionStatusLabel.frame), CGRectGetMinY(self.connectionStatusLabel.frame), CGRectGetWidth(self.connectionStatusLabel.frame), 20.0f);
        
        self.connectionStatusImageView.frame = CGRectMake(CGRectGetMaxX(self.connectionStatusLabel.frame) + 4.0f, CGRectGetMinY(self.connectionStatusImageView.frame), CGRectGetWidth(self.connectionStatusImageView.frame), CGRectGetHeight(self.connectionStatusImageView.frame));
        self.connectionStatusImageView.image = [UIImage imageNamed:@"TAPIconConnecting" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        
        self.connectionStatusLabelView.frame = CGRectMake(CGRectGetMinX(self.connectionStatusLabelView.frame), CGRectGetMinY(self.connectionStatusLabelView.frame), CGRectGetWidth(self.connectionStatusLabel.frame) + 4.0f + CGRectGetWidth(self.connectionStatusImageView.frame), CGRectGetHeight(self.connectionStatusLabelView.frame));
        self.connectionStatusLabelView.center = CGPointMake(self.connectionStatusView.center.x, self.connectionStatusLabelView.center.y);
        
        //Add Animation
        if ([self.connectionStatusImageView.layer animationForKey:@"SpinAnimation"] == nil) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            animation.fromValue = [NSNumber numberWithFloat:0.0f];
            animation.toValue = [NSNumber numberWithFloat: 2 * M_PI];
            animation.duration = 1.5f;
            animation.repeatCount = INFINITY;
            animation.removedOnCompletion = NO;
            [self.connectionStatusImageView.layer addAnimation:animation forKey:@"SpinAnimation"];
        }
    }
    else if (self.type == TAPConnectionStatusTypeConnected) {
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.connectionStatusView.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[TAPUtil getColor:@"3BC73D"].CGColor, [TAPUtil getColor:@"2DB80F"].CGColor, nil];
        gradient.startPoint = CGPointMake(0.0f, 0.0f);
        gradient.endPoint = CGPointMake(0.0f, 1.0f);
        [self.connectionStatusView.layer replaceSublayer:[self.connectionStatusView.layer.sublayers objectAtIndex:0] with:gradient];
        
        self.connectionStatusLabel.text = NSLocalizedStringFromTableInBundle(@"Connected", nil, [TAPUtil currentBundle], @"");
        NSMutableDictionary *connectionStatusAttributesDictionary = [NSMutableDictionary dictionary];
        CGFloat connectionStatusLetterSpacing = -0.2f;
        [connectionStatusAttributesDictionary setObject:@(connectionStatusLetterSpacing) forKey:NSKernAttributeName];
        NSMutableAttributedString *connectionStatusAttributedString = [[NSMutableAttributedString alloc] initWithString:self.connectionStatusLabel.text];
        [connectionStatusAttributedString addAttributes:connectionStatusAttributesDictionary
                                                  range:NSMakeRange(0, [self.connectionStatusLabel.text length])];
        self.connectionStatusLabel.attributedText = connectionStatusAttributedString;
        [self.connectionStatusLabel sizeToFit];
        self.connectionStatusLabel.frame = CGRectMake(CGRectGetMinX(self.connectionStatusLabel.frame), CGRectGetMinY(self.connectionStatusLabel.frame), CGRectGetWidth(self.connectionStatusLabel.frame), 20.0f);
        
        self.connectionStatusImageView.frame = CGRectMake(CGRectGetMaxX(self.connectionStatusLabel.frame) + 4.0f, CGRectGetMinY(self.connectionStatusImageView.frame), CGRectGetWidth(self.connectionStatusImageView.frame), CGRectGetHeight(self.connectionStatusImageView.frame));
        self.connectionStatusImageView.image = [UIImage imageNamed:@"TAPIconConnected" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        
        self.connectionStatusLabelView.frame = CGRectMake(CGRectGetMinX(self.connectionStatusLabelView.frame), CGRectGetMinY(self.connectionStatusLabelView.frame), CGRectGetWidth(self.connectionStatusLabel.frame) + 4.0f + CGRectGetWidth(self.connectionStatusImageView.frame), CGRectGetHeight(self.connectionStatusLabelView.frame));
        self.connectionStatusLabelView.center = CGPointMake(self.connectionStatusView.center.x, self.connectionStatusLabelView.center.y);
        
        //Remove Animation
        if ([self.connectionStatusImageView.layer animationForKey:@"SpinAnimation"] != nil) {
            [self.connectionStatusImageView.layer removeAnimationForKey:@"SpinAnimation"];
        }
    }
    else if (self.type == TAPConnectionStatusTypeOffline) {
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.connectionStatusView.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[TAPUtil getColor:@"9B9B9B"].CGColor, [TAPUtil getColor:@"9B9B9B"].CGColor, nil];
        gradient.startPoint = CGPointMake(0.0f, 0.0f);
        gradient.endPoint = CGPointMake(0.0f, 1.0f);
        [self.connectionStatusView.layer replaceSublayer:[self.connectionStatusView.layer.sublayers objectAtIndex:0] with:gradient];
        
        self.connectionStatusLabel.text = NSLocalizedStringFromTableInBundle(@"Waiting for Network", nil, [TAPUtil currentBundle], @"");
        NSMutableDictionary *connectionStatusAttributesDictionary = [NSMutableDictionary dictionary];
        CGFloat connectionStatusLetterSpacing = -0.2f;
        [connectionStatusAttributesDictionary setObject:@(connectionStatusLetterSpacing) forKey:NSKernAttributeName];
        NSMutableAttributedString *connectionStatusAttributedString = [[NSMutableAttributedString alloc] initWithString:self.connectionStatusLabel.text];
        [connectionStatusAttributedString addAttributes:connectionStatusAttributesDictionary
                                                  range:NSMakeRange(0, [self.connectionStatusLabel.text length])];
        self.connectionStatusLabel.attributedText = connectionStatusAttributedString;
        [self.connectionStatusLabel sizeToFit];
        self.connectionStatusLabel.frame = CGRectMake(CGRectGetMinX(self.connectionStatusLabel.frame), CGRectGetMinY(self.connectionStatusLabel.frame), CGRectGetWidth(self.connectionStatusLabel.frame), 20.0f);
        
        self.connectionStatusImageView.frame = CGRectMake(CGRectGetMaxX(self.connectionStatusLabel.frame) + 4.0f, CGRectGetMinY(self.connectionStatusImageView.frame), CGRectGetWidth(self.connectionStatusImageView.frame), CGRectGetHeight(self.connectionStatusImageView.frame));
        self.connectionStatusImageView.image = [UIImage imageNamed:@"TAPIconConnecting" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        
        self.connectionStatusLabelView.frame = CGRectMake(CGRectGetMinX(self.connectionStatusLabelView.frame), CGRectGetMinY(self.connectionStatusLabelView.frame), CGRectGetWidth(self.connectionStatusLabel.frame) + 4.0f + CGRectGetWidth(self.connectionStatusImageView.frame), CGRectGetHeight(self.connectionStatusLabelView.frame));
        self.connectionStatusLabelView.center = CGPointMake(self.connectionStatusView.center.x, self.connectionStatusLabelView.center.y);
        
        //Add Animation
        if ([self.connectionStatusImageView.layer animationForKey:@"SpinAnimation"] == nil) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            animation.fromValue = [NSNumber numberWithFloat:0.0f];
            animation.toValue = [NSNumber numberWithFloat: 2 * M_PI];
            animation.duration = 1.5f;
            animation.repeatCount = INFINITY;
            animation.removedOnCompletion = NO;
            [self.connectionStatusImageView.layer addAnimation:animation forKey:@"SpinAnimation"];
        }
    }
}

@end
