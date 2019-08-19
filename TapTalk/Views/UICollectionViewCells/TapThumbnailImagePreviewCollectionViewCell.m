//
//  TAPThumbnailImagePreviewCollectionViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 18/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPThumbnailImagePreviewCollectionViewCell.h"

@interface TAPThumbnailImagePreviewCollectionViewCell ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIView *removeView;

@property (strong, nonatomic) UIView *removeGrayImageContainerView;
@property (strong, nonatomic) UIView *removeRedImageContainerView;
@property (strong, nonatomic) UIView *alertImageContainerView;

@property (strong, nonatomic) UIImageView *removeImageView;
@property (strong, nonatomic) UIImageView *removeRedImageView;
@property (strong, nonatomic) UIImageView *alertImageView;

- (void)showAlertIcon:(BOOL)isShow animated:(BOOL)animated;

@end

@implementation TAPThumbnailImagePreviewCollectionViewCell

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
        
        _removeGrayImageContainerView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.removeView.frame) - 22.0f) / 2.0f, (CGRectGetHeight(self.removeView.frame) - 22.0f) / 2.0f, 22.0f, 22.0f)];
        self.removeGrayImageContainerView.layer.cornerRadius = CGRectGetHeight(self.removeGrayImageContainerView.frame) / 2.0f;
        self.removeGrayImageContainerView.clipsToBounds = YES;
        self.removeGrayImageContainerView.backgroundColor = [[TAPUtil getColor:@"040404"] colorWithAlphaComponent:0.5f];
        self.removeGrayImageContainerView.alpha = 0.0f;
        [self.removeView addSubview:self.removeGrayImageContainerView];
        
        _removeImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.removeGrayImageContainerView.frame) - 8.0f) / 2.0f, (CGRectGetHeight(self.removeGrayImageContainerView.frame) - 8.0f) / 2.0f, 8.0f, 8.0f)];
        self.removeImageView.image = [UIImage imageNamed:@"TAPIconCancel" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.removeGrayImageContainerView addSubview:self.removeImageView];
        
        _removeRedImageContainerView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.removeView.frame) - 22.0f) / 2.0f, (CGRectGetHeight(self.removeView.frame) - 22.0f) / 2.0f, 22.0f, 22.0f)];
        self.removeRedImageContainerView.layer.cornerRadius = CGRectGetHeight(self.removeRedImageContainerView.frame) / 2.0f;
        self.removeRedImageContainerView.clipsToBounds = YES;
        self.removeRedImageContainerView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconRemoveItem];
        self.removeRedImageContainerView.alpha = 0.0f;
        [self.removeView addSubview:self.removeRedImageContainerView];
        
        _removeRedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 22.0f, 22.0f)];
        self.removeRedImageView.image = [UIImage imageNamed:@"TAPIconRemoveMedia" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.removeRedImageView.image = [self.removeRedImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconRemoveItemBackground]];
        [self.removeRedImageContainerView addSubview:self.removeRedImageView];
        
        _alertImageContainerView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.imageView.frame) - 22.0f) / 2.0f, (CGRectGetHeight(self.imageView.frame) - 22.0f) / 2.0f, 22.0f, 22.0f)];
        self.alertImageContainerView.layer.cornerRadius = CGRectGetHeight(self.removeRedImageContainerView.frame) / 2.0f;
        self.alertImageContainerView.clipsToBounds = YES;
        self.alertImageContainerView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconMediaPreviewThumbnailWarning];
        self.alertImageContainerView.alpha = 0.0f;
        [self.contentView addSubview:self.alertImageContainerView];
        
        _alertImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 22.0f, 22.0f)];
        self.alertImageView.image = [UIImage imageNamed:@"TAPIconWarning" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.alertImageView.image = [self.alertImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconMediaPreviewThumbnailWarningBackground]];
        [self.alertImageContainerView addSubview:self.alertImageView];
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
            self.imageView.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorSelectedMediaPreviewThumbnailBorder].CGColor;
            
            [self showAlertIcon:NO animated:YES];
            self.removeView.alpha = 1.0f;
            
            if (self.isExceededMaxFileSize) {
                self.removeRedImageContainerView.alpha = 1.0f;
                self.removeGrayImageContainerView.alpha = 0.0f;
            }
            else {
                self.removeRedImageContainerView.alpha = 0.0f;
                self.removeGrayImageContainerView.alpha = 1.0f;
            }
        }];
    }
    else {
        [UIView animateWithDuration:0.2f animations:^{
            self.imageView.layer.borderWidth = 0.0f;
            self.removeView.alpha = 0.0f;
            
            if (self.isExceededMaxFileSize) {
                [self showAlertIcon:YES animated:YES];
            }
            else {
                [self showAlertIcon:NO animated:YES];
            }
            
        }];
    }
}

- (void)showAlertIcon:(BOOL)isShow animated:(BOOL)animated {
    if (animated) {
        if (isShow) {
            [UIView animateWithDuration:0.2f animations:^{
                self.alertImageContainerView.alpha = 1.0f;
            }];
        }
        else {
            [UIView animateWithDuration:0.2f animations:^{
                self.alertImageContainerView.alpha = 0.0f;
            }];
        }
    }
    else {
        if (isShow) {
            self.alertImageContainerView.alpha = 1.0f;
        }
        else {
            self.alertImageContainerView.alpha = 0.0f;
        }
    }
}

- (void)setAsExceededFileSize:(BOOL)isExceeded animated:(BOOL)animated {
//    if (animated) {
//        if (isExceeded) {
//            [UIView animateWithDuration:0.2f animations:^{
//                self.alertImageView.alpha = 1.0f;
//            }];
//        }
//        else {
//            [UIView animateWithDuration:0.2f animations:^{
//                self.alertImageView.alpha = 0.0f;
//            }];
//        }
//    }
//    else {
        if (isExceeded) {
            self.alertImageContainerView.alpha = 1.0f;
        }
        else {
            self.alertImageContainerView.alpha = 0.0f;
        }
//    }
}

- (void)setThumbnailImagePreviewCollectionViewCellType:(TAPThumbnailImagePreviewCollectionViewCellType)thumbnailImagePreviewCollectionViewCellType {
    _thumbnailImagePreviewCollectionViewCellType = thumbnailImagePreviewCollectionViewCellType;
}

@end
