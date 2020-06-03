//
//  NSBundle+Language.m
//  TapTalk
//
//  Created by Dominic Vedericho on 21/03/20.
//  Copyright © 2020 TapTalk.io. All rights reserved.
//

#import "NSBundle+Language.h"
#import "TAPLanguageManager.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static const char kBundleKey = 0;

@interface BundleEx : NSBundle

@end

@implementation BundleEx

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
    NSBundle *bundle = objc_getAssociatedObject(self, &kBundleKey);
    if (bundle) {
        return [bundle localizedStringForKey:key value:value table:tableName];
    }
    else {
        return [super localizedStringForKey:key value:value table:tableName];
    }
}

@end

@implementation NSBundle (Language)

+ (void)setLanguage:(NSString *)language {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        object_setClass([TAPUtil currentBundle], [BundleEx class]);
    });
    if ([TAPLanguageManager isCurrentLanguageRTL]) {
        if ([[[UIView alloc] init] respondsToSelector:@selector(setSemanticContentAttribute:)]) {
            [[UIView appearance] setSemanticContentAttribute:UISemanticContentAttributeForceRightToLeft];
            [[UITableView appearance] setSemanticContentAttribute:UISemanticContentAttributeForceRightToLeft];
        }
    }else {
        if ([[[UIView alloc] init] respondsToSelector:@selector(setSemanticContentAttribute:)]) {
            [[UIView appearance] setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
            [[UITableView appearance] setSemanticContentAttribute:UISemanticContentAttributeForceLeftToRight];
        }
    }
    [[NSUserDefaults standardUserDefaults] setBool:[TAPLanguageManager isCurrentLanguageRTL] forKey:@"AppleTextDirection"];
    [[NSUserDefaults standardUserDefaults] setBool:[TAPLanguageManager isCurrentLanguageRTL] forKey:@"NSForceRightToLeftWritingDirection"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    id value = language ? [NSBundle bundleWithPath:[[TAPUtil currentBundle] pathForResource:language ofType:@"lproj"]] : nil;
    objc_setAssociatedObject([TAPUtil currentBundle], &kBundleKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
