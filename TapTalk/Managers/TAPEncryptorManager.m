//
//  TAPEncryptorManager.m
//  TapTalk
//
//  Created by Dominic Vedericho on 15/08/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPEncryptorManager.h"

static NSString * const kKeyPasswordEncryptor = @"kHT0sVGIKKpnlJE5BNkINYtuf19u6+Kk811iMuWQ5tM";

@interface TAPEncryptorManager()
+ (NSString *)encryptString:(NSString *)originalString localID:(NSString *)localID;
+ (NSString *)decryptString:(NSString *)encryptedString localID:(NSString *)localID;
@end

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
    
    if (self) {
        
    }
    
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

#pragma mark - Custom Method
+ (NSString *)encryptString:(NSString *)originalString localID:(NSString *)localID {
    //DV Note
    //Encryption Flow
    // 1. Obtain message length, local ID length
    // 2. Get local ID index (message length modulo by local ID length)
    // 3. Generate random number from 1-9
    // 4. Obtain salt character from local ID string with character position of local ID index
    // 5. Insert salt character to encrypted message to the position index (index is calculated using this formula (((encrypted message length + random number) * random number) % encrypted message length)))
    //6. Add random number to the first index of the encrypted message with salt
    //END DV note
    
    if(originalString == nil || localID == nil || [originalString isEqualToString:@""] || [localID isEqualToString:@""]) {
        return nil;
    }
    
    NSString *substringLocalID = [localID substringWithRange:NSMakeRange(8, 16)];
    
    NSMutableString *reversedSubstringLocalID = [NSMutableString string];
    NSInteger charIndex = [substringLocalID length];
    while (charIndex > 0) {
        charIndex--;
        NSRange subStrRange = NSMakeRange(charIndex, 1);
        [reversedSubstringLocalID appendString:[substringLocalID substringWithRange:subStrRange]];
    }
    
    //password is generated based on 16 first characters of kKeyPasswordEncryptor + reversedSubstringLocalID
    NSString *substringKeyPassword = [kKeyPasswordEncryptor substringWithRange:NSMakeRange(0, 16)];
    NSString *password = [NSString stringWithFormat:@"%@%@", substringKeyPassword, reversedSubstringLocalID];
    
    NSInteger stringLength = [originalString length];
    NSInteger localIDLength = [localID length];
    NSInteger localIDIndex = stringLength % localIDLength;
    
    NSString *saltString = [localID substringWithRange:NSMakeRange(localIDIndex, 1)];
    
    NSString *encryptedString = [AESCrypt encrypt:originalString password:password];
    
    NSInteger randomNumber = 1 + (arc4random() % 9); //Random number from 1 - 9
    NSInteger encryptedStringLength = [encryptedString length];
    
    NSInteger saltCharIndexPosition = (((encryptedStringLength + randomNumber) * randomNumber) % encryptedStringLength);
    
    NSMutableString *encryptedStringWithSalt = [NSMutableString stringWithString:encryptedString];
    [encryptedStringWithSalt insertString:saltString atIndex:saltCharIndexPosition];
    [encryptedStringWithSalt insertString:[NSString stringWithFormat:@"%ld", (long)randomNumber] atIndex:0];
    
    return encryptedStringWithSalt;
}

+ (NSString *)decryptString:(NSString *)encryptedString localID:(NSString *)localID {
    
    if(encryptedString == nil || localID == nil || [encryptedString isEqualToString:@""] || [localID isEqualToString:@""]) {
        return nil;
    }
    
    NSString *substringLocalID = [localID substringWithRange:NSMakeRange(8, 16)];
    NSMutableString *reversedSubstringLocalID = [NSMutableString string];
    NSInteger charIndex = [substringLocalID length];
    while (charIndex > 0) {
        charIndex--;
        NSRange subStrRange = NSMakeRange(charIndex, 1);
        [reversedSubstringLocalID appendString:[substringLocalID substringWithRange:subStrRange]];
    }
    
    //password is generated based on 16 first characters of kKeyPasswordEncryptor + reversedSubstringLocalID
    NSString *substringKeyPassword = [kKeyPasswordEncryptor substringWithRange:NSMakeRange(0, 16)];
    NSString *password = [NSString stringWithFormat:@"%@%@", substringKeyPassword, reversedSubstringLocalID];
    
    NSString *encryptedStringWithSalt = encryptedString;
    NSInteger encryptedStringLength = [encryptedStringWithSalt length] - 2; //-2 for removing random number and salt character
    
    NSString *randomNumberString = [encryptedStringWithSalt substringWithRange:NSMakeRange(0, 1)];
    NSInteger randomNumber = [randomNumberString integerValue];
    NSInteger saltCharIndexPosition = (((encryptedStringLength + randomNumber) * randomNumber) % encryptedStringLength);
    
    NSString *encryptedStringModified = [encryptedStringWithSalt stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
    //CS NOTE - check if index position exist in range to  prevent crash
    if (saltCharIndexPosition < [encryptedStringModified length]) {
        encryptedStringModified = [encryptedStringModified stringByReplacingCharactersInRange:NSMakeRange(saltCharIndexPosition, 1) withString:@""];
    }
    else {
        return nil;
    }
    
    NSString *decryptedString = [AESCrypt decrypt:encryptedStringModified password:password];
    
    return decryptedString;
}

+ (NSDictionary *)encryptToDictionaryFromMessageModel:(TAPMessageModel *)message {
    
    if(message == nil) {
        return nil;
    }
    
    TAPMessageModel *encryptedMessage = [message copy];
    
    //Encrypt message
    encryptedMessage.body = [self encryptString:encryptedMessage.body localID:encryptedMessage.localID];
    encryptedMessage.quote.content = [self encryptString:encryptedMessage.quote.content localID:encryptedMessage.localID];
    
    NSMutableDictionary *parametersDictionary = [NSMutableDictionary dictionary];
    parametersDictionary = [[encryptedMessage toDictionary] mutableCopy];
    
    NSDictionary *dataDictionary = [parametersDictionary objectForKey:@"data"];
    NSString *dataJSONString = [TAPUtil jsonStringFromObject:dataDictionary];
    NSString *encryptedDataJSONString = [self encryptString:dataJSONString localID:message.localID];
    encryptedDataJSONString = [TAPUtil nullToEmptyString:encryptedDataJSONString];
    
    [parametersDictionary setObject:encryptedDataJSONString forKey:@"data"];
    
    return parametersDictionary;
}

+ (TAPMessageModel *)decryptToMessageModelFromDictionary:(NSDictionary *)dictionary {
    if(dictionary == nil || [dictionary objectForKey:@"localID"] == nil) {
        return nil;
    }
    
    NSString *encryptedString = [dictionary objectForKey:@"data"];
    NSString *decryptedString = [self decryptString:encryptedString localID:[dictionary objectForKey:@"localID"]];
    NSDictionary *decryptedDataDictionary = [TAPUtil jsonObjectFromString:decryptedString];
    decryptedDataDictionary = [TAPUtil nullToEmptyDictionary:decryptedDataDictionary];
    
    NSMutableDictionary *dataMutableDictionary = [dictionary mutableCopy];
    [dataMutableDictionary setObject:decryptedDataDictionary forKey:@"data"];
    
    dictionary = dataMutableDictionary;
    
    TAPMessageModel *message = [[TAPMessageModel alloc] initWithDictionary:dictionary error:nil];
    
    message.body = [self decryptString:message.body localID:message.localID];
    message.quote.content = [self decryptString:message.quote.content localID:message.localID];
        
    return message;
}

@end
