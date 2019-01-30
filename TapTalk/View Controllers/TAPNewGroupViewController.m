//
//  TAPNewGroupViewController.m
//  TapTalk
//
//  Created by Welly Kencana on 17/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPNewGroupViewController.h"
#import "TAPCreateGroupView.h"
#import "TAPCreateGroupSubjectViewController.h"

#import "TAPContactTableViewCell.h"

#import "TAPContactCollectionViewCell.h"

#import "TAPGroupModel.h"

#define kMaxGroupMember 50 - 1 //1 is group admin.

@interface TAPNewGroupViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) TAPCreateGroupView *createGroupView;

@property (strong, nonatomic) NSArray *alphabetSectionTitles;
@property (strong, nonatomic) NSArray *contactListArray;
@property (strong, nonatomic) NSMutableDictionary *indexSectionDictionary;

@property (strong, nonatomic) NSDictionary *contactListDictionary; //DV Temp
@property (strong, nonatomic) NSMutableArray *selectedIndexArray;
@property (strong, nonatomic) TAPGroupModel *groupModel;
@end

@implementation TAPNewGroupViewController

#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    _createGroupView = [[TAPCreateGroupView alloc] initWithFrame:[TAPBaseView frameWithNavigationBar]];
    [self.view addSubview:self.createGroupView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.createGroupView.searchBarView.searchTextField.delegate = self;
    
    self.createGroupView.contactsTableView.delegate = self;
    self.createGroupView.contactsTableView.dataSource = self;
    self.createGroupView.searchResultTableView.delegate = self;
    self.createGroupView.searchResultTableView.dataSource = self;
    
    self.createGroupView.selectedContactsCollectionView.delegate = self;
    self.createGroupView.selectedContactsCollectionView.dataSource = self;
    
    [self.createGroupView.continueButton addTarget:self action:@selector(continueButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    
    self.title = NSLocalizedString(@"New Group", @"");
    [self showCustomBackButton];
    
    //DV Temp
    TAPUserModel *firstUser = [TAPUserModel new];
    firstUser.userID = @"1";
    firstUser.xcUserID = @"1";
    firstUser.fullname = @"Ritchie Nathaniel";
    firstUser.email = @"ritchie@moselo.com";
    firstUser.phone = @"08979809026";
    firstUser.username = @"ritchie";
    firstUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/ritchie_1542363733889f.jpg";
    firstUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/ritchie_1542363733889t.jpg";
    firstUser.userRole.code = @"user";
    
    TAPUserModel *secondUser = [TAPUserModel new];
    secondUser.userID = @"2";
    secondUser.xcUserID = @"2";
    secondUser.fullname = @"Dominic Vedericho";
    secondUser.email = @"dominic@moselo.com";
    secondUser.phone = @"08979809026";
    secondUser.username = @"dominic";
    secondUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/dominic_1542363733889f.jpg";
    secondUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/dominic_1542363733889t.jpg";
    secondUser.userRole.code = @"user";
    
    TAPUserModel *thirdUser = [TAPUserModel new];
    thirdUser.userID = @"3";
    thirdUser.xcUserID = @"3";
    thirdUser.fullname = @"Rionaldo Linggautama";
    thirdUser.email = @"rionaldo@moselo.com";
    thirdUser.phone = @"08979809026";
    thirdUser.username = @"rionaldo";
    thirdUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/rionaldo_1542363733889f.jpg";
    thirdUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/rionaldo_1542363733889t.jpg";
    thirdUser.userRole.code = @"user";
    
    TAPUserModel *fourthUser = [TAPUserModel new];
    fourthUser.userID = @"4";
    fourthUser.xcUserID = @"4";
    fourthUser.fullname = @"Kevin Reynaldo";
    fourthUser.email = @"kevin@moselo.com";
    fourthUser.phone = @"08979809026";
    fourthUser.username = @"kevin";
    fourthUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/kevin_1542363733889f.jpg";
    fourthUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/kevin_1542363733889t.jpg";
    fourthUser.userRole.code = @"user";
    
    TAPUserModel *fifthUser = [TAPUserModel new];
    fifthUser.userID = @"5";
    fifthUser.xcUserID = @"5";
    fifthUser.fullname = @"Welly Kencana";
    fifthUser.email = @"welly@moselo.com";
    fifthUser.phone = @"08979809026";
    fifthUser.username = @"welly";
    fifthUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/welly_1542363733889f.jpg";
    fifthUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/welly_1542363733889t.jpg";
    fifthUser.userRole.code = @"user";
    
    TAPUserModel *sixthUser = [TAPUserModel new];
    sixthUser.userID = @"6";
    sixthUser.xcUserID = @"6";
    sixthUser.fullname = @"Jony Lim";
    sixthUser.email = @"jony@moselo.com";
    sixthUser.phone = @"08979809026";
    sixthUser.username = @"jony";
    sixthUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/jony_1542363733889f.jpg";
    sixthUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/jony_1542363733889t.jpg";
    sixthUser.userRole.code = @"user";
    
    TAPUserModel *seventhUser = [TAPUserModel new];
    seventhUser.userID = @"7";
    seventhUser.xcUserID = @"7";
    seventhUser.fullname = @"Michael Tansy";
    seventhUser.email = @"michael@moselo.com";
    seventhUser.phone = @"08979809026";
    seventhUser.username = @"michael";
    seventhUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/michael_1542363733889f.jpg";
    seventhUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/michael_1542363733889t.jpg";
    seventhUser.userRole.code = @"user";
    
    TAPUserModel *eighthUser = [TAPUserModel new];
    eighthUser.userID = @"8";
    eighthUser.xcUserID = @"8";
    eighthUser.fullname = @"Richard Fang";
    eighthUser.email = @"richard@moselo.com";
    eighthUser.phone = @"08979809026";
    eighthUser.username = @"richard";
    eighthUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/richard_1542363733889f.jpg";
    eighthUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/richard_1542363733889t.jpg";
    eighthUser.userRole.code = @"user";
    
    TAPUserModel *ninthUser = [TAPUserModel new];
    ninthUser.userID = @"9";
    ninthUser.xcUserID = @"9";
    ninthUser.fullname = @"Erwin Andreas";
    ninthUser.email = @"erwin@moselo.com";
    ninthUser.phone = @"08979809026";
    ninthUser.username = @"erwin";
    ninthUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/erwin_1542363733889f.jpg";
    ninthUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/erwin_1542363733889t.jpg";
    ninthUser.userRole.code = @"user";
    
    TAPUserModel *tenthUser = [TAPUserModel new];
    tenthUser.userID = @"10";
    tenthUser.xcUserID = @"10";
    tenthUser.fullname = @"Jefry Lorentono";
    tenthUser.email = @"jefry@moselo.com";
    tenthUser.phone = @"08979809026";
    tenthUser.username = @"jefry";
    tenthUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/jefry_1542363733889f.jpg";
    tenthUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/jefry_1542363733889t.jpg";
    tenthUser.userRole.code = @"user";
    
    TAPUserModel *eleventhUser = [TAPUserModel new];
    eleventhUser.userID = @"11";
    eleventhUser.xcUserID = @"11";
    eleventhUser.fullname = @"Cundy Sunardy";
    eleventhUser.email = @"cundy@moselo.com";
    eleventhUser.phone = @"08979809026";
    eleventhUser.username = @"cundy";
    eleventhUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/cundy_1542363733889f.jpg";
    eleventhUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/cundy_1542363733889t.jpg";
    eleventhUser.userRole.code = @"user";
    
    TAPUserModel *twelfthUser = [TAPUserModel new];
    twelfthUser.userID = @"12";
    twelfthUser.xcUserID = @"12";
    twelfthUser.fullname = @"Rizka Fatmawati";
    twelfthUser.email = @"rizka@moselo.com";
    twelfthUser.phone = @"08979809026";
    twelfthUser.username = @"rizka";
    twelfthUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/rizka_1542363733889f.jpg";
    twelfthUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/rizka_1542363733889t.jpg";
    twelfthUser.userRole.code = @"user";
    
    TAPUserModel *thirteenthUser = [TAPUserModel new];
    thirteenthUser.userID = @"13";
    thirteenthUser.xcUserID = @"13";
    thirteenthUser.fullname = @"Test 1";
    thirteenthUser.email = @"test1@moselo.com";
    thirteenthUser.phone = @"08979809026";
    thirteenthUser.username = @"test1";
    thirteenthUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/test1_1542363733889f.jpg";
    thirteenthUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/test1_1542363733889t.jpg";
    thirteenthUser.userRole.code = @"user";
    
    TAPUserModel *fourteenthUser = [TAPUserModel new];
    fourteenthUser.userID = @"14";
    fourteenthUser.xcUserID = @"14";
    fourteenthUser.fullname = @"Test 2";
    fourteenthUser.email = @"test2@moselo.com";
    fourteenthUser.phone = @"08979809026";
    fourteenthUser.username = @"test2";
    fourteenthUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/test2_1542363733889f.jpg";
    fourteenthUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/test2_1542363733889t.jpg";
    fourteenthUser.userRole.code = @"user";
    
    TAPUserModel *fifteenthUser = [TAPUserModel new];
    fifteenthUser.userID = @"15";
    fifteenthUser.xcUserID = @"15";
    fifteenthUser.fullname = @"Test 3";
    fifteenthUser.email = @"test3@moselo.com";
    fifteenthUser.phone = @"08979809026";
    fifteenthUser.username = @"test3";
    fifteenthUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/test3_1542363733889f.jpg";
    fifteenthUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/test3_1542363733889t.jpg";
    fifteenthUser.userRole.code = @"user";
    
    TAPUserModel *sixteenthUser = [TAPUserModel new];
    sixteenthUser.userID = @"17";
    sixteenthUser.xcUserID = @"16";
    sixteenthUser.fullname = @"Santo";
    sixteenthUser.email = @"santo@moselo.com";
    sixteenthUser.phone = @"08979809026";
    sixteenthUser.username = @"santo";
    sixteenthUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/santo_1542363733889f.jpg";
    sixteenthUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/santo_1542363733889t.jpg";
    sixteenthUser.userRole.code = @"user";
    
    TAPUserModel *seventeenthUser = [TAPUserModel new];
    seventeenthUser.userID = @"18";
    seventeenthUser.xcUserID = @"17";
    seventeenthUser.fullname = @"Veronica Dian";
    seventeenthUser.email = @"veronica@moselo.com";
    seventeenthUser.phone = @"08979809026";
    seventeenthUser.username = @"veronica";
    seventeenthUser.isRequestPending = NO;
    seventeenthUser.isRequestAccepted = YES;
    seventeenthUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/veronica_1542363733889f.jpg";
    seventeenthUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/veronica_1542363733889t.jpg";
    seventeenthUser.userRole.code = @"user";
    
    TAPUserModel *eighteenthUser = [TAPUserModel new];
    eighteenthUser.userID = @"19";
    eighteenthUser.xcUserID = @"18";
    eighteenthUser.fullname = @"Poppy Sibarani";
    eighteenthUser.email = @"poppy@moselo.com";
    eighteenthUser.phone = @"08979809026";
    eighteenthUser.username = @"poppy";
    eighteenthUser.isRequestPending = NO;
    eighteenthUser.isRequestAccepted = YES;
    eighteenthUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/poppy_1542363733889f.jpg";
    eighteenthUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/poppy_1542363733889t.jpg";
    eighteenthUser.userRole.code = @"user";
    
    TAPUserModel *nineteenthUser = [TAPUserModel new];
    nineteenthUser.userID = @"20";
    nineteenthUser.xcUserID = @"19";
    nineteenthUser.fullname = @"Axel Soedarsono";
    nineteenthUser.email = @"axel@moselo.com";
    nineteenthUser.phone = @"08979809026";
    nineteenthUser.username = @"axel";
    nineteenthUser.isRequestPending = NO;
    nineteenthUser.isRequestAccepted = YES;
    nineteenthUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/axel_1542363733889f.jpg";
    nineteenthUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/axel_1542363733889t.jpg";
    nineteenthUser.userRole.code = @"user";
    
    TAPUserModel *twentiethUser = [TAPUserModel new];
    twentiethUser.userID = @"21";
    twentiethUser.xcUserID = @"20";
    twentiethUser.fullname = @"Ovita";
    twentiethUser.email = @"ovita@moselo.com";
    twentiethUser.phone = @"08979809026";
    twentiethUser.username = @"ovita";
    twentiethUser.isRequestPending = NO;
    twentiethUser.isRequestAccepted = YES;
    twentiethUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/ovita_1542363733889f.jpg";
    twentiethUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/ovita_1542363733889t.jpg";
    twentiethUser.userRole.code = @"user";
    
    TAPUserModel *twentyFirstUser = [TAPUserModel new];
    twentyFirstUser.userID = @"22";
    twentyFirstUser.xcUserID = @"21";
    twentyFirstUser.fullname = @"Putri Prima";
    twentyFirstUser.email = @"putri@moselo.com";
    twentyFirstUser.phone = @"08979809026";
    twentyFirstUser.username = @"putri";
    twentyFirstUser.isRequestPending = NO;
    twentyFirstUser.isRequestAccepted = YES;
    twentyFirstUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/putri_1542363733889f.jpg";
    twentyFirstUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/putri_1542363733889t.jpg";
    twentyFirstUser.userRole.code = @"user";
    
    TAPUserModel *twentySecondUser = [TAPUserModel new];
    twentySecondUser.userID = @"23";
    twentySecondUser.xcUserID = @"22";
    twentySecondUser.fullname = @"Amalia Nanda";
    twentySecondUser.email = @"amalia@moselo.com";
    twentySecondUser.phone = @"08979809026";
    twentySecondUser.username = @"amalia";
    twentySecondUser.isRequestPending = NO;
    twentySecondUser.isRequestAccepted = YES;
    twentySecondUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/amalia_1542363733889f.jpg";
    twentySecondUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/amalia_1542363733889t.jpg";
    twentySecondUser.userRole.code = @"user";
    
    TAPUserModel *twentyThirdUser = [TAPUserModel new];
    twentyThirdUser.userID = @"24";
    twentyThirdUser.xcUserID = @"23";
    twentyThirdUser.fullname = @"Ronal Gorba";
    twentyThirdUser.email = @"ronal@moselo.com";
    twentyThirdUser.phone = @"08979809026";
    twentyThirdUser.username = @"ronal";
    twentyThirdUser.isRequestPending = NO;
    twentyThirdUser.isRequestAccepted = YES;
    twentyThirdUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/ronal_1542363733889f.jpg";
    twentyThirdUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/ronal_1542363733889t.jpg";
    twentyThirdUser.userRole.code = @"user";
    
    TAPUserModel *twentyFourthUser = [TAPUserModel new];
    twentyFourthUser.userID = @"25";
    twentyFourthUser.xcUserID = @"24";
    twentyFourthUser.fullname = @"Ardanti Wulandari";
    twentyFourthUser.email = @"ardanti@moselo.com";
    twentyFourthUser.phone = @"08979809026";
    twentyFourthUser.username = @"ardanti";
    twentyFourthUser.isRequestPending = NO;
    twentyFourthUser.isRequestAccepted = YES;
    twentyFourthUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/ardanti_1542363733889f.jpg";
    twentyFourthUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/ardanti_1542363733889t.jpg";
    twentyFourthUser.userRole.code = @"user";
    
    TAPUserModel *twentyFifthUser = [TAPUserModel new];
    twentyFifthUser.userID = @"26";
    twentyFifthUser.xcUserID = @"25";
    twentyFifthUser.fullname = @"Anita";
    twentyFifthUser.email = @"anita@moselo.com";
    twentyFifthUser.phone = @"08979809026";
    twentyFifthUser.username = @"anita";
    twentyFifthUser.isRequestPending = NO;
    twentyFifthUser.isRequestAccepted = YES;
    twentyFifthUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/anita_1542363733889f.jpg";
    twentyFifthUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/anita_1542363733889t.jpg";
    twentyFifthUser.userRole.code = @"user";
    
    TAPUserModel *twentySixthUser = [TAPUserModel new];
    twentySixthUser.userID = @"27";
    twentySixthUser.xcUserID = @"26";
    twentySixthUser.fullname = @"Kevin Fianto";
    twentySixthUser.email = @"kevin.fianto@moselo.com";
    twentySixthUser.phone = @"08979809026";
    twentySixthUser.username = @"kevinfianto";
    twentySixthUser.isRequestPending = NO;
    twentySixthUser.isRequestAccepted = YES;
    twentySixthUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/kevinfianto_1542363733889f.jpg";
    twentySixthUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/kevinfianto_1542363733889t.jpg";
    twentySixthUser.userRole.code = @"user";
    
    TAPUserModel *twentySeventhUser = [TAPUserModel new];
    twentySeventhUser.userID = @"28";
    twentySeventhUser.xcUserID = @"27";
    twentySeventhUser.fullname = @"Dessy Silitonga";
    twentySeventhUser.email = @"dessy@moselo.com";
    twentySeventhUser.phone = @"08979809026";
    twentySeventhUser.username = @"dessy";
    twentySeventhUser.isRequestPending = NO;
    twentySeventhUser.isRequestAccepted = YES;
    twentySeventhUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/dessy_1542363733889f.jpg";
    twentySeventhUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/dessy_1542363733889t.jpg";
    twentySecondUser.userRole.code = @"user";
    
    TAPUserModel *twentyEightUser = [TAPUserModel new];
    twentyEightUser.userID = @"29";
    twentyEightUser.xcUserID = @"28";
    twentyEightUser.fullname = @"Neni Nurhasanah";
    twentyEightUser.email = @"neni@moselo.com";
    twentyEightUser.phone = @"08979809026";
    twentyEightUser.username = @"neni";
    twentyEightUser.isRequestPending = NO;
    twentyEightUser.isRequestAccepted = YES;
    twentyEightUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/neni_1542363733889f.jpg";
    twentyEightUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/neni_1542363733889t.jpg";
    twentyEightUser.userRole.code = @"user";
    
    TAPUserModel *twentyNinthUser = [TAPUserModel new];
    twentyNinthUser.userID = @"30";
    twentyNinthUser.xcUserID = @"29";
    twentyNinthUser.fullname = @"Bernama Sabur";
    twentyNinthUser.email = @"bernama@moselo.com";
    twentyNinthUser.phone = @"08979809026";
    twentyNinthUser.username = @"bernama";
    twentyNinthUser.isRequestPending = NO;
    twentyNinthUser.isRequestAccepted = YES;
    twentyNinthUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/bernama_1542363733889f.jpg";
    twentyNinthUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/bernama_1542363733889t.jpg";
    twentyNinthUser.userRole.code = @"user";
    
    TAPUserModel *thirtiethUser = [TAPUserModel new];
    thirtiethUser.userID = @"31";
    thirtiethUser.xcUserID = @"30";
    thirtiethUser.fullname = @"William Raymond";
    thirtiethUser.email = @"william@moselo.com";
    thirtiethUser.phone = @"08979809026";
    thirtiethUser.username = @"william";
    thirtiethUser.isRequestPending = NO;
    thirtiethUser.isRequestAccepted = YES;
    thirtiethUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/william_1542363733889f.jpg";
    thirtiethUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/william_1542363733889t.jpg";
    thirtiethUser.userRole.code = @"user";
    
    TAPUserModel *thirtyFirstUser = [TAPUserModel new];
    thirtyFirstUser.userID = @"32";
    thirtyFirstUser.xcUserID = @"31";
    thirtyFirstUser.fullname = @"Sarah Febrina";
    thirtyFirstUser.email = @"sarah@moselo.com";
    thirtyFirstUser.phone = @"08979809026";
    thirtyFirstUser.username = @"sarah";
    thirtyFirstUser.isRequestPending = NO;
    thirtyFirstUser.isRequestAccepted = YES;
    thirtyFirstUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/sarah_1542363733889f.jpg";
    thirtyFirstUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/sarah_1542363733889t.jpg";
    thirtyFirstUser.userRole.code = @"user";
    
    TAPUserModel *thirtySecondUser = [TAPUserModel new];
    thirtySecondUser.userID = @"33";
    thirtySecondUser.xcUserID = @"32";
    thirtySecondUser.fullname = @"Retyan Arthasani";
    thirtySecondUser.email = @"retyan@moselo.com";
    thirtySecondUser.phone = @"08979809026";
    thirtySecondUser.username = @"retyan";
    thirtySecondUser.isRequestPending = NO;
    thirtySecondUser.isRequestAccepted = YES;
    thirtySecondUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/retyan_1542363733889f.jpg";
    thirtySecondUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/retyan_1542363733889t.jpg";
    thirtySecondUser.userRole.code = @"user";
    
    TAPUserModel *thirtyThirdUser = [TAPUserModel new];
    thirtyThirdUser.userID = @"34";
    thirtyThirdUser.xcUserID = @"33";
    thirtyThirdUser.fullname = @"Sekar Sari";
    thirtyThirdUser.email = @"sekar@moselo.com";
    thirtyThirdUser.phone = @"08979809026";
    thirtyThirdUser.username = @"sekar";
    thirtyThirdUser.isRequestPending = NO;
    thirtyThirdUser.isRequestAccepted = YES;
    thirtyThirdUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/sekar_1542363733889f.jpg";
    thirtyThirdUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/sekar_1542363733889t.jpg";
    thirtyThirdUser.userRole.code = @"user";
    
    TAPUserModel *thirtyFourthUser = [TAPUserModel new];
    thirtyFourthUser.userID = @"35";
    thirtyFourthUser.xcUserID = @"34";
    thirtyFourthUser.fullname = @"Meilika";
    thirtyFourthUser.email = @"mei@moselo.com";
    thirtyFourthUser.phone = @"08979809026";
    thirtyFourthUser.username = @"mei";
    thirtyFourthUser.isRequestPending = NO;
    thirtyFourthUser.isRequestAccepted = YES;
    thirtyFourthUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/mei_1542363733889f.jpg";
    thirtyFourthUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/mei_1542363733889t.jpg";
    thirtyFourthUser.userRole.code = @"user";
    
    TAPUserModel *thirtyFifthUser = [TAPUserModel new];
    thirtyFifthUser.userID = @"36";
    thirtyFifthUser.xcUserID = @"35";
    thirtyFifthUser.fullname = @"Yuendry";
    thirtyFifthUser.email = @"yuen@moselo.com";
    thirtyFifthUser.phone = @"08979809026";
    thirtyFifthUser.username = @"yuendry";
    thirtyFifthUser.isRequestPending = NO;
    thirtyFifthUser.isRequestAccepted = YES;
    thirtyFifthUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/yuendry_1542363733889f.jpg";
    thirtyFifthUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/yuendry_1542363733889t.jpg";
    thirtyFifthUser.userRole.code = @"user";
    
    TAPUserModel *thirtySixthUser = [TAPUserModel new];
    thirtySixthUser.userID = @"37";
    thirtySixthUser.xcUserID = @"36";
    thirtySixthUser.fullname = @"Ervin";
    thirtySixthUser.email = @"ervin@moselo.com";
    thirtySixthUser.phone = @"08979809026";
    thirtySixthUser.username = @"ervin";
    thirtySixthUser.isRequestPending = NO;
    thirtySixthUser.isRequestAccepted = YES;
    thirtySixthUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/ervin_1542363733889f.jpg";
    thirtySixthUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/ervin_1542363733889t.jpg";
    thirtySixthUser.userRole.code = @"user";
    
    TAPUserModel *thirtySeventhUser = [TAPUserModel new];
    thirtySeventhUser.userID = @"38";
    thirtySeventhUser.xcUserID = @"37";
    thirtySeventhUser.fullname = @"Fauzi";
    thirtySeventhUser.email = @"fauzi@moselo.com";
    thirtySeventhUser.phone = @"08979809026";
    thirtySeventhUser.username = @"fauzi";
    thirtySeventhUser.isRequestPending = NO;
    thirtySeventhUser.isRequestAccepted = YES;
    thirtySeventhUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/fauzi_1542363733889f.jpg";
    thirtySeventhUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/fauzi_1542363733889t.jpg";
    thirtySeventhUser.userRole.code = @"user";
    
    TAPUserModel *thirtyEighthUser = [TAPUserModel new];
    thirtyEighthUser.userID = @"39";
    thirtyEighthUser.xcUserID = @"38";
    thirtyEighthUser.fullname = @"Lucas";
    thirtyEighthUser.email = @"lucas@moselo.com";
    thirtyEighthUser.phone = @"08979809026";
    thirtyEighthUser.username = @"lucas";
    thirtyEighthUser.isRequestPending = NO;
    thirtyEighthUser.isRequestAccepted = YES;
    thirtyEighthUser.imageURL.fullsize = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/lucas_1542363733889f.jpg";
    thirtyEighthUser.imageURL.thumbnail = @"https://s3-ap-southeast-1.amazonaws.com/taptalk-dev/images/lucas_1542363733889t.jpg";
    thirtyEighthUser.userRole.code = @"user";
    
    _contactListDictionary = @{@"ritchie" : firstUser, @"dominic" : secondUser, @"rionaldo" : thirdUser, @"kevin" : fourthUser, @"welly" : fifthUser, @"jony" : sixthUser, @"michael" : seventhUser, @"richard" : eighthUser, @"erwin" : ninthUser, @"jefry" : tenthUser, @"cundy" : eleventhUser, @"rizka" : twelfthUser, @"test1" : thirteenthUser, @"test2" : fourteenthUser, @"test3" : fifteenthUser, @"santo" : sixteenthUser, @"veronica" : seventeenthUser, @"poppy" : eighteenthUser, @"axel" : nineteenthUser, @"ovita" : twentiethUser, @"putri" : twentyFirstUser, @"amalia" : twentySecondUser, @"ronal" : twentyThirdUser, @"ardanti" : twentyFourthUser, @"anita" : twentyFifthUser, @"kevinfianto" : twentySixthUser, @"dessy" : twentySeventhUser, @"neni" : twentyEightUser, @"bernama" : twentyNinthUser, @"william" : thirtiethUser, @"sarah" : thirtyFirstUser, @"retyan" : thirtySecondUser, @"sekar" : thirtyThirdUser, @"mei" : thirtyFourthUser, @"yuendry" : thirtyFifthUser, @"ervin" : thirtySixthUser, @"fauzi" : thirtySeventhUser,  @"lucas" : thirtyEighthUser};
    //END DV Temp
    
    _alphabetSectionTitles = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"#", nil];
    
    _contactListArray = [NSMutableArray array];
    _indexSectionDictionary = [NSMutableDictionary dictionary];
    
    NSArray *unsortedContactListArray = @[firstUser, secondUser, thirdUser, fourthUser, fifthUser, sixthUser, seventhUser, eighthUser, ninthUser, tenthUser, eleventhUser, twelfthUser, thirteenthUser, fourteenthUser, fifteenthUser, sixteenthUser, seventeenthUser, eighteenthUser, nineteenthUser, twentiethUser, twentyFirstUser, twentySecondUser, twentyThirdUser, twentyFourthUser, twentyFifthUser, twentySixthUser, twentySeventhUser, twentyEightUser, twentyNinthUser, thirtiethUser, thirtyFirstUser, thirtySecondUser, thirtyThirdUser, thirtyFourthUser, thirtyFifthUser, thirtySixthUser, thirtySeventhUser, thirtyEighthUser];
    
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"fullname"
                                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByName];
    NSArray *sortedArray = [unsortedContactListArray sortedArrayUsingDescriptors:sortDescriptors];
    
    self.contactListArray = sortedArray;
    
    for (TAPUserModel *user in self.contactListArray) {
        NSString *nameString = user.fullname;
        NSString *firstAlphabet = [[nameString substringWithRange:NSMakeRange(0, 1)] uppercaseString];
        if ([self.alphabetSectionTitles containsObject:firstAlphabet]) {
            if ([self.indexSectionDictionary objectForKey:firstAlphabet] == nil) {
                //No alphabet found
                [self.indexSectionDictionary setObject:[NSArray arrayWithObjects:user, nil] forKey:firstAlphabet];
            }
            else {
                //Alphabet found
                NSMutableArray *contactArray = [[self.indexSectionDictionary objectForKey:firstAlphabet] mutableCopy];
                [contactArray addObject:user];
                [self.indexSectionDictionary setObject:contactArray forKey:firstAlphabet];
            }
        }
        else {
            if ([self.indexSectionDictionary objectForKey:@"#"] == nil) {
                //No alphabet found
                [self.indexSectionDictionary setObject:[NSArray arrayWithObjects:user, nil] forKey:firstAlphabet];
            }
            else {
                //Alphabet found
                NSMutableArray *contactArray = [[self.indexSectionDictionary objectForKey:@"#"] mutableCopy];
                [contactArray addObject:user];
                [self.indexSectionDictionary setObject:contactArray forKey:firstAlphabet];
            }
        }
    }
    
    _groupModel = [TAPGroupModel new]; //WK Temp
    
    _selectedIndexArray = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data Source
#pragma mark TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.createGroupView.contactsTableView) {
        return [self.indexSectionDictionary count];
    }
    else if (tableView == self.createGroupView.searchResultTableView) {
        return 1;
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.createGroupView.contactsTableView) {
        if (section <= [self.indexSectionDictionary count] - 1) {
            NSArray *keysArray = [self.indexSectionDictionary allKeys];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
            keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
            
            NSString *key = [keysArray objectAtIndex:section];
            NSArray *contactArray = [self.indexSectionDictionary objectForKey:key];
            return [contactArray count];
        }
    }
    else if (tableView == self.createGroupView.searchResultTableView) {
        if (section == 0) {
            return 5; //WK Temp
        }
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.createGroupView.contactsTableView) {
        if (indexPath.section <= [self.alphabetSectionTitles count] - 1) {
            return 64.0f;
        }
    }
    else if (tableView == self.createGroupView.searchResultTableView) {
        if (indexPath.section == 0) {
            return 64.0f;
        }
    }
    
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.createGroupView.contactsTableView) {
        if (indexPath.section <= [self.indexSectionDictionary count] - 1) {
            static NSString *cellID = @"TAPContactTableViewCell";
            TAPContactTableViewCell *cell = [[TAPContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            
            NSArray *keysArray = [self.indexSectionDictionary allKeys];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
            keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
            
            NSString *key = [keysArray objectAtIndex:indexPath.section];
            NSArray *contactArray = [self.indexSectionDictionary objectForKey:key];
            TAPUserModel *currentUser = [contactArray objectAtIndex:indexPath.row];
            [cell setContactTableViewCellWithUser:currentUser];
            
            [cell isRequireSelection:YES];
            
            NSString *objectString = [NSString stringWithFormat:@"%ld - %ld", indexPath.section, indexPath.row];
            if ([self.selectedIndexArray containsObject:objectString]) {
                [cell isCellSelected:YES];
            }
            else {
                [cell isCellSelected:NO];
            }
            
            if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
                [cell showSeparatorLine:NO];
            }
            else {
                [cell showSeparatorLine:YES];
            }
            
            return cell;
        }
    }
    else if (tableView == self.createGroupView.searchResultTableView) {
        if (indexPath.section <= [self.alphabetSectionTitles count] - 1) {
            static NSString *cellID = @"TAPContactTableViewCell";
            TAPContactTableViewCell *cell = [[TAPContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            
            [cell setContactTableViewCellWithUser:[TAPUserModel new]]; //WK Temp
//            [cell setContactTableViewCellWithUser:currentUser];

            [cell isRequireSelection:YES];
            
            [cell isCellSelected:YES];
            
            if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
                [cell showSeparatorLine:NO];
            }
            else {
                [cell showSeparatorLine:YES];
            }
            
            return cell;
        }
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.createGroupView.contactsTableView) {
        if (section <= [self.alphabetSectionTitles count] - 1) {
            return 34.0f;
        }
    }
    
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.createGroupView.contactsTableView) {
        if (section <= [[self.indexSectionDictionary allKeys] count]) {
            UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), 34.0f)];
            header.backgroundColor = [TAPUtil getColor:@"F8F8F8"];
            
            NSArray *keysArray = [self.indexSectionDictionary allKeys];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
            keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 0.0f, CGRectGetWidth(header.frame) - 16.0f - 16.0f, 34.0f)];
            titleLabel.textColor = [TAPUtil getColor:TAP_COLOR_MOSELO_PURPLE];
            titleLabel.font = [UIFont fontWithName:TAP_FONT_LATO_BOLD size:11.0f];
            [header addSubview:titleLabel];
            
            if ([keysArray count] != 0) {
                titleLabel.text = [keysArray objectAtIndex:section];
            }
            
            return header;
        }
    }
    
    UIView *header = [[UIView alloc] init];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footer = [[UIView alloc] init];
    return footer;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.createGroupView.contactsTableView) {
        if (section <= [[self.indexSectionDictionary allKeys] count]) {
            //Contacts
            NSArray *keysArray = [self.indexSectionDictionary allKeys];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
            keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
            
            return [keysArray objectAtIndex:section];
        }
    }
    
    return @"";
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.createGroupView.contactsTableView) {
        NSArray *keysArray = [self.indexSectionDictionary allKeys];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
        keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        return keysArray;
    }
    
    NSArray *sectionIndexArray = [NSArray array];
    return sectionIndexArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (tableView == self.createGroupView.contactsTableView) {
        NSArray *keysArray = [self.indexSectionDictionary allKeys];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
        keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
        
        return [keysArray indexOfObject:title];
    }
    
    return 0;
}

