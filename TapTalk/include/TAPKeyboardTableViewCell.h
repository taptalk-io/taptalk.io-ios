//
//  TAPKeyboardTableViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 10/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseXIBTableViewCell.h"
#import "TAPCustomKeyboardItemModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPKeyboardTableViewCell : TAPBaseXIBTableViewCell

- (void)setKeyboardCellWithKeyboardItem:(TAPCustomKeyboardItemModel *)keyboardItem;

@end

NS_ASSUME_NONNULL_END
