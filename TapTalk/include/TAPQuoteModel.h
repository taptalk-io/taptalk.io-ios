//
//  TAPQuoteModel.h
//  TapTalk
//
//  Created by Cundy Sunardy on 26/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseModel.h"
@class TAPMessageModel;

@interface TAPQuoteModel : TAPBaseModel

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *fileID; //Image from TapTalk
@property (nonatomic, strong) NSString *imageURL; //Image from Client
@property (nonatomic, strong) NSString *fileType; //fileType is the same as message type casted to NSString

+ (instancetype)constructFromMessageModel:(TAPMessageModel *)message;

@end
