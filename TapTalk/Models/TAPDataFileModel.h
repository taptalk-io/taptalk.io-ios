//
//  TAPDataFileModel.h
//  TapTalk
//
//  Created by Dominic Vedericho on 05/03/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPDataFileModel : TAPBaseModel

@property (strong, nonatomic) NSString *fileID;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSString *mediaType;
@property (strong, nonatomic) NSNumber *size;

//Not needed to send to message.data in API
@property (strong, nonatomic) NSData *fileData;

@end

NS_ASSUME_NONNULL_END
