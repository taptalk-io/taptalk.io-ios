//
//  TAPBaseViewController.m
//  Moselo
//
//  Created by Ritchie Nathaniel on 2/23/16.
//  Copyright © 2016 Moselo. All rights reserved.
//

#import "TAPBaseViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "TAPPopUpInfoViewController.h"
#import "TAPLeftCustomNavigationButton.h"

@interface TAPBaseViewController () <TAPPopUpInfoViewControllerDelegate>

@property (strong, nonatomic) UIImage *navigationShadowImage;
@property (nonatomic) CGFloat navigationBarShadowOpacity;
@property (nonatomic) CGFloat currentKeyboardHeight;

- (void)backButtonDidTapped;
- (void)closeButtonDidTapped;

@end

@implementation TAPBaseViewController

#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    
    //Set navigation bar background color
    UIColor *navigationBarBackgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultNavigationBarBackground];
    [[UINavigationBar appearance] setBarTintColor:navigationBarBackgroundColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIFont *navigationTitleFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontNavigationBarTitleLabel];
    UIColor *navigationTitleColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorNavigationBarTitleLabel];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:navigationTitleColor,
       NSFontAttributeName:navigationTitleFont}];
    
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f].CGColor;
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(0.0, 1.0f);
    self.navigationController.navigationBar.layer.shadowRadius = 1.0;
    self.navigationController.navigationBar.layer.shadowOpacity = 0.4;
    _navigationShadowImage = self.navigationController.navigationBar.shadowImage;
    _navigationBarShadowOpacity = self.navigationController.navigationBar.layer.shadowOpacity;
    
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    //End Note
    
    //DV Note - To show line under navigation bar
