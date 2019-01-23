//
//  TAPImageSelectCollectionViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 30/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPImageSelectCollectionViewCell.h"

@implementation TAPImageSelectCollectionViewCell

#pragma mark - Life Cycle
- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        
        self.contentView.backgroundColor = [UIColor whiteColor];

        CGFloat widthSize = (CGRectGetWidth([UIScreen mainScreen].bounds) - 1.0f - 1.0f - 1.0f - 1.0f) / 3.0f;
        _imageView = [[TAPImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, widthSize, widthSize)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self.contentView addSubview:self.imageView];
        
        _checklistImageView = [[UIImageView alloc] initWithFrame:CGRectMake(widthSize - 20.0f - 8.0f, 8.0f, 20.0f, 20.0f)];
        self.checklistImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.checklistImageView.clipsToBounds = YES;
        self.checklistImageView.layer.cornerRadius = CGRectGetHeight(self.checklistImageView.frame) / 2.0f;
        self.checklistImageView.image = [UIImage imageNamed:@"TAPIconCheckOff" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.contentView addSubview:self.checklistImageView];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
            self.checklistImageView.image = [UIImage imageNamed:@"TAPIconCheckOff" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
}

#pragma mark - Custom Method
- (void)setCellWithImageString:(NSString *)imageURL {
    [self.imageView setImageWithURLString:imageURL];
}

- (void)setCellWithImage:(UIImage *)image {
    self.imageView.image = image;
}

- (void)setCellAsSelected:(BOOL)isSelected {
    if(isSelected) {
        [UIView animateWithDuration:0.2f animations:^{
            self.checklistImageView.image = [UIImage imageNamed:@"TapIconGreenCheckOn" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        }];
    }
    else {
        [UIView animateWithDuration:0.2f animations:^{
            self.checklistImageView.image = [UIImage imageNamed:@"TAPIconCheckOff" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        }];
    }
}

@end
