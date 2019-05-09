//
//  TAPQuoteModel.h
//  TapTalk
//
//  Created by Cundy Sunardy on 26/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPQuoteModel : TAPBaseModel

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *fileID; //Image from TapTalk
@property (nonatomic, strong) NSString *imageURL; //Image from Client
@property (nonatomic, strong) NSString *fileType; //fileType is the same as message type casted to NSString

@end

NS_ASSUME_NONNULL_END
