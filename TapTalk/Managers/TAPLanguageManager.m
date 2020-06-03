//
//  TAPLanguageManager.m
//  TapTalk
//
//  Created by Dominic Vedericho on 22/04/20.
//  Copyright © 2020 Moselo. All rights reserved.
//

#import "TAPLanguageManager.h"
#import "NSBundle+Language.h"

static NSString * const LanguageCodes[] = { @"en", @"id"};
static NSString * const LanguageStrings[] = { @"English", @"Indonesian"};
static NSString * const LanguageSaveKey = @"currentLanguageKey";

@implementation TAPLanguageManager
+ (void)setupCurrentLanguage {
    NSString *currentLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:LanguageSaveKey];
    if (!currentLanguage) {
        NSArray *languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
        if (languages.count > 0) {
            currentLanguage = languages[0];
            [[NSUserDefaults standardUserDefaults] setObject:currentLanguage forKey:LanguageSaveKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }

    [[NSUserDefaults standardUserDefaults] setObject:@[currentLanguage] forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [NSBundle setLanguage:currentLanguage];
}

+ (NSArray *)languageStrings {
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger count = 0; count < TAPLanguageCount; ++count) {
        [array addObject:NSLocalizedString(LanguageStrings[count], @"")];
    }
    return [array copy];
}

+ (NSString *)currentLanguageString {
    NSString *string = @"";
    NSString *currentCode = [[NSUserDefaults standardUserDefaults] objectForKey:LanguageSaveKey];
    for (NSInteger count = 0; count < TAPLanguageCount; ++count) {
        if ([currentCode isEqualToString:LanguageCodes[count]]) {
            string = NSLocalizedString(LanguageStrings[count], @"");
            break;
        }
    }
    return string;
}

+ (NSString *)currentLanguageCode {
    return [[NSUserDefaults standardUserDefaults] objectForKey:LanguageSaveKey];
}

+ (NSInteger)currentLanguageIndex {
    NSInteger index = 0;
    NSString *currentCode = [[NSUserDefaults standardUserDefaults] objectForKey:LanguageSaveKey];
    for (NSInteger count = 0; count < TAPLanguageCount; ++count) {
        if ([currentCode isEqualToString:LanguageCodes[count]]) {
            index = count;
            break;
        }
    }
    return index;
}

+ (void)saveLanguageByType:(TAPLanguageType)languageType {
    NSString *code = LanguageCodes[0];
    if (languageType == TAPLanguageTypeIndonesian) {
        code = LanguageCodes[1];
    }
    else if (languageType == TAPLanguageTypeEnglish) {
        code = LanguageCodes[0];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:code forKey:LanguageSaveKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [NSBundle setLanguage:code];
}

+ (BOOL)isCurrentLanguageRTL {
    NSInteger currentLanguageIndex = [self currentLanguageIndex];
    return ([NSLocale characterDirectionForLanguage:LanguageCodes[currentLanguageIndex]] == NSLocaleLanguageDirectionRightToLeft);
}

@end
