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

- (void)customKeyboardDidTappedWithSender:(TAPUserModel *)sender
                                recipient:(TAPUserModel *)recipient
                             keyboardItem:(TAPCustomKeyboardItemModel *)keyboardItem {
    if ([self.delegate respondsToSelector:@selector(customKeyboardItemTappedWithSender:recipient:keyboardItem:)]) {
        [self.delegate customKeyboardItemTappedWithSender:sender recipient:recipient keyboardItem:keyboardItem];
    }
}

- (NSArray *)getCustomKeyboardWithSender:(TAPUserModel *)sender recipient:(TAPUserModel *)recipient {
    if([self.delegate respondsToSelector:@selector(setCustomKeyboardItemsForSender:recipient:)]) {
        return [self.delegate setCustomKeyboardItemsForSender:sender recipient:recipient];
    }
    
    return [NSArray array];
}

@end
