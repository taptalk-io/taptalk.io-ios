//
//  TAPProfileCollectionViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 31/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPProfileCollectionViewCellType) {
    profileCollectionViewCellTypeNotification = 1,
    profileCollectionViewCellTypeConversationColor = 2,
    profileCollectionViewCellTypeBlock = 3,
    profileCollectionViewCellTypeClearChat = 4,
    profileCollectionViewCellTypeLeaveGroup = 5,
    profileCollectionViewCellTypeDeleteGroup = 6,
    profileCollectionViewCellTypeViewGroupMembers = 7,
    profileCollectionViewCellTypeAddContacts = 8,
    profileCollectionViewCellTypeSendMessage = 9,
    profileCollectionViewCellTypeAppointAsAdmin = 10,
    profileCollectionViewCellTypeRemoveMember = 11,
    profileCollectionViewCellTypeRemoveFromAdmin = 12,
    profileCollectionViewCellTypeReportUser = 13,
    profileCollectionViewCellTypeReportGroup = 14,
};

@interface TAPProfileCollectionViewCell : TAPBaseCollectionViewCell

- (void)showSeparatorView:(BOOL)isShowed;
- (void)setProfileCollectionViewCellType:(TAPProfileCollectionViewCellType) type;

@end

NS_ASSUME_NONNULL_END
