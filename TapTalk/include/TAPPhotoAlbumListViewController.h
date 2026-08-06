//
//  TAPPhotoAlbumListViewController.h
//  TapTalk
//
//  Created by Dominic Vedericho on 30/12/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseViewController.h"

typedef NS_ENUM(NSInteger, TAPPhotoAlbumListViewControllerType) {
    TAPPhotoAlbumListViewControllerTypeDefault = 0,
    TAPPhotoAlbumListViewControllerTypeAddMore = 1
};

@protocol TAPPhotoAlbumListViewControllerDelegate <NSObject>

- (void)photoAlbumListViewControllerSelectImageWithDataArray:(NSArray *)dataArray;
- (void)photoAlbumListViewControllerDidFinishAndSendImageWithDataArray:(NSArray *)dataArray;

@end

@interface TAPPhotoAlbumListViewController : TAPBaseViewController

@property (weak, nonatomic) id <TAPPhotoAlbumListViewControllerDelegate> delegate;
@property (nonatomic) TAPPhotoAlbumListViewControllerType photoAlbumListViewControllerType;
@property (strong, nonatomic) NSMutableArray *selectedMediaDataArray;
@property (strong, nonatomic) NSMutableDictionary *selectedImagePositionDictionary; //dictionary key format albumsection-albumrow-imagerow ex:1-2-3

@property (nonatomic) BOOL isNotFromPersonalRoom;
@property (strong, nonatomic) NSArray *participantListArray;

- (void)setPhotoAlbumListViewControllerType:(TAPPhotoAlbumListViewControllerType)photoAlbumListViewControllerType;

@end
