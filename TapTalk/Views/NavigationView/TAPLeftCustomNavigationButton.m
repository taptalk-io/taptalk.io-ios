//
//  TAPLeftCustomNavigationButton.m
//  TapTalk
//
//  Created by Cundy Sunardy on 08/04/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPLeftCustomNavigationButton.h"

@implementation TAPLeftCustomNavigationButton
//CS NOTE - override the alignmentRectsInsets to realign the position of button in NavigationItem
- (UIEdgeInsets)alignmentRectInsets {
    [super alignmentRectInsets];
    return UIEdgeInsetsMake(0.0f, 6.0f, 0.0f, -6.0f);
}

@end
