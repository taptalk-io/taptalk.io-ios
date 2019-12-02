//
//  TAPContactTableViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 13/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseTableViewCell.h"

typedef NS_ENUM(NSInteger, TAPContactTableViewCellSeparatorType) {
    TAPContactTableViewCellSeparatorTypeDefault,
    TAPContactTableViewCellSeparatorTypeFull,
};

typedef NS_ENUM(NSInteger, TAPContactTableViewCellType) {
    TAPContactTableViewCellTypeDefault, //Without username
    TAPContactTableViewCellTypeWithUsername,
};

@interface TAPContactTableViewCell : TAPBaseTableViewCell

@property (nonatomic) TAPContactTableViewCellType contactTableViewCellType;
- (void)setContactTableViewCellType:(TAPContactTableViewCellType)contactTableViewCellType;

- (void)setContactTableViewCellWithUser:(TAPUserModel *)user;
- (void)isRequireSelection:(BOOL)isRequired;
- (void)isCellSelected:(BOOL)isSelected;
- (void)showSeparatorLine:(BOOL)isVisible separatorLineType:(TAPContactTableViewCellSeparatorType)separatorType;
- (void)showAdminIndicator:(BOOL)show;

@end
