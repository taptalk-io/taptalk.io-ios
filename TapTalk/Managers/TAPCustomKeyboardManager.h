//
//  TAPCustomKeyboardManager.h
//  TapTalk
//
//  Created by Cundy Sunardy on 30/11/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TAPCustomKeyboardManager : NSObject

+ (TAPCustomKeyboardManager *)sharedManager;

- (void)customKeyboardTappedWithSender:(TAPUserModel *)sender
                             recipient:(TAPUserModel *)recipient
                          keyboardItem:(TAPCustomKeyboardItemModel *)keyboardItem;

- (NSArray *)getCustomKeyboardWithSender:(TAPUserModel *)sender
                               recipient:(TAPUserModel *)recipient;

@end

NS_ASSUME_NONNULL_END
