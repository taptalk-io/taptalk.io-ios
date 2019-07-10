//
//  TAPUserRoleModel.m
//  TapTalk
//
//  Created by Dominic Vedericho on 26/09/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPUserRoleModel.h"

@implementation TAPUserRoleModel

//used to save model to preference
- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.code forKey:@"code"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.iconURL forKey:@"iconURL"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.code = [decoder decodeObjectForKey:@"code"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.iconURL = [decoder decodeObjectForKey:@"iconURL"];
    }
    return self;
}

@end
