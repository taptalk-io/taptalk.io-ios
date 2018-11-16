//
//  TAPRegisterViewController.m
//  TapTalk
//
//  Created by Welly Kencana on 16/8/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPRegisterViewController.h"

@interface TAPRegisterViewController ()
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UIButton *confirmButton;

//DV Temp
@property (strong, nonatomic) NSDictionary *contactListDictionary;
//END DV Temp

@end

@implementation TAPRegisterViewController
#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.confirmButton.layer.cornerRadius = 4.0f;
    self.confirmButton.clipsToBounds = YES;
    // Do any additional setup after loading the view from its nib.
    
    //DV Temp
    TAPUserModel *firstUser = [TAPUserModel new];
    firstUser.userID = @"1";
    firstUser.xcUserID = @"1";
    firstUser.fullname = @"Ritchie Nathaniel";
    firstUser.email = @"ritchie@moselo.com";
    firstUser.phone = @"08979809026";
    firstUser.username = @"ritchie";
    
    TAPUserModel *secondUser = [TAPUserModel new];
    secondUser.userID = @"2";
    secondUser.xcUserID = @"2";
    secondUser.fullname = @"Dominic Vedericho";
    secondUser.email = @"dominic@moselo.com";
    secondUser.phone = @"08979809026";
    secondUser.username = @"dominic";
    
    TAPUserModel *thirdUser = [TAPUserModel new];
    thirdUser.userID = @"3";
    thirdUser.xcUserID = @"3";
    thirdUser.fullname = @"Rionaldo Linggautama";
    thirdUser.email = @"rionaldo@moselo.com";
    thirdUser.phone = @"08979809026";
    thirdUser.username = @"rionaldo";
    
    TAPUserModel *fourthUser = [TAPUserModel new];
    fourthUser.userID = @"4";
    fourthUser.xcUserID = @"4";
    fourthUser.fullname = @"Kevin Reynaldo";
    fourthUser.email = @"kevin@moselo.com";
    fourthUser.phone = @"08979809026";
    fourthUser.username = @"kevin";
    
    TAPUserModel *fifthUser = [TAPUserModel new];
    fifthUser.userID = @"5";
    fifthUser.xcUserID = @"5";
    fifthUser.fullname = @"Welly Kencana";
    fifthUser.email = @"welly@moselo.com";
    fifthUser.phone = @"08979809026";
    fifthUser.username = @"welly";
    
    TAPUserModel *sixthUser = [TAPUserModel new];
    sixthUser.userID = @"6";
    sixthUser.xcUserID = @"6";
    sixthUser.fullname = @"Jony Lim";
    sixthUser.email = @"jony@moselo.com";
    sixthUser.phone = @"08979809026";
    sixthUser.username = @"jony";
    
    TAPUserModel *seventhUser = [TAPUserModel new];
    seventhUser.userID = @"7";
    seventhUser.xcUserID = @"7";
    seventhUser.fullname = @"Michael Tansy";
    seventhUser.email = @"michael@moselo.com";
    seventhUser.phone = @"08979809026";
    seventhUser.username = @"michael";
    
    TAPUserModel *eighthUser = [TAPUserModel new];
    eighthUser.userID = @"8";
    eighthUser.xcUserID = @"8";
    eighthUser.fullname = @"Richard Fang";
    eighthUser.email = @"richard@moselo.com";
    eighthUser.phone = @"08979809026";
    eighthUser.username = @"richard";
    
    TAPUserModel *ninthUser = [TAPUserModel new];
    ninthUser.userID = @"9";
    ninthUser.xcUserID = @"9";
    ninthUser.fullname = @"Erwin Andreas";
    ninthUser.email = @"erwin@moselo.com";
    ninthUser.phone = @"08979809026";
    ninthUser.username = @"erwin";
    
    TAPUserModel *tenthUser = [TAPUserModel new];
    tenthUser.userID = @"10";
    tenthUser.xcUserID = @"10";
    tenthUser.fullname = @"Jefry Lorentono";
    tenthUser.email = @"jefry@moselo.com";
    tenthUser.phone = @"08979809026";
    tenthUser.username = @"jefry";
    
    TAPUserModel *eleventhUser = [TAPUserModel new];
    eleventhUser.userID = @"11";
    eleventhUser.xcUserID = @"11";
    eleventhUser.fullname = @"Cundy Sunardy";
    eleventhUser.email = @"cundy@moselo.com";
    eleventhUser.phone = @"08979809026";
    eleventhUser.username = @"cundy";
    
    TAPUserModel *twelfthUser = [TAPUserModel new];
    twelfthUser.userID = @"12";
    twelfthUser.xcUserID = @"12";
    twelfthUser.fullname = @"Rizka Fatmawati";
    twelfthUser.email = @"rizka@moselo.com";
    twelfthUser.phone = @"08979809026";
    twelfthUser.username = @"rizka";
    
    TAPUserModel *thirteenthUser = [TAPUserModel new];
    thirteenthUser.userID = @"13";
    thirteenthUser.xcUserID = @"13";
    thirteenthUser.fullname = @"Test 1";
    thirteenthUser.email = @"test1@moselo.com";
    thirteenthUser.phone = @"08979809026";
    thirteenthUser.username = @"test1";
    
    TAPUserModel *fourteenthUser = [TAPUserModel new];
    fourteenthUser.userID = @"14";
    fourteenthUser.xcUserID = @"14";
    fourteenthUser.fullname = @"Test 2";
    fourteenthUser.email = @"test2@moselo.com";
    fourteenthUser.phone = @"08979809026";
    fourteenthUser.username = @"test2";
    
    TAPUserModel *fifteenthUser = [TAPUserModel new];
    fifteenthUser.userID = @"15";
    fifteenthUser.xcUserID = @"15";
    fifteenthUser.fullname = @"Test 3";
    fifteenthUser.email = @"test3@moselo.com";
    fifteenthUser.phone = @"08979809026";
    fifteenthUser.username = @"test3";
    
    TAPUserModel *sixteenthUser = [TAPUserModel new];
    sixteenthUser.userID = @"17";
    sixteenthUser.xcUserID = @"16";
    sixteenthUser.fullname = @"Santo";
    sixteenthUser.email = @"santo@moselo.com";
    sixteenthUser.phone = @"08979809026";
    sixteenthUser.username = @"santo";
    
    _contactListDictionary = @{@"ritchie" : firstUser, @"dominic" : secondUser, @"rionaldo" : thirdUser, @"kevin" : fourthUser, @"welly" : fifthUser, @"jony" : sixthUser, @"michael" : seventhUser, @"richard" : eighthUser, @"erwin" : ninthUser, @"jefry" : tenthUser, @"cundy" : eleventhUser, @"rizka" : twelfthUser, @"test1" : thirteenthUser, @"test2" : fourteenthUser, @"test3" : fifteenthUser, @"santo" : sixteenthUser};
    //END DV Temp
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.nameTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Method
- (IBAction)confirmButtonDidTapped:(id)sender {
    if ([self.nameTextField.text isEqualToString:@""]) {
        return;
    }
    
    //DV Temp
    //DV Note - 14 Sept Temporary added for checking 1 on 1 chat
    
    NSString *username = self.nameTextField.text;
    
    TAPUserModel *selectedUser = [self.contactListDictionary objectForKey:username];
    NSString *userID = selectedUser.userID;
    userID = [TAPUtil nullToEmptyString:userID];
    
    if(selectedUser == nil) {
        self.nameTextField.text = @"";
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Username Not Found!", @"") message:@"Please input the correct username" preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];

        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    [TAPDataManager callAPIGetAuthTicketWithUser:selectedUser success:^(NSString *authTicket) {
        [[TapTalk sharedInstance] setAuthTicket:authTicket success:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        } failure:^(NSError *error) {
            
            //DV Temp
            //DV Note - show error with custom popup
            //        NSInteger errorCode = error.code;
            //        if(errorCode != 999) {
            //            [self showFailAPIWithMessageString:error.domain show:YES];
            //        }
            //END DV Temp
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Failed", @"") message:error.domain preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }];
    } failure:^(NSError *error) {
        //DV Temp
        //DV Note - show error with custom popup
//        NSInteger errorCode = error.code;
//        if(errorCode != 999) {
//            [self showFailAPIWithMessageString:error.domain show:YES];
//        }
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Failed", @"") message:error.domain preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
        //END DV Temp
    }];

    //END DV Temp
}

- (void)presentRegisterViewControllerIfNeededFromViewController:(UIViewController *)viewController force:(BOOL)force {
    if(![[TapTalk sharedInstance] isAuthenticated] || force) {
        [viewController presentViewController:self animated:YES completion:nil];
    }
}

@end
