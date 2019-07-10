//
//  UIImage+Color.m
//  TapTalk
//
//  Created by Dominic Vedericho on 03/07/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "UIImage+Color.h"
#import <objc/runtime.h>

@implementation UIImage (Color)

#pragma mark - Tint Color
- (UIImage *)setImageTintColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, self.scale);
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [self drawInRect:rect];
    CGContextSetFillColorWithColor(contextRef, [color CGColor]);
    CGContextSetBlendMode(contextRef, kCGBlendModeSourceAtop);
    CGContextFillRect(contextRef, rect);
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

@end
