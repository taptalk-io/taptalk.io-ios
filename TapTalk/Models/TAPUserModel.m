//
//  TAPUserModel.m
//  Moselo
//
//  Created by Ritchie Nathaniel on 3/8/17.
//  Copyright © 2017 Moselo. All rights reserved.
//

#import "TAPUserModel.h"

@implementation TAPUserModel

//used to save model to preference
- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.userID forKey:@"userID"];
    [encoder encodeObject:self.xcUserID forKey:@"xcUserID"];
    [encoder encodeObject:self.fullname forKey:@"fullname"];
    [encoder encodeObject:self.email forKey:@"email"];
    [encoder encodeObject:self.phone forKey:@"phone"];
    [encoder encodeObject:self.username forKey:@"username"];
    [encoder encodeObject:self.phoneWithCode forKey:@"phoneWithCode"];
    [encoder encodeObject:self.countryCallingCode forKey:@"countryCallingCode"];
    [encoder encodeObject:self.countryID forKey:@"countryID"];
    [encoder encodeObject:self.imageURL forKey:@"imageURL"];
    [encoder encodeObject:self.userRole forKey:@"userRole"];
    [encoder encodeObject:self.lastLogin forKey:@"lastLogin"];
    [encoder encodeObject:self.lastActivity forKey:@"lastActivity"];
    [encoder encodeBool:self.requireChangePassword forKey:@"requireChangePassword"];
    [encoder encodeObject:self.created forKey:@"created"];
    [encoder encodeObject:self.updated forKey:@"updated"];
    [encoder encodeObject:self.deleted forKey:@"deleted"];
    
    [encoder encodeBool:self.isRequestPending forKey:@"isRequestPending"];
    [encoder encodeBool:self.isRequestAccepted forKey:@"isRequestAccepted"];
    [encoder encodeBool:self.isContact forKey:@"isContact"];
    [encoder encodeBool:self.isOnline forKey:@"isOnline"];
    [encoder encodeBool:self.isEmailVerified forKey:@"isEmailVerified"];
    [encoder encodeBool:self.isPhoneVerified forKey:@"isPhoneVerified"];
    [encoder encodeObject:self.bio forKey:@"bio"];

}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.userID = [decoder decodeObjectForKey:@"userID"];
        self.xcUserID = [decoder decodeObjectForKey:@"xcUserID"];
        self.fullname = [decoder decodeObjectForKey:@"fullname"];
        self.email = [decoder decodeObjectForKey:@"email"];
        self.phone = [decoder decodeObjectForKey:@"phone"];
        self.username = [decoder decodeObjectForKey:@"username"];
        self.phoneWithCode = [decoder decodeObjectForKey:@"phoneWithCode"];
        self.countryCallingCode = [decoder decodeObjectForKey:@"countryCallingCode"];
        self.countryID = [decoder decodeObjectForKey:@"countryID"];
        self.imageURL = [decoder decodeObjectForKey:@"imageURL"];
        self.userRole = [decoder decodeObjectForKey:@"userRole"];
        self.lastLogin = [decoder decodeObjectForKey:@"lastLogin"];
        self.lastActivity = [decoder decodeObjectForKey:@"lastActivity"];
        self.requireChangePassword = [decoder decodeBoolForKey:@"requireChangePassword"];
        self.created = [decoder decodeObjectForKey:@"created"];
        self.updated = [decoder decodeObjectForKey:@"updated"];
        self.deleted = [decoder decodeObjectForKey:@"deleted"];

        self.isRequestPending = [decoder decodeBoolForKey:@"isRequestPending"];
        self.isRequestAccepted = [decoder decodeBoolForKey:@"isRequestAccepted"];
        self.isContact = [decoder decodeBoolForKey:@"isContact"];
        self.isOnline = [decoder decodeBoolForKey:@"isOnline"];
        self.isEmailVerified = [decoder decodeBoolForKey:@"isEmailVerified"];
        self.isPhoneVerified = [decoder decodeBoolForKey:@"isPhoneVerified"];
        self.bio = [decoder decodeObjectForKey:@"bio"];
    }
    return self;
}

@end
