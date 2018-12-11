//
//  TAPProfileCollectionViewCell.h
//  TapTalk
//
//  Created by Welly Kencana on 31/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPProfileCollectionViewCellType) {
    profileCollectionViewCellTypeNotification = 1,
    profileCollectionViewCellTypeConversationColor = 2,
    profileCollectionViewCellTypeBlock = 3,
    profileCollectionViewCellTypeClearChat = 4,
};

@interface TAPProfileCollectionViewCell : TAPBaseCollectionViewCell

- (void)showSeparatorView:(BOOL)isShowed;
- (void)setProfileCollectionViewCellType:(TAPProfileCollectionViewCellType) type;

@end

NS_ASSUME_NONNULL_END
