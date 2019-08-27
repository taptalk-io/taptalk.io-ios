//
//  TAPCustomKeyboardManager.m
//  TapTalk
//
//  Created by Cundy Sunardy on 30/11/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPCustomKeyboardManager.h"

@interface TAPCustomKeyboardManager()

@end

@implementation TAPCustomKeyboardManager

+ (TAPCustomKeyboardManager *)sharedManager {
    static TAPCustomKeyboardManager *sharedManager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[TAPCustomKeyboardManager alloc] init];
    });
    return sharedManager;
}

- (id)init {
    self = [super init];
    
    if (self) {

    }
    
    return self;
}

@end
