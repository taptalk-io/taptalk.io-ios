//
//  TAPBaseTableViewCell.h
//  Moselo
//
//  Created by Ritchie Nathaniel on 2/16/17.
//  Copyright © 2017 Moselo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TAPBaseTableViewCellDelegate <NSObject>

@optional

- (void)baseTableViewCellDidRequestRefreshCellHeight;

@end

@interface TAPBaseTableViewCell : UITableViewCell

@property (weak, nonatomic) id<TAPBaseTableViewCellDelegate> delegate;

- (void)setGrayHighlightColor;
- (void)setOrangeHighlightColor;
- (void)setHighlightColor:(UIColor *)color;
- (UITableView * _Nullable)getTableView;
- (void)refreshCellHeight;

@end
