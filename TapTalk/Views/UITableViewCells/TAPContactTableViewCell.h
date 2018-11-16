//
//  TAPContactTableViewCell.h
//  TapTalk
//
//  Created by Welly Kencana on 13/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseTableViewCell.h"

@interface TAPContactTableViewCell : TAPBaseTableViewCell

- (void)setContactTableViewCellWithUser:(TAPUserModel *)user;
- (void)isRequireSelection:(BOOL)isRequired;
- (void)isCellSelected:(BOOL)isSelected;
- (void)showSeparatorLine:(BOOL)isVisible;

@end
