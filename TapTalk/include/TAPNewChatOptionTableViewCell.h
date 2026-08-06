//
//  TAPNewChatOptionTableViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 13/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseTableViewCell.h"

typedef NS_ENUM(NSInteger, TAPNewChatOptionTableViewCellType) {
    TAPNewChatOptionTableViewCellTypeNewContact = 1,
    TAPNewChatOptionTableViewCellTypeScanQRCode = 2,
    TAPNewChatOptionTableViewCellTypeNewGroup = 3,
};

@interface TAPNewChatOptionTableViewCell : TAPBaseTableViewCell

- (void)setNewChatOptionTableViewCellType:(TAPNewChatOptionTableViewCellType)type;

@end
