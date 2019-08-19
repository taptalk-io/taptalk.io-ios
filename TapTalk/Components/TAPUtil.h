//
//  TAPUtil.h
//  Traveloka
//
//  Created by Ritchie Nathaniel on 3/19/14.
//  Copyright (c) 2014 Traveloka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import <CoreLocation/CoreLocation.h>
#include <sys/types.h>
#include <sys/sysctl.h>

#pragma mark - Math
#define DEGREES_TO_RADIANS(x) (M_PI * x / 180.0f)
#define RADIANS_TO_DEGREES(x) ((x) * M_PI * 180.0f)

#pragma mark - Device
#define IS_IPHONE_4_INCH_AND_ABOVE ([[UIScreen mainScreen] bounds].size.height >= 568)?YES:NO
#define IS_IPHONE_4_7_INCH_AND_ABOVE ([[UIScreen mainScreen] bounds].size.width >= 375)?YES:NO
#define IS_IPHONE_5_5_INCH_AND_ABOVE ([[UIScreen mainScreen] bounds].size.height >= 736)?YES:NO
#define IS_IPHONE_3_5_INCH ([[UIScreen mainScreen] bounds].size.height == 480)?YES:NO
#define IS_IPHONE_4_INCH ([[UIScreen mainScreen] bounds].size.height == 568)?YES:NO
#define IS_IPHONE_4_7_INCH ([[UIScreen mainScreen] bounds].size.height == 667)?YES:NO
#define IS_IPHONE_5_5_INCH ([[UIScreen mainScreen] bounds].size.height == 736)?YES:NO
#define IS_IPHONE_X_FAMILY ([TAPUtil safeAreaBottomPadding] > 0)?YES:NO

#define IS_BELOW_IOS_7 ([[[[UIDevice currentDevice] systemVersion] substringWithRange:NSMakeRange(0, 1)] integerValue] < 7)?YES:NO
#define IS_BELOW_IOS_8 ([[[[UIDevice currentDevice] systemVersion] substringWithRange:NSMakeRange(0, 1)] integerValue] < 8)?YES:NO
#define IS_IOS_8_OR_ABOVE (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
#define IS_BELOW_IOS_9 ([[[[UIDevice currentDevice] systemVersion] substringWithRange:NSMakeRange(0, 1)] integerValue] < 9)?YES:NO
#define IS_IOS_10_OR_ABOVE (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0"))
#define IS_IOS_11_OR_ABOVE (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"11.0"))

#define SYSTEM_VERSION ([[UIDevice currentDevice] systemVersion])
#define SYSTEM_VERSION_EQUAL_TO(version) ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(version) ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version) ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(version) ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(version) ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] != NSOrderedDescending)

#pragma mark - App Version
#define APP_VERSION ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"])
#define APP_VERSION_EQUAL_TO(version) ([[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] compare:version options:NSNumericSearch] == NSOrderedSame)
#define APP_VERSION_GREATER_THAN(version) ([[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] compare:version options:NSNumericSearch] == NSOrderedDescending)
#define APP_VERSION_GREATER_THAN_OR_EQUAL_TO(version) ([[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] compare:version options:NSNumericSearch] != NSOrderedAscending)
#define APP_VERSION_LESS_THAN(version) ([[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] compare:version options:NSNumericSearch] == NSOrderedAscending)
#define APP_VERSION_LESS_THAN_OR_EQUAL_TO(version) ([[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] compare:version options:NSNumericSearch] != NSOrderedDescending)

#pragma mark - String
#define STRING_FROM_BOOL(BOOL) ((BOOL) ? @"YES" : @"NO")

@interface TAPUtil : NSObject {
    
}

#pragma mark - Date
+ (BOOL)date:(NSDate*)date isBetweenDate:(NSDate *)beginDate andDate:(NSDate *)endDate;
+ (NSInteger)daysDifferentBetweenDate:(NSDate *)date1 fromDate:(NSDate *)date2;

#pragma mark - Time
+ (NSString *)stringFromTimeInterval:(NSTimeInterval)interval;

