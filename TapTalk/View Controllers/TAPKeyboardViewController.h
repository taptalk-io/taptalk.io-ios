//
//  TAPKeyboardViewController.h
//  TapTalk
//
//  Created by Dominic Vedericho on 10/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TAPKeyboardViewController : UIInputViewController

@property (nonatomic) CGFloat keyboardHeight;
@property (strong, nonatomic) NSArray *customKeyboardArray;
@property (strong, nonatomic) TAPUserModel *sender;
@property (strong, nonatomic) TAPUserModel *recipient;
@property (strong, nonatomic) TAPRoomModel *room;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *customInputViewHeightConstraint;

- (void)setCustomKeyboardArray:(NSArray *)customKeyboardArray
                        sender:(TAPUserModel *)sender
                     recipient:(TAPUserModel *)recipient
                          room:(TAPRoomModel *)room;

@end

NS_ASSUME_NONNULL_END
