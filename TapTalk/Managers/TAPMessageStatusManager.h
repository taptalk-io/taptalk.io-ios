//
//  TAPMessageStatusManager.h
//  TapTalk
//
//  Created by Dominic Vedericho on 29/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TAPMessageStatusManagerDelegate <NSObject>

@optional

- (void)messageStatusManagerDidUpdateReadMessageWithData:(NSArray *)messageArray;

@end


@interface TAPMessageStatusManager : NSObject

+ (TAPMessageStatusManager *)sharedManager;

#warning Do not forget to remove the delegate object, since an object can't weak retained in an array, also please remove this delegate before dealloc or the delegate will always retained
- (void)addDelegate:(id <TAPMessageStatusManagerDelegate>)delegate;
- (void)removeDelegate:(id <TAPMessageStatusManagerDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
