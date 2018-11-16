//
//  TAPRoomListViewController.h
//  TapTalk
//
//  Created by Welly Kencana on 6/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseViewController.h"

@interface TAPRoomListViewController : TAPBaseViewController

@property (nonatomic) BOOL isViewAppear;
@property (nonatomic) BOOL isShouldNotLoadFromAPI;

- (void)viewLoadedSequence;

@end
