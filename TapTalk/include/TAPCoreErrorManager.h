//
//  TAPCoreErrorManager.h
//  TapTalk
//
//  Created by Dominic Vedericho on 12/08/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPCoreErrorManager : TAPBaseModel

+ (TAPCoreErrorManager *)sharedManager;

- (NSError *)generateLocalizedError:(NSError *)error;
- (NSError *)generateLocalizedErrorWithErrorCode:(NSInteger)errorCode
                                    errorMessage:(NSString *)errorMessage;

@end

NS_ASSUME_NONNULL_END