#pragma mark - Null Handler
+ (NSString *)nullToEmptyString:(id)value;
+ (NSDictionary *)nullToEmptyDictionary:(id)value;
+ (NSArray *)nullToEmptyArray:(id)value;
+ (NSNumber *)nullToEmptyNumber:(id)value;

#pragma mark - Color
+ (UIColor *)getColor:(NSString *)hexColor;
+ (UIColor *)randomPastelColor;

#pragma mark - Image Processing
+ (UIImage *)makeRoundCornerImage:(UIImage*)img width:(int)cornerWidth height:(int)cornerHeight;
+ (UIImage *)resizedImage:(UIImage *)inImage frame:(CGRect)thumbRect;
+ (UIImage *)imageByScaling:(BOOL)isScaling cropping:(BOOL)isCropping sourceImage:(UIImage *)sourceImage frame:(CGRect)targetFrame;

#pragma mark - Encoding
+ (NSString *)urlEncodeFromString:(NSString *)sourceString;
+ (NSString *)sha1:(NSString*)input;
+ (NSString *)md5:(NSString *)input;

#pragma mark - String
+ (NSString *)generateRandomStringWithLength:(NSInteger)length;
+ (NSString *)ordinalNumberWithInteger:(NSInteger)number;
+ (NSString *)formattedCurrencyWithCurrencySign:(NSString *)currencySign value:(CGFloat)value;

#pragma mark - Location
+ (CGFloat)getDistanceFromLong:(double)longitude lat:(double)latitude andLong2:(double)longitude2 lat2:(double)latitude2;

#pragma mark - JSON
+ (NSString *)jsonStringFromObject:(id)json;
+ (id)jsonObjectFromString:(NSString *)string;

#pragma mark - Rect
+ (CGFloat)lineMinimumHeight;
+ (CGFloat)screenAdjustedHeight:(CGFloat)currentHeight;
+ (CGFloat)screenAdjustedWidth:(CGFloat)currentWidth;
+ (CGRect)getStringConstrainedSizeWithString:(NSString *)string withFont:(UIFont *)font withConstrainedSize:(CGSize)size;

#pragma mark - Device
+ (NSString *)hardwareModel;
+ (NSString *)hardwareString;

#pragma mark - Validation
+ (BOOL)isAlphabetCharactersOnlyFromText:(NSString *)text;
+ (BOOL)isEmptyString:(NSString *)string;
+ (BOOL)validatePhoneNumber:(NSString *)candidate;
+ (BOOL)validateAllNumber:(NSString *)candidate;
+ (BOOL)validateEmail:(NSString *)candidate;
+ (BOOL)validateUsername:(NSString *)candidate;
+ (BOOL)validatePassword:(NSString *)candidate;

#pragma mark - Taptic Feedback
+ (void)tapticImpactFeedbackGenerator;
+ (void)tapticSelectionFeedbackGenerator;
+ (void)tapticNotificationFeedbackGeneratorWithType:(UINotificationFeedbackType)type;

#pragma mark - Others
+ (void)logAllFontFamiliesAndName;
+ (void)log:(NSString *)string;
+ (NSDictionary *)parameterFromURLString:(NSString *)urlString;
+ (CGFloat)currentDeviceStatusBarHeight;
+ (CGFloat)currentDeviceNavigationBarHeightWithStatusBar:(BOOL)statusBar iPhoneXLargeLayout:(BOOL)iPhoneXLargeLayout;
+ (NSString *)mimeTypeForFileAtPath:(NSString *)path;
+ (NSString *)mimeTypeForFileWithExtension:(NSString *)fileExtension;
+ (NSString *)mimeTypeForData:(NSData *)data;
+ (NSString *)getNewFileAndCheckExistingFilePath:(NSString *)path fileNameCounterStart:(NSInteger)counter;
+ (CGFloat)safeAreaBottomPadding;
+ (CGFloat)safeAreaTopPadding;
+ (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;

#pragma mark - TapTalk
+ (NSBundle *)currentBundle;

@end
