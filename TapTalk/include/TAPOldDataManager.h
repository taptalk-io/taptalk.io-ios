//
//  TAPOldDataManager.h
//  TapTalk
//
//  Created by Dominic Vedericho on 06/11/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TAPOldDataManager : NSObject

+ (TAPOldDataManager *)sharedManager;

+ (void)runCleaningOldDataSequence;

@end

NS_ASSUME_NONNULL_END
