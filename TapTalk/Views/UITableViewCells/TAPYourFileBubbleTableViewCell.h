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

- (void)yourFileBubbleViewDidTapped:(TAPMessageModel *)tappedMessage;
- (void)yourFileQuoteViewDidTapped:(TAPMessageModel *)tappedMessage;
- (void)yourFileReplyDidTapped:(TAPMessageModel *)tappedMessage;
- (void)yourFileBubbleLongPressedWithMessage:(TAPMessageModel *)longPressedMessage;
- (void)yourFileDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage;
- (void)yourFileRetryDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage;
- (void)yourFileCancelButtonDidTapped:(TAPMessageModel *)tappedMessage;
- (void)yourFileOpenFileButtonDidTapped:(TAPMessageModel *)tappedMessage;
- (void)yourFileBubbleDidTappedProfilePictureWithMessage:(TAPMessageModel *)tappedMessage;

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

@end

NS_ASSUME_NONNULL_END
