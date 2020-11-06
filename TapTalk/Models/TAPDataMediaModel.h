//
//  TAPDataMediaModel.h
//  TapTalk
//
//  Created by Dominic Vedericho on 08/01/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseModel.h"
#import <AVKit/AVKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface TAPDataMediaModel : TAPBaseModel

@property (strong, nonatomic) NSString *fileID;
@property (strong, nonatomic) NSString *fileURL;
@property (strong, nonatomic) NSString *mediaType;
@property (strong, nonatomic) NSString *caption;
@property (strong, nonatomic) UIImage *dummyImage;
@property (nonatomic) CGFloat imageHeight;
@property (nonatomic) CGFloat imageWidth;
@property (nonatomic) CGFloat size;

@property (strong, nonatomic) PHAsset *asset;
@property (strong, nonatomic) NSString *assetIdentifier;

@end

NS_ASSUME_NONNULL_END
