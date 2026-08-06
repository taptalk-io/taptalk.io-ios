//
//  TAPImageCollectionViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 31/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseCollectionViewCell.h"
#import "TAPMessageModel.h"
#import "TAPImageView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TAPImageCollectionViewCellDelegate <NSObject>

- (void)imageCollectionViewCellDidTappedDownloadWithMessage:(TAPMessageModel *)message;
- (void)imageCollectionViewCellDidTappedCancelWithMessage:(TAPMessageModel *)message;
- (void)imageCollectionViewCellLongPressedWithMessage:(TAPMessageModel *)longPressedMessage;

@end


@interface TAPImageCollectionViewCell : TAPBaseCollectionViewCell

@property (weak, nonatomic) id<TAPImageCollectionViewCellDelegate> delegate;

@property (strong, nonatomic) TAPImageView *imageView;
@property (strong, nonatomic) TAPImageView *thumbnailImageView;
@property (strong, nonatomic) TAPMessageModel *currentMessage;

- (void)setImageCollectionViewCellWithMessage:(TAPMessageModel *)message;
- (void)setImageCollectionViewCellImageWithImage:(UIImage *)image;
- (void)setInfoLabelWithString:(NSString *)infoString;
- (void)setAsDownloaded;
- (void)setAsNotDownloaded;
- (void)animateFinishedDownloadingMedia;
- (void)animateFailedDownloadingMedia;
- (void)animateProgressDownloadingMediaWithProgress:(CGFloat)progress total:(CGFloat)total;
- (void)setInitialAnimateDownloadingMedia;
- (void)setThumbnailImageForVideoWithMessage:(TAPMessageModel *)message;
@end

NS_ASSUME_NONNULL_END
