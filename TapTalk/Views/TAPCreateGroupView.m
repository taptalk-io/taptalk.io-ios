//
//  TAPCreateGroupView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 17/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPCreateGroupView.h"

@interface TAPCreateGroupView()
@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UIView *overlayView;
@property (strong, nonatomic) UIButton *overlayButton;

@property (strong, nonatomic) UIView *bottomActionShadowView;
@property (strong, nonatomic) UIView *bottomActionView;

@property (strong, nonatomic) UIView *loadingView;
@property (strong, nonatomic) UIImageView *loadingImageView;
@property (strong, nonatomic) UILabel *loadingLabel;
@property (strong, nonatomic) UIButton *loadingButton;

@property (strong, nonatomic) UIView *loadingMembersView;
@property (strong, nonatomic) UIView *loadingMembersBackgroundView;
@property (strong, nonatomic) UILabel *loadingMemberLabel;
@property (strong, nonatomic) UIImageView *loadingMemberImageView;

- (void)animateMembersLoading:(BOOL)isAnimate;

@end

@implementation TAPCreateGroupView

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        self.bgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.bgView];
        
        _searchBarBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bgView.frame), 46.0f)];
        self.searchBarView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
        [self.bgView addSubview:self.searchBarBackgroundView];
        
        _searchBarView = [[TAPSearchBarView alloc] initWithFrame:CGRectMake(16.0f, 8.0f, CGRectGetWidth(self.searchBarBackgroundView.frame) - 16.0f - 16.0f, 30.0f)];
        self.searchBarView.customPlaceHolderString = NSLocalizedString(@"Search for people to add", @"");
        [self.searchBarBackgroundView addSubview:self.searchBarView];
        
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.searchBarBackgroundView.frame) - 1.0f, CGRectGetWidth(self.frame), 1.0f)];
        separatorView.backgroundColor = [TAPUtil getColor:TAP_COLOR_GREY_DC];
        [self.searchBarBackgroundView addSubview:separatorView];
        
        UIFont *searchBarCancelButtonFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontSearchBarTextCancelButton];
        UIColor *searchBarCancelButtonColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorSearchBarTextCancelButton];
        _searchBarCancelButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.searchBarView.frame) + 8.0f, 0.0f, 0.0f, CGRectGetHeight(self.searchBarBackgroundView.frame))];
        NSString *searchBarCancelString = NSLocalizedString(@"Cancel", @"");
        NSMutableAttributedString *searchBarCancelAttributedString = [[NSMutableAttributedString alloc] initWithString:searchBarCancelString];
        NSMutableDictionary *searchBarCancelAttributesDictionary = [NSMutableDictionary dictionary];
        float searchBarCancelLetterSpacing = -0.4f;
        [searchBarCancelAttributesDictionary setObject:@(searchBarCancelLetterSpacing) forKey:NSKernAttributeName];
        [searchBarCancelAttributesDictionary setObject:searchBarCancelButtonFont forKey:NSFontAttributeName];
        [searchBarCancelAttributesDictionary setObject:searchBarCancelButtonColor forKey:NSForegroundColorAttributeName];
        [searchBarCancelAttributedString addAttributes:searchBarCancelAttributesDictionary
                                                 range:NSMakeRange(0, [searchBarCancelString length])];
        [self.searchBarCancelButton setAttributedTitle:searchBarCancelAttributedString forState:UIControlStateNormal];
        self.searchBarCancelButton.clipsToBounds = YES;
        [self.searchBarCancelButton addTarget:self action:@selector(searchBarCancelButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.searchBarBackgroundView addSubview:self.searchBarCancelButton];
        
        _contactsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.searchBarBackgroundView.frame), CGRectGetWidth(self.bgView.frame), CGRectGetHeight(self.bgView.frame) - CGRectGetHeight(self.searchBarBackgroundView.frame)) style:UITableViewStylePlain];
        self.contactsTableView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
        self.contactsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.contactsTableView setSectionIndexColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTableViewSectionIndex]];
        [self.bgView addSubview:self.contactsTableView];
        
        _searchResultTableView = [[UITableView alloc] initWithFrame:self.contactsTableView.frame];
        self.searchResultTableView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
        self.searchResultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.searchResultTableView setSectionIndexColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTableViewSectionIndex]];
        self.searchResultTableView.alpha = 0.0f;
        [self.bgView addSubview:self.searchResultTableView];
        
        _selectedContactsShadowView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.contactsTableView.frame), CGRectGetWidth(self.bgView.frame), 190.0f)];
        self.selectedContactsShadowView.backgroundColor = [[TAPUtil getColor:@"191919"]colorWithAlphaComponent:0.1f];
        self.selectedContactsShadowView.layer.shadowOffset = CGSizeMake(0.0f, -1.0f);
        self.selectedContactsShadowView.layer.shadowOpacity = 1.0f;
        self.selectedContactsShadowView.layer.masksToBounds = NO;
        [self.bgView addSubview:self.selectedContactsShadowView];

        _selectedContactsView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.frame) - 190.0f - [TAPUtil safeAreaBottomPadding], CGRectGetWidth(self.bgView.frame), 190.0f + [TAPUtil safeAreaBottomPadding])];
        self.selectedContactsView.alpha = 0.0f;
        self.selectedContactsView.backgroundColor = [UIColor whiteColor];
        [self.bgView addSubview:self.selectedContactsView];
        
        UIFont *sectionHeaderLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontTableViewSectionHeaderLabel];
        UIColor *sectionHeaderLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorTableViewSectionHeaderLabel];
        _selectedContactsTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 16.0f, CGRectGetWidth(self.bgView.frame) - 16.0f - 16.0f, 13.0f)];
        self.selectedContactsTitleLabel.font = sectionHeaderLabelFont;
        self.selectedContactsTitleLabel.textColor = sectionHeaderLabelColor;
        [self.selectedContactsView addSubview:self.selectedContactsTitleLabel];
        
        UICollectionViewFlowLayout *collectionLayout = [[UICollectionViewFlowLayout alloc] init];
        collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _selectedContactsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.selectedContactsTitleLabel.frame) + 10.0f, CGRectGetWidth(self.selectedContactsView.frame), 74.0f) collectionViewLayout:collectionLayout];
        self.selectedContactsCollectionView.backgroundColor = [UIColor whiteColor];
        self.selectedContactsCollectionView.showsVerticalScrollIndicator = NO;
        self.selectedContactsCollectionView.showsHorizontalScrollIndicator = NO;
        [self.selectedContactsView addSubview:self.selectedContactsCollectionView];
        
        _continueButtonView = [[TAPCustomButtonView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.selectedContactsCollectionView.frame) + 16.0f, CGRectGetWidth(self.selectedContactsView.frame), 44.0f)];
        [self.continueButtonView setCustomButtonViewType:TAPCustomButtonViewTypeActive];
        [self.continueButtonView setCustomButtonViewStyleType:TAPCustomButtonViewStyleTypePlain];
        [self.continueButtonView setButtonWithTitle:NSLocalizedString(@"Continue", @"")];
        [self.selectedContactsView addSubview:self.continueButtonView];
        
        _bottomActionShadowView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.frame) - 74.0f - [TAPUtil safeAreaBottomPadding], CGRectGetWidth(self.bgView.frame), 74.0f)];
        self.bottomActionShadowView.backgroundColor = [[TAPUtil getColor:@"191919"]colorWithAlphaComponent:0.1f];
        self.bottomActionShadowView.layer.shadowOffset = CGSizeMake(0.0f, -1.0f);
        self.bottomActionShadowView.layer.shadowOpacity = 1.0f;
        self.bottomActionShadowView.layer.masksToBounds = NO;
        [self.bgView addSubview:self.bottomActionShadowView];
        
        _bottomActionView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.frame) - 74.0f - [TAPUtil safeAreaBottomPadding], CGRectGetWidth(self.bgView.frame), 74.0f + [TAPUtil safeAreaBottomPadding])];
        self.bottomActionView.alpha = 1.0f;
        self.bottomActionView.backgroundColor = [UIColor whiteColor];
        [self.bgView addSubview:self.bottomActionView];
        
        _addMembersButtonView = [[TAPCustomButtonView alloc] initWithFrame:CGRectMake(0.0f, 16.0f, CGRectGetWidth(self.bottomActionView.frame), 44.0f)];
        [self.addMembersButtonView setCustomButtonViewStyleType:TAPCustomButtonViewStyleTypeWithIcon];
        [self.addMembersButtonView setCustomButtonViewType:TAPCustomButtonViewTypeActive];
        [self.addMembersButtonView setButtonWithTitle:NSLocalizedString(@"Add Members", @"") andIcon:@"TAPIconAddMembers" iconPosition:TAPCustomButtonViewIconPosititonLeft];
        self.addMembersButtonView.alpha = 0.0f;
        [self.bottomActionView addSubview:self.addMembersButtonView];
        
        _removeMembersButtonView = [[TAPCustomButtonView alloc] initWithFrame:CGRectMake(0.0f, 16.0f, CGRectGetWidth(self.bottomActionView.frame), 44.0f)];
        [self.removeMembersButtonView setCustomButtonViewStyleType:TAPCustomButtonViewStyleTypeDestructiveWithIcon];
        [self.removeMembersButtonView setCustomButtonViewType:TAPCustomButtonViewTypeActive];
        [self.removeMembersButtonView setButtonWithTitle:NSLocalizedString(@"Remove Members", @"") andIcon:@"TAPIconRemoveMemberRed" iconPosition:TAPCustomButtonViewIconPosititonLeft];
        self.removeMembersButtonView.alpha = 0.0f;
        [self.bottomActionView addSubview:self.removeMembersButtonView];
        
        _promoteAdminButtonView = [[TAPCustomButtonView alloc] initWithFrame:CGRectMake(0.0f, 16.0f, CGRectGetWidth(self.bottomActionView.frame), 44.0f)];
        [self.promoteAdminButtonView setCustomButtonViewStyleType:TAPCustomButtonViewStyleTypeWithIcon];
        [self.promoteAdminButtonView setCustomButtonViewType:TAPCustomButtonViewTypeActive];
        [self.promoteAdminButtonView setButtonWithTitle:NSLocalizedString(@"Promote to Admin", @"") andIcon:@"TAPIconAppointAdminWhite" iconPosition:TAPCustomButtonViewIconPosititonLeft];
        self.promoteAdminButtonView.alpha = 0.0f;
        [self.bottomActionView addSubview:self.promoteAdminButtonView];
        
        _demoteAdminButtonView = [[TAPCustomButtonView alloc] initWithFrame:CGRectMake(0.0f, 16.0f, CGRectGetWidth(self.bottomActionView.frame), 44.0f)];
        [self.demoteAdminButtonView setCustomButtonViewStyleType:TAPCustomButtonViewStyleTypeWithIcon];
        [self.demoteAdminButtonView setCustomButtonViewType:TAPCustomButtonViewTypeActive];
        [self.demoteAdminButtonView setButtonWithTitle:NSLocalizedString(@"Demote from Admin", @"") andIcon:@"TAPIconDemoteWhite" iconPosition:TAPCustomButtonViewIconPosititonLeft];
        self.demoteAdminButtonView.alpha = 0.0f;
        [self.bottomActionView addSubview:self.demoteAdminButtonView];
        
        //Save Loading View
        _loadingBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds))];
        self.loadingBackgroundView.backgroundColor = [[TAPUtil getColor:@"04040F"] colorWithAlphaComponent:0.4f];
        self.loadingBackgroundView.alpha = 0.0;
