//
//  TAPContactLoadingTableViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 12/11/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPContactLoadingTableViewCell.h"

@interface TAPContactLoadingTableViewCell ()

@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UIImageView *loadingImageView;

@end

@implementation TAPContactLoadingTableViewCell
#pragma mark - Lifecycle
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 50.0f)];
        self.containerView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
        [self.contentView addSubview:self.containerView];
        
        _loadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.containerView.frame) - 20.0f) / 2.0f, (CGRectGetHeight(self.containerView.frame) - 20.0f) / 2.0f, 20.0f, 20.0f)];
        [self.loadingImageView setImage:[UIImage imageNamed:@"TAPIconLoaderProgress" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil]];
        self.loadingImageView.image = [self.loadingImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconLoadingProgressPrimary]];
        [self.containerView addSubview:self.loadingImageView];
    }
    
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

#pragma mark - Custom Method
- (void)animateLoading:(BOOL)isAnimate {
        if (isAnimate) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            animation.fromValue = [NSNumber numberWithFloat:0.0f];
            animation.toValue = [NSNumber numberWithFloat: 2 * M_PI];
            animation.duration = 1.5f;
            animation.repeatCount = INFINITY;
            animation.removedOnCompletion = NO;
            [self.loadingImageView.layer addAnimation:animation forKey:@"SpinAnimation"];
        }
        else {
            [self.loadingImageView.layer removeAnimationForKey:@"SpinAnimation"];
        }
}

@end
