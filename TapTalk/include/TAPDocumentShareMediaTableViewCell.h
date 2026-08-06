//
//  TAPDocumentShareMediaTableViewCell.h
//  TapTalk
//
//  Created by TapTalk.io on 19/08/22.
//

#import "TAPBaseXIBTableViewCell.h"
#import "TAPMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPDocumentShareManagerStateType) {
    TAPDocumentShareManagerStateTypeDoneDownloadedUploaded = 0,
    TAPDocumentShareManagerStateTypeNotDownloaded = 1,
    TAPDocumentShareManagerStateTypeUploading = 2,
    TAPDocumentShareManagerStateTypeDownloading = 3,
    TAPDocumentShareManagerStateTypeRetryDownload = 4,
    TAPDocumentShareManagerStateTypeRetryUpload = 5
};

@protocol TAPDocumentShareManagerCellDelegate <NSObject>

- (void)documentShareManagerLongPressedWithMessage:(TAPMessageModel *)longPressedMessage;
- (void)documentShareManagerRetryUploadDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage;
- (void)documentShareManagerDownloadButtonDidTapped:(TAPMessageModel *)tappedMessage;
- (void)documentShareManagerCancelButtonDidTapped:(TAPMessageModel *)tappedMessage;
- (void)documentShareManagerOpenFileButtonDidTapped:(TAPMessageModel *)tappedMessage;

@end

@interface TAPDocumentShareMediaTableViewCell : TAPBaseXIBTableViewCell
@property (weak, nonatomic) id<TAPDocumentShareManagerCellDelegate> delegate;
@property (weak, nonatomic) TAPMessageModel *message;
- (void)setDocumentTitleInfoWithMessage:(TAPMessageModel *)message;
- (void)showDownloadedState:(BOOL)isShow;
- (void)animateFinishedUploadFile;
- (void)animateFinishedDownloadFile;
- (void)animateCancelDownloadFile;
- (void)animateFailedUploadFile;
- (void)animateFailedDownloadFile;
- (void)animateProgressUploadingFileWithProgress:(CGFloat)progress total:(CGFloat)total;
- (void)animateProgressDownloadingFileWithProgress:(CGFloat)progress total:(CGFloat)total;

- (void)showFileBubbleStatusWithType:(TAPDocumentShareManagerStateType)type;

@end

NS_ASSUME_NONNULL_END
