//
//  TAPContactRealmModel.m
//  TapTalk
//
//  Created by Welly Kencana on 19/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPContactRealmModel.h"

@implementation TAPContactRealmModel

+ (NSString *)primaryKey {
    NSString *primaryKey = @"userID";
    return primaryKey;
}

+ (NSArray<NSString *> *)indexedProperties {
    NSArray *indexedPropertiesArray = [NSArray arrayWithObjects:@"userRoleID", nil];
    return indexedPropertiesArray;
}

@end
