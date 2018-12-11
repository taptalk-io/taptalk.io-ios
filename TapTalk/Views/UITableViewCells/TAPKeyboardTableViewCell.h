//
//  TAPKeyboardTableViewCell.h
//  TapTalk
//
//  Created by Welly Kencana on 10/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseXIBTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPKeyboardTableViewCellType) {
    TAPKeyboardTableViewCellTypePriceList = 1,
    TAPKeyboardTableViewCellTypeExpertNotes = 2,
    TAPKeyboardTableViewCellTypeSendService = 3,
    TAPKeyboardTableViewCellTypeCreateOrderCard = 4,
};

@interface TAPKeyboardTableViewCell : TAPBaseXIBTableViewCell

- (void)setKeyboardCellWithType:(TAPKeyboardTableViewCellType)type;
- (void)setKeyboardCellWithKeyboardItem:(TAPCustomKeyboardItemModel *)keyboardItem;

@end

NS_ASSUME_NONNULL_END
