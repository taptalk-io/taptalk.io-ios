//
//  TAPImageSelectCollectionViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 30/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPImageSelectCollectionViewCell.h"

@interface TAPImageSelectCollectionViewCell ()

@property (strong, nonatomic) UIView *videoTypeView;
@property (strong, nonatomic) UIImageView *videoTypeImageView;
@property (strong, nonatomic) UILabel *videoDurationLabel;

- (void)showCellAsVideoType:(BOOL)isShow;

@end

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
        
        _videoTypeView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, widthSize - 62.0f, widthSize, 62.0f)];
        self.videoTypeView.alpha = 0.0f;
        self.videoTypeView.backgroundColor = [UIColor clearColor];
        self.videoTypeView.clipsToBounds = YES;
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.videoTypeView.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[[TAPUtil getColor:@"0A0A22"] colorWithAlphaComponent:0.0f].CGColor, (id)[TAPUtil getColor:@"04040f"].CGColor, nil];
        gradient.startPoint = CGPointMake(0.0f, 0.0f);
        gradient.endPoint = CGPointMake(0.0f, 1.0f);
        [self.videoTypeView.layer insertSublayer:gradient atIndex:0];
        [self.contentView addSubview:self.videoTypeView];
        
        _videoTypeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8.0f, CGRectGetHeight(self.videoTypeView.frame) - 15.0f - 6.0f, 15.0f, 15.0f)];
        self.videoTypeImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.videoTypeImageView.clipsToBounds = YES;
        self.videoTypeImageView.image = [UIImage imageNamed:@"TAPIconThumbnailVideo" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.videoTypeView addSubview:self.videoTypeImageView];
        
        _videoDurationLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.videoTypeView.frame) - 60.0f - 8.0f, CGRectGetHeight(self.videoTypeView.frame) - 15.0f - 6.0f, 60.0f, 15.0f)];
        self.videoDurationLabel.backgroundColor = [UIColor clearColor];
        self.videoDurationLabel.font = [UIFont fontWithName:TAP_FONT_NAME_BOLD size:12.0f];
        self.videoDurationLabel.textAlignment = NSTextAlignmentRight;
        self.videoDurationLabel.textColor = [UIColor whiteColor];
        [self.videoTypeView addSubview:self.videoDurationLabel];
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

- (void)setCellWithImage:(UIImage *)image andMediaAsset:(PHAsset *)asset {
    PHAssetMediaType mediaType = asset.mediaType;
    
    if (mediaType == PHAssetMediaTypeVideo) {
        [self showCellAsVideoType:YES];
        NSTimeInterval videoDuration = asset.duration;
        NSString *videoDurationString = [TAPUtil stringFromTimeInterval:ceil(videoDuration)];
        self.videoDurationLabel.text = videoDurationString;
    }
    else {
        [self showCellAsVideoType:NO];
    }
    
    self.imageView.image = image;
}

- (void)setCellAsSelected:(BOOL)isSelected {
    if(isSelected) {
        [UIView animateWithDuration:0.2f animations:^{
            self.checklistImageView.image = [UIImage imageNamed:@"TAPIconCheckOn" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        }];
    }
    else {
        [UIView animateWithDuration:0.2f animations:^{
            self.checklistImageView.image = [UIImage imageNamed:@"TAPIconCheckOff" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        }];
    }
}

- (void)showCellAsVideoType:(BOOL)isShow {
    if (isShow) {
        self.videoTypeView.alpha = 1.0f;
    }
    else {
        self.videoTypeView.alpha = 0.0f;
    }
}

@end
