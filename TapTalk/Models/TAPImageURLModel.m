//
//  TAPImageURLModel.m
//  Moselo
//
//  Created by Ritchie Nathaniel on 4/12/17.
//  Copyright © 2017 Moselo. All rights reserved.
//

#import "TAPImageURLModel.h"

@implementation TAPImageURLModel

//used to save model to preference
- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.thumbnail forKey:@"thumbnail"];
    [encoder encodeObject:self.fullsize forKey:@"fullsize"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.thumbnail = [decoder decodeObjectForKey:@"thumbnail"];
        self.fullsize = [decoder decodeObjectForKey:@"fullsize"];
    }
    return self;
}

@end
