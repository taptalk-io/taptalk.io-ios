//
//  TAPMessageRealmModel.m
//  TapTalk
//
//  Created by Dominic Vedericho on 28/08/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPMessageRealmModel.h"

@implementation TAPMessageRealmModel
+ (NSString *)primaryKey {
    NSString *primaryKey = @"localID";
    return primaryKey;
}

+ (NSArray<NSString *> *)indexedProperties {
    NSArray *indexedPropertiesArray = [NSArray arrayWithObjects:@"roomID", nil];
    return indexedPropertiesArray;
}


@end
