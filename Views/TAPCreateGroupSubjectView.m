//
//  TAPCreateGroupSubjectView.m
//  TapTalk
//
//  Created by Welly Kencana on 19/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPCreateGroupSubjectView.h"

@interface TAPCreateGroupSubjectView()

@property (strong, nonatomic) UIView *groupPictureNameView;

@property (strong, nonatomic) UILabel *groupPictureTitleLabel;
@property (strong, nonatomic) UIView *groupPictureView;
@property (strong, nonatomic) UIImageView *groupPictureImageView;
@property (strong, nonatomic) UIImageView *groupPictureIconImageView;
@property (strong, nonatomic) UILabel *groupPictureDescriptionLabel;

@property (strong, nonatomic) UILabel *groupNameTitleLabel;
@end

@implementation TAPCreateGroupSubjectView
#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        self.bgScrollView.backgroundColor = [UIColor whiteColor];
        self.bgScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bgScrollView.frame), CGRectGetMaxY(self.bgScrollView.frame));
        self.bgScrollView.showsVerticalScrollIndicator = NO;
        self.bgScrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.bgScrollView];
        
        _selectedContactsView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bgScrollView.frame), 118.0f)];
        self.selectedContactsView.backgroundColor = [UIColor whiteColor];
        self.selectedContactsView.layer.shadowColor = [TAPUtil getColor:@"D9D9D9"].CGColor;
        self.selectedContactsView.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        self.selectedContactsView.layer.shadowOpacity = 0.4f;
        self.selectedContactsView.layer.shadowRadius = 4.0f;
        [self.bgScrollView addSubview:self.selectedContactsView];
        
        _selectedContactsTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 8.0f, CGRectGetWidth(self.bgScrollView.frame) - 16.0f - 16.0f, 13.0f)];
        self.selectedContactsTitleLabel.text = @"Group Members (10/50)";//WK Temp
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
        
        _groupPictureNameView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(self.selectedContactsView.frame) + 16.0f, CGRectGetWidth(self.bgScrollView.frame), 234.0f)];
        self.groupPictureNameView.backgroundColor = [UIColor whiteColor];
        [self.bgScrollView addSubview:self.groupPictureNameView];
        
        _groupPictureTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, 8.0f, CGRectGetWidth(self.bgScrollView.frame) - 16.0f - 16.0f, 13.0f)];
        NSString *groupPictureTitleString = NSLocalizedString(@"Group Picture", @"");
        NSString *groupPictureTitleUppercaseString = [groupPictureTitleString uppercaseString];
        self.groupPictureTitleLabel.text = groupPictureTitleUppercaseString;
        self.groupPictureTitleLabel.textColor = [TAPUtil getColor:TAP_COLOR_MOSELO_PURPLE];
        self.groupPictureTitleLabel.textAlignment = NSTextAlignmentCenter;
        self.groupPictureTitleLabel.font = [UIFont fontWithName:TAP_FONT_LATO_BOLD size:11.0f];
        [self.groupPictureNameView addSubview:self.groupPictureTitleLabel];
        
        _groupPictureView = [[UIView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.bgScrollView.frame) - 64.0f) / 2.0f, CGRectGetMaxY(self.groupPictureTitleLabel.frame) + 10.0f, 64.0f, 64.0f)];
        self.groupPictureView.layer.cornerRadius = CGRectGetHeight(self.groupPictureView.frame) / 2.0f;
        self.groupPictureView.clipsToBounds = YES;
        self.groupPictureView.backgroundColor = [TAPUtil getColor:@"D9D9D9"];
        [self.groupPictureNameView addSubview:self.groupPictureView];
        
        _groupPictureIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.groupPictureView.frame) - 28.0f) / 2.0f, (CGRectGetHeight(self.groupPictureView.frame) - 21.0f) / 2.0f, 28.0f, 21.0f)];
        self.groupPictureIconImageView.image = [UIImage imageNamed:@"TAPIconCamera" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.groupPictureView addSubview:self.groupPictureIconImageView];
        
        _groupPictureImageView = [[UIImageView alloc] initWithFrame:self.groupPictureView.frame];
        self.groupPictureImageView.alpha = 0.0f;
        self.groupPictureImageView.layer.cornerRadius = CGRectGetHeight(self.groupPictureImageView.frame) / 2.0f;
        self.groupPictureImageView.clipsToBounds = YES;
        [self.groupPictureNameView addSubview:self.groupPictureImageView];
        
        _groupPictureButton = [[UIButton alloc] initWithFrame:self.groupPictureView.frame];
        [self.groupPictureNameView addSubview:self.groupPictureButton];
        
        _groupPictureDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.groupPictureImageView.frame) + 10.0f, CGRectGetWidth(self.groupPictureNameView.frame) - 16.0f - 16.0f, 18.0f)];
        self.groupPictureDescriptionLabel.text = NSLocalizedString(@"Tap icon to change group profile image", @"");
        self.groupPictureDescriptionLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
        self.groupPictureDescriptionLabel.textAlignment = NSTextAlignmentCenter;
        self.groupPictureDescriptionLabel.font = [UIFont fontWithName:TAP_FONT_LATO_REGULAR size:15.0f];
        [self.groupPictureNameView addSubview:self.groupPictureDescriptionLabel];
        
        _groupNameTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.groupPictureDescriptionLabel.frame) + 24.0f, CGRectGetWidth(self.groupPictureNameView.frame) - 16.0f - 16.0f, 13.0f)];
        NSString *groupNameTitleString = NSLocalizedString(@"Group Name", @"");
        NSString *groupNameTitleUppercaseString = [groupNameTitleString uppercaseString];
        self.groupNameTitleLabel.text = groupNameTitleUppercaseString;
        self.groupNameTitleLabel.textColor = [TAPUtil getColor:TAP_COLOR_MOSELO_PURPLE];
        self.groupNameTitleLabel.textAlignment = NSTextAlignmentCenter;
        self.groupNameTitleLabel.font = [UIFont fontWithName:TAP_FONT_LATO_BOLD size:11.0f];
        [self.groupPictureNameView addSubview:self.groupNameTitleLabel];
        
        _groupNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(16.0f, CGRectGetMaxY(self.groupNameTitleLabel.frame) + 10.0f, CGRectGetWidth(self.groupPictureNameView.frame) - 16.0f - 16.0f, 36.0f)];
        self.groupNameTextField.backgroundColor = [UIColor whiteColor];
        self.groupNameTextField.tintColor = [TAPUtil getColor:TAP_COLOR_MOSELO_GREEN];
        NSString *placeHolderTitleString = NSLocalizedString(@"Type group name", @"");
        NSMutableAttributedString *placeHolderAttributedString = [[NSMutableAttributedString alloc] initWithString:placeHolderTitleString];
        NSMutableDictionary *placeHolderAttributesDictionary = [NSMutableDictionary dictionary];
        CGFloat placeHolderLetterSpacing = -0.2f;
        [placeHolderAttributesDictionary setObject:@(placeHolderLetterSpacing) forKey:NSKernAttributeName];
        [placeHolderAttributesDictionary setObject:[UIFont fontWithName:TAP_FONT_LATO_REGULAR size:15.0f] forKey:NSFontAttributeName];
        [placeHolderAttributesDictionary setObject:[TAPUtil getColor:TAP_COLOR_GREY_9B] forKey:NSForegroundColorAttributeName];
        [placeHolderAttributedString addAttributes:placeHolderAttributesDictionary
                                             range:NSMakeRange(0, [placeHolderTitleString length])];
