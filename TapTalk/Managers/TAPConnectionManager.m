//
//  TAPConnectionManager.m
//  TapTalk
//
//  Created by Dominic Vedericho on 09/08/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPConnectionManager.h"

#import <AFNetworking/AFNetworking.h>

#define kSocketAutomaticallyReconnect YES
#define kSocketReconnectDelay 0.5f
#define kSocketReconnectMaximumMultiplier 60.0f

@interface TAPConnectionManager () <SRWebSocketDelegate>

@property (strong, nonatomic) SRWebSocket *webSocket;
@property (strong, nonatomic) NSString *socketURL;
@property (nonatomic) NSInteger reconnectAttempt;
@property (nonatomic) BOOL isShouldReconnect;

@property (strong, nonatomic) NSMutableArray *delegatesArray;

- (void)tryToReconnect;
- (void)reconnect;

@end

@implementation TAPConnectionManager

#pragma mark - Lifecycle
+ (TAPConnectionManager *)sharedManager {
    static TAPConnectionManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (id)init {
    self = [super init];
    
    if (self) {
        _tapConnectionStatus = TAPConnectionManagerStatusTypeNotConnected;
        _socketURL = [[NSString alloc] init];
        
        _delegatesArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

#pragma mark - Delegate
#pragma mark SRWebSocket
- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
#ifdef DEBUG
    NSLog(@"Socket Open");
#endif
    
    _reconnectAttempt = 0;
    _webSocket = webSocket;
    _tapConnectionStatus = TAPConnectionManagerStatusTypeConnected;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_SOCKET_CONNECTED object:nil];
    
    for (id delegate in self.delegatesArray) {
        if ([delegate respondsToSelector:@selector(connectionManagerDidConnected)]) {
            [delegate connectionManagerDidConnected];
        }
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
#ifdef DEBUG
    NSLog(@"Socket Receive Emit");
#endif

    NSString *messageString = [[NSString alloc] initWithData:message encoding:NSUTF8StringEncoding];
    
    //Seperate combined message from server if exist
    NSArray *messageArray = [messageString componentsSeparatedByString:@"\n"];
    
    //Loop for combined message from server
    for (NSString *currentMessage in messageArray) {
        NSDictionary *messageDictionary = [TAPUtil jsonObjectFromString:currentMessage];
        
        NSString *eventName = [messageDictionary objectForKey:@"eventName"];
        NSDictionary *dataDictionary = [messageDictionary objectForKey:@"data"];
        
        for (id delegate in self.delegatesArray) {
            if ([delegate respondsToSelector:@selector(connectionManagerDidReceiveNewEmit:parameter:)]) {
                [delegate connectionManagerDidReceiveNewEmit:eventName parameter:dataDictionary];
            }
        }
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
#ifdef DEBUG
    NSLog(@"Socket Fail with Error: %@", [error description]);
#endif
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_SOCKET_RECEIVE_ERROR object:error];
    
    _tapConnectionStatus = TAPConnectionManagerStatusTypeDisconnected;
    
    for (id delegate in self.delegatesArray) {
        if ([delegate respondsToSelector:@selector(connectionManagerDidReceiveError:)]) {
            [delegate connectionManagerDidReceiveError:error];
        }
    }
    
    [self tryToReconnect];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(nullable NSString *)reason wasClean:(BOOL)wasClean {
#ifdef DEBUG
    NSLog(@"Socket Close with Code: %li Reason:%@ Clean:%@", code, reason, STRING_FROM_BOOL(wasClean));
#endif
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_SOCKET_DISCONNECTED object:nil];
    
    _tapConnectionStatus = TAPConnectionManagerStatusTypeDisconnected;
    
    for (id delegate in self.delegatesArray) {
        if ([delegate respondsToSelector:@selector(connectionManagerDidDisconnectedWithCode:reason:cleanClose:)]) {
            if (reason == nil) {
                reason = @"";
            }
            
            [delegate connectionManagerDidDisconnectedWithCode:code reason:reason cleanClose:wasClean];
        }
    }
    
    [self tryToReconnect];
}

#pragma mark - Custom Method
- (void)connect {
#ifdef DEBUG
    NSLog(@"ConnectionManager Connect");
#endif
    
    if (self.tapConnectionStatus != TAPConnectionManagerStatusTypeDisconnected && self.tapConnectionStatus != TAPConnectionManagerStatusTypeNotConnected) {
        return;
    }
    
    _tapConnectionStatus = TAPConnectionManagerStatusTypeConnecting;
    _isShouldReconnect = kSocketAutomaticallyReconnect;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_SOCKET_CONNECTING object:nil];
    
    for (id delegate in self.delegatesArray) {
        if ([delegate respondsToSelector:@selector(connectionManagerIsConnecting)]) {
            [delegate connectionManagerIsConnecting];
        }
    }
    
    _webSocket.delegate = nil;
    _webSocket = nil;
    
    [self validateToken];
    
    NSString *authorizationValueString = [NSString stringWithFormat:@"Bearer %@", [TAPDataManager getAccessToken]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.socketURL]];
    NSString *encodedAppKey = [[TAPNetworkManager sharedManager] getAppKey];
    NSString *clientUserAgent = [[TapTalk sharedInstance] getTapTalkUserAgent];
    
    if ([clientUserAgent isEqualToString:@""] || clientUserAgent == nil) {
        clientUserAgent = @"ios";
    }
    
    [urlRequest addValue:encodedAppKey forHTTPHeaderField:@"App-Key"];
    [urlRequest addValue:[[UIDevice currentDevice] identifierForVendor].UUIDString forHTTPHeaderField:@"Device-Identifier"];
    [urlRequest addValue:[[UIDevice currentDevice] model] forHTTPHeaderField:@"Device-Model"];
    [urlRequest addValue:@"ios" forHTTPHeaderField:@"Device-Platform"];
    [urlRequest addValue:[[UIDevice currentDevice] systemVersion] forHTTPHeaderField:@"Device-OS-Version"];
    [urlRequest addValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forHTTPHeaderField:@"App-Version"];
    [urlRequest addValue:clientUserAgent forHTTPHeaderField:@"User-Agent"];
    [urlRequest addValue:authorizationValueString forHTTPHeaderField:@"Authorization"];
    
    SRWebSocket *webSocket = [[SRWebSocket alloc] initWithURLRequest:urlRequest];
    webSocket.delegate = self;
    [webSocket open];
}

