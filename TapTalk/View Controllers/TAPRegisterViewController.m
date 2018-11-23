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
    
    TAPUserModel *seventeenthUser = [TAPUserModel new];
    seventeenthUser.userID = @"18";
    seventeenthUser.xcUserID = @"17";
    seventeenthUser.fullname = @"Veronica Dian";
    seventeenthUser.email = @"veronica@moselo.com";
    seventeenthUser.phone = @"08979809026";
    seventeenthUser.username = @"veronica";
    seventeenthUser.isRequestPending = NO;
    seventeenthUser.isRequestAccepted = YES;
    
    TAPUserModel *eighteenthUser = [TAPUserModel new];
    eighteenthUser.userID = @"19";
    eighteenthUser.xcUserID = @"18";
    eighteenthUser.fullname = @"Poppy Sibarani";
    eighteenthUser.email = @"poppy@moselo.com";
    eighteenthUser.phone = @"08979809026";
    eighteenthUser.username = @"poppy";
    eighteenthUser.isRequestPending = NO;
    eighteenthUser.isRequestAccepted = YES;
    
    TAPUserModel *nineteenthUser = [TAPUserModel new];
    nineteenthUser.userID = @"20";
    nineteenthUser.xcUserID = @"19";
    nineteenthUser.fullname = @"Axel Soedarsono";
    nineteenthUser.email = @"axel@moselo.com";
    nineteenthUser.phone = @"08979809026";
    nineteenthUser.username = @"axel";
    nineteenthUser.isRequestPending = NO;
    nineteenthUser.isRequestAccepted = YES;
    
    TAPUserModel *twentiethUser = [TAPUserModel new];
    twentiethUser.userID = @"21";
    twentiethUser.xcUserID = @"20";
    twentiethUser.fullname = @"Ovita";
    twentiethUser.email = @"ovita@moselo.com";
    twentiethUser.phone = @"08979809026";
    twentiethUser.username = @"ovita";
    twentiethUser.isRequestPending = NO;
    twentiethUser.isRequestAccepted = YES;
    
    TAPUserModel *twentyFirstUser = [TAPUserModel new];
    twentyFirstUser.userID = @"22";
    twentyFirstUser.xcUserID = @"21";
    twentyFirstUser.fullname = @"Putri Prima";
    twentyFirstUser.email = @"putri@moselo.com";
    twentyFirstUser.phone = @"08979809026";
    twentyFirstUser.username = @"putri";
    twentyFirstUser.isRequestPending = NO;
    twentyFirstUser.isRequestAccepted = YES;
    
    TAPUserModel *twentySecondUser = [TAPUserModel new];
    twentySecondUser.userID = @"23";
    twentySecondUser.xcUserID = @"22";
    twentySecondUser.fullname = @"Amalia Nanda";
    twentySecondUser.email = @"amalia@moselo.com";
    twentySecondUser.phone = @"08979809026";
    twentySecondUser.username = @"amalia";
    twentySecondUser.isRequestPending = NO;
    twentySecondUser.isRequestAccepted = YES;
    
    TAPUserModel *twentyThirdUser = [TAPUserModel new];
    twentyThirdUser.userID = @"24";
    twentyThirdUser.xcUserID = @"23";
    twentyThirdUser.fullname = @"Ronal Gorba";
    twentyThirdUser.email = @"ronal@moselo.com";
    twentyThirdUser.phone = @"08979809026";
    twentyThirdUser.username = @"ronal";
    twentyThirdUser.isRequestPending = NO;
    twentyThirdUser.isRequestAccepted = YES;
    
    TAPUserModel *twentyFourthUser = [TAPUserModel new];
    twentyFourthUser.userID = @"25";
    twentyFourthUser.xcUserID = @"24";
    twentyFourthUser.fullname = @"Ardanti Wulandari";
    twentyFourthUser.email = @"ardanti@moselo.com";
    twentyFourthUser.phone = @"08979809026";
    twentyFourthUser.username = @"ardanti";
    twentyFourthUser.isRequestPending = NO;
    twentyFourthUser.isRequestAccepted = YES;
    
    TAPUserModel *twentyFifthUser = [TAPUserModel new];
    twentyFifthUser.userID = @"26";
    twentyFifthUser.xcUserID = @"25";
    twentyFifthUser.fullname = @"Anita";
    twentyFifthUser.email = @"anita@moselo.com";
    twentyFifthUser.phone = @"08979809026";
    twentyFifthUser.username = @"anita";
    twentyFifthUser.isRequestPending = NO;
    twentyFifthUser.isRequestAccepted = YES;
    
    TAPUserModel *twentySixthUser = [TAPUserModel new];
    twentySixthUser.userID = @"27";
    twentySixthUser.xcUserID = @"26";
    twentySixthUser.fullname = @"Kevin Fianto";
    twentySixthUser.email = @"kevin.fianto@moselo.com";
    twentySixthUser.phone = @"08979809026";
    twentySixthUser.username = @"kevinfianto";
    twentySixthUser.isRequestPending = NO;
    twentySixthUser.isRequestAccepted = YES;
    
    TAPUserModel *twentySeventhUser = [TAPUserModel new];
    twentySeventhUser.userID = @"28";
    twentySeventhUser.xcUserID = @"27";
    twentySeventhUser.fullname = @"Dessy Silitonga";
    twentySeventhUser.email = @"dessy@moselo.com";
    twentySeventhUser.phone = @"08979809026";
    twentySeventhUser.username = @"dessy";
    twentySeventhUser.isRequestPending = NO;
    twentySeventhUser.isRequestAccepted = YES;
    
    TAPUserModel *twentyEightUser = [TAPUserModel new];
    twentyEightUser.userID = @"29";
    twentyEightUser.xcUserID = @"28";
    twentyEightUser.fullname = @"Neni Nurhasanah";
    twentyEightUser.email = @"neni@moselo.com";
    twentyEightUser.phone = @"08979809026";
    twentyEightUser.username = @"neni";
    twentyEightUser.isRequestPending = NO;
    twentyEightUser.isRequestAccepted = YES;
    
    TAPUserModel *twentyNinthUser = [TAPUserModel new];
    twentyNinthUser.userID = @"30";
    twentyNinthUser.xcUserID = @"29";
    twentyNinthUser.fullname = @"Bernama Sabur";
    twentyNinthUser.email = @"bernama@moselo.com";
    twentyNinthUser.phone = @"08979809026";
    twentyNinthUser.username = @"bernama";
    twentyNinthUser.isRequestPending = NO;
    twentyNinthUser.isRequestAccepted = YES;
    
    TAPUserModel *thirtiethUser = [TAPUserModel new];
    thirtiethUser.userID = @"31";
    thirtiethUser.xcUserID = @"30";
    thirtiethUser.fullname = @"William Raymond";
    thirtiethUser.email = @"william@moselo.com";
    thirtiethUser.phone = @"08979809026";
    thirtiethUser.username = @"william";
    thirtiethUser.isRequestPending = NO;
    thirtiethUser.isRequestAccepted = YES;
    
    TAPUserModel *thirtyFirstUser = [TAPUserModel new];
    thirtyFirstUser.userID = @"32";
    thirtyFirstUser.xcUserID = @"31";
    thirtyFirstUser.fullname = @"Sarah Febrina";
    thirtyFirstUser.email = @"sarah@moselo.com";
    thirtyFirstUser.phone = @"08979809026";
    thirtyFirstUser.username = @"sarah";
    thirtyFirstUser.isRequestPending = NO;
    thirtyFirstUser.isRequestAccepted = YES;
    
    TAPUserModel *thirtySecondUser = [TAPUserModel new];
    thirtySecondUser.userID = @"33";
    thirtySecondUser.xcUserID = @"32";
    thirtySecondUser.fullname = @"Retyan Arthasani";
    thirtySecondUser.email = @"retyan@moselo.com";
    thirtySecondUser.phone = @"08979809026";
    thirtySecondUser.username = @"retyan";
    thirtySecondUser.isRequestPending = NO;
    thirtySecondUser.isRequestAccepted = YES;
    
    TAPUserModel *thirtyThirdUser = [TAPUserModel new];
    thirtyThirdUser.userID = @"34";
    thirtyThirdUser.xcUserID = @"33";
    thirtyThirdUser.fullname = @"Sekar Sari";
    thirtyThirdUser.email = @"sekar@moselo.com";
    thirtyThirdUser.phone = @"08979809026";
    thirtyThirdUser.username = @"sekar";
    thirtyThirdUser.isRequestPending = NO;
    thirtyThirdUser.isRequestAccepted = YES;
    
    TAPUserModel *thirtyFourthUser = [TAPUserModel new];
    thirtyFourthUser.userID = @"35";
    thirtyFourthUser.xcUserID = @"34";
    thirtyFourthUser.fullname = @"Meilika";
    thirtyFourthUser.email = @"mei@moselo.com";
    thirtyFourthUser.phone = @"08979809026";
    thirtyFourthUser.username = @"mei";
    thirtyFourthUser.isRequestPending = NO;
    thirtyFourthUser.isRequestAccepted = YES;
    
    TAPUserModel *thirtyFifthUser = [TAPUserModel new];
    thirtyFifthUser.userID = @"36";
    thirtyFifthUser.xcUserID = @"35";
    thirtyFifthUser.fullname = @"Yuendry";
    thirtyFifthUser.email = @"yuen@moselo.com";
    thirtyFifthUser.phone = @"08979809026";
    thirtyFifthUser.username = @"yuendry";
    thirtyFifthUser.isRequestPending = NO;
    thirtyFifthUser.isRequestAccepted = YES;
    
    TAPUserModel *thirtySixthUser = [TAPUserModel new];
    thirtySixthUser.userID = @"37";
    thirtySixthUser.xcUserID = @"36";
    thirtySixthUser.fullname = @"Ervin";
    thirtySixthUser.email = @"ervin@moselo.com";
    thirtySixthUser.phone = @"08979809026";
    thirtySixthUser.username = @"ervin";
    thirtySixthUser.isRequestPending = NO;
    thirtySixthUser.isRequestAccepted = YES;
    
    TAPUserModel *thirtySeventhUser = [TAPUserModel new];
    thirtySeventhUser.userID = @"38";
    thirtySeventhUser.xcUserID = @"37";
    thirtySeventhUser.fullname = @"Fauzi";
    thirtySeventhUser.email = @"fauzi@moselo.com";
    thirtySeventhUser.phone = @"08979809026";
    thirtySeventhUser.username = @"fauzi";
    thirtySeventhUser.isRequestPending = NO;
    thirtySeventhUser.isRequestAccepted = YES;
    
    TAPUserModel *thirtyEighthUser = [TAPUserModel new];
    thirtyEighthUser.userID = @"39";
    thirtyEighthUser.xcUserID = @"38";
    thirtyEighthUser.fullname = @"Lucas";
    thirtyEighthUser.email = @"lucas@moselo.com";
    thirtyEighthUser.phone = @"08979809026";
    thirtyEighthUser.username = @"lucas";
    thirtyEighthUser.isRequestPending = NO;
    thirtyEighthUser.isRequestAccepted = YES;
    
    _contactListDictionary = @{@"ritchie" : firstUser, @"dominic" : secondUser, @"rionaldo" : thirdUser, @"kevin" : fourthUser, @"welly" : fifthUser, @"jony" : sixthUser, @"michael" : seventhUser, @"richard" : eighthUser, @"erwin" : ninthUser, @"jefry" : tenthUser, @"cundy" : eleventhUser, @"rizka" : twelfthUser, @"test1" : thirteenthUser, @"test2" : fourteenthUser, @"test3" : fifteenthUser, @"santo" : sixteenthUser, @"veronica" : seventeenthUser, @"poppy" : eighteenthUser, @"axel" : nineteenthUser, @"ovita" : twentiethUser, @"putri" : twentyFirstUser, @"amalia" : twentySecondUser, @"ronal" : twentyThirdUser, @"ardanti" : twentyFourthUser, @"anita" : twentyFifthUser, @"kevinfianto" : twentySixthUser, @"dessy" : twentySeventhUser, @"neni" : twentyEightUser, @"bernama" : twentyNinthUser, @"william" : thirtiethUser, @"sarah" : thirtyFirstUser, @"retyan" : thirtySecondUser, @"sekar" : thirtyThirdUser, @"mei" : thirtyFourthUser, @"yuendry" : thirtyFifthUser, @"ervin" : thirtySixthUser, @"fauzi" : thirtySeventhUser, @"lucas" : thirtyEighthUser};
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
    
    if (selectedUser == nil) {
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
            
            //Refresh Contact List From API
            [TAPDataManager callAPIGetContactList:^(NSArray *userArray) {
            } failure:^(NSError *error) {
                //        NSLog(@"%@", error);
            }];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        } failure:^(NSError *error) {
            
            //DV Temp
            //DV Note - show error with custom popup
            //        NSInteger errorCode = error.code;
            //        if (errorCode != 999) {
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
//        if (errorCode != 999) {
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
    if (![[TapTalk sharedInstance] isAuthenticated] || force) {
        [viewController presentViewController:self animated:YES completion:nil];
    }
}

@end
