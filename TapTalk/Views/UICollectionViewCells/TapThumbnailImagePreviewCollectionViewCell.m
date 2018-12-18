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
    }
    
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.imageView.image= nil;
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
        }];
    }
    else {
        [UIView animateWithDuration:0.2f animations:^{
            self.imageView.layer.borderWidth = 0.0f;
        }];
    }
}

@end
