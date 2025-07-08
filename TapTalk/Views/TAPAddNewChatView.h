//
//  AddNewChatView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 13/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseView.h"
#import "TAPCustomButtonView.h"

typedef NS_ENUM(NSInteger, TAPSyncNotificationViewType) {
    TAPSyncNotificationViewTypeSyncing,
    TAPSyncNotificationViewTypeSynced
};

@interface TAPAddNewChatView : TAPBaseView

@property (strong, nonatomic) UIView *searchBarBackgroundView;
@property (strong, nonatomic) TAPSearchBarView *searchBarView;
//@property (strong, nonatomic) UITextField *searchBarTextField;
@property (strong, nonatomic) UIButton *searchBarCancelButton;
@property (strong, nonatomic) TAPBaseTableView *contactsTableView;
@property (strong, nonatomic) TAPBaseTableView *searchResultTableView;
@property (strong, nonatomic) TapHighlightCustomButtonView *syncButton;

- (void)showOverlayView:(BOOL)isVisible;
- (void)showSyncContactButtonView:(BOOL)show;
- (void)showSyncNotificationWithString:(NSString *)string type:(TAPSyncNotificationViewType)type;
- (void)hideSyncNotification;

@end
