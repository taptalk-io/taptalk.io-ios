//
//  TAPSystemMessageTableViewCell.h
//  TapTalk
//
//  Created by Cundy Sunardy on 12/06/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseXIBRotatedTableViewCell.h"
#import "TAPMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPSystemMessageTableViewCell : TAPBaseXIBRotatedTableViewCell

- (void)setMessage:(TAPMessageModel *)message;

@end

NS_ASSUME_NONNULL_END
