//
//  TAPPhotoAlbumListView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 30/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseView.h"
#import "TAPBaseTableView.h"

@interface TAPPhotoAlbumListView : TAPBaseView

@property (strong, nonatomic) TAPBaseTableView *tableView;
@property (strong, nonatomic) TAPBaseTableView *selectedItemCollectionView;

@end
