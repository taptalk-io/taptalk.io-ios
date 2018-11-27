//
//  TAPKeyboardViewController.m
//  TapTalk
//
//  Created by Welly Kencana on 10/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPKeyboardViewController.h"
#import "TAPKeyboardTableViewCell.h"

@interface TAPKeyboardViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIInputView *customInputView;

@end

@implementation TAPKeyboardViewController
#pragma mark - Lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.inputView = self.customInputView;
    self.inputView.autoresizingMask = UIViewAutoresizingNone;
    self.inputView.allowsSelfSizing = YES;
    self.view.autoresizingMask = UIViewAutoresizingNone;
    self.customInputViewHeightConstraint.constant = self.keyboardHeight;
}

#pragma mark - Data Source
#pragma mark TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4; //WK Temp
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView registerNib:[TAPKeyboardTableViewCell cellNib] forCellReuseIdentifier:[TAPKeyboardTableViewCell description]];
    TAPKeyboardTableViewCell *cell = (TAPKeyboardTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[TAPKeyboardTableViewCell description]];
    if (indexPath.row == 0) {
        [cell setKeyboardCellWithType:TAPKeyboardTableViewCellTypePriceList];
    }
    else if (indexPath.row == 1) {
        [cell setKeyboardCellWithType:TAPKeyboardTableViewCellTypeExpertNotes];
    }
    else if (indexPath.row == 2) {
        [cell setKeyboardCellWithType:TAPKeyboardTableViewCellTypeSendService];
    }
    else if (indexPath.row == 3) {
        [cell setKeyboardCellWithType:TAPKeyboardTableViewCellTypeCreateOrderCard];
    }
    
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
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.delegate respondsToSelector:@selector(keyboardViewControllerDidSelectRowAtIndexPath:)]) {
        [self.delegate keyboardViewControllerDidSelectRowAtIndexPath:indexPath];
    }
}

#pragma mark - Custom Method
- (void)setKeyboardHeight:(CGFloat)keyboardHeight {
    _keyboardHeight = keyboardHeight;
    self.customInputViewHeightConstraint.constant = self.keyboardHeight;
}

@end
