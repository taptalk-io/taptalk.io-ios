//
//  TAPEncryptorManager.m
//  TapTalk
//
//  Created by Dominic Vedericho on 15/08/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPEncryptorManager.h"

static NSString * const kKeyPasswordEncryptor = @"kHT0sVGIKKpnlJE5BNkINYtuf19u6+Kk811iMuWQ5tM";

@implementation TAPEncryptorManager

#pragma mark - Lifecycle
+ (TAPEncryptorManager *)sharedManager {
    static TAPEncryptorManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (id)init {
    self = [super init];
    
    if(self) {
        
    }
    
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

#pragma mark - Custom Method
+ (TAPMessageModel *)encryptMessage:(TAPMessageModel *)message {
    //DV Note
    //Encryption Flow
    // 1. Obtain message length, local ID length
    // 2. Get local ID index (message length modulo by local ID length)
    // 3. Generate random number from 1-9
    // 4. Obtain salt character from local ID string with character position of local ID index
    // 5. Insert salt character to encrypted message to the position index (index is calculated using this formula (((encrypted message length + random number) * random number) % encrypted message length)))
    //6. Add random number to the first index of the encrypted message with salt
    //END DV note
    
    NSString *localID = message.localID;
    NSString *substringLocalID = [localID substringWithRange:NSMakeRange(8, 16)];
    
    NSMutableString *reversedSubstringLocalID = [NSMutableString string];
    NSInteger charIndex = [substringLocalID length];
    while (charIndex > 0) {
        charIndex--;
        NSRange subStrRange = NSMakeRange(charIndex, 1);
        [reversedSubstringLocalID appendString:[substringLocalID substringWithRange:subStrRange]];
    }
    
    NSString *password = [NSString stringWithFormat:@"%@%@", kKeyPasswordEncryptor, reversedSubstringLocalID];
    
    NSInteger messageLength = [message.body length];
    NSInteger localIDLength = [localID length];
    NSInteger localIDIndex = messageLength % localIDLength;
    
    NSString *saltString = [localID substringWithRange:NSMakeRange(localIDIndex, 1)];
    
    NSString *encryptedMessage = [AESCrypt encrypt:message.body password:password];
    
    NSInteger randomNumber = 1 + (arc4random() % 9); //Random number from 1 - 9
    NSInteger encryptedMessageLength = [encryptedMessage length];
    
    NSInteger saltCharIndexPosition = (((encryptedMessageLength + randomNumber) * randomNumber) % encryptedMessageLength);
    
    NSMutableString *encryptedMessageWithSalt = [NSMutableString stringWithString:encryptedMessage];
    [encryptedMessageWithSalt insertString:saltString atIndex:saltCharIndexPosition];
    [encryptedMessageWithSalt insertString:[NSString stringWithFormat:@"%ld", (long)randomNumber] atIndex:0];
    
    TAPMessageModel *messageForReturn = [[TAPMessageModel alloc] initWithDictionary:[message toDictionary] error:nil];
    messageForReturn.body = encryptedMessageWithSalt;
    
    return messageForReturn;
}

+ (TAPMessageModel *)decryptMessage:(TAPMessageModel *)message {
    if (!message) {
        return nil;
    }
    
    NSString *localID = message.localID;
    NSString *substringLocalID = [localID substringWithRange:NSMakeRange(8, 16)];
    NSMutableString *reversedSubstringLocalID = [NSMutableString string];
    NSInteger charIndex = [substringLocalID length];
    while (charIndex > 0) {
        charIndex--;
        NSRange subStrRange = NSMakeRange(charIndex, 1);
        [reversedSubstringLocalID appendString:[substringLocalID substringWithRange:subStrRange]];
    }
    
    NSString *password = [NSString stringWithFormat:@"%@%@", kKeyPasswordEncryptor, reversedSubstringLocalID];
    
    NSString *encryptedMessageWithSalt = message.body;
    NSInteger encryptedMessageLength = [encryptedMessageWithSalt length] - 2; //-2 for removing random number and salt character
    
    NSString *randomNumberString = [encryptedMessageWithSalt substringWithRange:NSMakeRange(0, 1)];
    NSInteger randomNumber = [randomNumberString integerValue];
    NSInteger saltCharIndexPosition = (((encryptedMessageLength + randomNumber) * randomNumber) % encryptedMessageLength);
    
    NSString *encryptedMessage = [encryptedMessageWithSalt stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
    encryptedMessage = [encryptedMessage stringByReplacingCharactersInRange:NSMakeRange(saltCharIndexPosition, 1) withString:@""];
    
    NSString *decryptedMessage = [AESCrypt decrypt:encryptedMessage password:password];
    
    TAPMessageModel *messageForReturn = [[TAPMessageModel alloc] initWithDictionary:[message toDictionary] error:nil];
    messageForReturn.body = decryptedMessage;

    return messageForReturn;
}

@end
