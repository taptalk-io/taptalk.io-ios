//
//  TAPImagePreviewModel.h
//  TapTalk
//
//  Created by Dominic Vedericho on 21/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPImagePreviewModel : TAPBaseModel

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *caption;

@end

NS_ASSUME_NONNULL_END
