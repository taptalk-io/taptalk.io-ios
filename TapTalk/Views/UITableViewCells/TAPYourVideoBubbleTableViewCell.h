//
//  TAPYourVideoBubbleTableViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 19/03/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseXIBRotatedTableViewCell.h"

@class TAPYourVideoBubbleTableViewCell;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPYourVideoBubbleTableViewCellStateType) {
    TAPYourVideoBubbleTableViewCellStateTypeDoneDownloaded = 0,
    TAPYourVideoBubbleTableViewCellStateTypeNotDownloaded = 1,
    TAPYourVideoBubbleTableViewCellStateTypeDownloading = 2,
    TAPYourVideoBubbleTableViewCellStateTypeRetryDownload = 3
};

@protocol TAPYourVideoBubbleTableViewCellDelegate <NSObject>

- (void)yourVideoQuoteDidTappedWithMessage:(TAPMessageModel *)message;
- (void)yourVideoReplyDidTappedWithMessage:(TAPMessageModel *)message;
- (void)yourVideoBubbleLongPressedWithMessage:(TAPMessageModel *)longPressedMessage;
- (void)yourVideoLongPressedUrl:(NSURL *)url
                 originalString:(NSString*)originalString;
- (void)yourVideoLongPressedPhoneNumber:(NSString *)phoneNumber
                         originalString:(NSString*)originalString;
- (void)yourVideoDidTappedUrl:(NSURL *)url
               originalString:(NSString*)originalString;
- (void)yourVideoDidTappedPhoneNumber:(NSString *)phoneNumber
                       originalString:(NSString*)originalString;
- (void)yourVideoPlayDidTappedWithMessage:(TAPMessageModel *)message;
- (void)yourVideoCancelDidTappedWithMessage:(TAPMessageModel *)message;
- (void)yourVideoRetryDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage;
- (void)yourVideoDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage;
- (void)yourVideoBubbleDidTappedProfilePictureWithMessage:(TAPMessageModel *)tappedMessage;
- (void)yourVideoBubbleDidTriggerSwipeToReplyWithMessage:(TAPMessageModel *)message;
- (void)yourVideoBubblePressedMentionWithWord:(NSString*)word
                               tappedAtIndex:(NSInteger)index
                                     message:(TAPMessageModel *)message
                         mentionIndexesArray:(NSArray *)mentionIndexesArray;
- (void)yourVideoBubbleLongPressedMentionWithWord:(NSString*)word
                                   tappedAtIndex:(NSInteger)index
                                         message:(TAPMessageModel *)message
                             mentionIndexesArray:(NSArray *)mentionIndexesArray;

@end

@interface TAPYourVideoBubbleTableViewCell : TAPBaseXIBRotatedTableViewCell

@property (weak, nonatomic) id<TAPYourVideoBubbleTableViewCellDelegate> delegate;
@property (weak, nonatomic) TAPMessageModel *message;
@property (nonatomic) TAPYourVideoBubbleTableViewCellStateType yourVideoBubbleTableViewCellStateType;
@property (strong, nonatomic) NSIndexPath *currentIndexPath;
@property (strong, nonatomic) NSArray *mentionIndexesArray;

@property (strong, nonatomic) IBOutlet TAPImageView *bubbleImageView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bubbleImageViewWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bubbleImageViewHeightConstraint;

- (void)setMessage:(TAPMessageModel *)message;
- (void)showProgressDownloadView:(BOOL)show;
- (void)showDownloadedState:(BOOL)isShow;
- (void)animateFinishedDownloadVideo;
- (void)animateCancelDownloadVideo;
- (void)animateFailedDownloadVideo;
- (void)animateProgressDownloadingVideoWithProgress:(CGFloat)progress total:(CGFloat)total;
- (void)showVideoBubbleStatusWithType:(TAPYourVideoBubbleTableViewCellStateType)type;
- (void)setVideoDurationAndSizeProgressViewWithMessage:(TAPMessageModel *)message progress:(NSNumber *)progress stateType:(TAPYourVideoBubbleTableViewCellStateType)type;
- (void)setThumbnailImageForVideoWithMessage:(TAPMessageModel *)message;

@end

NS_ASSUME_NONNULL_END
