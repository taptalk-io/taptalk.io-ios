//
//  TAPAddNewChatView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 13/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPAddNewChatView.h"

@interface TAPAddNewChatView()
@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UIView *syncedContactNotificationView;
@property (strong, nonatomic) UIView *syncContactButtonView;
@property (strong, nonatomic) UIView *separatorView;

@property (strong, nonatomic) UIView *overlayView;
@property (strong, nonatomic) UIButton *overlayButton;

@property (strong, nonatomic) UILabel *syncedContactNotificationLabel;
@property (strong, nonatomic) UIImageView *syncedContactNotificationCheckMarkImageView;

- (void)setSyncStatusWithString:(NSString *)string;
- (void)showNotificationLoading:(BOOL)show;

@end

@implementation TAPAddNewChatView
#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        self.bgView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
        [self addSubview:self.bgView];
        
        _syncedContactNotificationView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bgView.frame), 20.0f)];
        self.syncedContactNotificationView.backgroundColor = [UIColor whiteColor];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.syncedContactNotificationView.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[TAPUtil getColor:@"3BC73D"].CGColor, [TAPUtil getColor:@"2DB80F"].CGColor,nil];
        gradient.startPoint = CGPointMake(0.0f, 0.0f);
        gradient.endPoint = CGPointMake(0.0f, 1.0f);
        [self.syncedContactNotificationView.layer insertSublayer:gradient atIndex:0];
        [self.bgView addSubview:self.syncedContactNotificationView];
        
        _syncedContactNotificationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, CGRectGetHeight(self.syncedContactNotificationView.frame))];
        UIFont *obtainedFont = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
        obtainedFont = [obtainedFont fontWithSize:12.0f];
        self.syncedContactNotificationLabel.font = obtainedFont;
        self.syncedContactNotificationLabel.textColor = [UIColor whiteColor];
        [self.syncedContactNotificationView addSubview:self.syncedContactNotificationLabel];
        
        _syncedContactNotificationCheckMarkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.syncedContactNotificationLabel.frame) + 4.0f, (CGRectGetHeight(self.syncedContactNotificationView.frame) - 9.0f) / 2.0f, 9.0f, 9.0f)];
        self.syncedContactNotificationCheckMarkImageView.image = [UIImage imageNamed:@"TAPIconConnected" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.syncedContactNotificationView addSubview:self.syncedContactNotificationCheckMarkImageView];
            
        _searchBarBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bgView.frame), 46.0f)];
        self.searchBarBackgroundView.backgroundColor = [UIColor whiteColor];
        [self.bgView addSubview:self.searchBarBackgroundView];
        
        _searchBarView = [[TAPSearchBarView alloc] initWithFrame:CGRectMake(16.0f, 8.0f, CGRectGetWidth(self.searchBarBackgroundView.frame) - 16.0f - 16.0f, 30.0f)];
        self.searchBarView.customPlaceHolderString = NSLocalizedStringFromTableInBundle(@"Search for contacts", nil, [TAPUtil currentBundle], @"");
        [self.searchBarBackgroundView addSubview:self.searchBarView];
        
        UIFont *searchBarCancelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontSearchBarTextCancelButton];
        UIColor *searchBarCancelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorSearchBarTextCancelButton];
        _searchBarCancelButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.searchBarView.frame) + 8.0f, 0.0f, 0.0f, CGRectGetHeight(self.searchBarBackgroundView.frame))];
        NSString *searchBarCancelString = NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"");
        NSMutableAttributedString *searchBarCancelAttributedString = [[NSMutableAttributedString alloc] initWithString:searchBarCancelString];
        NSMutableDictionary *searchBarCancelAttributesDictionary = [NSMutableDictionary dictionary];
        CGFloat searchBarCancelLetterSpacing = -0.4f;
        [searchBarCancelAttributesDictionary setObject:@(searchBarCancelLetterSpacing) forKey:NSKernAttributeName];
        [searchBarCancelAttributesDictionary setObject:searchBarCancelFont forKey:NSFontAttributeName];
        [searchBarCancelAttributesDictionary setObject:searchBarCancelColor forKey:NSForegroundColorAttributeName];
        [searchBarCancelAttributedString addAttributes:searchBarCancelAttributesDictionary
                                                 range:NSMakeRange(0, [searchBarCancelString length])];
        [self.searchBarCancelButton setAttributedTitle:searchBarCancelAttributedString forState:UIControlStateNormal];
        self.searchBarCancelButton.clipsToBounds = YES;
        [self.searchBarCancelButton addTarget:self action:@selector(searchBarCancelButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.searchBarBackgroundView addSubview:self.searchBarCancelButton];
        
        _contactsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.separatorView.frame), CGRectGetWidth(self.bgView.frame), CGRectGetHeight(self.bgView.frame) - CGRectGetHeight(self.searchBarBackgroundView.frame) - 1.0f - 62.0f - [TAPUtil safeAreaBottomPadding]) style:UITableViewStylePlain]; //62.0f - height of sync contact button view
        self.contactsTableView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
        self.contactsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.contactsTableView setSectionIndexColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTableViewSectionIndex]];
        [self.bgView addSubview:self.contactsTableView];
        
        if ([[TapUI sharedInstance] isAddContactEnabled]) {
            _separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(self.searchBarBackgroundView.frame) - 1.0f, CGRectGetWidth(self.frame), 1.0f)];
        }
        else {
            _separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), 1.0f)];
            
            self.searchBarBackgroundView.frame = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);
        }
        
        self.separatorView.backgroundColor = [TAPUtil getColor:TAP_COLOR_GREY_DC];
        [self.searchBarBackgroundView addSubview:self.separatorView];
        
        _syncContactButtonView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.contactsTableView.frame), CGRectGetWidth(self.bgView.frame), 62.0f + [TAPUtil safeAreaBottomPadding])];
        self.syncContactButtonView.backgroundColor = [UIColor whiteColor];
        [self.bgView addSubview:self.syncContactButtonView];
        
        UIView *syncContactTopSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.syncContactButtonView.frame), 1.0f)];
        syncContactTopSeparatorView.backgroundColor = [TAPUtil getColor:TAP_COLOR_GREY_DC];
        [self.syncContactButtonView addSubview:syncContactTopSeparatorView];
        
        _syncButton = [[TAPCustomButtonView alloc] initWithFrame:CGRectMake(0.0f, 10.0f, CGRectGetWidth(self.frame), 44.0f)];
        [self.syncButton setCustomButtonViewStyleType:TAPCustomButtonViewStyleTypeWithIcon];
        [self.syncButton setCustomButtonViewType:TAPCustomButtonViewTypeActive];
        [self.syncButton setButtonWithTitle:NSLocalizedStringFromTableInBundle(@"Sync Contacts Now", nil, [TAPUtil currentBundle], @"") andIcon:@"TAPIconSync" iconPosition:TAPCustomButtonViewIconPosititonLeft];
        [self.syncButton setButtonIconTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonIcon]];
        [self.syncContactButtonView addSubview:self.syncButton];
        
        _searchResultTableView = [[UITableView alloc] initWithFrame:self.contactsTableView.frame];
        self.searchResultTableView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
        self.searchResultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.searchResultTableView setSectionIndexColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorTableViewSectionIndex]];
        self.searchResultTableView.alpha = 0.0f;
        [self.bgView addSubview:self.searchResultTableView];
        
        //WK Note: This must be on the front
        _overlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.searchBarBackgroundView.frame), CGRectGetWidth(self.bgView.frame), CGRectGetHeight(self.bgView.frame) - CGRectGetHeight(self.searchBarBackgroundView.frame))];
        self.overlayView.backgroundColor = [[TAPUtil getColor:@"04040F"] colorWithAlphaComponent:0.4f];
        self.overlayView.alpha = 0.0f;
        [self.bgView addSubview:self.overlayView];
        
        _overlayButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.overlayView.frame), CGRectGetHeight(self.overlayView.frame))];
        self.overlayButton.backgroundColor = [UIColor clearColor];
        [self.overlayButton addTarget:self action:@selector(searchBarCancelButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.overlayView addSubview:self.overlayButton];
        //End Note
    }
    return self;
}

