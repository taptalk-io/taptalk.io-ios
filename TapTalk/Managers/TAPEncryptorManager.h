//
//  TAPEncryptorManager.h
//  TapTalk
//
//  Created by Dominic Vedericho on 15/08/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AESCrypt.h"

@interface TAPEncryptorManager : NSObject

+ (TAPEncryptorManager *)sharedManager;

+ (TAPMessageModel *)decryptToMessageModelFromDictionary:(NSDictionary *)dictionary;
+ (NSDictionary *)encryptToDictionaryFromMessageModel:(TAPMessageModel *)message;
+ (NSDictionary *)encryptToDictionaryFromMessageModelForAPI:(TAPMessageModel *)message;

@end
