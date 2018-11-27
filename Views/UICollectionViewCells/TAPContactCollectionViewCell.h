//
//  TAPContactCollectionViewCell.h
//  TapTalk
//
//  Created by Welly Kencana on 18/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseCollectionViewCell.h"

@interface TAPContactCollectionViewCell : TAPBaseCollectionViewCell

- (void)setContactCollectionViewCellWithModel:(NSString *)nantiDigantiJadiModel;
- (void)showRemoveIcon:(BOOL)isVisible;

@end
