//
//  TAPSearchResultChatTableViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 22/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPSearchResultChatTableViewCell : TAPBaseTableViewCell
- (void)setSearchResultChatTableViewCellWithData:(TAPRoomModel *)room
                                  searchedString:(NSString *)searchedString
                          numberOfUnreadMessages:(NSString *)unreadMessageCount
                                      hasMention:(BOOL)hasMention;
- (void)hideSeparatorView:(BOOL)isHide;
- (void)showUnreadMentionBadge:(BOOL)isShow;

@end

NS_ASSUME_NONNULL_END
