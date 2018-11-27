//
//  TAPSearchResultMessageTableViewCell.h
//  TapTalk
//
//  Created by Welly Kencana on 16/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseTableViewCell.h"
#import "TAPRoomListModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPSearchResultMessageStatusType) {
    TAPSearchResultMessageStatusTypeNone = 0,
    TAPSearchResultMessageStatusTypeSending = 1,
    TAPSearchResultMessageStatusTypeSent = 2,
    TAPSearchResultMessageStatusTypeDelivered = 3,
    TAPSearchResultMessageStatusTypeRead = 4,
    TAPSearchResultMessageStatusTypeFailed = 5,
};

@interface TAPSearchResultMessageTableViewCell : TAPBaseTableViewCell

- (void)setSearchResultMessageTableViewCell:(TAPMessageModel *)message
                             searchedString:(NSString *)searchedString;

@end

NS_ASSUME_NONNULL_END