//        [self addSubview:self.loadingBackgroundView]; //added to navigationBar view
        
        _loadingView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - 150.0f) / 2.0f, (CGRectGetHeight(self.frame) - 150.0f) / 2.0f, 160.0f, 160.0f)];
        self.loadingView.backgroundColor = [UIColor whiteColor];
        self.loadingView.layer.shadowRadius = 5.0f;
        self.loadingView.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.1f].CGColor;
        self.loadingView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        self.loadingView.layer.shadowOpacity = 1.0f;
        self.loadingView.layer.masksToBounds = NO;
        self.loadingView.layer.cornerRadius = 6.0f;
        self.loadingView.clipsToBounds = YES;
        [self.loadingBackgroundView addSubview:self.loadingView];
        
        _loadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.loadingView.frame) - 60.0f) / 2.0f, 28.0f, 60.0f, 60.0f)];
        [self.loadingView addSubview:self.loadingImageView];
        
        UIFont *popupLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontPopupLoadingLabel];
        UIColor *popupLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorPopupLoadingLabel];
        _loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(8.0f, CGRectGetMaxY(self.loadingImageView.frame) + 16.0f, CGRectGetWidth(self.loadingView.frame) - 8.0f - 8.0f, 20.0f)];
        self.loadingLabel.font = popupLabelFont;
        self.loadingLabel.textColor = popupLabelColor;
        self.loadingLabel.textAlignment = NSTextAlignmentCenter;
        [self.loadingView addSubview:self.loadingLabel];
        
        _loadingButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.loadingBackgroundView.frame), CGRectGetHeight(self.loadingBackgroundView.frame))];
        self.loadingButton.alpha = 0.0f;
        self.loadingButton.userInteractionEnabled = NO;
        [self.loadingBackgroundView addSubview:self.loadingButton];
        
        //Loading Members
        _loadingMembersView  = [[UIView alloc] initWithFrame:self.frame];
        self.loadingMembersView.backgroundColor = [UIColor clearColor];
        self.loadingMembersView.alpha = 0.0f;
        [self addSubview:self.loadingMembersView];
        
        _loadingMembersBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMinY(self.contactsTableView.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) + [TAPUtil safeAreaBottomPadding] - CGRectGetHeight(self.searchBarView.frame))];
        self.loadingMembersBackgroundView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
        [self.loadingMembersView addSubview:self.loadingMembersBackgroundView];
        
        _loadingMemberImageView = [[UIImageView alloc] initWithFrame:CGRectMake(110.0f, 183.0f, 20.0f, 20.0f)];
        self.loadingMemberImageView.image = [UIImage imageNamed:@"TAPIconImageSaving" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        //DV TEMP ICON - changing color
        [self.loadingMembersBackgroundView addSubview:self.loadingMemberImageView];

        UIColor *clickableLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorClickableLabel];
        UIFont *clickableLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontClickableLabel];
        
        _loadingMemberLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.loadingMemberImageView.frame) + 8.0f, CGRectGetMinY(self.loadingMemberImageView.frame)-1.0f, 200.0f, 22.0f)];
        self.loadingMemberLabel.font = clickableLabelFont;
        self.loadingMemberLabel.textColor = clickableLabelColor;
        self.loadingMemberLabel.text = NSLocalizedString(@"Loading Members", @"");
        [self.loadingMembersBackgroundView addSubview:self.loadingMemberLabel];
        
        CGSize loadingLabelFitSize = [self.loadingMemberLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGRectGetHeight(self.loadingMemberLabel.frame))];
        self.loadingMemberImageView.frame = CGRectMake((CGRectGetWidth(self.frame) - 20.0f - 8.0f - loadingLabelFitSize.width)/2, 183.0f, 20.0f, 20.0f);
        self.loadingMemberLabel.frame = CGRectMake(CGRectGetMaxX(self.loadingMemberImageView.frame) + 8.0f, CGRectGetMinY(self.loadingMemberImageView.frame)-1.0f, loadingLabelFitSize.width, 22.0f);
        
        //WK Note: This must be on the front
        _overlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.searchBarBackgroundView.frame), CGRectGetWidth(self.bgView.frame), CGRectGetHeight(self.bgView.frame) - CGRectGetHeight(self.searchBarBackgroundView.frame))];
        self.overlayView.backgroundColor = [[TAPUtil getColor:@"04040F"] colorWithAlphaComponent:0.4f];
        self.overlayView.alpha = 0.0f;
        [self.bgView addSubview:self.overlayView];
        
        _overlayButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.overlayView.frame), CGRectGetHeight(self.overlayView.frame))];
        self.overlayButton.backgroundColor = [UIColor clearColor];
        [self.overlayButton addTarget:self action:@selector(searchBarCancelButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.overlayView addSubview:self.overlayButton];
        
        self.contactsTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, [TAPUtil safeAreaBottomPadding], 0.0f);
        
        CGRect bottomActionViewFrame = self.bottomActionView.frame;
        bottomActionViewFrame.origin.y = CGRectGetMaxY(self.contactsTableView.frame);
        self.bottomActionView.frame = bottomActionViewFrame;
        self.bottomActionShadowView.frame = bottomActionViewFrame;
    }
    
    return self;
}

