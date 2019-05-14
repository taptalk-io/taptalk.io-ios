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

- (void)backButtonDidTapped;
- (void)closeButtonDidTapped;

@end

@implementation TAPBaseViewController

#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(reachabilityDidChange:)
//                                                 name:AFNetworkingReachabilityDidChangeNotification
//                                               object:nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[TAPUtil getColor:TAP_COLOR_BLACK_44],
       NSFontAttributeName:[UIFont fontWithName:TAP_FONT_NAME_BOLD size:17.0f]}];
    
    //WK Note - To remove line under navigation bar
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.layer.shadowColor = [TAPUtil getColor:@"D9D9D9"].CGColor;
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(0.0, 1.0f);
    self.navigationController.navigationBar.layer.shadowRadius = 1.0;
    self.navigationController.navigationBar.layer.shadowOpacity = 0.4;
    _navigationShadowImage = self.navigationController.navigationBar.shadowImage;
    _navigationBarShadowOpacity = self.navigationController.navigationBar.layer.shadowOpacity;
    
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
    //End Note
    
    //WK Note - To show line under navigation bar
//    [self.navigationController.navigationBar setShadowImage:self.navigationShadowImage];
    //End Note
    
    self.navigationController.navigationBar.translucent = NO;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
    
    [self keyboardWillShowWithHeight:keyboardHeight];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGFloat keyboardHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
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

    UIImage *buttonImage = [UIImage imageNamed:@"TAPIconBackArrowOrange" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    [button setImage:buttonImage forState:UIControlStateNormal];

    UIBarButtonItem *positiveSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    positiveSeparator.width = 6.0f;
    
    self.navigationItem.leftBarButtonItems = @[positiveSeparator, item];
}

- (void)backButtonDidTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showCustomCloseButton {
    UIImage *buttonImage = [UIImage imageNamed:@"TAPIconCancelOrange" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
    button.contentEdgeInsets = UIEdgeInsetsMake(0.0f, 18.0f, 0.0f, 0.0f);
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(closeButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setRightBarButtonItem:barButtonItem];
}

- (void)closeButtonDidTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
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
