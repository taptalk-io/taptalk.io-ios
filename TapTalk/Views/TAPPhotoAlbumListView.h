//
//  TAPPhotoAlbumListView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 30/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseView.h"

@interface TAPPhotoAlbumListView : TAPBaseView

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UITableView *selectedItemCollectionView;

- (void)setChooseItemLabelWithItemCount:(NSInteger)count;

@end
