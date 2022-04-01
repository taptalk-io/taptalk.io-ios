//
//  TAPMyFileBubbleTableViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 04/03/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseMyBubbleTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPMyFileBubbleTableViewCellStateType) {
    TAPMyFileBubbleTableViewCellStateTypeDoneDownloadedUploaded = 0,
    TAPMyFileBubbleTableViewCellStateTypeNotDownloaded = 1,
    TAPMyFileBubbleTableViewCellStateTypeUploading = 2,
    TAPMyFileBubbleTableViewCellStateTypeDownloading = 3,
    TAPMyFileBubbleTableViewCellStateTypeRetryDownload = 4,
    TAPMyFileBubbleTableViewCellStateTypeRetryUpload = 5
};

@protocol TAPMyFileBubbleTableViewCellDelegate <NSObject>

- (void)myFileQuoteViewDidTapped:(TAPMessageModel *)tappedMessage;
- (void)myFileReplyDidTapped:(TAPMessageModel *)tappedMessage;
- (void)myFileBubbleLongPressedWithMessage:(TAPMessageModel *)longPressedMessage;
- (void)myFileRetryUploadDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage;
- (void)myFileDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage;
- (void)myFileCancelButtonDidTapped:(TAPMessageModel *)tappedMessage;
- (void)myFileOpenFileButtonDidTapped:(TAPMessageModel *)tappedMessage;
- (void)myFileBubbleDidTriggerSwipeToReplyWithMessage:(TAPMessageModel *)message;

@end

@interface TAPMyFileBubbleTableViewCell : TAPBaseMyBubbleTableViewCell

@property (weak, nonatomic) id<TAPMyFileBubbleTableViewCellDelegate> delegate;
@property (weak, nonatomic) TAPMessageModel *message;
@property (nonatomic) TAPMyFileBubbleTableViewCellStateType myFileBubbleTableViewCellStateType;

- (void)setMessage:(TAPMessageModel *)message;
- (void)receiveSentEvent;
- (void)receiveDeliveredEvent;
- (void)receiveReadEvent;
- (void)showDownloadedState:(BOOL)isShow;
- (void)animateFinishedUploadFile;
- (void)animateFinishedDownloadFile;
- (void)animateCancelDownloadFile;
- (void)animateFailedUploadFile;
- (void)animateFailedDownloadFile;
- (void)animateProgressUploadingFileWithProgress:(CGFloat)progress total:(CGFloat)total;
- (void)animateProgressDownloadingFileWithProgress:(CGFloat)progress total:(CGFloat)total;
- (void)showFileBubbleStatusWithType:(TAPMyFileBubbleTableViewCellStateType)type;
- (void)showBubbleHighlight;
- (void)showStarMessageView;
- (void)showSeperator;

@end

NS_ASSUME_NONNULL_END
