//
//  TAPMentionListXIBTableViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 13/05/20.
//  Copyright © 2020 Moselo. All rights reserved.
//

#import "TAPBaseXIBTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPMentionListXIBTableViewCell : TAPBaseXIBTableViewCell

- (void)setMentionListCellWithUser:(TAPUserModel *)user;
- (void)showSeparatorView:(BOOL)show;

@end

NS_ASSUME_NONNULL_END
