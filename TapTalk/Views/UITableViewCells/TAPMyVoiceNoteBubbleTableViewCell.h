//
//  TAPMyVoiceNoteBubbleTableViewCell.h
//  TapTalk
//
//  Created by TapTalk.io on 13/04/22.
//

#import "TAPBaseMyBubbleTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPMyVoiceNoteBubbleTableViewCellStateType) {
    TAPMyVoiceNoteBubbleTableViewCellStateTypeDoneDownloadedUploaded = 0,
    TAPMyVoiceNoteBubbleTableViewCellStateTypeNotDownloaded = 1,
    TAPMyVoiceNoteBubbleTableViewCellStateTypeUploading = 2,
    TAPMyVoiceNoteBubbleTableViewCellStateTypeDownloading = 3,
    TAPMyVoiceNoteBubbleTableViewCellStateTypeRetryDownload = 4,
    TAPMyVoiceNoteBubbleTableViewCellStateTypeRetryUpload = 5
};

@protocol TAPMyVoiceNoteBubbleTableViewCellDelegate <NSObject>

- (void)myVoiceNoteQuoteViewDidTapped:(TAPMessageModel *)tappedMessage;
- (void)myVoiceNoteReplyDidTapped:(TAPMessageModel *)tappedMessage;
- (void)myVoiceNoteCheckmarkDidTapped:(TAPMessageModel *)tappedMessage;
- (void)myVoiceNoteBubbleLongPressedWithMessage:(TAPMessageModel *)longPressedMessage;
- (void)myVoiceNoteRetryUploadDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage;
- (void)myVoiceNoteDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage;
- (void)myVoiceNoteCancelButtonDidTapped:(TAPMessageModel *)tappedMessage;
- (void)myVoiceNotePlayPauseButtonDidTapped:(TAPMessageModel *)tappedMessage;
- (void)myVoiceNoteBubbleDidTriggerSwipeToReplyWithMessage:(TAPMessageModel *)message;
- (void)myVoiceNoteBubblePlayerSliderDidChange:(NSTimeInterval)currentTime message:(TAPMessageModel *)message;
- (void)myVoiceNoteBubblePlayerSliderDidEnd;

@end

@interface TAPMyVoiceNoteBubbleTableViewCell : TAPBaseMyBubbleTableViewCell

@property (weak, nonatomic) id<TAPMyVoiceNoteBubbleTableViewCellDelegate> delegate;
@property (weak, nonatomic) TAPMessageModel *message;
@property (nonatomic) TAPMyVoiceNoteBubbleTableViewCellStateType myFileBubbleTableViewCellStateType;

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
- (void)showFileBubbleStatusWithType:(TAPMyVoiceNoteBubbleTableViewCellStateType)type;
- (void)showBubbleHighlight;
- (void)showStarMessageView;
- (void)showSeperator;
- (void)setAudioSliderValue:(NSTimeInterval)currentTime;
- (void)setAudioSliderMaximumValue:(NSTimeInterval)duration;
- (void)setPlayingState:(BOOL)isPlay;
- (void)setVoiceNoteDurationLabel:(NSString *)duration;
- (void)showCheckMarkIcon:(BOOL)isShow;
- (void)setCheckMarkState:(BOOL)isSelected;
- (void)setSwipeGestureEnable:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END