#pragma mark UICollectionView
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(52.0f, 74.0f);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0.0f, 16.0f, 0.0f, 16.0f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 16.0f;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [self.selectedIndexArray count] + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *cellID = @"TAPContactCollectionViewCell";
        
        [collectionView registerClass:[TAPContactCollectionViewCell class] forCellWithReuseIdentifier:cellID];
        TAPContactCollectionViewCell *cell = (TAPContactCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
        
        if (indexPath.row == 0) {
            //Group Admin
            [cell setContactCollectionViewCellWithModel:@"You"];
            [cell showRemoveIcon:NO];
            
            return cell;
        }
        else {
            NSString *objectString = [self.selectedIndexArray objectAtIndex:indexPath.row - 1];
            NSArray *objectStringSplitArray = [objectString componentsSeparatedByString:@" - "];
            NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForItem:[[objectStringSplitArray objectAtIndex:1] integerValue] inSection:[[objectStringSplitArray objectAtIndex:0] integerValue]];
            
            NSArray *keysArray = [self.indexSectionDictionary allKeys];
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
            keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
            
            NSString *key = [keysArray objectAtIndex:selectedIndexPath.section];
            NSArray *contactArray = [self.indexSectionDictionary objectForKey:key];
            TAPUserModel *currentUser = [contactArray objectAtIndex:selectedIndexPath.row];
//            [cell setContactTableViewCellWithUser:currentUser];
            
//            NSArray *keysArray = [self.indexSectionDictionary allKeys];
//            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
//            keysArray = [keysArray sortedArrayUsingDescriptors:@[sortDescriptor]];
//
//            NSString *key = [keysArray objectAtIndex:selectedIndexPath.section];
//            NSArray *userArray = [self.contactListDictionary valueForKey:key];
            
//            [cell setContactCollectionViewCellWithModel:[self.alphabetSectionTitles objectAtIndex:selectedIndexPath.section]];
//            TAPUserModel *user = [userArray objectAtIndex:selectedIndexPath.row];
            [cell setContactCollectionViewCellWithModel:currentUser.username];
            [cell showRemoveIcon:YES];
            
            return cell;
        }
    }
    
    UICollectionViewCell *cell = [[UICollectionViewCell alloc] init];
    return cell;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attributesInRect = [NSArray array];
    return attributesInRect;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *reusableview = [[UICollectionReusableView alloc] init];
        return reusableview;
    }
    else if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *reusableview = [[UICollectionReusableView alloc] init];
        return reusableview;
    }
    
    return nil;
}

