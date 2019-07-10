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
    profileCollectionViewCellTypeViewGroupMembers = 6,
    profileCollectionViewCellTypeAddContacts = 7,
    profileCollectionViewCellTypeSendMessage = 8,
    profileCollectionViewCellTypeAppointAsAdmin = 9,
    profileCollectionViewCellTypeRemoveMember = 10,
    profileCollectionViewCellTypeRemoveFromAdmin = 11
};

@interface TAPProfileCollectionViewCell : TAPBaseCollectionViewCell

- (void)showSeparatorView:(BOOL)isShowed;
- (void)setProfileCollectionViewCellType:(TAPProfileCollectionViewCellType) type;

@end

NS_ASSUME_NONNULL_END
