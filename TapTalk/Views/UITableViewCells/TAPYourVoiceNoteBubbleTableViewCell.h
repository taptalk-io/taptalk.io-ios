//
//  TAPYourVoiceNoteBubbleTableViewCell.h
//  TapTalk
//
//  Created by TapTalk.io on 18/04/22.
//

#import "TAPBaseXIBRotatedTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPYourVoiceNoteBubbleTableViewCellStateType) {
    TAPYourVoiceNoteBubbleTableViewCellStateTypeDoneDownloadedUploaded = 0,
    TAPYourVoiceNoteBubbleTableViewCellStateTypeNotDownloaded = 1,
    TAPYourVoiceNoteBubbleTableViewCellStateTypeDownloading = 2,
    TAPYourVoiceNoteBubbleTableViewCellStateTypeRetry = 3
};

@protocol TAPYourVoiceNoteBubbleTableViewCellDelegate <NSObject>

- (void)yourVoiceNoteCheckmarkDidTapped:(TAPMessageModel *)tappedMessage;
- (void)yourVoiceNoteBubbleViewDidTapped:(TAPMessageModel *)tappedMessage;
- (void)yourVoiceNoteQuoteViewDidTapped:(TAPMessageModel *)tappedMessage;
- (void)yourVoiceNoteReplyDidTapped:(TAPMessageModel *)tappedMessage;
- (void)yourVoiceNoteBubbleLongPressedWithMessage:(TAPMessageModel *)longPressedMessage;
- (void)yourVoiceNoteDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage;
- (void)yourVoiceNoteRetryDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage;
- (void)yourVoiceNoteCancelButtonDidTapped:(TAPMessageModel *)tappedMessage;
- (void)yourVoiceNoteOpenFileButtonDidTapped:(TAPMessageModel *)tappedMessage;
- (void)yourVoiceNoteBubbleDidTappedProfilePictureWithMessage:(TAPMessageModel *)tappedMessage;
- (void)yourVoiceNoteBubbleDidTriggerSwipeToReplyWithMessage:(TAPMessageModel *)message;
- (void)yourVoiceNoteBubblePlayerSliderDidChange:(NSTimeInterval)currentTime message:(TAPMessageModel *)message;
- (void)yourVoiceNoteBubblePlayerSliderDidEnd;
@end

@interface TAPYourVoiceNoteBubbleTableViewCell : TAPBaseXIBRotatedTableViewCell

@property (weak, nonatomic) id<TAPYourVoiceNoteBubbleTableViewCellDelegate> delegate;
@property (weak, nonatomic) TAPMessageModel *message;
@property (nonatomic) TAPYourVoiceNoteBubbleTableViewCellStateType yourFileBubbleTableViewCellStateType;

- (void)setMessage:(TAPMessageModel *)message;
- (void)showStatusLabel:(BOOL)isShowed animated:(BOOL)animated;
- (void)showProgressDownloadView:(BOOL)show;
- (void)showDownloadedState:(BOOL)isShow;
- (void)animateFinishedDownloadFile;
- (void)animateCancelDownloadFile;
- (void)animateFailedDownloadFile;
- (void)animateProgressDownloadingFileWithProgress:(CGFloat)progress total:(CGFloat)total;
- (void)showFileBubbleStatusWithType:(TAPYourVoiceNoteBubbleTableViewCellStateType)type;
- (void)showBubbleHighlight;
- (void)showStarMessageView;
- (void)showSeperator;
- (void)setAudioSliderValue:(NSTimeInterval)currentTime;
- (void)setAudioSliderMaximumValue:(NSTimeInterval)duration;
- (void)setPlayingState:(BOOL)isPlay;
- (void)setVoiceNoteDurationLabel:(NSString *)duration;
- (void)showCheckMarkIcon:(BOOL)isShow;
- (void)setCheckMarkState:(BOOL)isSelected;

@end

NS_ASSUME_NONNULL_END