#pragma mark - Delegate
#pragma mark TableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == self.createGroupView.contactsTableView) {
        //Contacts
//        if ([self.selectedIndexArray count] == kMaxGroupMember) {
//            //WK Temp
//            [self isShowTwoOptionButton:NO];
//            [self showPopupView:YES];
//        }
//        else {
            NSString *objectString = [NSString stringWithFormat:@"%ld - %ld", indexPath.section, indexPath.row];
            NSArray *objectStringSplitArray = [objectString componentsSeparatedByString:@" - "];
            NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForItem:[[objectStringSplitArray objectAtIndex:1] integerValue] inSection:[[objectStringSplitArray objectAtIndex:0] integerValue]];
            TAPContactTableViewCell *contactTableViewCell = [self.createGroupView.contactsTableView cellForRowAtIndexPath:selectedIndexPath];
            if ([self.selectedIndexArray containsObject:objectString]) {
                [self.selectedIndexArray removeObject:objectString];
                [contactTableViewCell isCellSelected:NO];
            }
            else {
                if ([self.selectedIndexArray count] == kMaxGroupMember) {
                    //WK Temp
                    [self showPopupView:YES withPopupType:TAPPopUpInfoViewControllerTypeErrorMessage title:NSLocalizedString(@"Failed", @"") detailInformation:NSLocalizedString(@"Exceeded number of maximum group members",@"")];
                    //END WK Temp
                }
                else {
                    [self.selectedIndexArray addObject:objectString];
                    [contactTableViewCell isCellSelected:YES];
                }
            }
            
            //check array count
            [self validateSelectedIndexArray];
        
