//
//  TAPYourFileBubbleTableViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 04/03/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseXIBRotatedTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPYourFileBubbleTableViewCellStateType) {
    TAPYourFileBubbleTableViewCellStateTypeDoneDownloadedUploaded = 0,
    TAPYourFileBubbleTableViewCellStateTypeNotDownloaded = 1,
    TAPYourFileBubbleTableViewCellStateTypeDownloading = 2,
    TAPYourFileBubbleTableViewCellStateTypeRetry = 3
};

@protocol TAPYourFileBubbleTableViewCellDelegate <NSObject>

- (void)yourFileCheckmarkDidTapped:(TAPMessageModel *)tappedMessage;
- (void)yourFileBubbleViewDidTapped:(TAPMessageModel *)tappedMessage;
- (void)yourFileQuoteViewDidTapped:(TAPMessageModel *)tappedMessage;
- (void)yourFileReplyDidTapped:(TAPMessageModel *)tappedMessage;
- (void)yourFileBubbleLongPressedWithMessage:(TAPMessageModel *)longPressedMessage;
- (void)yourFileDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage;
- (void)yourFileRetryDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage;
- (void)yourFileCancelButtonDidTapped:(TAPMessageModel *)tappedMessage;
- (void)yourFileOpenFileButtonDidTapped:(TAPMessageModel *)tappedMessage;
- (void)yourFileBubbleDidTappedProfilePictureWithMessage:(TAPMessageModel *)tappedMessage;
- (void)yourFileBubbleDidTriggerSwipeToReplyWithMessage:(TAPMessageModel *)message;

@end

@interface TAPYourFileBubbleTableViewCell : TAPBaseXIBRotatedTableViewCell

@property (weak, nonatomic) id<TAPYourFileBubbleTableViewCellDelegate> delegate;
@property (weak, nonatomic) TAPMessageModel *message;
@property (nonatomic) TAPYourFileBubbleTableViewCellStateType yourFileBubbleTableViewCellStateType;

- (void)setMessage:(TAPMessageModel *)message;
- (void)showStatusLabel:(BOOL)isShowed animated:(BOOL)animated;
- (void)showProgressDownloadView:(BOOL)show;
- (void)showDownloadedState:(BOOL)isShow;
- (void)animateFinishedDownloadFile;
- (void)animateCancelDownloadFile;
- (void)animateFailedDownloadFile;
- (void)animateProgressDownloadingFileWithProgress:(CGFloat)progress total:(CGFloat)total;
- (void)showFileBubbleStatusWithType:(TAPYourFileBubbleTableViewCellStateType)type;
- (void)showBubbleHighlight;
- (void)showStarMessageView;
- (void)showSeperator;
- (void)showCheckMarkIcon:(BOOL)isShow;
- (void)setCheckMarkState:(BOOL)isSelected;

@end

NS_ASSUME_NONNULL_END
