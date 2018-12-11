//
//  TAPBaseXIBTableViewCell.h
//  Moselo
//
//  Created by Ritchie Nathaniel on 3/6/17.
//  Copyright © 2017 Moselo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TAPBaseXIBTableViewCell : UITableViewCell

+ (UINib *)cellNib;
- (CGFloat)automaticHeight;

@end