#pragma mark - Custom Method
- (void)searchBarCancelButtonDidTapped {
    [self.searchBarView handleCancelButtonTappedState];
    [self showOverlayView:NO];
    [self.contactsTableView reloadData];
    [UIView animateWithDuration:0.3f animations:^{
        CGRect searchBarViewFrame = self.searchBarView.frame;
        searchBarViewFrame.size.width = CGRectGetWidth(self.searchBarBackgroundView.frame) - 16.0f - 16.0f;
        self.searchBarView.frame = searchBarViewFrame;
        self.searchBarView.searchTextField.text = @"";
        [self.searchBarView.searchTextField endEditing:YES];
        
        CGRect searchBarCancelButtonFrame = self.searchBarCancelButton.frame;
        searchBarCancelButtonFrame.origin.x = CGRectGetMaxX(searchBarViewFrame) + 8.0f;
        searchBarCancelButtonFrame.size.width = 0.0f;
        self.searchBarCancelButton.frame = searchBarCancelButtonFrame;
        
        self.searchResultTableView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        //completion
    }];
}

- (void)showSelectedContacts:(BOOL)isVisible {
    if (isVisible) {
        self.selectedContactsView.alpha = 1.0f;
        [UIView animateWithDuration:0.2f animations:^{
            self.contactsTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 190.0f + [TAPUtil safeAreaBottomPadding], 0.0f);
            
            CGRect selectedContactsViewFrame = self.selectedContactsView.frame;
            selectedContactsViewFrame.origin.y = CGRectGetMaxY(self.contactsTableView.frame) - 190.0f - [TAPUtil safeAreaBottomPadding];
            self.selectedContactsView.frame = selectedContactsViewFrame;
            self.selectedContactsShadowView.frame = selectedContactsViewFrame;
        } completion:^(BOOL finished) {
            //completion
            self.selectedContactsView.alpha = 1.0f;
        }];
    }
    else {
        [UIView animateWithDuration:0.2f animations:^{
            self.contactsTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, [TAPUtil safeAreaBottomPadding], 0.0f);
            
            CGRect selectedContactsViewFrame = self.selectedContactsView.frame;
            selectedContactsViewFrame.origin.y = CGRectGetMaxY(self.contactsTableView.frame);
            self.selectedContactsView.frame = selectedContactsViewFrame;
            self.selectedContactsShadowView.frame = selectedContactsViewFrame;
        } completion:^(BOOL finished) {
            //completion
            self.selectedContactsView.alpha = 0.0f;
        }];
    }
}

