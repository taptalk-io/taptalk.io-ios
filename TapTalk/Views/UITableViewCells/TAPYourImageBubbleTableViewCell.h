//
//  TAPYourImageBubbleTableViewCell.h
//  TapTalk
//
//  Created by Welly Kencana on 29/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseXIBRotatedTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPYourImageBubbleTableViewCell : TAPBaseXIBRotatedTableViewCell

@property (weak, nonatomic) TAPMessageModel *message;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bubbleImageViewWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bubbleImageViewHeightConstraint;

- (void)setMessage:(TAPMessageModel *)message;
- (void)showStatusLabel:(BOOL)isShowed animated:(BOOL)animated;

- (void)showProgressDownloadView:(BOOL)show;
- (void)animateFailedDownloadingImage;
- (void)animateProgressDownloadingImageWithProgress:(CGFloat)progress total:(CGFloat)total;
- (void)animateFinishedDownloadingImage;
- (void)setInitialAnimateDownloadingImage;
- (void)setFullImage:(UIImage *)image;
- (void)setThumbnailImage:(UIImage *)thumbnailImage;

@end

NS_ASSUME_NONNULL_END
