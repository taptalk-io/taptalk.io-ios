//
//  TAPMyImageBubbleTableViewCell.h
//  TapTalk
//
//  Created by Welly Kencana on 29/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseMyBubbleTableViewCell.h"

@class TAPMyImageBubbleTableViewCell;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPMyImageBubbleTableViewCellStateType) {
    TAPMyImageBubbleTableViewCellStateTypeUploading = 0,
    TAPMyImageBubbleTableViewCellStateTypeDownloading = 1,
    TAPMyImageBubbleTableViewCellStateTypeFailed = 2
};

@protocol TAPMyImageBubbleTableViewCellDelegate <NSObject>

- (void)myImageCancelDidTappedWithMessage:(TAPMessageModel *)message;
- (void)myImageRetryDidTappedWithMessage:(TAPMessageModel *)message;
- (void)myImageQuoteDidTappedWithMessage:(TAPMessageModel *)message;
- (void)myImageReplyDidTappedWithMessage:(TAPMessageModel *)message;
- (void)myImageDidTapped:(TAPMyImageBubbleTableViewCell *)myImageBubbleCell;

@end

@interface TAPMyImageBubbleTableViewCell : TAPBaseMyBubbleTableViewCell

@property (weak, nonatomic) id<TAPMyImageBubbleTableViewCellDelegate> delegate;
@property (weak, nonatomic) TAPMessageModel *message;
@property (nonatomic) TAPMyImageBubbleTableViewCellStateType myImageBubbleTableViewCellStateType;
@property (strong, nonatomic) NSIndexPath *currentIndexPath;

@property (strong, nonatomic) IBOutlet TAPImageView *bubbleImageView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bubbleImageViewWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bubbleImageViewHeightConstraint;

- (void)setMessage:(TAPMessageModel *)message;
- (void)receiveSentEvent;
- (void)receiveDeliveredEvent;
- (void)receiveReadEvent;
- (void)showStatusLabel:(BOOL)isShowed animated:(BOOL)animated updateStatusIcon:(BOOL)updateStatusIcon message:(TAPMessageModel *)message;

- (void)showProgressUploadView:(BOOL)show;
- (void)animateFailedUploadingImage;
- (void)animateProgressUploadingImageWithProgress:(CGFloat)progress total:(CGFloat)total;
- (void)setInitialAnimateUploadingImageWithType:(TAPMyImageBubbleTableViewCellStateType)type;
- (void)animateFinishedUploadingImage;
- (void)setFullImage:(UIImage *)image;
- (void)setThumbnailImage:(UIImage *)thumbnailImage;
- (void)setMyImageBubbleTableViewCellStateType:(TAPMyImageBubbleTableViewCellStateType)myImageBubbleTableViewCellStateType;

@end

NS_ASSUME_NONNULL_END
