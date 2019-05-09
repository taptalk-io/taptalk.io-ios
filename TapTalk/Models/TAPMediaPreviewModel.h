//
//  TAPMediaPreviewModel.h
//  TapTalk
//
//  Created by Dominic Vedericho on 21/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseModel.h"
#import <AVKit/AVKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface TAPMediaPreviewModel : TAPBaseModel

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *mediaType;

//0 for not define, 1 for is exceeded, 2 for not exceeded
@property (nonatomic) NSInteger fileSizeLimitStatus;

@property (nonatomic, strong) AVAsset *videoAsset;
@property (nonatomic) BOOL isExceededSizeLimit;

@end

NS_ASSUME_NONNULL_END
