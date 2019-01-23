//
//  TAPMyImageBubbleTableViewCell.h
//  TapTalk
//
//  Created by Welly Kencana on 29/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseMyBubbleTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TAPMyImageBubbleTableViewCellDelegate <NSObject>

- (void)myImageCancelDidTapped;
- (void)myImageReplyDidTapped;

@end

@interface TAPMyImageBubbleTableViewCell : TAPBaseMyBubbleTableViewCell

@property (weak, nonatomic) id<TAPMyImageBubbleTableViewCellDelegate> delegate;
@property (weak, nonatomic) TAPMessageModel *message;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bubbleImageViewWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bubbleImageViewHeightConstraint;

- (void)setMessage:(TAPMessageModel *)message;
- (void)receiveSentEvent;
- (void)receiveDeliveredEvent;
- (void)receiveReadEvent;
- (void)showStatusLabel:(BOOL)isShowed animated:(BOOL)animated updateStatusIcon:(BOOL)updateStatusIcon;

- (void)showProgressUploadView:(BOOL)show;
- (void)animateFailedUploadingImage;
- (void)animateProgressUploadingImageWithProgress:(CGFloat)progress total:(CGFloat)total;
- (void)setInitialAnimateUploadingImageWithCancelButton:(BOOL)withCancelButton;
- (void)animateFinishedUploadingImage;
- (void)setFullImage:(UIImage *)image;
- (void)setThumbnailImage:(UIImage *)thumbnailImage;

@end

NS_ASSUME_NONNULL_END
