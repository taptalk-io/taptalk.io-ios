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

@interface TAPBaseViewController () <TAPPopUpInfoViewControllerDelegate>

@property (strong, nonatomic) TAPPopUpInfoViewController *popupInfoViewController;
@property (strong, nonatomic) UIImage *navigationShadowImage;
- (void)backButtonDidTapped;
- (void)closeButtonDidTapped;

@end

@implementation TAPBaseViewController

#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    _popupInfoViewController = [[TAPPopUpInfoViewController alloc] init];
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
    
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
    //End Note
    
    //WK Note - To show line under navigation bar
//    [self.navigationController.navigationBar setShadowImage:self.navigationShadowImage];
    //End Note
    
    self.navigationController.navigationBar.translucent = NO;

    self.popupInfoViewController.view.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
    self.popupInfoViewController.delegate = self;
    self.popupInfoViewController.view.alpha = 0.0f;

    //Checking if there any navigationController
    if ([self tabBarController] && ![[[self tabBarController] tabBar] isHidden]){
        //is visible
        [self.tabBarController.view addSubview:self.popupInfoViewController.view];
        [self.tabBarController.view bringSubviewToFront:self.popupInfoViewController.view];

    } else {
        //is not visible or do not exists so is not visible
        if (self.navigationController != nil){
            [self.navigationController.view addSubview:self.popupInfoViewController.view];
            [self.navigationController.view bringSubviewToFront:self.popupInfoViewController.view];
        }
        else {
            [self.view addSubview:self.popupInfoViewController.view];
            [self.view bringSubviewToFront:self.popupInfoViewController.view];
        }
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
- (void)popUpInfoViewControllerDidTappedLeftButton {
    [self popUpInfoDidTappedLeftButton];
}

- (void)popUpInfoViewControllerDidTappedSingleButtonOrRightButton {
    [self popUpInfoTappedSingleButtonOrRightButton];
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

- (void)backButtonDidTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showCustomCloseButton {
    UIImage *buttonImage = [UIImage imageNamed:@"TAPIconCloseGreen" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
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

- (void)showPopupView:(BOOL)isVisible withPopupType:(TAPPopUpInfoViewControllerType)type title:(NSString *)title detailInformation:(NSString *)detailInfo {
    //Note - isVisible is NO, set the title and detailInformation to empty string
    [self.popupInfoViewController setPopUpInfoViewControllerType:type withTitle:title detailInformation:detailInfo];
    if (isVisible) {
        [UIView animateWithDuration:0.2f animations:^{
            self.popupInfoViewController.view.alpha = 1.0f;
        }];
    }
    else {
        [UIView animateWithDuration:0.2f animations:^{
            self.popupInfoViewController.view.alpha = 0.0f;
        }];
    }
}

- (void)popUpInfoDidTappedLeftButton {
    
}

- (void)popUpInfoTappedSingleButtonOrRightButton {
    
}


@end
