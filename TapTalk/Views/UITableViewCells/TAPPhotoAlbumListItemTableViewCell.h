//
//  TAPPhotoAlbumListItemTableViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 30/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseTableViewCell.h"

@interface TAPPhotoAlbumListItemTableViewCell : TAPBaseTableViewCell

- (void)showSeparatorView:(BOOL)show;
- (void)setDataWithName:(NSString *)name total:(NSInteger)total selectedCount:(NSInteger)selectedCount;
@end
