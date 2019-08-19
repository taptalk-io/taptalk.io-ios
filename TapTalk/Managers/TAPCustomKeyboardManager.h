//
//  TAPCustomKeyboardManager.h
//  TapTalk
//
//  Created by Cundy Sunardy on 30/11/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAPCustomKeyboardItemModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TAPCustomKeyboardManagerDelegate <NSObject>

- (void)customKeyboardItemTappedWithSender:(TAPUserModel *)sender
                                 recipient:(TAPUserModel *)recipient
                              keyboardItem:(TAPCustomKeyboardItemModel *)keyboardItem;

- (NSArray<TAPCustomKeyboardItemModel *> *)setCustomKeyboardItemsForSender:(TAPUserModel *)sender
                                                                 recipient:(TAPUserModel *)recipient;

@end

@interface TAPCustomKeyboardManager : NSObject

@property (weak, nonatomic) id<TAPCustomKeyboardManagerDelegate> delegate;

+ (TAPCustomKeyboardManager *)sharedManager;

- (void)customKeyboardTappedWithSender:(TAPUserModel *)sender
                             recipient:(TAPUserModel *)recipient
                          keyboardItem:(TAPCustomKeyboardItemModel *)keyboardItem;

- (NSArray *)getCustomKeyboardWithSender:(TAPUserModel *)sender
                               recipient:(TAPUserModel *)recipient;

@end

NS_ASSUME_NONNULL_END
