//
//  TAPCustomButtonView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 01/04/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPCustomButtonViewType) {
    TAPCustomButtonViewTypeActive = 0,
    TAPCustomButtonViewTypeInactive = 1
};

typedef NS_ENUM(NSInteger, TAPCustomButtonViewStyleType) {
    TAPCustomButtonViewStyleTypePlain = 0,
    TAPCustomButtonViewStyleTypeWithIcon = 1
};

@protocol TAPCustomButtonViewDelegate <NSObject>

- (void)customButtonViewDidTappedButton;

@end

@interface TAPCustomButtonView : UIView

@property (strong, nonatomic) UIButton *button;
@property (nonatomic) TAPCustomButtonViewType customButtonViewType;
@property (nonatomic) TAPCustomButtonViewStyleType customButtonViewStyleType;
@property (weak, nonatomic) id <TAPCustomButtonViewDelegate> delegate;

- (void)setCustomButtonViewType:(TAPCustomButtonViewType)customButtonViewType;
- (void)setCustomButtonViewStyleType:(TAPCustomButtonViewStyleType)customButtonViewStyleType;
- (void)setButtonWithTitle:(NSString *)title;
- (void)setButtonWithTitle:(NSString *)title andIcon:(NSString *)imageName;
- (void)setAsActiveState:(BOOL)active animated:(BOOL)animated;
- (void)setAsLoading:(BOOL)loading animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
