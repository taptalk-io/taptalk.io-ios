//
//  TapThumbnailImagePreviewCollectionViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 18/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TapThumbnailImagePreviewCollectionViewCell.h"

@interface TapThumbnailImagePreviewCollectionViewCell ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIView *removeView;
@property (strong, nonatomic) UIImageView *removeImageView;

@end

@implementation TapThumbnailImagePreviewCollectionViewCell

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 56.0f, 56.0f)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self.contentView addSubview:self.imageView];
        
        _removeView = [[UIView alloc] initWithFrame:self.imageView.frame];
        self.removeView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
        [self.contentView addSubview:self.removeView];
        
        _removeImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.removeView.frame) - 22.0f) / 2.0f, (CGRectGetHeight(self.removeView.frame) - 22.0f) / 2.0f, 22.0f, 22.0f)];
        self.removeImageView.image = [UIImage imageNamed:@"TAPIconRemoveGray" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.removeView addSubview:self.removeImageView];
    }
    
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.imageView.image = nil;
    self.removeView.alpha = 0.0f;
    [self setAsSelected:NO];
}

#pragma mark - Custom Method
- (void)setThumbnailImageView:(UIImage *)image {
    self.imageView.image = image;
}

- (void)setAsSelected:(BOOL)isSelected {
    if (isSelected) {
        [UIView animateWithDuration:0.2f animations:^{
            self.imageView.layer.borderWidth = 2.0f;
            self.imageView.layer.borderColor = [TAPUtil getColor:TAP_COLOR_MOSELO_GREEN].CGColor;
            self.removeView.alpha = 1.0f;
        }];
    }
    else {
        [UIView animateWithDuration:0.2f animations:^{
            self.imageView.layer.borderWidth = 0.0f;
            self.removeView.alpha = 0.0f;
        }];
    }
}

@end