//    [self.navigationController.navigationBar setShadowImage:self.navigationShadowImage];
    //End Note
    
    self.navigationController.navigationBar.translucent = NO;
    
    // FIXME: OVERRIDE STYLE TO LIGHT (DARK MODE UI NOT HANDLED)
    if (@available(iOS 13, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AFNetworkingReachabilityDidChangeNotification
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
#ifdef DEBUG
    NSLog(@"Screen: %@", [self.class description]);
#endif
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self showNavigationSeparator:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

#pragma mark - Delegate
#pragma TAPPopUpInfoViewController
- (void)popUpInfoViewControllerDidTappedLeftButtonWithIdentifier:(NSString *)identifier {
    [self popUpInfoDidTappedLeftButtonWithIdentifier:identifier];
}

- (void)popUpInfoViewControllerDidTappedSingleButtonOrRightButtonWithIdentifier:(NSString *)identifier {
    [self popUpInfoTappedSingleButtonOrRightButtonWithIdentifier:identifier];
}

#pragma mark - Custom Method
- (void)keyboardWillShow:(NSNotification *)notification {
    CGFloat keyboardHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    self->_currentKeyboardHeight = keyboardHeight;
    [self keyboardWillShowWithHeight:keyboardHeight];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGFloat keyboardHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    self->_currentKeyboardHeight = 0.0f;
    [self keyboardWillHideWithHeight:keyboardHeight];
}

- (void)keyboardWillShowWithHeight:(CGFloat)keyboardHeight {
    
}

- (void)keyboardWillHideWithHeight:(CGFloat)keyboardHeight {
    
}

- (void)reachabilityDidChange:(NSNotification *)notification {
    
    BOOL reachable;
    NSString *status = [notification.userInfo objectForKey:AFNetworkingReachabilityNotificationStatusItem];
    NSInteger statusValue = [status integerValue];
    switch(statusValue)
    {
        case 0:
            //AFNetworkReachabilityStatusNotReachable
            reachable = NO;
            break;
        case 1:
            //AFNetworkReachabilityStatusReachableViaWWAN
            reachable = YES;
            break;
        case 2:
            //AFNetworkReachabilityStatusReachableViaWiFi
            reachable = YES;
            break;
        default:
            //AFNetworkReachabilityStatusUnknown
            reachable = NO;
            break;
    }
    
    [self reachabilityChangeIsReachable:reachable];
}

- (void)reachabilityChangeIsReachable:(BOOL)reachable {

}

- (void)showCustomBackButton {
    UIImage *buttonImage = [UIImage imageNamed:@"TAPIconBackArrow" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    buttonImage = [buttonImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconNavigationBarBackButton]];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
    button.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 18.0f);
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
}

- (void)showCustomBackButtonOrange {
    TAPLeftCustomNavigationButton *button = [TAPLeftCustomNavigationButton buttonWithType:UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button addTarget:self action:@selector(backButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    button.contentEdgeInsets = UIEdgeInsetsMake(4.0f, 0.0f, 4.0f, 18.0f);
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];

    UIImage *buttonImage = [UIImage imageNamed:@"TAPIconBackArrow" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    buttonImage = [buttonImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconNavigationBarBackButton]];
    [button setImage:buttonImage forState:UIControlStateNormal];

    UIBarButtonItem *positiveSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    positiveSeparator.width = 6.0f;
    
    self.navigationItem.leftBarButtonItems = @[positiveSeparator, item];
}

- (void)backButtonDidTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showCustomCloseButton {
    UIImage *buttonImage = [UIImage imageNamed:@"TAPIconClose" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    buttonImage = [buttonImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconNavigationBarCloseButton]];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
    button.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 18.0f, 0.0f, 0.0f);
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(closeButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setRightBarButtonItem:barButtonItem];
}

- (void)showCustomCancelButton {
    //LeftBarButton
    
    UIFont *leftBarButtonItemFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontNavigationBarButtonLabel];
    UIColor *leftBarButtonItemColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorNavigationBarButtonLabel];
    UIButton* leftBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [leftBarButton setTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"") forState:UIControlStateNormal];
    [leftBarButton setTitleColor:leftBarButtonItemColor forState:UIControlStateNormal];
    leftBarButton.contentEdgeInsets  = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 18.0f);
    leftBarButton.titleLabel.font = leftBarButtonItemFont;
    [leftBarButton addTarget:self action:@selector(closeButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
    [self.navigationItem setLeftBarButtonItem:leftBarButtonItem];
}

- (void)showCustomEditButton {
    //RightBarButton
    UIFont *rightBarButtonItemFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontNavigationBarButtonLabel];
    UIColor *rightBarButtonItemColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorNavigationBarButtonLabel];
    
    UIButton* rightBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [rightBarButton setTitle:NSLocalizedStringFromTableInBundle(@"Edit", nil, [TAPUtil currentBundle], @"") forState:UIControlStateNormal];
    [rightBarButton setTitleColor:rightBarButtonItemColor forState:UIControlStateNormal];
    rightBarButton.contentEdgeInsets  = UIEdgeInsetsMake(0.0f, 18.0f, 0.0f, 0.0f);
    rightBarButton.titleLabel.font = rightBarButtonItemFont;
    [rightBarButton addTarget:self action:@selector(editButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
}

- (void)showCustomCancelButtonRight {
    //RightBarButton
    UIFont *rightBarButtonItemFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontNavigationBarButtonLabel];
    UIColor *rightBarButtonItemColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorNavigationBarButtonLabel];

    UIButton* rightBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
    [rightBarButton setTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"") forState:UIControlStateNormal];
    [rightBarButton setTitleColor:rightBarButtonItemColor forState:UIControlStateNormal];
    rightBarButton.contentEdgeInsets  = UIEdgeInsetsMake(0.0f, 18.0f, 0.0f, 0.0f);
    rightBarButton.titleLabel.font = rightBarButtonItemFont;
    [rightBarButton addTarget:self action:@selector(cancelButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBarButton];
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
}

