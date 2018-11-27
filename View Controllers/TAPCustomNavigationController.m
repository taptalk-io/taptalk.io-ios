//
//  TAPCustomNavigationController.m
//  Moselo
//
//  Created by Ritchie Nathaniel on 2/17/17.
//  Copyright © 2017 Moselo. All rights reserved.
//

#import "TAPCustomNavigationController.h"

@interface TAPCustomNavigationController ()

@end

@implementation TAPCustomNavigationController

#pragma mark - Lifecycle
- (id)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    
    if (self) {
        self.navigationBar.translucent = NO;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
