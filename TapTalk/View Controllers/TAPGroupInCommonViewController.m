//
//  TAPGroupInCommonViewController.m
//  TapTalk
//
//  Created by TapTalk.io on 07/11/22.
//

#import "TAPGroupInCommonViewController.h"
#import "TAPContactTableViewCell.h"
#import "PowerTalk.h"

@interface TAPGroupInCommonViewController () <UITableViewDataSource, UITableViewDelegate>
@property (unsafe_unretained, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *emptyView;
@property (strong, nonatomic) NSArray *groupsInCommonRoom;
@end

@implementation TAPGroupInCommonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.otherUser == nil || self.otherUser.userID == nil) {
        [self.navigationController popViewControllerAnimated:NO];
        return;
    }
    
    self.title = NSLocalizedStringFromTableInBundle(self.otherUser.fullname, nil, [TAPUtil currentBundle], @"");
    [self showCustomBackButton];
    
    _groupsInCommonRoom = [NSArray new];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.delaysContentTouches = NO;
    self.view.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
    
    [TAPDataManager callAPIGetGroupsInCommon:self.otherUser.userID success:^(NSMutableArray<TAPRoomModel *> *groupsInCommonRoom) {
        self.groupsInCommonRoom = groupsInCommonRoom;
        
        if(groupsInCommonRoom.count == 0) {
            self.emptyView.alpha = 1.0f;
        }
        
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - Data Source
#pragma mark TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.groupsInCommonRoom count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *cellID = @"TAPContactTableViewCell";
        TAPContactTableViewCell *cell = [[TAPContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        TAPRoomModel *room = [self.groupsInCommonRoom objectAtIndex:indexPath.row];
        [cell setContactTableViewCellWithRoom:room]; //WK Temp
        [cell setContactTableViewCellType:TAPContactTableViewCellTypeDefault];
        [cell isRequireSelection:NO];
        
        if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] - 1) {
            [cell showSeparatorLine:YES separatorLineType:TAPContactTableViewCellSeparatorTypeFull];
        }
        else {
            [cell showSeparatorLine:YES separatorLineType:TAPContactTableViewCellSeparatorTypeDefault];
        }
        [cell setGrayHighlightColor];
        return cell;
    }
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 23.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] init];
    
    header.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.05f];
    
    UILabel *headerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, 300.0f, 23.0f)];
    
    NSString *groupString = @"GROUP";
    
    if(self.groupsInCommonRoom.count > 1) {
        groupString = @"GROUPS";
    }
    
    NSString *headerTitleString = [NSString stringWithFormat:@"%ld %@ IN COMMON", self.groupsInCommonRoom.count, groupString];
    
    headerTitleLabel.text = headerTitleString;
    headerTitleLabel.font =  [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontTableViewSectionHeaderLabel];
    headerTitleLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
    
    if(self.groupsInCommonRoom.count == 0) {
        headerTitleLabel.hidden = YES;
    }
    else {
        headerTitleLabel.hidden = NO;
    }
    
    [header addSubview:headerTitleLabel];
    
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TAPRoomModel *room = [self.groupsInCommonRoom objectAtIndex:indexPath.row];
    
    [[TapUI sharedInstance] createRoomWithRoom:room success:^(TapUIChatViewController * _Nonnull chatViewController) {
        chatViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chatViewController animated:YES];
    }];
}

#pragma mark - Custom Method

@end
