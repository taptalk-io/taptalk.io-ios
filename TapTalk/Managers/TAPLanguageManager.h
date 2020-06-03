//
//  TAPLanguageManager.h
//  TapTalk
//
//  Created by Dominic Vedericho on 22/04/20.
//  Copyright © 2020 Moselo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPLanguageType)
{
    TAPLanguageTypeEnglish,
    TAPLanguageTypeIndonesian,
    
    TAPLanguageCount
};

@interface TAPLanguageManager : NSObject

+ (void)setupCurrentLanguage;
+ (NSArray *)languageStrings;
+ (NSString *)currentLanguageString;
+ (NSString *)currentLanguageCode;
+ (NSInteger)currentLanguageIndex;
+ (void)saveLanguageByType:(TAPLanguageType)languageType;
+ (BOOL)isCurrentLanguageRTL;

@end

NS_ASSUME_NONNULL_END
