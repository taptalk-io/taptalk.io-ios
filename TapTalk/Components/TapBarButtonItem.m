//
//  TapBarButtonItem.m
//  TapTalk
//
//  Created by Kevin on 15/06/26.
//  Copyright © 2026 Moselo. All rights reserved.
//

#import "TapBarButtonItem.h"

@implementation TapBarButtonItem

- (instancetype)init {
    self = [super init];
    if (self) {
        [self hideBackground];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self hideBackground];
    }
    return self;
}

- (void)hideBackground {
    if (@available(iOS 26.0, *)) {
        self.hidesSharedBackground = YES;
    }
}

//- (instancetype)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem menu:(UIMenu *)menu {
//    TapBarButtonItem *instance = [super initWithBarButtonSystemItem:systemItem menu:menu];
//    if (@available(iOS 26.0, *)) {
//        instance.hidesSharedBackground = YES;
//    }
//    return instance;
//}
//
//- (instancetype)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem primaryAction:(UIAction *)primaryAction {
//    TapBarButtonItem *instance = [super initWithBarButtonSystemItem:systemItem primaryAction:primaryAction];
//    if (@available(iOS 26.0, *)) {
//        instance.hidesSharedBackground = YES;
//    }
//    return instance;
//}
//
//- (instancetype)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem target:(id)target action:(SEL)action {
//    TapBarButtonItem *instance = [super initWithBarButtonSystemItem:systemItem target:target action:action];
//    if (@available(iOS 26.0, *)) {
//        instance.hidesSharedBackground = YES;
//    }
//    return instance;
//}
//
//- (instancetype)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem primaryAction:(UIAction *)primaryAction menu:(UIMenu *)menu {
//    TapBarButtonItem *instance = [super initWithBarButtonSystemItem:systemItem primaryAction:primaryAction menu:menu];
//    if (@available(iOS 26.0, *)) {
//        instance.hidesSharedBackground = YES;
//    }
//    return instance;
//}
//
//- (instancetype)initWithCustomView:(UIView *)customView {
//    TapBarButtonItem *instance = [super initWithCustomView:customView];
//    if (@available(iOS 26.0, *)) {
//        instance.hidesSharedBackground = YES;
//    }
//    return instance;
//}


@end