#pragma mark - Custom Method
- (void)searchBarCancelButtonDidTapped {
    [self.searchBarView handleCancelButtonTappedState];
    [self showOverlayView:NO];
    
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

- (void)setSyncStatusWithString:(NSString *)string {
    self.syncedContactNotificationLabel.text = string;
    CGSize size = [self.syncedContactNotificationLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, 20.0f)];
    CGFloat maximumLabelWidth = CGRectGetWidth(self.frame) - 16.0f - 16.0f - 4.0f - 9.0f; //16 - left&right gap, 4 - gap to image view, 9 image view width
    CGFloat newWidth = size.width;
    if (newWidth > maximumLabelWidth) {
        newWidth = maximumLabelWidth;
    }
    CGFloat newMinX = (CGRectGetWidth(self.syncedContactNotificationView.frame) - (newWidth + 4.0f + 9.0f))/2.0f;
    self.syncedContactNotificationLabel.frame = CGRectMake(newMinX, 0.0f, newWidth, CGRectGetHeight(self.syncedContactNotificationLabel.frame));
    self.syncedContactNotificationCheckMarkImageView.frame = CGRectMake(CGRectGetMaxX(self.syncedContactNotificationLabel.frame) + 4.0f, (CGRectGetHeight(self.syncedContactNotificationView.frame) - 9.0f) / 2.0f, 9.0f, 9.0f);
}