- (void)showOverlayView:(BOOL)isVisible {
    if (isVisible) {
        [UIView animateWithDuration:0.2f animations:^{
            self.overlayView.alpha = 1.0f;
        }];
    }
    else {
        [UIView animateWithDuration:0.2f animations:^{
            self.overlayView.alpha = 0.0f;
        }];
    }
}

- (void)setTapCreateGroupViewType:(TAPCreateGroupViewType)tapCreateGroupViewType {
    _tapCreateGroupViewType = tapCreateGroupViewType;
    if (tapCreateGroupViewType == TAPCreateGroupViewTypeAddMember) {
        [self.continueButtonView setButtonWithTitle:NSLocalizedString(@"Add Members", @"")];
        [self showBottomActionButtonView:NO];
    }
    else if (tapCreateGroupViewType == TAPCreateGroupViewTypeMemberList) {
        [self showAddMembersButton];
        [self showBottomActionButtonView:YES];
    }
    else {
        //default
        [self showBottomActionButtonView:NO];
    }
}

- (void)showAddMembersButton {
    self.addMembersButtonView.alpha = 1.0f;
    self.removeMembersButtonView.alpha = 0.0f;
    self.demoteAdminButtonView.alpha = 0.0f;
    self.promoteAdminButtonView.alpha = 0.0f;
    //CS TEMP - hide remove button, uncomment to show later
//    [self showBottomActionButtonViewExtension:NO withActiveButton:0];
}

