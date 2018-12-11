//
//  BaseView.h
//  Moselo
//
//  Created by Ritchie Nathaniel on 2/23/16.
//  Copyright © 2016 Moselo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TAPBaseView : UIView

+ (CGRect)frameWithNavigationBar;
+ (CGRect)frameWithoutNavigationBar;

@end