- (void)showSyncContactButtonView:(BOOL)show {
    if (show) {
        self.syncContactButtonView.alpha = 1.0f;
        self.contactsTableView.frame = CGRectMake(0.0f, CGRectGetMaxY(self.searchBarBackgroundView.frame), CGRectGetWidth(self.bgView.frame), CGRectGetHeight(self.bgView.frame) - CGRectGetHeight(self.searchBarBackgroundView.frame) - 62.0f - [TAPUtil safeAreaBottomPadding]);
        self.searchResultTableView.frame = self.contactsTableView.frame;
    }
    else {
        self.syncContactButtonView.alpha = 0.0f;
        self.contactsTableView.frame = CGRectMake(0.0f, CGRectGetMaxY(self.searchBarBackgroundView.frame), CGRectGetWidth(self.bgView.frame), CGRectGetHeight(self.bgView.frame) - CGRectGetHeight(self.searchBarBackgroundView.frame));
        self.searchResultTableView.frame = self.contactsTableView.frame;
    }
}

- (void)showSyncNotificationView:(BOOL)show {
    if (show) {
        self.searchBarBackgroundView.frame = CGRectMake(0.0f, 20.0f, CGRectGetWidth(self.bgView.frame), 46.0f);
        self.contactsTableView.frame = CGRectMake(0.0f, CGRectGetMaxY(self.searchBarBackgroundView.frame), CGRectGetWidth(self.bgView.frame), CGRectGetHeight(self.contactsTableView.frame));
    }
    else {
        self.searchBarBackgroundView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bgView.frame), 46.0f);
        self.contactsTableView.frame = CGRectMake(0.0f, CGRectGetMaxY(self.searchBarBackgroundView.frame), CGRectGetWidth(self.bgView.frame), CGRectGetHeight(self.contactsTableView.frame));
    }
}

- (void)showSyncNotificationWithString:(NSString *)string type:(TAPSyncNotificationViewType)type {
    
    if (type == TAPSyncNotificationViewTypeSyncing) {
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.syncedContactNotificationView.frame;
        gradient.colors = [NSArray arrayWithObjects:(id)[TAPUtil getColor:@"FF9F00"].CGColor, [TAPUtil getColor:@"FFA107"].CGColor, [TAPUtil getColor:@"FFB438"].CGColor,nil];
        gradient.startPoint = CGPointMake(0.0f, 0.0f);
        gradient.endPoint = CGPointMake(0.0f, 1.0f);
        [self.syncedContactNotificationView.layer replaceSublayer:[self.syncedContactNotificationView.layer.sublayers objectAtIndex:0] with:gradient];
        self.syncedContactNotificationCheckMarkImageView.image = [UIImage imageNamed:@"TAPIconLoaderProgress" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        self.syncedContactNotificationCheckMarkImageView.image = [self.syncedContactNotificationCheckMarkImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconLoadingProgressWhite]];
        [self showNotificationLoading:YES];
    }
    else if (type == TAPSyncNotificationViewTypeSynced) {
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.syncedContactNotificationView.frame;
        gradient.colors = [NSArray arrayWithObjects:(id)[TAPUtil getColor:@"3BC73D"].CGColor, [TAPUtil getColor:@"2DB80F"].CGColor,nil];
        gradient.startPoint = CGPointMake(0.0f, 0.0f);
        gradient.endPoint = CGPointMake(0.0f, 1.0f);
        [self.syncedContactNotificationView.layer replaceSublayer:[self.syncedContactNotificationView.layer.sublayers objectAtIndex:0] with:gradient];
        self.syncedContactNotificationCheckMarkImageView.image = [UIImage imageNamed:@"TAPIconConnected" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self showNotificationLoading:NO];
    }
    
    [self setSyncStatusWithString:string];
    
    if (CGRectGetMinY(self.searchBarBackgroundView.frame) == 20.0f) {
        //already shown
        [UIView animateWithDuration:0.2f
                              delay:0.5f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             //animate
                             [self showSyncNotificationView:NO];
                         }
                         completion:nil];
    }
    else {
        [UIView animateWithDuration:0.2f animations:^{
            [self showSyncNotificationView:YES];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2f
                                  delay:0.5f
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 //animate
                                 [self showSyncNotificationView:NO];
                             }
                             completion:nil];
        }];
    }
}

- (void)hideSyncNotification {
    [UIView animateWithDuration:0.2f animations:^{
        [self showSyncNotificationView:NO];
    }];
}

- (void)showNotificationLoading:(BOOL)show {
    if (show) {
        //ADD ANIMATION
        if ([self.syncedContactNotificationCheckMarkImageView.layer animationForKey:@"SpinAnimationCheckMark"] == nil) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            animation.fromValue = [NSNumber numberWithFloat:0.0f];
            animation.toValue = [NSNumber numberWithFloat:(2*M_PI)];
            animation.duration = 1.5f;
            animation.repeatCount = INFINITY;
            animation.cumulative = YES;
            animation.removedOnCompletion = NO;
            [self.syncedContactNotificationCheckMarkImageView.layer addAnimation:animation forKey:@"SpinAnimationCheckMark"];
        }
    }
    else {
        //REMOVE ANIMATION
        if ([self.syncedContactNotificationCheckMarkImageView.layer animationForKey:@"SpinAnimationCheckMark"] != nil) {
            [self.syncedContactNotificationCheckMarkImageView.layer removeAnimationForKey:@"SpinAnimationCheckMark"];
        }
    }
}

@end
