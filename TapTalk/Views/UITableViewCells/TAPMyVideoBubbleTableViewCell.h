//
//  TAPMyVideoBubbleTableViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 19/03/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseMyBubbleTableViewCell.h"

@class TAPMyVideoBubbleTableViewCell;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPMyVideoBubbleTableViewCellStateType) {
    TAPMyVideoBubbleTableViewCellStateTypeDoneDownloadedUploaded = 0,
    TAPMyVideoBubbleTableViewCellStateTypeNotDownloaded = 1,
    TAPMyVideoBubbleTableViewCellStateTypeUploading = 2,
    TAPMyVideoBubbleTableViewCellStateTypeDownloading = 3,
    TAPMyVideoBubbleTableViewCellStateTypeRetryDownload = 4,
    TAPMyVideoBubbleTableViewCellStateTypeRetryUpload = 5
};

@protocol TAPMyVideoBubbleTableViewCellDelegate <NSObject>

- (void)myVideoQuoteDidTappedWithMessage:(TAPMessageModel *)message;
- (void)myVideoReplyDidTappedWithMessage:(TAPMessageModel *)message;
- (void)myVideoCheckmarkDidTappedWithMessage:(TAPMessageModel *)message;
- (void)myVideoBubbleLongPressedWithMessage:(TAPMessageModel *)longPressedMessage;
- (void)myVideoLongPressedUrl:(NSURL *)url
               originalString:(NSString*)originalString;
- (void)myVideoLongPressedPhoneNumber:(NSString *)phoneNumber
                       originalString:(NSString *)originalString;
- (void)myVideoDidTappedUrl:(NSURL *)url
             originalString:(NSString*)originalString;
- (void)myVideoDidTappedPhoneNumber:(NSString *)phoneNumber
                     originalString:(NSString*)originalString;
- (void)myVideoPlayDidTappedWithMessage:(TAPMessageModel *)message;
- (void)myVideoCancelDidTappedWithMessage:(TAPMessageModel *)message;
- (void)myVideoRetryUploadDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage;
- (void)myVideoDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage;
- (void)myVideoBubbleDidTriggerSwipeToReplyWithMessage:(TAPMessageModel *)message;
- (void)myVideoBubblePressedMentionWithWord:(NSString*)word
                              tappedAtIndex:(NSInteger)index
                                    message:(TAPMessageModel *)message
                        mentionIndexesArray:(NSArray *)mentionIndexesArray;
- (void)myVideoBubbleLongPressedMentionWithWord:(NSString*)word
                                  tappedAtIndex:(NSInteger)index
                                        message:(TAPMessageModel *)message
                            mentionIndexesArray:(NSArray *)mentionIndexesArray;

@end

@interface TAPMyVideoBubbleTableViewCell : TAPBaseMyBubbleTableViewCell

@property (weak, nonatomic) id<TAPMyVideoBubbleTableViewCellDelegate> delegate;
@property (weak, nonatomic) TAPMessageModel *message;
@property (nonatomic) TAPMyVideoBubbleTableViewCellStateType myVideoBubbleTableViewCellStateType;
@property (strong, nonatomic) NSIndexPath *currentIndexPath;
@property (strong, nonatomic) NSArray *mentionIndexesArray;

@property (strong, nonatomic) IBOutlet TAPImageView *bubbleImageView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bubbleImageViewWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bubbleImageViewHeightConstraint;

- (void)setMessage:(TAPMessageModel *)message;
- (void)receiveSentEvent;
- (void)receiveDeliveredEvent;
- (void)receiveReadEvent;
- (void)showStatusLabel:(BOOL)isShowed animated:(BOOL)animated updateStatusIcon:(BOOL)updateStatusIcon message:(TAPMessageModel *)message;
- (void)showBubbleHighlight;

- (void)showProgressUploadView:(BOOL)show;
- (void)showDownloadedState:(BOOL)isShow;
- (void)animateFinishedUploadVideo;
- (void)animateFinishedDownloadVideo;
- (void)animateCancelDownloadVideo;
- (void)animateFailedUploadVideo;
- (void)animateFailedDownloadVideo;
- (void)animateProgressUploadingVideoWithProgress:(CGFloat)progress total:(CGFloat)total;
- (void)animateProgressDownloadingVideoWithProgress:(CGFloat)progress total:(CGFloat)total;
- (void)showVideoBubbleStatusWithType:(TAPMyVideoBubbleTableViewCellStateType)type;
- (void)setVideoDurationAndSizeProgressViewWithMessage:(TAPMessageModel *)message progress:(NSNumber *)progress stateType:(TAPMyVideoBubbleTableViewCellStateType)type;
- (void)setThumbnailImageForVideoWithMessage:(TAPMessageModel *)message;
- (void)showStarMessageView;
- (void)showSeperator;
- (void)showCheckMarkIcon:(BOOL)isShow;
- (void)setCheckMarkState:(BOOL)isSelected;

@end

NS_ASSUME_NONNULL_END