//        [self.createGroupView.contactsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//        }
    }
    else if (tableView == self.createGroupView.searchResultTableView) {
        //Contacts
    }
}

#pragma mark UICollectionView
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != 0) { //WK Note : indexPath.row 0 is group admin
        NSString *objectString = [self.selectedIndexArray objectAtIndex:indexPath.row - 1];
        NSArray *objectStringSplitArray = [objectString componentsSeparatedByString:@" - "];
        NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForItem:[[objectStringSplitArray objectAtIndex:1] integerValue] inSection:[[objectStringSplitArray objectAtIndex:0] integerValue]];
        [self.selectedIndexArray removeObjectAtIndex:indexPath.row - 1];
        
        TAPContactTableViewCell *contactTableViewCell = [self.createGroupView.contactsTableView cellForRowAtIndexPath:selectedIndexPath];
        [contactTableViewCell isCellSelected:NO];
        
        [self validateSelectedIndexArray];
    }
    
//    [self.createGroupView.contactsTableView reloadRowsAtIndexPaths:@[selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark TextField
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.createGroupView.searchBarView.searchTextField) {
        [self.createGroupView showOverlayView:YES];
        [UIView animateWithDuration:0.3f animations:^{
            CGRect searchBarViewFrame = self.createGroupView.searchBarView.frame;
            searchBarViewFrame.size.width = CGRectGetWidth(self.createGroupView.searchBarView.frame) - 70.0f;
            self.createGroupView.searchBarView.frame = searchBarViewFrame;
            
            CGRect searchBarCancelButtonFrame = self.createGroupView.searchBarCancelButton.frame;
            searchBarCancelButtonFrame.origin.x = CGRectGetMaxX(searchBarViewFrame) + 8.0f;
            searchBarCancelButtonFrame.size.width = 70.0f;
            self.createGroupView.searchBarCancelButton.frame = searchBarCancelButtonFrame;
        } completion:^(BOOL finished) {
            //completion
        }];
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self.createGroupView showOverlayView:YES];
    [UIView animateWithDuration:0.2f animations:^{
        self.createGroupView.searchResultTableView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        //completion
    }];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([newString length] <= 0) {
        [self.createGroupView showOverlayView:YES];
        [UIView animateWithDuration:0.2f animations:^{
            self.createGroupView.searchResultTableView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            //completion
        }];
    }
    else {
        [self.createGroupView showOverlayView:NO];
        [UIView animateWithDuration:0.2f animations:^{
            self.createGroupView.searchResultTableView.alpha = 1.0f;
        } completion:^(BOOL finished) {
            //completion
        }];
    }
    
    return YES;
}

#pragma mark - Custom Method
- (void)validateSelectedIndexArray {
    if ([self.selectedIndexArray count] > 0) {
        [self.createGroupView showSelectedContacts:YES];
        self.createGroupView.selectedContactsTitleLabel.text = [NSString stringWithFormat:@"Group Members (%ld/%ld)", [self.selectedIndexArray count] + 1, kMaxGroupMember + 1];
        
        [self.createGroupView.selectedContactsCollectionView reloadData];
    }
    else {
        [self.createGroupView showSelectedContacts:NO];
        self.createGroupView.selectedContactsTitleLabel.text = [NSString stringWithFormat:@"Group Members (1/%ld)", kMaxGroupMember + 1];
    }
}

- (void)continueButtonDidTapped {
    TAPCreateGroupSubjectViewController *createGroupSubjectViewController = [[TAPCreateGroupSubjectViewController alloc] init];
    createGroupSubjectViewController.groupModel = self.groupModel;
    [self.navigationController pushViewController:createGroupSubjectViewController animated:YES];
}

- (void)popUpInfoTappedSingleButtonOrRightButton {
    [self showPopupView:NO withPopupType:TAPPopUpInfoViewControllerTypeErrorMessage title:@"" detailInformation:@""];
}

@end
