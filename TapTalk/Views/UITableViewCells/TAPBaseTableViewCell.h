//
//  TAPBaseTableViewCell.h
//  Moselo
//
//  Created by Ritchie Nathaniel on 2/16/17.
//  Copyright © 2017 Moselo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TAPBaseTableViewCell : UITableViewCell

- (void)setGrayHighlightColor;
- (void)setOrangeHighlightColor;
- (void)setHighlightColor:(UIColor *)color;
- (UITableView * _Nullable)getTableView;
- (void)refreshCellHeight;

@end
