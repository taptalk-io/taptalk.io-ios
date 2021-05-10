//
//  TAPConnectionManager.h
//  TapTalk
//
//  Created by Dominic Vedericho on 09/08/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SocketRocket/SocketRocket.h>

typedef NS_ENUM(NSInteger, TAPConnectionManagerStatusType) {
    TAPConnectionManagerStatusTypeNotConnected = 0,
    TAPConnectionManagerStatusTypeDisconnected = 1,
    TAPConnectionManagerStatusTypeConnecting = 2,
    TAPConnectionManagerStatusTypeConnected = 3,
};

@protocol TAPConnectionManagerDelegate <NSObject>

- (void)connectionManagerDidReceiveNewEmit:(NSString *)eventName parameter:(NSDictionary *)dataDictionary;

@optional

- (void)connectionManagerIsConnecting;
- (void)connectionManagerDidConnected;
- (void)connectionManagerDidReceiveError:(NSError *)error;
- (void)connectionManagerIsReconnecting;
- (void)connectionManagerDidDisconnectedWithCode:(NSInteger)code reason:(NSString *)reason cleanClose:(BOOL)clean;

@end

@interface TAPConnectionManager : NSObject

@property (nonatomic) TAPConnectionManagerStatusType tapConnectionStatus;

+ (TAPConnectionManager *)sharedManager;

#warning Do not forget to remove the delegate object, since an object can't weak retained in an array, also please remove this delegate before dealloc or the delegate will always retained
- (void)addDelegate:(id <TAPConnectionManagerDelegate>)delegate;
- (void)removeDelegate:(id <TAPConnectionManagerDelegate>)delegate;

- (void)connect;
- (void)sendEmit:(NSString *)eventName parameters:(NSDictionary *)parameterDictionary;
- (void)disconnect;
- (TAPConnectionManagerStatusType)getSocketConnectionStatus;
- (void)setSocketURLString:(NSString *)urlString;

@end
