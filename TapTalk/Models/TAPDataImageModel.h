//
//  TAPDataImageModel.h
//  TapTalk
//
//  Created by Dominic Vedericho on 08/01/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPDataImageModel : TAPBaseModel

@property (strong, nonatomic) NSString *fileID;
@property (strong, nonatomic) NSString *mediaType;
@property (strong, nonatomic) NSString *caption;
@property (strong, nonatomic) UIImage *dummyImage;
@property (nonatomic) CGFloat imageHeight;
@property (nonatomic) CGFloat imageWidth;
@property (nonatomic) CGFloat size;

@end

NS_ASSUME_NONNULL_END