//        self.groupNameTextField.attributedPlaceholder = placeHolderAttributedString;
        self.groupNameTextField.layer.cornerRadius = 8.0f;
        self.groupNameTextField.layer.borderWidth = 1.0f;
        self.groupNameTextField.layer.borderColor = [TAPUtil getColor:@"E4E4E4"].CGColor;
        self.groupNameTextField.clipsToBounds = YES;
        self.groupNameTextField.textAlignment = NSTextAlignmentCenter;
        self.groupNameTextField.font = [UIFont fontWithName:TAP_FONT_LATO_REGULAR size:15.0f];
        self.groupNameTextField.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
        [self.groupPictureNameView addSubview:self.groupNameTextField];
        
        _placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, -2.0f, CGRectGetWidth(self.groupNameTextField.frame), CGRectGetHeight(self.groupNameTextField.frame))];
        self.placeHolderLabel.attributedText = placeHolderAttributedString;
        self.placeHolderLabel.textAlignment = NSTextAlignmentCenter;
        [self.groupNameTextField addSubview:self.placeHolderLabel];
        
        _createButton = [[UIButton alloc] initWithFrame:CGRectMake(8.0f, CGRectGetHeight(self.bgScrollView.frame) - 10.0f - 44.0f, CGRectGetWidth(self.selectedContactsView.frame) - 8.0f - 8.0f, 44.0f)];
        NSString *createString = NSLocalizedString(@"Create", @"");
        NSMutableDictionary *createAttributesDictionary = [NSMutableDictionary dictionary];
        CGFloat createLetterSpacing = -0.2f;
        [createAttributesDictionary setObject:@(createLetterSpacing) forKey:NSKernAttributeName];
        [createAttributesDictionary setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
        NSMutableAttributedString *createAttributedString = [[NSMutableAttributedString alloc] initWithString:createString];
        [createAttributedString setAttributes:createAttributesDictionary
                                        range:NSMakeRange(0, [createString length])];
        [self.createButton setAttributedTitle:createAttributedString forState:UIControlStateNormal];
        self.createButton.titleLabel.font = [UIFont fontWithName:TAP_FONT_LATO_BOLD size:17.0f];
        self.createButton.layer.borderWidth = 1.0f;
        self.createButton.layer.borderColor = [TAPUtil getColor:@"D9D9D9"].CGColor;
        self.createButton.layer.cornerRadius = 6.0f;
        self.createButton.clipsToBounds = YES;
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.createButton.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[TAPUtil getColor:@"CBCBCB"].CGColor, (id)[TAPUtil getColor:@"D9D9D9"].CGColor, nil];
        gradient.startPoint = CGPointMake(0.0f, 0.0f);
        gradient.endPoint = CGPointMake(0.0f, 1.0f);
        gradient.cornerRadius = 6.0f;
        [self.createButton.layer insertSublayer:gradient atIndex:0];
        self.createButton.userInteractionEnabled = NO;
        [self.bgScrollView addSubview:self.createButton];
    }
    
    return self;
}
#pragma mark - Custom Method
- (void)setGroupPictureImageViewWithImage:(UIImage *)image {
    self.groupPictureImageView.image = image;
    
    self.groupPictureImageView.alpha = 1.0f;
    self.groupPictureView.alpha = 0.0f;
    self.groupPictureIconImageView.alpha = 0.0f;
}

@end
