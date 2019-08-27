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

- (void)customKeyboardItemTappedWithRoom:(TAPRoomModel * _Nonnull)room
                                  sender:(TAPUserModel * _Nonnull)sender
                               recipient:(TAPUserModel * _Nullable)recipient
                            keyboardItem:(TAPCustomKeyboardItemModel * _Nonnull)keyboardItem;

- (NSArray<TAPCustomKeyboardItemModel *> *)setCustomKeyboardItemsForRoom:(TAPRoomModel * _Nonnull)room
                                                                  sender:(TAPUserModel * _Nonnull)sender
                                                               recipient:(TAPUserModel * _Nullable)recipient;

@end

@interface TAPCustomKeyboardManager : NSObject

@property (weak, nonatomic) id<TAPCustomKeyboardManagerDelegate> delegate;

+ (TAPCustomKeyboardManager *)sharedManager;

@end

NS_ASSUME_NONNULL_END
