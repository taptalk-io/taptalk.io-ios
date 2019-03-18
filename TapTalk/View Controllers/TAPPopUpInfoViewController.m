//
//  TAPPopUpInfoViewController.m
//  TapTalk
//
//  Created by Dominic Vedericho on 19/09/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPPopUpInfoViewController.h"

@interface TAPPopUpInfoViewController ()

- (void)popUpInfoViewHandleDidTappedLeftButton;
- (void)popUpInfoViewHandleDidTappedRightButton;

@end

@implementation TAPPopUpInfoViewController

#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    
    _popUpInfoView = [[TAPPopUpInfoView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.popUpInfoView.leftButton addTarget:self action:@selector(popUpInfoViewHandleDidTappedLeftButton) forControlEvents:UIControlEventTouchUpInside];
    [self.popUpInfoView.rightButton addTarget:self action:@selector(popUpInfoViewHandleDidTappedRightButton) forControlEvents:UIControlEventTouchUpInside];
    self.popUpInfoView.alpha = 0.0f;
    [self.view addSubview:self.popUpInfoView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor clearColor];
    
    if (self.popUpInfoViewControllerType == TAPPopUpInfoViewControllerTypeErrorMessage) {
        [self.popUpInfoView setPopupInfoViewType:TAPPopupInfoViewTypeErrorMessage withTitle:self.titleInformation detailInformation:self.detailInformation];
        [self.popUpInfoView isShowTwoOptionButton:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self showPopupInfoView:YES animated:YES completion:^{
    }];
}

#pragma mark - Custom Method
- (void)popUpInfoViewHandleDidTappedLeftButton {
    [self showPopupInfoView:NO animated:YES completion:^{
        [self dismissViewControllerAnimated:NO completion:^{
            if ([self.delegate respondsToSelector:@selector(popUpInfoViewControllerDidTappedLeftButton)]) {
                [self.delegate popUpInfoViewControllerDidTappedLeftButton];
            }
        }];
    }];
    
}

- (void)popUpInfoViewHandleDidTappedRightButton {
    [self showPopupInfoView:NO animated:YES completion:^{
        [self dismissViewControllerAnimated:NO completion:^{
            if ([self.delegate respondsToSelector:@selector(popUpInfoViewControllerDidTappedSingleButtonOrRightButton)]) {
                [self.delegate popUpInfoViewControllerDidTappedSingleButtonOrRightButton];
            }
        }];
    }];
}

- (void)setPopUpInfoViewControllerType:(TAPPopUpInfoViewControllerType)popUpInfoViewControllerType withTitle:(NSString *)title detailInformation:(NSString *)detailInfo {
    _popUpInfoViewControllerType = popUpInfoViewControllerType;
    _titleInformation = title;
    _detailInformation = detailInfo;
}

- (void)showPopupInfoView:(BOOL)isShow animated:(BOOL)animated completion:(void (^)(void))completion {
    if (animated) {
        if (isShow) {
            [UIView animateWithDuration:0.2f animations:^{
                self.popUpInfoView.alpha = 1.0f;
            } completion:^(BOOL finished) {
                completion();
            }];
        }
        else {
            [UIView animateWithDuration:0.2f animations:^{
                self.popUpInfoView.alpha = 0.0f;
            } completion:^(BOOL finished) {
                completion();
            }];
        }
    }
    else {
        if (isShow) {
            self.popUpInfoView.alpha = 1.0f;
            completion();
        }
        else {
            self.popUpInfoView.alpha = 0.0f;
            completion();
        }
    }
}

@end
