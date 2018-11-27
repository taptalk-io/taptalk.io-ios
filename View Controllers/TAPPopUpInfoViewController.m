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
//- (void)loadView {
//    [super loadView];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _popUpInfoView = [[TAPPopUpInfoView alloc] initWithFrame:[TAPBaseView frameWithoutNavigationBar]];
    [self.view addSubview:self.popUpInfoView];
    
    self.view.backgroundColor = [UIColor clearColor];
    [self.popUpInfoView.leftButton addTarget:self action:@selector(popUpInfoViewHandleDidTappedLeftButton) forControlEvents:UIControlEventTouchUpInside];
    [self.popUpInfoView.rightButton addTarget:self action:@selector(popUpInfoViewHandleDidTappedRightButton) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Custom Method
- (void)popUpInfoViewHandleDidTappedLeftButton {
    if ([self.delegate respondsToSelector:@selector(popUpInfoViewControllerDidTappedLeftButton)]) {
        [self.delegate popUpInfoViewControllerDidTappedLeftButton];
    }
}

- (void)popUpInfoViewHandleDidTappedRightButton {
    if ([self.delegate respondsToSelector:@selector(popUpInfoViewControllerDidTappedSingleButtonOrRightButton)]) {
        [self.delegate popUpInfoViewControllerDidTappedSingleButtonOrRightButton];
    }
}

- (void)setPopUpInfoViewControllerType:(TAPPopUpInfoViewControllerType)popUpInfoViewControllerType withTitle:(NSString *)title detailInformation:(NSString *)detailInfo {
    _popUpInfoViewControllerType = popUpInfoViewControllerType;
    if (self.popUpInfoViewControllerType == TAPPopUpInfoViewControllerTypeErrorMessage) {
        [self.popUpInfoView setPopupInfoViewType:TAPPopupInfoViewTypeErrorMessage withTitle:title detailInformation:detailInfo];
        [self.popUpInfoView isShowTwoOptionButton:NO];
    }
}

@end
