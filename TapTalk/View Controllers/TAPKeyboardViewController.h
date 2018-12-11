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
@property (strong, nonatomic) NSArray *customKeyboardArray;
@property (strong, nonatomic) TAPUserModel *sender;
@property (strong, nonatomic) TAPUserModel *recipient;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *customInputViewHeightConstraint;

- (void)setCustomKeyboardArray:(NSArray *)customKeyboardArray
                        sender:(TAPUserModel *)sender
                     recipient:(TAPUserModel *)recipient;

@end

NS_ASSUME_NONNULL_END
