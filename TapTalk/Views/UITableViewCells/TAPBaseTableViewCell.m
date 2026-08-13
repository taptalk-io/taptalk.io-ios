//
//  TAPBaseTableViewCell.m
//  Moselo
//
//  Created by Ritchie Nathaniel on 2/16/17.
//  Copyright © 2017 Moselo. All rights reserved.
//

#import "TAPBaseTableViewCell.h"
#import "PowerTalk.h"

@interface TAPBaseTableViewCell ()

@property (strong, nonatomic) UITableView *tableView;

@end

@implementation TAPBaseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setGrayHighlightColor {
    [self setHighlightColor:[TAPUtil getColor:TAP_COLOR_BLACK_19 withAlpha:0.2f]];
}

- (void)setOrangeHighlightColor {
    [self setHighlightColor:[[[TAPStyleManager sharedManager] getDefaultColorForType:TAPDefaultColorPrimary] colorWithAlphaComponent:0.18f]];
}

- (void)setHighlightColor:(UIColor *)color {
    [self setSelectionStyle:UITableViewCellSelectionStyleDefault];
    [self setSelectedBackgroundView:[[UIView alloc] init]];
    self.selectedBackgroundView.backgroundColor = color;
}

- (UITableView * _Nullable)getTableView {
    if (self.tableView != nil) {
        return self.tableView;
    }
    id view = [self superview];
    while (view && [view isKindOfClass:[UITableView class]] == NO) {
        view = [view superview];
    }
    if (view != nil && [view isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)view;
        _tableView = tableView;
        return tableView;
    }
    return nil;
}

- (void)refreshCellHeight {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(baseTableViewCellDidRequestRefreshCellHeight)]) {
        [self.delegate baseTableViewCellDidRequestRefreshCellHeight];
        return;
    }
    UITableView *tableView = [self getTableView];
    if (tableView != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            [tableView reloadData];
            [tableView beginUpdates];
            [tableView endUpdates];

        });
    }
}

@end
