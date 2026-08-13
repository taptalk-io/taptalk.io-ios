//
//  TAPBaseRealmModel.h
//  TapTalk
//
//  Created by Dominic Vedericho on 25/8/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import <Realm/Realm.h>

@interface TAPBaseRealmModel : RLMObject

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError **)err;
- (NSDictionary *)toDictionary;
@end
