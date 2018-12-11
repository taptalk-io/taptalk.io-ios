//
//  TAPCustomBubbleManager.h
//  TapTalk
//
//  Created by Dominic Vedericho on 30/11/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TAPCustomBubbleManager : NSObject

+ (TAPCustomBubbleManager *)sharedManager;

- (void)addCustomBubbleDataWithCellName:(NSString *)cellName type:(NSInteger)type delegate:(id)delegate;
- (NSDictionary *)getCustomBubbleClassNameWithType:(NSInteger)type;

@end

NS_ASSUME_NONNULL_END
