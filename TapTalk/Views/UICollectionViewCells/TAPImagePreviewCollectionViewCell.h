//
//  TAPImagePreviewCollectionViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 18/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPImagePreviewCollectionViewCellType) {
    TAPImagePreviewCollectionViewCellTypeImage = 0,
    TAPImagePreviewCollectionViewCellTypeVideo = 1,
    TAPImagePreviewCollectionViewCellTypeProfileImage = 2
};

typedef NS_ENUM(NSInteger, TAPImagePreviewCollectionViewCellStateType) {
    TAPImagePreviewCollectionViewCellStateTypeDefault = 0,
    TAPImagePreviewCollectionViewCellStateTypeDownloading = 1
};

@protocol TAPImagePreviewCollectionViewCellDelegate <NSObject>

- (void)imagePreviewCollectionViewCellDidPlayVideoButtonDidTappedWithMediaPreview:(TAPMediaPreviewModel *)mediaPreview indexPath:(NSIndexPath *)indexPath;
- (void)saveImageButtonDidLongpressWithIndex:(TAPImageView *)currentImageView;

@end

@interface TAPImagePreviewCollectionViewCell : TAPBaseCollectionViewCell

@property (weak, nonatomic) id<TAPImagePreviewCollectionViewCellDelegate> delegate;
@property (strong, nonatomic) NSIndexPath *currentIndexPath;
@property (strong, nonatomic) TAPMediaPreviewModel *mediaPreviewData;
@property (nonatomic) TAPImagePreviewCollectionViewCellType imagePreviewCollectionViewCellType;
@property (nonatomic) TAPImagePreviewCollectionViewCellStateType imagePreviewCollectionViewCellStateType;
@property (nonatomic) BOOL isExceededMaxFileSize;
@property (strong, nonatomic) TAPImageView *selectedPictureImageView;

- (void)setImagePreviewImage:(UIImage *)image;
- (void)setImagePreviewImageWithUrl:(NSString *)imageUrl;
- (void)setImagePreviewCollectionViewCellType:(TAPImagePreviewCollectionViewCellType)imagePreviewCollectionViewCellType;
- (void)setImagePreviewCollectionViewCellStateType:(TAPImagePreviewCollectionViewCellStateType)imagePreviewCollectionViewCellStateType;
- (void)animateProgressMediaWithProgress:(CGFloat)progress total:(CGFloat)total;
- (void)showProgressView:(BOOL)show animated:(BOOL)isAnimated;
- (void)animateFinishedDownload;
- (void)showPlayButton:(BOOL)show animated:(BOOL)isAnimated;
- (void)setPageIndicatorActive:(BOOL)isActive;

@end

NS_ASSUME_NONNULL_END