- (void)reconnect {
#ifdef DEBUG
    NSLog(@"ConnectionManager Reconnect");
#endif
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_SOCKET_RECONNECTING object:nil];
    
    for (id delegate in self.delegatesArray) {
        if ([delegate respondsToSelector:@selector(connectionManagerIsReconnecting)]) {
            [delegate connectionManagerIsReconnecting];
        }
    }
    
    [self connect];
}

- (void)sendEmit:(NSString *)eventName parameters:(NSDictionary *)parameterDictionary {
#ifdef DEBUG
    NSLog(@"ConnectionManager Send Emit: %@\nParameter: %@", eventName, parameterDictionary);
#endif
    
    NSMutableDictionary *emitDictionary = [NSMutableDictionary dictionary];
    [emitDictionary setObject:eventName forKey:@"eventName"];
    [emitDictionary setObject:parameterDictionary forKey:@"data"];
    
    NSString *emitString = [TAPUtil jsonStringFromObject:emitDictionary];
    
    NSData *emitData = [emitString dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.webSocket send:emitData];
}

- (void)disconnect {
#ifdef DEBUG
    NSLog(@"ConnectionManager Disconnect");
#endif
    
    if (self.webSocket == nil) {
        return;
    }
    
    _isShouldReconnect = NO;
    
    [self.webSocket close];
    _webSocket.delegate = nil;
    _webSocket = nil;
    
    _tapConnectionStatus = TAPConnectionManagerStatusTypeDisconnected;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TAP_NOTIFICATION_SOCKET_DISCONNECTED object:nil];
    
    for (id delegate in self.delegatesArray) {
        if ([delegate respondsToSelector:@selector(connectionManagerDidDisconnectedWithCode:reason:cleanClose:)]) {
            [delegate connectionManagerDidDisconnectedWithCode:1 reason:@"User close connection" cleanClose:YES];
        }
    }
}

- (void)tryToReconnect {
    if ([TapTalk sharedInstance].instanceState == TapTalkInstanceStateInactive) {
        //Don't reconnect if apps is in background and doesn't have background sequence task
        _reconnectAttempt = 0;
        return;
    }
    
    if (self.isShouldReconnect) {
        _reconnectAttempt++;
        
        CGFloat reconnectDelay = self.reconnectAttempt * kSocketReconnectDelay;
        
        if (reconnectDelay > kSocketReconnectMaximumMultiplier) {
            //Set maximum reconnect delay if excedeed
            reconnectDelay = kSocketReconnectMaximumMultiplier;
        }
        
        [self performSelector:@selector(reconnect) withObject:nil afterDelay:reconnectDelay];
    }
}

- (TAPConnectionManagerStatusType)getSocketConnectionStatus {
    return self.tapConnectionStatus;
}

- (void)validateToken {
    NSString *accessToken = [TAPDataManager getAccessToken];

    if (accessToken == nil || [accessToken isEqualToString:@""]) {
        return;
    }
    
    [TAPDataManager callAPIValidateAccessTokenAndAutoRefreshSuccess:^{
#ifdef DEBUG
        NSLog(@"Token Validated");
#endif
    } failure:^(NSError *error) {
        
    }];
}

- (void)setSocketURLString:(NSString *)urlString {
    NSString *formattedSocketURLString;
    if ([urlString hasPrefix:@"https"]) {
        formattedSocketURLString = [urlString stringByReplacingOccurrencesOfString:@"https" withString:@"wss"];
    }
    else if ([urlString hasPrefix:@"http"]) {
        formattedSocketURLString = [urlString stringByReplacingOccurrencesOfString:@"http" withString:@"wss"];
    }
    
    _socketURL = [NSString stringWithFormat:@"%@/connect", formattedSocketURLString];
}

- (void)addDelegate:(id)delegate {
    if ([self.delegatesArray containsObject:delegate]) {
        return;
    }
    
    NSLog(@"[WARNING] ConnectionManager - Do not forget to remove the delegate object, since an object can't weak retained in an array, also please remove this delegate before dealloc or the delegate will always retained");
    
    [self.delegatesArray addObject:delegate];
}

- (void)removeDelegate:(id)delegate {
    [self.delegatesArray removeObject:delegate];
}

@end
