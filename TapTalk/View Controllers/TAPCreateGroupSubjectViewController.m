//
//  TAPCreateGroupSubjectViewController.m
//  TapTalk
//
//  Created by Welly Kencana on 19/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPCreateGroupSubjectViewController.h"
#import "TAPCreateGroupSubjectView.h"

#import "TAPContactCollectionViewCell.h"

@interface TAPCreateGroupSubjectViewController () <UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) TAPCreateGroupSubjectView *createGroupSubjectView;

@end

@implementation TAPCreateGroupSubjectViewController
#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    _createGroupSubjectView = [[TAPCreateGroupSubjectView alloc] initWithFrame:[TAPBaseView frameWithNavigationBar]];
    [self.view addSubview:self.createGroupSubjectView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Group Subject", @"");
    [self showCustomBackButton];
    
    self.createGroupSubjectView.selectedContactsCollectionView.delegate = self;
    self.createGroupSubjectView.selectedContactsCollectionView.dataSource = self;
    
    self.createGroupSubjectView.bgScrollView.delegate = self;
    self.createGroupSubjectView.groupNameTextField.delegate = self;
    
    [self.createGroupSubjectView.groupPictureButton addTarget:self action:@selector(groupPictureButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.createGroupSubjectView.createButton addTarget:self action:@selector(createButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.groupModel.groupImage != nil) {
        [self.createGroupSubjectView setGroupPictureImageViewWithImage:[UIImage imageNamed:self.groupModel.groupImage inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil]];
    }
    if (self.groupModel.groupName != nil) {
        self.createGroupSubjectView.groupNameTextField.text = self.groupModel.groupName;
        
        //hide placeholder
        self.createGroupSubjectView.placeHolderLabel.alpha = 0.0f;
        
        //enable button create
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.createGroupSubjectView.createButton.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[TAPUtil getColor:@"CBCBCB"].CGColor, (id)[TAPUtil getColor:@"D9D9D9"].CGColor, nil];
        gradient.startPoint = CGPointMake(0.0f, 0.0f);
        gradient.endPoint = CGPointMake(0.0f, 1.0f);
        gradient.cornerRadius = 6.0f;
        self.createGroupSubjectView.createButton.layer.borderColor = [TAPUtil getColor:TAP_COLOR_GREENBLUE_93].CGColor;
        gradient.colors = [NSArray arrayWithObjects:(id)[TAPUtil getColor:TAP_COLOR_AQUAMARINE_C1].CGColor, (id)[TAPUtil getColor:TAP_COLOR_MOSELO_GREEN].CGColor, nil];
        [self.createGroupSubjectView.createButton.layer replaceSublayer:[self.createGroupSubjectView.createButton.layer.sublayers objectAtIndex:0] with:gradient];
        self.createGroupSubjectView.createButton.userInteractionEnabled = YES;
    }
}

#pragma mark - Data Source
#pragma mark UICollectionView
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(52.0f, 74.0f);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0.0f, 16.0f, 0.0f, 16.0f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 16.0f;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return 10; //WK Temp
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *cellID = @"TAPContactCollectionViewCell";
        
        [collectionView registerClass:[TAPContactCollectionViewCell class] forCellWithReuseIdentifier:cellID];
        TAPContactCollectionViewCell *cell = (TAPContactCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
        
        //WK Temp
        NSInteger modValue = indexPath.row % 5;
        NSString *nameString;
        if (indexPath.row == 0) { //Group admin
            nameString = @"You";
        }
        else {
            switch (modValue) {
                case 0:
                {
                    nameString = @"Arsya";
                    break;
                }
                case 1:
                {
                    nameString = @"Abdul";
                    break;
                }
                case 2:
                {
                    nameString = @"Binar";
                    break;
                }
                case 3:
                {
                    nameString = @"Adryan";
                    break;
                }
                case 4:
                {
                    nameString = @"Cynthia ";
                    break;
                }
                    
                default:
                    break;
            }
        }
        [cell setContactCollectionViewCellWithModel:nameString];
        [cell showRemoveIcon:NO];
        //End Temp
        
        return cell;
    }
    
    static NSString *cellID = @"UICollectionViewCell";
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellID];
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    
    return cell;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attributesInRect = [NSArray array];
    return attributesInRect;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *reusableview = [[UICollectionReusableView alloc] init];
        return reusableview;
    }
    else if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *reusableview = [[UICollectionReusableView alloc] init];
        return reusableview;
    }
    
    return nil;
}

#pragma mark - Delegate
#pragma mark UICollectionView
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark UIScrollView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.createGroupSubjectView.bgScrollView) {
        [self.view endEditing:YES];
    }
}

#pragma mark UITextField
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.groupModel.groupName = newString;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.createGroupSubjectView.createButton.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[TAPUtil getColor:@"CBCBCB"].CGColor, (id)[TAPUtil getColor:@"D9D9D9"].CGColor, nil];
    gradient.startPoint = CGPointMake(0.0f, 0.0f);
    gradient.endPoint = CGPointMake(0.0f, 1.0f);
    gradient.cornerRadius = 6.0f;
    if ([newString length] <= 0) {
        //show placeholder
        self.createGroupSubjectView.placeHolderLabel.alpha = 1.0f;
        
        //disable button create
        self.createGroupSubjectView.createButton.layer.borderColor = [TAPUtil getColor:@"D9D9D9"].CGColor;
        gradient.colors = [NSArray arrayWithObjects:(id)[TAPUtil getColor:@"CBCBCB"].CGColor, (id)[TAPUtil getColor:@"D9D9D9"].CGColor, nil];
        [self.createGroupSubjectView.createButton.layer replaceSublayer:[self.createGroupSubjectView.createButton.layer.sublayers objectAtIndex:0] with:gradient];
        self.createGroupSubjectView.createButton.userInteractionEnabled = NO;
    }
    else {
        //hide placeholder
        self.createGroupSubjectView.placeHolderLabel.alpha = 0.0f;
        
        //enable button create
        self.createGroupSubjectView.createButton.layer.borderColor = [TAPUtil getColor:TAP_COLOR_GREENBLUE_93].CGColor;
        gradient.colors = [NSArray arrayWithObjects:(id)[TAPUtil getColor:TAP_COLOR_AQUAMARINE_C1].CGColor, (id)[TAPUtil getColor:TAP_COLOR_MOSELO_GREEN].CGColor, nil];
        [self.createGroupSubjectView.createButton.layer replaceSublayer:[self.createGroupSubjectView.createButton.layer.sublayers objectAtIndex:0] with:gradient];
        self.createGroupSubjectView.createButton.userInteractionEnabled = YES;
    }
    
    return YES;
}

#pragma mark - Custom Method
- (void)keyboardWillShowWithHeight:(CGFloat)keyboardHeight {
    self.createGroupSubjectView.bgScrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, keyboardHeight, 0.0f);
}

- (void)keyboardWillHideWithHeight:(CGFloat)keyboardHeight {
    self.createGroupSubjectView.bgScrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
}

- (void)groupPictureButtonDidTapped { //WK Temp
    self.groupModel.groupImage = @"groupPictureDummy";
    [self.createGroupSubjectView setGroupPictureImageViewWithImage:[UIImage imageNamed:self.groupModel.groupImage inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil]];
}

- (void)createButtonDidTapped { //WK Temp
    NSLog(@"create button did tapped");
}

@end
