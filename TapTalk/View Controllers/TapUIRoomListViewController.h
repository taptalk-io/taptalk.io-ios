//
//  TapUIRoomListViewController.h
//  TapTalk
//
//  Created by Dominic Vedericho on 6/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseViewController.h"

@protocol TapUIRoomListViewControllerLifecycleDelegate <NSObject>
    
@optional
- (void)TapUIRoomListViewControllerLoadView;
- (void)TapUIRoomListViewControllerViewDidLoad;
- (void)TapUIRoomListViewControllerViewWillAppear;
- (void)TapUIRoomListViewControllerViewWillDisappear;
- (void)TapUIRoomListViewControllerViewDidAppear;
- (void)TapUIRoomListViewControllerViewDidDisappear;
- (void)TapUIRoomListViewControllerDealloc;
- (void)TapUIRoomListViewControllerDidReceiveMemoryWarning;
@end

@interface TapUIRoomListViewController : TAPBaseViewController

@property (nonatomic) BOOL isViewAppear;
@property (nonatomic) BOOL isShouldNotLoadFromAPI;
@property (weak, nonatomic) id<TapUIRoomListViewControllerLifecycleDelegate> lifecycleDelegate;

- (void)viewLoadedSequence;
- (void)setMyAccountButtonInRoomListVisible:(BOOL)isVisible;

@end
