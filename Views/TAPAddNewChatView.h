//
//  AddNewChatView.h
//  TapTalk
//
//  Created by Welly Kencana on 13/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseView.h"

@interface TAPAddNewChatView : TAPBaseView

@property (strong, nonatomic) UIView *searchBarBackgroundView;
@property (strong, nonatomic) TAPSearchBarView *searchBarView;
//@property (strong, nonatomic) UITextField *searchBarTextField;
@property (strong, nonatomic) UIButton *searchBarCancelButton;
@property (strong, nonatomic) UITableView *contactsTableView;
@property (strong, nonatomic) UITableView *searchResultTableView;

- (void)showOverlayView:(BOOL)isVisible;

@end