- (void)showRemoveMembersButton {
    self.addMembersButtonView.alpha = 0.0f;
    self.removeMembersButtonView.alpha = 1.0f;
    //CS TEMP - hide remove button, uncomment to show later
//    [self showBottomActionButtonViewExtension:NO withActiveButton:0];
}

- (void)showBottomActionButtonView:(BOOL)isVisible {
    if (isVisible) {
        self.bottomActionShadowView.alpha = 1.0f;
        self.bottomActionView.alpha = 1.0f;
 
        [UIView animateWithDuration:0.2f animations:^{
        
            CGRect bottomActionViewFrame = self.bottomActionView.frame;
            bottomActionViewFrame.origin.y = CGRectGetMaxY(self.contactsTableView.frame) - 74.0f - [TAPUtil safeAreaBottomPadding];
            self.bottomActionView.frame = bottomActionViewFrame;
            self.bottomActionShadowView.frame = bottomActionViewFrame;
        } completion:^(BOOL finished) {
            //completion
            self.contactsTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 74.0f + [TAPUtil safeAreaBottomPadding], 0.0f);
        }];
    }
    else {
        [UIView animateWithDuration:0.2f animations:^{
            CGRect bottomActionViewFrame = self.bottomActionView.frame;
            bottomActionViewFrame.origin.y = CGRectGetMaxY(self.contactsTableView.frame) - [TAPUtil safeAreaBottomPadding];;
            self.bottomActionView.frame = bottomActionViewFrame;
            self.bottomActionShadowView.frame = bottomActionViewFrame;
        } completion:^(BOOL finished) {
            //completion
            self.contactsTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, [TAPUtil safeAreaBottomPadding], 0.0f);
            self.bottomActionShadowView.alpha = 0.0f;
            self.bottomActionView.alpha = 0.0f;

        }];
    }
}

