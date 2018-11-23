//
//  TAPCreateGroupView.m
//  TapTalk
//
//  Created by Welly Kencana on 17/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPCreateGroupView.h"

@interface TAPCreateGroupView()
@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UIView *overlayView;
@property (strong, nonatomic) UIButton *overlayButton;
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
        self.searchBarView.backgroundColor = [TAPUtil getColor:TAP_COLOR_WHITE_F3];
        [self.bgView addSubview:self.searchBarBackgroundView];
        
        _searchBarView = [[TAPSearchBarView alloc] initWithFrame:CGRectMake(16.0f, 8.0f, CGRectGetWidth(self.searchBarBackgroundView.frame) - 16.0f - 16.0f, 30.0f)];
        self.searchBarView.customPlaceHolderString = NSLocalizedString(@"Search for people to add", @"");
        [self.searchBarBackgroundView addSubview:self.searchBarView];
        
        _searchBarCancelButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.searchBarView.frame) + 8.0f, 0.0f, 0.0f, CGRectGetHeight(self.searchBarBackgroundView.frame))];
        NSString *searchBarCancelString = NSLocalizedString(@"Cancel", @"");
        NSMutableAttributedString *searchBarCancelAttributedString = [[NSMutableAttributedString alloc] initWithString:searchBarCancelString];
        NSMutableDictionary *searchBarCancelAttributesDictionary = [NSMutableDictionary dictionary];
        float searchBarCancelLetterSpacing = -0.4f;
        [searchBarCancelAttributesDictionary setObject:@(searchBarCancelLetterSpacing) forKey:NSKernAttributeName];
        [searchBarCancelAttributesDictionary setObject:[UIFont fontWithName:TAP_FONT_LATO_REGULAR size:17.0f] forKey:NSFontAttributeName];
        [searchBarCancelAttributesDictionary setObject:[TAPUtil getColor:TAP_COLOR_GREENBLUE_93] forKey:NSForegroundColorAttributeName];
        [searchBarCancelAttributedString addAttributes:searchBarCancelAttributesDictionary
                                                 range:NSMakeRange(0, [searchBarCancelString length])];
        [self.searchBarCancelButton setAttributedTitle:searchBarCancelAttributedString forState:UIControlStateNormal];
        self.searchBarCancelButton.clipsToBounds = YES;
        [self.searchBarCancelButton addTarget:self action:@selector(searchBarCancelButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.searchBarBackgroundView addSubview:self.searchBarCancelButton];
        
        _contactsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.searchBarBackgroundView.frame), CGRectGetWidth(self.bgView.frame), CGRectGetHeight(self.bgView.frame) - CGRectGetHeight(self.searchBarBackgroundView.frame)) style:UITableViewStylePlain];
        self.contactsTableView.backgroundColor = [TAPUtil getColor:TAP_COLOR_WHITE_F3];
        self.contactsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.contactsTableView setSectionIndexColor:[TAPUtil getColor:TAP_COLOR_GREENBLUE_93]];
        [self.bgView addSubview:self.contactsTableView];
        
        _searchResultTableView = [[UITableView alloc] initWithFrame:self.contactsTableView.frame];
        self.searchResultTableView.backgroundColor = [TAPUtil getColor:TAP_COLOR_WHITE_F3];
        self.searchResultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.searchResultTableView setSectionIndexColor:[TAPUtil getColor:TAP_COLOR_GREENBLUE_93]];
        self.searchResultTableView.alpha = 0.0f;
        [self.bgView addSubview:self.searchResultTableView];
        
        _selectedContactsView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.contactsTableView.frame), CGRectGetWidth(self.bgView.frame), 190.0f)];
        self.selectedContactsView.alpha = 0.0f;
        self.selectedContactsView.backgroundColor = [UIColor whiteColor];
        [self.bgView addSubview:self.selectedContactsView];
        
        _selectedContactsTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 8.0f, CGRectGetWidth(self.bgView.frame) - 16.0f - 16.0f, 13.0f)];
        self.selectedContactsTitleLabel.font = [UIFont fontWithName:TAP_FONT_LATO_BOLD size:11.0f];
        self.selectedContactsTitleLabel.textColor = [TAPUtil getColor:TAP_COLOR_MOSELO_PURPLE];
        [self.selectedContactsView addSubview:self.selectedContactsTitleLabel];
        
        UICollectionViewFlowLayout *collectionLayout = [[UICollectionViewFlowLayout alloc] init];
        collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _selectedContactsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.selectedContactsTitleLabel.frame) + 10.0f, CGRectGetWidth(self.selectedContactsView.frame), 74.0f) collectionViewLayout:collectionLayout];
        self.selectedContactsCollectionView.backgroundColor = [UIColor whiteColor];
        self.selectedContactsCollectionView.showsVerticalScrollIndicator = NO;
        self.selectedContactsCollectionView.showsHorizontalScrollIndicator = NO;
        [self.selectedContactsView addSubview:self.selectedContactsCollectionView];
        
        _continueButton = [[UIButton alloc] initWithFrame:CGRectMake(8.0f, CGRectGetHeight(self.selectedContactsView.frame) - 10.0f - 44.0f, CGRectGetWidth(self.selectedContactsView.frame) - 8.0f - 8.0f, 44.0f)];
        NSString *continueString = NSLocalizedString(@"Continue", @"");
        NSMutableDictionary *continueAttributesDictionary = [NSMutableDictionary dictionary];
        CGFloat continueLetterSpacing = -0.2f;
        [continueAttributesDictionary setObject:@(continueLetterSpacing) forKey:NSKernAttributeName];
        [continueAttributesDictionary setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
        NSMutableAttributedString *continueAttributedString = [[NSMutableAttributedString alloc] initWithString:continueString];
        [continueAttributedString setAttributes:continueAttributesDictionary
                                          range:NSMakeRange(0, [continueString length])];
        [self.continueButton setAttributedTitle:continueAttributedString forState:UIControlStateNormal];
        self.continueButton.titleLabel.font = [UIFont fontWithName:TAP_FONT_LATO_BOLD size:17.0f];
        self.continueButton.layer.borderWidth = 1.0f;
        self.continueButton.layer.borderColor = [TAPUtil getColor:TAP_COLOR_GREENBLUE_93].CGColor;
        self.continueButton.layer.cornerRadius = 6.0f;
        self.continueButton.clipsToBounds = YES;
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.continueButton.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[TAPUtil getColor:TAP_COLOR_AQUAMARINE_C1].CGColor, (id)[TAPUtil getColor:TAP_COLOR_MOSELO_GREEN].CGColor, nil];
        gradient.startPoint = CGPointMake(0.0f, 0.0f);
        gradient.endPoint = CGPointMake(0.0f, 1.0f);
        gradient.cornerRadius = 6.0f;
        [self.continueButton.layer insertSublayer:gradient atIndex:0];
        [self.selectedContactsView addSubview:self.continueButton];
        
        //WK Note: This must be on the front
        _overlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.searchBarBackgroundView.frame), CGRectGetWidth(self.bgView.frame), CGRectGetHeight(self.bgView.frame) - CGRectGetHeight(self.searchBarBackgroundView.frame))];
        self.overlayView.backgroundColor = [[TAPUtil getColor:@"04040F"] colorWithAlphaComponent:0.4f];
        self.overlayView.alpha = 0.0f;
        [self.bgView addSubview:self.overlayView];
        
        _overlayButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.overlayView.frame), CGRectGetHeight(self.overlayView.frame))];
        self.overlayButton.backgroundColor = [UIColor clearColor];
        [self.overlayButton addTarget:self action:@selector(searchBarCancelButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.overlayView addSubview:self.overlayButton];
    }
    
    return self;
}

#pragma mark - Custom Method
- (void)searchBarCancelButtonDidTapped {
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

- (void)showSelectedContacts:(BOOL)isVisible {
    if (isVisible) {
        self.selectedContactsView.alpha = 1.0f;
        [UIView animateWithDuration:0.2f animations:^{
            self.contactsTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 190.0f, 0.0f);
            
            CGRect selectedContactsViewFrame = self.selectedContactsView.frame;
            selectedContactsViewFrame.origin.y = CGRectGetMaxY(self.contactsTableView.frame) - 190.0f;
            self.selectedContactsView.frame = selectedContactsViewFrame;
        } completion:^(BOOL finished) {
            //completion
            self.selectedContactsView.alpha = 1.0f;
        }];
    }
    else {
        [UIView animateWithDuration:0.2f animations:^{
            self.contactsTableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
            
            CGRect selectedContactsViewFrame = self.selectedContactsView.frame;
            selectedContactsViewFrame.origin.y = CGRectGetMaxY(self.contactsTableView.frame);
            self.selectedContactsView.frame = selectedContactsViewFrame;
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

@end
