//
//  TAPCoreErrorManager.m
//  TapTalk
//
//  Created by Dominic Vedericho on 12/08/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPCoreErrorManager.h"

@implementation TAPCoreErrorManager

+ (TAPCoreErrorManager *)sharedManager {
    
    //Check if only implement TAPUI, don't init the core manager
    TapTalkImplentationType implementationType = [[TapTalk sharedInstance] getTapTalkImplementationType];
    if (implementationType == TapTalkImplentationTypeUI) {
        return nil;
    }
    
    static TAPCoreErrorManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (id)init {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

- (void)dealloc {
    
}

#pragma mark - Custom Method
- (NSError *)generateLocalizedError:(NSError *)error {
    NSString *errorMessage = [error.userInfo objectForKey:@"message"];
    errorMessage = [TAPUtil nullToEmptyString:errorMessage];
    NSMutableDictionary *generatedUserInfo = [NSMutableDictionary dictionary];
    [generatedUserInfo setObject:errorMessage forKey:NSLocalizedDescriptionKey];
    
    NSError *generatedError = [NSError errorWithDomain:@"io.TapTalk.framework.ErrorDomain" code:error.code userInfo:generatedUserInfo];
    
    return generatedError;
}

- (NSError *)generateLocalizedErrorWithErrorCode:(NSInteger)errorCode
                                    errorMessage:(NSString *)errorMessage {
    errorMessage = [TAPUtil nullToEmptyString:errorMessage];
    NSMutableDictionary *generatedUserInfo = [NSMutableDictionary dictionary];
    [generatedUserInfo setObject:errorMessage forKey:NSLocalizedDescriptionKey];
    
    NSError *generatedError = [NSError errorWithDomain:@"io.TapTalk.framework.ErrorDomain" code:errorCode userInfo:generatedUserInfo];
    
    return generatedError;
}

@end
