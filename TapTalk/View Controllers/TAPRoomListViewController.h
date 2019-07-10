//
//  TAPRoomListViewController.h
//  TapTalk
//
//  Created by Dominic Vedericho on 6/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseViewController.h"

@protocol TAPRoomListViewControllerLifecycleDelegate <NSObject>
    
@optional
- (void)TAPRoomListViewControllerLoadView;
- (void)TAPRoomListViewControllerViewDidLoad;
- (void)TAPRoomListViewControllerViewWillAppear;
- (void)TAPRoomListViewControllerViewWillDisappear;
- (void)TAPRoomListViewControllerViewDidAppear;
- (void)TAPRoomListViewControllerViewDidDisappear;
- (void)TAPRoomListViewControllerDealloc;
- (void)TAPRoomListViewControllerDidReceiveMemoryWarning;
@end

@interface TAPRoomListViewController : TAPBaseViewController

@property (nonatomic) BOOL isViewAppear;
@property (nonatomic) BOOL isShouldNotLoadFromAPI;
@property (weak, nonatomic) id<TAPRoomListViewControllerLifecycleDelegate> lifecycleDelegate;


- (void)viewLoadedSequence;

@end
