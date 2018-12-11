//
//  TAPCustomBubbleManager.m
//  TapTalk
//
//  Created by Dominic Vedericho on 30/11/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPCustomBubbleManager.h"

@interface TAPCustomBubbleManager ()

@property (strong, nonatomic) NSMutableDictionary *customBubbleDataDictionary;

@end

@implementation TAPCustomBubbleManager

#pragma mark - Lifecycle
+ (TAPConnectionManager *)sharedManager {
    static TAPCustomBubbleManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (id)init {
    self = [super init];
    
    if (self) {
        _customBubbleDataDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)dealloc {
    
}

#pragma mark - Custom Method
- (void)addCustomBubbleDataWithCellName:(NSString *)cellName type:(NSInteger)type delegate:(id)delegate {
    NSMutableDictionary *cellDictionary = [[NSMutableDictionary alloc] init];
    [cellDictionary setObject:cellName forKey:@"name"];
    [cellDictionary setObject:[NSNumber numberWithInteger:type] forKey:@"type"];
    [cellDictionary setObject:delegate forKey:@"delegate"];
    [self.customBubbleDataDictionary setObject:cellDictionary forKey:[NSNumber numberWithInteger:type]];
}

- (NSDictionary *)getCustomBubbleClassNameWithType:(NSInteger)type {
    NSDictionary *customBubbleCellDictionary = [self.customBubbleDataDictionary objectForKey:[NSNumber numberWithInteger:type]];
    customBubbleCellDictionary = [TAPUtil nullToEmptyDictionary:customBubbleCellDictionary];
    return customBubbleCellDictionary;
}

@end