- (void)showLoadingView:(BOOL)isShow {
    if (isShow) {
        [UIView animateWithDuration:0.2f animations:^{
            self.loadingBackgroundView.alpha = 1.0f;
        }];
    }
    else {
        [UIView animateWithDuration:0.2f animations:^{
            self.loadingBackgroundView.alpha = 0.0f;
        }];
    }
}

- (void)animateSaveLoading:(BOOL)isAnimate {
    if (isAnimate) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.fromValue = [NSNumber numberWithFloat:0.0f];
        animation.toValue = [NSNumber numberWithFloat: 2 * M_PI];
        animation.duration = 1.5f;
        animation.repeatCount = INFINITY;
        animation.removedOnCompletion = NO;
        [self.loadingImageView.layer addAnimation:animation forKey:@"FirstLoadSpinAnimation"];
    }
    else {
        [self.loadingImageView.layer removeAnimationForKey:@"FirstLoadSpinAnimation"];
    }
}

- (void)setAsLoadingState:(BOOL)isLoading withType:(TAPCreateGroupLoadingType)type {
    
    NSString *loadingString;
    NSString *doneLoadingString;
    
    switch (type) {
        case TAPCreateGroupLoadingTypeAppointAdmin:
        {
            loadingString = @"Updating...";
            doneLoadingString = @"Admin Promoted";
            break;
        }
        case TAPCreateGroupLoadingTypeRemoveAdmin:
        {
            loadingString = @"Updating...";
            doneLoadingString = @"Admin Demoted";
            break;
        }
        case TAPCreateGroupLoadingTypeRemoveMember:
        {
            loadingString = @"Removing...";
            doneLoadingString = @"Member Removed";
            break;
        }
        case TAPCreateGroupLoadingTypeDoneLoading:
        {
            loadingString = @"";
            doneLoadingString = @"";
            break;
        }
        default:
        {
            loadingString = @"Updating...";
            doneLoadingString = @"Success";
            break;
        }
    }
    
    if (isLoading) {
        [self animateSaveLoading:YES];
        self.loadingImageView.image = [UIImage imageNamed:@"TAPIconImageSaving" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.loadingLabel.text = NSLocalizedString(loadingString, @"");
        self.loadingButton.alpha = 1.0f;
        self.loadingButton.userInteractionEnabled = YES;
    }
    else {
        [self animateSaveLoading:NO];
        self.loadingImageView.image = [UIImage imageNamed:@"TAPIconImageSaved" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.loadingLabel.text = NSLocalizedString(doneLoadingString, @"");
        self.loadingButton.alpha = 1.0f;
        self.loadingButton.userInteractionEnabled = YES;
    }
}

- (void)showBottomActionButtonViewExtension:(BOOL)isVisible withActiveButton:(TAPCreateGroupActionExtensionType)type {
    if (isVisible) {
        if (type == TAPCreateGroupActionExtensionTypePromoteAdmin) {
            self.promoteAdminButtonView.alpha = 1.0f;
            self.demoteAdminButtonView.alpha = 0.0f;
        }
        else {
            self.demoteAdminButtonView.alpha = 1.0f;
            self.promoteAdminButtonView.alpha = 0.0f;
        }
        
        //CS TEMP - hide remove button, uncomment to show later
//        self.contactsTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 128.0f + [TAPUtil safeAreaBottomPadding], 0.0f);
//
//        CGRect bottomActionViewFrame = self.bottomActionView.frame;
//        bottomActionViewFrame.origin.y = CGRectGetMaxY(self.contactsTableView.frame) - 128.0f - [TAPUtil safeAreaBottomPadding];
//        bottomActionViewFrame.size.height = 128.0f + [TAPUtil safeAreaBottomPadding];
//        [UIView animateWithDuration:0.2f animations:^{
//            self.bottomActionView.frame = bottomActionViewFrame;
//            self.bottomActionShadowView.frame = bottomActionViewFrame;
//            self.removeMembersButtonView.frame = CGRectMake(0.0f, CGRectGetMaxY(self.promoteAdminButtonView.frame) + 10.0f, CGRectGetWidth(self.bottomActionView.frame), 44.0f);
//
//        }];
        
    }
    else {
        //CS TEMP - hide remove button, uncomment to show later
//        self.contactsTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 74.0f + [TAPUtil safeAreaBottomPadding], 0.0f);
//
//        CGRect bottomActionViewFrame = self.bottomActionView.frame;
//        bottomActionViewFrame.origin.y = CGRectGetMaxY(self.contactsTableView.frame) - 74.0f - [TAPUtil safeAreaBottomPadding];
//        bottomActionViewFrame.size.height = 74.0f + [TAPUtil safeAreaBottomPadding];
//        [UIView animateWithDuration:0.2f animations:^{
//            self.bottomActionView.frame = bottomActionViewFrame;
//            self.bottomActionShadowView.frame = bottomActionViewFrame;
//            self.removeMembersButtonView.frame = CGRectMake(0.0f, 16.0f, CGRectGetWidth(self.bottomActionView.frame), 44.0f);
//        }];
        
        self.demoteAdminButtonView.alpha = 0.0f;
        self.promoteAdminButtonView.alpha = 0.0f;
    }
}

- (void)showLoadingMembersView:(BOOL)isShow {
    [self animateMembersLoading:isShow];
    if (isShow) {
        [UIView animateWithDuration:0.2f animations:^{
            self.loadingMembersView.alpha = 1.0f;
        }];
    }
    else {
        [UIView animateWithDuration:0.2f animations:^{
            self.loadingMembersView.alpha = 0.0f;
        }];
    }
}

- (void)animateMembersLoading:(BOOL)isAnimate {
    if (isAnimate) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.fromValue = [NSNumber numberWithFloat:0.0f];
        animation.toValue = [NSNumber numberWithFloat: 2 * M_PI];
        animation.duration = 1.5f;
        animation.repeatCount = INFINITY;
        animation.removedOnCompletion = NO;
        [self.loadingMemberImageView.layer addAnimation:animation forKey:@"FirstLoadSpinMembersAnimation"];
    }
    else {
        [self.loadingMemberImageView.layer removeAnimationForKey:@"FirstLoadSpinMembersAnimation"];
    }
}

@end
