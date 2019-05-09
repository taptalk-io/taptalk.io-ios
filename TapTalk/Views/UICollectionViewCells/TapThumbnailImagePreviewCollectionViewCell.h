//
//  TAPThumbnailImagePreviewCollectionViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 18/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPThumbnailImagePreviewCollectionViewCellType) {
    TAPThumbnailImagePreviewCollectionViewCellTypeImage = 0,
    TAPThumbnailImagePreviewCollectionViewCellTypeVideo = 1,
};

@interface TAPThumbnailImagePreviewCollectionViewCell : TAPBaseCollectionViewCell

@property (strong, nonatomic) TAPMediaPreviewModel *mediaPreviewData;
@property (nonatomic) TAPThumbnailImagePreviewCollectionViewCellType thumbnailImagePreviewCollectionViewCellType;
@property (nonatomic) BOOL isExceededMaxFileSize;

- (void)setThumbnailImageView:(UIImage *)image;
- (void)setAsSelected:(BOOL)isSelected;
- (void)setAsExceededFileSize:(BOOL)isExceeded animated:(BOOL)animated;
- (void)setThumbnailImagePreviewCollectionViewCellType:(TAPThumbnailImagePreviewCollectionViewCellType)thumbnailImagePreviewCollectionViewCellType;

@end

NS_ASSUME_NONNULL_END
