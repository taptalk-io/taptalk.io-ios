//
//  TAPLoadingViewController.m
//  TapTalk
//
//  Created by Cundy Sunardy on 30/04/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPLoadingViewController.h"
#import "TAPLoadingView.h"

@interface TAPLoadingViewController ()

@property (strong, nonatomic) TAPLoadingView *loadingView;

@end

@implementation TAPLoadingViewController
#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    
    _loadingView = [[TAPLoadingView alloc] initWithFrame:[TAPBaseView frameWithoutNavigationBar]];
    self.loadingView.alpha = 0.0f;
    [self.view addSubview:self.loadingView];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.2f animations:^{
        self.loadingView.alpha = 1.0f;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - Custom Method
- (void)dismissLoading {
    [UIView animateWithDuration:0.2f animations:^{
        self.loadingView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
