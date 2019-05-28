//
//  TAPLoadingTableViewCell.m
//  TapTalk
//
//  Created by Cundy Sunardy on 23/05/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPLoadingTableViewCell.h"

@interface TAPLoadingTableViewCell ()

@property (strong, nonatomic) IBOutlet UIImageView *loadingImageView;

- (void)animateLoading:(BOOL)isAnimate;

@end

@implementation TAPLoadingTableViewCell
#pragma mark - Life Cycle
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
