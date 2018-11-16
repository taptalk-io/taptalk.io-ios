//
//  TAPKeyboardViewController.h
//  TapTalk
//
//  Created by Welly Kencana on 10/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TAPKeyboardViewControllerDelegate <NSObject>

- (void)keyboardViewControllerDidSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface TAPKeyboardViewController : UIInputViewController

@property (weak, nonatomic) id<TAPKeyboardViewControllerDelegate> delegate;
@property (nonatomic) CGFloat keyboardHeight;

@end

NS_ASSUME_NONNULL_END