- (void)closeButtonDidTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)editButtonDidTapped {
    
}

- (void)cancelButtonDidTapped {
    
}

- (void)showSnackBar:(SnackBarType)type message:(NSString *_Nonnull)message iconName:(NSString *_Nullable)iconName {
    [self showSnackBar:type message:message iconName:iconName showDuration:3.0f animationDuration:0.3f];
}

- (void)showSnackBar:(SnackBarType)type message:(NSString *_Nonnull)message iconName:(NSString *_Nullable)iconName showDuration:(CGFloat)showDuration animationDuration:(CGFloat)animationDuration {
    UIView *snackBarView = [[UIView alloc] initWithFrame:CGRectMake(
        16.0f,
        CGRectGetHeight(self.view.frame) - 80.0f - [TAPUtil safeAreaBottomPadding] - self.currentKeyboardHeight,
        CGRectGetWidth(self.view.frame) - 32.0f,
        48.0f
    )];
    snackBarView.clipsToBounds = YES;
    snackBarView.alpha = 0.0f;
    
    UIImage *iconImage = nil;
    UIImageView *iconImageView = nil;
    if (![TAPUtil isEmptyString:iconName]) {
        iconImage = [UIImage imageNamed:iconName];
    }
    if (iconImage != nil) {
        iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0f, 12.0f, 24.0f, 24.0f)];
        iconImageView.image = iconImage;
        [snackBarView addSubview:iconImageView];
    }
    
    CGFloat labelX = 0.0f;
    if (iconImageView != nil && iconImageView.image != nil) {
        labelX = 32.0f;
    }
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(
        16.0f + labelX,
        12.0f,
        CGRectGetWidth(snackBarView.frame) - 32.0f - labelX,
        24.0f
    )];
    label.font = [UIFont fontWithName:TAP_FONT_FAMILY_BOLD size:16.0f];
    label.text = message;
    label.numberOfLines = 0;
    [snackBarView addSubview:label];
    
    if (type == SnackBarTypeError) {
        snackBarView.backgroundColor = [TAPUtil getColor:@"FFECEE"];
        snackBarView.layer.borderColor = [TAPUtil getColor:TAP_COLOR_ERROR].CGColor;
        snackBarView.layer.borderWidth = 1.0f;
        label.textColor = [TAPUtil getColor:TAP_COLOR_ERROR];
        if (iconImageView != nil && iconImageView.image != nil) {
            iconImageView.image = [iconImageView.image setImageTintColor:[TAPUtil getColor:TAP_COLOR_ERROR]];
        }
    }
    else {
        snackBarView.backgroundColor = [TAPUtil getColor:TAP_COLOR_TEXT_DARK];
        snackBarView.layer.borderWidth = 0.0f;
        label.textColor = [UIColor whiteColor];
        if (iconImageView != nil && iconImageView.image != nil) {
            iconImageView.image = [iconImageView.image setImageTintColor:[UIColor whiteColor]];
        }
    }
    
    if (type == SnackBarTypeToast) {
        [label sizeToFit];
        CGFloat iconWidth = 0.0f;
        if (iconImageView != nil && iconImageView.image != nil) {
            iconWidth = 32.0f;
        }
        snackBarView.frame = CGRectMake(
            MAX(CGRectGetMinX(snackBarView.frame), (CGRectGetWidth(self.view.frame) - CGRectGetWidth(label.frame) - iconWidth - 32.0f) / 2),
            MIN(CGRectGetMinY(snackBarView.frame), CGRectGetHeight(self.view.frame) - CGRectGetHeight(label.frame) - 24.0f - [TAPUtil safeAreaBottomPadding] - self.currentKeyboardHeight),
            MIN(CGRectGetWidth(snackBarView.frame), CGRectGetWidth(label.frame) + iconWidth + 32.0f),
            MAX(CGRectGetHeight(snackBarView.frame), CGRectGetHeight(label.frame) + 24.0f)
        );
        snackBarView.backgroundColor = [TAPUtil getColor:TAP_COLOR_TEXT_DARK withAlpha:0.8f];
        snackBarView.layer.cornerRadius = 24.0f;
    }
    else {
        CGSize labelSize = [label sizeThatFits:CGSizeMake(CGRectGetWidth(label.frame), CGFLOAT_MAX)];
        label.frame = CGRectMake(
            CGRectGetMinX(label.frame),
            CGRectGetMinY(label.frame),
            CGRectGetWidth(label.frame),
            MAX(CGRectGetHeight(label.frame), labelSize.height)
        );
        snackBarView.frame = CGRectMake(
            CGRectGetMinX(snackBarView.frame),
            MIN(CGRectGetMinY(snackBarView.frame), CGRectGetHeight(self.view.frame) - CGRectGetHeight(label.frame) - 24.0f - [TAPUtil safeAreaBottomPadding] - self.currentKeyboardHeight),
            CGRectGetWidth(snackBarView.frame),
            MAX(CGRectGetHeight(snackBarView.frame), CGRectGetHeight(label.frame) + 24.0f)
        );
        snackBarView.layer.cornerRadius = 8.0f;
    }
    
    if (iconImageView != nil && iconImageView.image != nil) {
        iconImageView.frame = CGRectMake(
            CGRectGetMinX(iconImageView.frame),
            (CGRectGetHeight(snackBarView.frame) - CGRectGetHeight(iconImageView.frame)) / 2,
            CGRectGetWidth(iconImageView.frame),
            CGRectGetHeight(iconImageView.frame)
        );
    }
    
    [self.view addSubview:snackBarView];
    
    [UIView animateWithDuration:animationDuration animations:^{
        snackBarView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [TAPUtil performBlock:^{
            [UIView animateWithDuration:animationDuration * 3.0f animations:^{
                snackBarView.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [snackBarView removeFromSuperview];
            }];
        } afterDelay:showDuration];
    }];
}

