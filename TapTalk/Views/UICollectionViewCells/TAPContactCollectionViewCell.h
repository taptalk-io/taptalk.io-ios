//
//  TAPContactCollectionViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 18/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseCollectionViewCell.h"

@interface TAPContactCollectionViewCell : TAPBaseCollectionViewCell

- (void)setContactCollectionViewCellWithModel:(TAPUserModel *)user;
- (void)showRemoveIcon:(BOOL)isVisible;

@end
