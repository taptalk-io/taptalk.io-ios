//
//  TAPBlockedListViewController.m
//  TapTalk
//
//  Created by Dominic Vedericho on 14/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBlockedListViewController.h"
#import "TAPBlockedListView.h"
#import "TAPContactTableViewCell.h"

@interface TAPBlockedListViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) TAPBlockedListView *blockedListView;
@end

@implementation TAPBlockedListViewController

#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    _blockedListView = [[TAPBlockedListView alloc] initWithFrame:[TAPBaseView frameWithNavigationBar]];
    [self.view addSubview:self.blockedListView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"Blocked List", @"");
    [self showCustomBackButton];

    self.blockedListView.tableView.delegate = self;
    self.blockedListView.tableView.dataSource = self;
    self.blockedListView.tableView.contentInset = UIEdgeInsetsMake(8.0f, 0.0f, 0.0f, 0.0f);
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Data Source
#pragma mark TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *cellID = @"TAPContactTableViewCell";
        TAPContactTableViewCell *cell = [[TAPContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        [cell setContactTableViewCellWithUser:[TAPUserModel new]]; //WK Temp
        [cell isRequireSelection:NO];
        
        if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
            [cell showSeparatorLine:YES separatorLineType:TAPContactTableViewCellSeparatorTypeFull];
        }
        else {
            [cell showSeparatorLine:YES separatorLineType:TAPContactTableViewCellSeparatorTypeDefault];
        }
        
        return cell;
    }
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
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

#pragma mark - Delegate
#pragma mark TableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Custom Method

@end