//Note
//Set left or right button option title to nil to set to default value ("OK" for single or right option button, "Cancel" for left option button)
- (void)showPopupViewWithPopupType:(TAPPopUpInfoViewControllerType)type popupIdentifier:(NSString *)popupIdentifier title:(NSString *)title detailInformation:(NSString *)detailInfo leftOptionButtonTitle:(NSString * __nullable)leftOptionString singleOrRightOptionButtonTitle:(NSString * __nullable)singleOrRightOptionString {
    
    TAPPopUpInfoViewController *popupInfoViewController = [[TAPPopUpInfoViewController alloc] init];
    popupInfoViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    popupInfoViewController.popupIdentifier = popupIdentifier;
    popupInfoViewController.delegate = self;
    [popupInfoViewController setPopUpInfoViewControllerType:type withTitle:title detailInformation:detailInfo leftOptionButtonTitle:leftOptionString singleOrRightOptionButtonTitle:singleOrRightOptionString];

    [self presentViewController:popupInfoViewController animated:NO completion:^{
    }];
}

- (void)popUpInfoDidTappedLeftButtonWithIdentifier:(NSString *)popupIdentifier {

}

- (void)popUpInfoTappedSingleButtonOrRightButtonWithIdentifier:(NSString *)popupIdentifier {
    
}

- (void)showNavigationSeparator:(BOOL)show {
    if (show) {
        [self.navigationController.navigationBar setShadowImage:nil];
        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        
        if (self.navigationBarShadowOpacity != 0.0f) {
            self.navigationController.navigationBar.layer.shadowOpacity = self.navigationBarShadowOpacity;
        }
        
    }
    else {
        
        if (self.navigationBarShadowOpacity == 0.0f) {
            _navigationBarShadowOpacity = self.navigationController.navigationBar.layer.shadowOpacity;
        }
        
        [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
        [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.layer.shadowOpacity = 0.0f;
    }
}


@end
