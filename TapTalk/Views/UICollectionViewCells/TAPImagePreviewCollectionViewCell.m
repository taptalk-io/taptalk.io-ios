//
//  TAPImagePreviewCollectionViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 18/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPImagePreviewCollectionViewCell.h"

@interface TAPImagePreviewCollectionViewCell ()

@property (strong, nonatomic) UIImageView *selectedPictureImageView;

@end

@implementation TAPImagePreviewCollectionViewCell

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _selectedPictureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.contentView.frame), CGRectGetHeight(self.contentView.frame))];
        self.selectedPictureImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.selectedPictureImageView.clipsToBounds = YES;
        [self.contentView addSubview:self.selectedPictureImageView];
    }
    
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.selectedPictureImageView.image = nil;
}

#pragma mark - Custom Method
- (void)setImagePreviewImage:(UIImage *)image {
    self.selectedPictureImageView.image = image;
}

@end

