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
    TAPMyFileBubbleTableViewCellStateTypeRetry = 4
};

@protocol TAPMyFileBubbleTableViewCellDelegate <NSObject>

- (void)myFileBubbleViewDidTapped:(TAPMessageModel *)tappedMessage;
- (void)myFileQuoteViewDidTapped:(TAPMessageModel *)tappedMessage;
- (void)myFileReplyDidTapped:(TAPMessageModel *)tappedMessage;
- (void)myFileBubbleLongPressedWithMessage:(TAPMessageModel *)longPressedMessage;

@end

@interface TAPMyFileBubbleTableViewCell : TAPBaseMyBubbleTableViewCell

@property (weak, nonatomic) id<TAPMyFileBubbleTableViewCellDelegate> delegate;
@property (weak, nonatomic) TAPMessageModel *message;
@property (nonatomic) TAPMyFileBubbleTableViewCellStateType myFileBubbleTableViewCellStateType;

- (void)setMessage:(TAPMessageModel *)message;
- (void)receiveSentEvent;
- (void)receiveDeliveredEvent;
- (void)receiveReadEvent;
- (void)showStatusLabel:(BOOL)isShowed animated:(BOOL)animated updateStatusIcon:(BOOL)updateStatusIcon message:(TAPMessageModel *)message;
- (void)showProgressUploadView:(BOOL)show;
- (void)showNotDownloadedState;
- (void)animateFinishedUploadFile;
- (void)animateFinishedDownloadFile;
- (void)animateFailedUploadFile;
- (void)animateFailedDownloadFile;
- (void)animateProgressUploadingImageWithProgress:(CGFloat)progress total:(CGFloat)total;
- (void)showFileBubbleStatusWithType:(TAPMyFileBubbleTableViewCellStateType)type;

@end

NS_ASSUME_NONNULL_END
