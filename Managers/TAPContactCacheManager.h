//
//  TAPContactCacheManager.h
//  TapTalk
//
//  Created by Dominic Vedericho on 31/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TAPContactCacheManagerDelegate <NSObject>

- (void)contactCacheManagerDidUpdateContactWithData:(TAPUserModel *)user;

@end

@interface TAPContactCacheManager : NSObject

+ (TAPContactCacheManager *)sharedManager;

@property (weak, nonatomic) id<TAPContactCacheManagerDelegate> delegate;

@property (strong, nonatomic) NSMutableDictionary *contactDictionary;

- (void)shouldUpdateUserWithData:(TAPUserModel *)user;
- (void)clearContactDictionary;

#warning Do not forget to remove the delegate object, since an object can't weak retained in an array, also please remove this delegate before dealloc or the delegate will always retained
- (void)addDelegate:(id <TAPContactCacheManagerDelegate>)delegate;
- (void)removeDelegate:(id <TAPContactCacheManagerDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
