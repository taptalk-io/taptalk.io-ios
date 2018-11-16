//
//  TAPCreateGroupView.h
//  TapTalk
//
//  Created by Welly Kencana on 17/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseView.h"

@interface TAPCreateGroupView : TAPBaseView

@property (strong, nonatomic) UIView *searchBarBackgroundView;
@property (strong, nonatomic) TAPSearchBarView *searchBarView;
//@property (strong, nonatomic) UITextField *searchBarTextField;
@property (strong, nonatomic) UIButton *searchBarCancelButton;
@property (strong, nonatomic) UITableView *contactsTableView;
@property (strong, nonatomic) UITableView *searchResultTableView;

@property (strong, nonatomic) UIView *selectedContactsView;
@property (strong, nonatomic) UILabel *selectedContactsTitleLabel;
@property (strong, nonatomic) UICollectionView *selectedContactsCollectionView;
@property (strong, nonatomic) UIButton *continueButton;

- (void)searchBarCancelButtonDidTapped;
- (void)showSelectedContacts:(BOOL)isVisible;
- (void)showOverlayView:(BOOL)isVisible;

@end
