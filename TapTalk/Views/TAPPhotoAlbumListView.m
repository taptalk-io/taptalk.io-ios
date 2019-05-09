//
//  TAPPhotoAlbumListView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 30/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPPhotoAlbumListView.h"

@interface TAPPhotoAlbumListView ()

@property (strong, nonatomic) UIView *chooseItemView;
@property (strong, nonatomic) UILabel *chooseItemLabel;
@property (strong, nonatomic) UIView *selectedItemView;
@property (strong, nonatomic) UILabel *selectedItemLabel;

@end

@implementation TAPPhotoAlbumListView

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if(self) {
        
        _chooseItemView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), 38.0f)];
        self.chooseItemView.backgroundColor = [TAPUtil getColor:@"F3F3F3"];
        [self addSubview:self.chooseItemView];
        
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.chooseItemView.frame) - 1.0f, CGRectGetWidth(self.chooseItemView.frame), 1.0f)];
        separatorView.backgroundColor = [TAPUtil getColor:@"C8C7CC"];
        [self.chooseItemView addSubview:separatorView];
        
        _chooseItemLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 14.0f, CGRectGetWidth(self.frame) - 16.0f - 16.0f, 18.0f)];
        self.chooseItemLabel.font = [UIFont fontWithName:TAP_FONT_NAME_REGULAR size:11.0f];
        self.chooseItemLabel.textColor = [TAPUtil getColor:@"8E8E93"];
        self.chooseItemLabel.text = NSLocalizedString(@"Please choose 5 items to upload", @"");
        [self.chooseItemView addSubview:self.chooseItemLabel];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.chooseItemView.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        
        if (IS_IPHONE_X_FAMILY) {
            self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, [TAPUtil safeAreaBottomPadding] + 30.0f, 0.0f);
        }
        else {
            self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, [TAPUtil safeAreaBottomPadding], 0.0f);
        }
        
        self.tableView.separatorInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        self.tableView.separatorColor = [UIColor clearColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (IS_IOS_11_OR_ABOVE) {
            [self.tableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        }
        [self addSubview:self.tableView];
    
        self.tableView.backgroundColor = [UIColor clearColor];
        
    }
    
    return self;
}

#pragma mark - Custom Method
- (void)setChooseItemLabelWithItemCount:(NSInteger)count {
//    if(count < 5) {
//        NSInteger itemLeft = 5 - count;
//        NSString *pleaseChooseString = NSLocalizedString(@"Please choose", @"");
//        NSString *itemsString = NSLocalizedString(@"more items", @"");
//        NSString *toUploadString = NSLocalizedString(@"to upload", @"");
//        NSString *remainingItemString = [NSString stringWithFormat:@"%ld", (long)itemLeft];
//
//        if(itemLeft > 1) {
//            itemsString = NSLocalizedString(@"more items", @"");
//        }
//        else {
//            itemsString = NSLocalizedString(@"more item", @"");
//        }
//
//        self.chooseItemLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@", pleaseChooseString, remainingItemString, itemsString, toUploadString];
//    }
//    else {
//        self.chooseItemLabel.text = NSLocalizedString(@"Please choose 5 items to upload", @"");
//    }
    
    self.chooseItemLabel.text = NSLocalizedString(@"Please choose media to upload", @"");
}
@end
