//
//  TapThumbnailImagePreviewCollectionViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 18/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TapThumbnailImagePreviewCollectionViewCell : TAPBaseCollectionViewCell

- (void)setThumbnailImageView:(UIImage *)image;
- (void)setAsSelected:(BOOL)isSelected;

@end

NS_ASSUME_NONNULL_END
