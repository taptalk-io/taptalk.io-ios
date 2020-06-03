//
//  TAPMentionListTableViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 13/05/20.
//  Copyright © 2020 Moselo. All rights reserved.
//

#import "TAPBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPMentionListTableViewCell : TAPBaseTableViewCell

- (void)setMentionListCellWithUser:(TAPUserModel *)user;
- (void)showSeparatorView:(BOOL)show;

@end

NS_ASSUME_NONNULL_END
