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

@end
