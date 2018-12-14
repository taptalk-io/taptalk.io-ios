//
//  TAPImageCollectionViewCell.m
//  TapTalk
//
//  Created by Welly Kencana on 31/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPImageCollectionViewCell.h"

@interface TAPImageCollectionViewCell ()

@property (strong, nonatomic) TAPImageView *imageView;

@end

@implementation TAPImageCollectionViewCell

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _imageView = [[TAPImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        self.imageView.clipsToBounds = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.imageView];
    }
    
    return self;
}

- (void)prepareForReuse {
    self.imageView.image = nil;
}

#pragma mark - Custom Method
- (void)setImageCollectionViewCellWithURL:(NSString *)imageURL {
    [self.imageView setImageWithURLString:imageURL];
}

@end
