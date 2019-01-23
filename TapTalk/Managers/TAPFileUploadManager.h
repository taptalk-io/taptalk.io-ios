//
//  TAPFileUploadManager.h
//  TapTalk
//
//  Created by Dominic Vedericho on 05/09/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TAPFileUploadManager : NSObject

+ (TAPFileUploadManager *)sharedManager;

- (NSInteger)obtainImageUploadStatusWithMessage:(TAPMessageModel *)message;
- (void)sendFileWithData:(TAPMessageModel *)message;
- (NSDictionary *)getUploadProgressWithLocalID:(NSString *)localID;

@end

NS_ASSUME_NONNULL_END
