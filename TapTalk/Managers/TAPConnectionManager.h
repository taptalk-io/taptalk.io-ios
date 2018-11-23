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

@property (weak, nonatomic) id<TAPConnectionManagerDelegate> delegate;
@property (nonatomic) TAPConnectionManagerStatusType tapConnectionStatus;

+ (TAPConnectionManager *)sharedManager;

- (void)connect;
- (void)sendEmit:(NSString *)eventName parameters:(NSDictionary *)parameterDictionary;
- (void)disconnect;
- (TAPConnectionManagerStatusType)getSocketConnectionStatus;
- (void)validateToken;
- (void)setSocketURLWithTapTalkEnvironment:(TapTalkEnvironment)environment;

@end
