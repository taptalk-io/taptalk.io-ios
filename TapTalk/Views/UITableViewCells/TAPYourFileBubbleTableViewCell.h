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

@end

@interface TAPYourFileBubbleTableViewCell : TAPBaseXIBRotatedTableViewCell

@property (weak, nonatomic) id<TAPYourFileBubbleTableViewCellDelegate> delegate;
@property (weak, nonatomic) TAPMessageModel *message;
@property (nonatomic) TAPYourFileBubbleTableViewCellStateType yourFileBubbleTableViewCellStateType;

- (void)setMessage:(TAPMessageModel *)message;
- (void)showStatusLabel:(BOOL)isShowed animated:(BOOL)animated;
- (void)showProgressDownloadView:(BOOL)show;
- (void)showNotDownloadedState;
- (void)animateFinishedDownloadFile;
- (void)animateFailedDownloadFile;
- (void)animateProgressDownloadingImageWithProgress:(CGFloat)progress total:(CGFloat)total;
- (void)showFileBubbleStatusWithType:(TAPYourFileBubbleTableViewCellStateType)type;

@end

NS_ASSUME_NONNULL_END
