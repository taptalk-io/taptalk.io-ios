//
//  TAPNetworkManager.h
//  Moselo
//
//  Created by Ritchie Nathaniel on 3/9/17.
//  Copyright © 2017 Moselo. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AFNetworking;

#define NETWORK_MANAGER_NO_CONNECTION_NOTIFICATION_KEY @"Prefs.NetworkManagerNoConnectionNotificationKey"
#define NETWORK_MANAGER_NO_CONNECTION_MESSAGE NSLocalizedStringFromTableInBundle(@"Oops! It seems like you are offline, please check your connection.", nil, [TAPUtil currentBundle], @"");
#define NETWORK_MANAGER_NO_CONNECTION_MESSAGE_OLD NSLocalizedStringFromTableInBundle(@"It appears you don't have internet connection, please try again later...", nil, [TAPUtil currentBundle], @"");

@interface TAPNetworkManager : NSObject

+ (TAPNetworkManager *)sharedManager;

- (void)get:(NSString *)urlString
 parameters:(NSMutableDictionary *)parameters
   progress:(void (^)(NSProgress *downloadProgress))progress
    success:(void (^)(NSURLSessionDataTask *dataTask, NSDictionary *responseObject))success
    failure:(void (^)(NSURLSessionDataTask *dataTask, NSError *error))failure;
- (void)post:(NSString *)urlString
  parameters:(NSMutableDictionary *)parameters
    progress:(void (^)(NSProgress *uploadProgress))progress
     success:(void (^)(NSURLSessionDataTask *dataTask, NSDictionary *responseObject))success
     failure:(void (^)(NSURLSessionDataTask *dataTask, NSError *error))failure;
- (void)put:(NSString *)urlString
 parameters:(NSMutableDictionary *)parameters
    success:(void (^)(NSURLSessionDataTask *dataTask, NSDictionary *responseObject))success
    failure:(void (^)(NSURLSessionDataTask *dataTask, NSError *error))failure;
- (void)delete:(NSString *)urlString
parameters:(NSMutableDictionary *)parameters
success:(void (^)(NSURLSessionDataTask *dataTask, NSDictionary *responseObject))success
failure:(void (^)(NSURLSessionDataTask *dataTask, NSError *error))failure;

- (NSString *)urlEncodedStringFromDictionary:(NSDictionary *)parameterDictionary;

//TapTalk
- (void)post:(NSString *)urlString
  authTicket:(NSString *)authTicket
  parameters:(NSMutableDictionary *)parameters
    progress:(void (^)(NSProgress *uploadProgress))progress
     success:(void (^)(NSURLSessionDataTask *dataTask, NSDictionary *responseObject))success
     failure:(void (^)(NSURLSessionDataTask *dataTask, NSError *error))failure;

- (void)post:(NSString *)urlString
refreshToken:(NSString *)refreshToken
  parameters:(NSMutableDictionary *)parameters
    progress:(void (^)(NSProgress *uploadProgress))progress
     success:(void (^)(NSURLSessionDataTask *dataTask, NSDictionary *responseObject))success
     failure:(void (^)(NSURLSessionDataTask *dataTask, NSError *error))failure;

- (NSURLSessionUploadTask *)upload:(NSString *)urlString
                          fileData:(NSData *)fileData
                          fileName:(NSString *)fileName
                          fileType:(NSString *)filetype
                          mimeType:(NSString *)mimeType
                        parameters:(NSDictionary *)parameters
                          progress:(void (^)(NSProgress *uploadProgress))progress
                           success:(void (^)(NSDictionary *responseObject))success
                           failure:(void (^)(NSError *error))failure;

- (NSURLSessionUploadTask *)upload:(NSString *)urlString
                          fileData:(NSData *)fileData
                        parameters:(NSDictionary *)parameters
                          progress:(void (^)(NSProgress *uploadProgress))progress
                           success:(void (^)(NSDictionary *responseObject))success
                           failure:(void (^)(NSError *error))failure;

- (void)download:(NSString *)urlString
      parameters:(NSMutableDictionary *)parameters
        progress:(void (^)(NSProgress *downloadProgress))progress
         success:(void (^)(NSData *downloadedData))success
         failure:(void (^)(NSError *error))failure;

- (void)cancelDownloadWithFileID:(NSString *)fileID;

- (void)setAppKeyWithID:(NSString *)appKeyID secret:(NSString *)appKeySecret;
- (NSString *)getAppKey;

@end
