//
//  TAPMyAccountViewController.m
//  TapTalk
//
//  Created by Dominic Vedericho on 04/05/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPMyAccountViewController.h"
#import "TAPMyAccountView.h"
#import "TAPImagePreviewCollectionViewCell.h"

@interface TAPMyAccountViewController () <TAPCustomTextFieldViewDelegate, UIScrollViewDelegate, TAPCustomButtonViewDelegate, UIImagePickerControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, TAPCustomGrowingTextViewDelegate>

@property (strong, nonatomic) TAPMyAccountView *myAccountView;

@property (strong, nonatomic) TAPUserModel *currentUser;

@property (nonatomic) BOOL isUsernameValid;
@property (nonatomic) BOOL isFullNameValid;
@property (nonatomic) BOOL isEmailValid;

@property (strong, nonatomic) NSString *lastCheckUsernameString;
@property (strong, nonatomic) NSString *lastCheckFullNameString;
@property (strong, nonatomic) NSString *lastCheckEmailString;
@property (strong, nonatomic) UIButton *editButton;
@property (strong, nonatomic) UIButton *saveButton;
@property (strong, nonatomic) UIBarButtonItem *barButtonRightItem;
@property (nonatomic) NSInteger lastPageIndicatorIndex;
@property (strong, nonatomic) NSMutableArray<TAPPhotoListModel *> *photoListArray;

@property (strong, nonatomic) UIImage *selectedProfileImage;
@property (nonatomic) CGFloat keyboardHeight;

- (void)refreshButtonState;
- (void)checkUsername;
- (void)checkFullName;
- (void)checkEmail;
- (void)checkUsernameAPI:(NSString *)username;
- (void)removeProfilePictureButtonDidTapped;
- (void)changeProfilePictureButtonDidTapped;
- (void)cancelButtonDidTapped;
- (void)openCamera;
- (void)openGallery;
- (void)fetchUserDataWithUser:(TAPUserModel *)user;
- (void)logoutButtonDidTapped;

@end

@implementation TAPMyAccountViewController

#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    _myAccountView = [[TAPMyAccountView alloc] initWithFrame:[TAPBaseView frameWithoutNavigationBar]];
    [self.view addSubview:self.myAccountView];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.myAccountView.scrollView.delegate = self;
    self.photoListArray = [NSMutableArray array];
    
    self.myAccountView.fullNameTextField.delegate = self;
    self.myAccountView.usernameTextField.delegate = self;
    self.myAccountView.mobileNumberTextField.delegate = self;
    self.myAccountView.emailTextField.delegate = self;
    self.myAccountView.continueButtonView.delegate = self;
    self.myAccountView.profilImageCollectionView.dataSource = self;
    self.myAccountView.profilImageCollectionView.delegate = self;
    self.myAccountView.pageIndicatorCollectionView.dataSource = self;
    self.myAccountView.pageIndicatorCollectionView.delegate = self;
    self.myAccountView.scrollView.delegate = self;
    
    self.myAccountView.bioTextView.delegate = self;
    [self.myAccountView.bioTextView setPlaceholderText:NSLocalizedStringFromTableInBundle(@"Input your bio here.", nil, [TAPUtil currentBundle], @"")];
    
    self.lastPageIndicatorIndex = 0;
    
    [self.myAccountView.cancelButton addTarget:self action:@selector(cancelButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[TapUI sharedInstance] getChangeProfilePictureButtonVisibleState]) {
        [self.myAccountView.changeProfilePictureButton addTarget:self action:@selector(changeProfilePictureButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.myAccountView.removeProfilePictureButton addTarget:self action:@selector(removeProfilePictureButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    }

    if ([[TapUI sharedInstance] getLogoutButtonVisibleState]) {
        //Handle only when logout is visible
        [self.myAccountView.logoutButton addTarget:self action:@selector(logoutButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.myAccountView setContinueButtonEnabled:YES];
    
    _currentUser = [TAPDataManager getActiveUser];
    [self fetchUserDataWithUser:self.currentUser];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //DV Note
    //Temporary disabled all waiting for API update user
    [self.myAccountView setContentEditable:NO];
    [self.myAccountView showAccountDetailView];
    //END DV Note
    [self setupNavigationViewData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
 }

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - Delegate
#pragma mark CollectionView
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if(collectionView == self.myAccountView.pageIndicatorCollectionView){
        CGSize cellSize = CGSizeMake((CGRectGetWidth([UIScreen mainScreen].bounds) / self.photoListArray.count) - 1, 3.0f);
        return cellSize;
    }
    else if(collectionView == self.myAccountView.profilImageCollectionView){
        CGSize cellSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 360.0f);
        return cellSize;
    }
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    if(collectionView == self.myAccountView.pageIndicatorCollectionView){
        return 1.0f;
    }
    else if(collectionView == self.myAccountView.profilImageCollectionView){
        return 0.0f;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if(collectionView == self.myAccountView.pageIndicatorCollectionView){
        return 1.0f;
    }
    else if(collectionView == self.myAccountView.profilImageCollectionView){
        return 0.0f;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.photoListArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = @"TAPImagePreviewCollectionViewCell";
    [collectionView registerClass:[TAPImagePreviewCollectionViewCell class] forCellWithReuseIdentifier:cellID];
    TAPImagePreviewCollectionViewCell *cell = (TAPImagePreviewCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    
    [cell setImagePreviewCollectionViewCellType:TAPImagePreviewCollectionViewCellTypeProfileImage];
    //[cell setImagePreviewCollectionViewCellStateType:TAPImagePreviewCollectionViewCellStateTypeDefault];
    if(collectionView == self.myAccountView.pageIndicatorCollectionView){
        if(indexPath.row == 0){
            [cell setPageIndicatorActive:YES];
        }
        else{
            [cell setPageIndicatorActive:NO];
        }
    }
    else{
        //UIImage *image = [UIImage imageNamed:@"TAPIconDefaultGroupAvatar"];
        NSString *imageUrl = self.photoListArray[indexPath.row].fullsizeImageURL;
        [cell setImagePreviewImageWithUrl:imageUrl];
        //cell.backgroundColor = [TAPUtil randomPastelColor];
    }
    
    return cell;
}
#pragma mark TAPCustomGrowingTextView
- (void)customGrowingTextView:(UITextView *)textView shouldChangeHeight:(CGFloat)height {
    [UIView animateWithDuration:0.1f animations:^{
        [self.myAccountView updateGrowingTextViewPosition:height];
    }];
}

- (void)customGrowingTextViewDidBeginEditing:(UITextView *)textView {
    [TAPUtil performBlock:^{
        CGFloat additionalHeight = 0.0f;
        additionalHeight = self.myAccountView.bioTextView.frame.origin.y + (self.keyboardHeight + 28.0f);
        [self.myAccountView.scrollView setContentOffset:CGPointMake(0, additionalHeight) animated:YES];
    } afterDelay:0.1f];
  
}

- (BOOL)customGrowingTextView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    NSInteger textLength = [newString length];
    
    [self.myAccountView setCurrentWordCountWithCurrentCharCount:textLength];
    
    if (textLength > [[TapTalk sharedInstance] getMaxCaptionLength]) {
        return NO;
    }
    
    return YES;
    
}




#pragma mark TAPCustomTextFieldView
- (BOOL)customTextFieldViewTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if (textField == self.myAccountView.fullNameTextField.textField) {
        _isFullNameValid = NO;
        _lastCheckFullNameString = newText;
        [self performSelector:@selector(checkFullName) withObject:newText afterDelay:1.0f];
    }
    else if (textField == self.myAccountView.usernameTextField.textField) {
        _isUsernameValid = NO;
        _lastCheckUsernameString = newText;
        [self performSelector:@selector(checkUsername) withObject:nil afterDelay:1.0f];
    }
    else if (textField == self.myAccountView.emailTextField.textField) {
        _isEmailValid = NO;
        _lastCheckEmailString = newText;
        [self performSelector:@selector(checkEmail) withObject:newText afterDelay:1.0f];
    }
    
    [self refreshButtonState];
    
    return YES;
}

- (BOOL)customTextFieldViewTextFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.myAccountView.fullNameTextField.textField) {
        [self.myAccountView.usernameTextField.textField becomeFirstResponder];
    }
    else if (textField == self.myAccountView.usernameTextField.textField) {
        [self.myAccountView.usernameTextField.textField resignFirstResponder];
    }
    
    return YES;
}

- (BOOL)customTextFieldViewTextFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (void)customTextFieldViewTextFieldDidBeginEditing:(UITextField *)textField {
    
}

- (BOOL)customTextFieldViewTextFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (void)customTextFieldViewTextFieldDidEndEditing:(UITextField *)textField {
    
}

- (BOOL)customTextFieldViewTextFieldShouldClear:(UITextField *)textField {
    return YES;
}

#pragma mark TAPCustomButtonView
- (void)customButtonViewDidTappedButton {
    //CONTINUE BUTTON TAPPED
//    [self.myAccountView.continueButtonView setAsLoading:YES animated:NO];
//    [self.myAccountView setContentEditable:NO];
//
//    //TODO
//    //API Update User
//
//    [self.myAccountView.continueButtonView setAsLoading:NO animated:NO];
//    [self.myAccountView setContentEditable:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIScrollView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (void)scrollViewDidEnd:(UIScrollView *)scrollView {

    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat scrollViewHeight = CGRectGetHeight(scrollView.frame);
    CGFloat scrollContentSizeHeight = scrollView.contentSize.height;
    CGFloat currentYOffset = scrollView.contentOffset.y;
    
    if(scrollView == self.myAccountView.profilImageCollectionView){
        NSInteger currentIndex = roundf(scrollView.contentOffset.x / CGRectGetWidth([UIScreen mainScreen].bounds));
        [self updatePageIndicator:currentIndex];
        self.lastPageIndicatorIndex = currentIndex;
    }

    if (IS_IPHONE_X_FAMILY) {
        if (currentYOffset + scrollViewHeight >= scrollContentSizeHeight) {
            //Reach bottom of scrollView
            self.myAccountView.navigationSeparatorView.alpha = 1.0f;
            self.myAccountView.shadowView.alpha = 1.0f;
        }
        else {
            CGFloat maxOffset = 120.0f;
            
            //Default position offset
            if (currentYOffset <= -44.0f) {
                self.myAccountView.navigationSeparatorView.alpha = 0.0f;
                self.myAccountView.shadowView.alpha = 0.0f;
                
                CGFloat heightDifference = fabsf(currentYOffset + 44.0f);
                self.myAccountView.additionalWhiteBounceView.frame = CGRectMake(CGRectGetMinX(self.myAccountView.additionalWhiteBounceView.frame), -heightDifference, CGRectGetWidth(self.myAccountView.additionalWhiteBounceView.frame), heightDifference);
            }
            else if (currentYOffset >= maxOffset) {
                self.myAccountView.navigationSeparatorView.alpha = 1.0f;
                self.myAccountView.shadowView.alpha = 1.0f;
            }
            else {
                CGFloat percentage = (currentYOffset + 44.0f) / 164.0f;
                self.myAccountView.navigationSeparatorView.alpha = percentage;
                self.myAccountView.shadowView.alpha = percentage;
            }
        }
    }
    else {
        if (currentYOffset + scrollViewHeight >= scrollContentSizeHeight) {
            //Reach bottom of scrollView
            self.myAccountView.navigationSeparatorView.alpha = 1.0f;
            self.myAccountView.shadowView.alpha = 1.0f;
        }
        else {
            CGFloat maxOffset = 180.0f;
            
            //Default position offset
            if (currentYOffset <= -20.0f) {
                self.myAccountView.navigationSeparatorView.alpha = 0.0f;
                self.myAccountView.shadowView.alpha = 0.0f;
                
                CGFloat heightDifference = fabsf(currentYOffset + 20.0f);
                self.myAccountView.additionalWhiteBounceView.frame = CGRectMake(CGRectGetMinX(self.myAccountView.additionalWhiteBounceView.frame), -heightDifference, CGRectGetWidth(self.myAccountView.additionalWhiteBounceView.frame), heightDifference);

            }
            else if (currentYOffset >= maxOffset) {
                self.myAccountView.navigationSeparatorView.alpha = 1.0f;
                self.myAccountView.shadowView.alpha = 1.0f;
            }
            else {
                CGFloat percentage = (currentYOffset + 20.0f) / 200.0f;
                self.myAccountView.navigationSeparatorView.alpha = percentage;
                self.myAccountView.shadowView.alpha = percentage;
            }
        }
    }
}

#pragma mark UIImagePickerController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        if ([[info objectForKey:@"UIImagePickerControllerMediaType"] isEqualToString:@"public.image"]) {
            //IMAGE TYPE
            UIImage *selectedImage;
            
            if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
                selectedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
            }
            else if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
                selectedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
            }
            
            self.selectedProfileImage = selectedImage;
            //[self.myAccountView setProfilePictureWithImage:self.selectedProfileImage userFullName:self.currentUser.fullname];
            
            [self.myAccountView setAsLoadingState:YES withType:TAPMyAccountLoadingTypeSetProfilPicture];
            //upload Image
            [[TAPFileUploadManager sharedManager] resizeImage:self.selectedProfileImage maxImageSize:TAP_MAX_IMAGE_LARGE_SIZE success:^(UIImage * _Nonnull resizedImage) {
                
                NSData *imageData = UIImageJPEGRepresentation(resizedImage, [[TapTalk sharedInstance] getImageCompressionQuality]);
                
                [TAPDataManager callAPIUploadUserImageWithImageData:imageData completionBlock:^(TAPUserModel *user) {
                    [self.myAccountView setAsLoadingState:NO withType:TAPMyAccountLoadingTypeSetProfilPicture];
                    [self getPhotoListApi];
                    if ([self.delegate respondsToSelector:@selector(myAccountViewControllerDoneChangingImageProfile)]) {
                        [self.delegate myAccountViewControllerDoneChangingImageProfile];
                    }
                    
                } progressBlock:^(CGFloat progress, CGFloat total) {
                    [self.myAccountView animateProgressUploadingImageWithProgress:progress total:total];
                } failureBlock:^(NSError *error) {
                    //Show error, retry or skip popup
                    [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDefault popupIdentifier:@"Error Upload Profile Image In Account" title:NSLocalizedStringFromTableInBundle(@"Failed to upload image", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"An error occurred while uploading your profile picture, would you like to try again?", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"Retry", nil, [TAPUtil currentBundle], @"") singleOrRightOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"")];
                    

                    [self.myAccountView setAsLoadingState:NO withType:TAPMyAccountLoadingTypeSetProfilPicture];
                }];
            }];
            
        }
    }];
}

#pragma mark - Custom Method
- (void)backButtonDidTapped {
    if(self.myAccountView.editViewContainer.alpha == 1){
        NSString *bio = self.myAccountView.bioTextView.text;
        bio = [TAPUtil nullToEmptyString:bio];
        [self.view endEditing:YES];
        if([bio isEqualToString:self.currentUser.bio]){
            [self.myAccountView showAccountDetailView];
            self.barButtonRightItem.customView = self.editButton;
            [self.navigationItem setRightBarButtonItem:self.barButtonRightItem];
            self.title = self.currentUser.fullname;
        }
        else{
            [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDestructive popupIdentifier:@"unsavedChanges"  title:NSLocalizedStringFromTableInBundle(@"You have unsaved changes!", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"All updates will not be saved. Are you sure you want to continue?", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:@"Cancel" singleOrRightOptionButtonTitle:@"Yes"];
        }
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)updatePageIndicator:(NSInteger)currentIndex{
    TAPImagePreviewCollectionViewCell *cellActive = (TAPImagePreviewCollectionViewCell *)[self.myAccountView.pageIndicatorCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currentIndex inSection:0]];
    [cellActive setPageIndicatorActive:YES];
    
    if(currentIndex != self.lastPageIndicatorIndex){
        TAPImagePreviewCollectionViewCell *cellDisable = (TAPImagePreviewCollectionViewCell *)[self.myAccountView.pageIndicatorCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.lastPageIndicatorIndex inSection:0]];
       [cellDisable setPageIndicatorActive:NO];
    }
   
}
- (void)setupNavigationViewData {
    //This method is used to setup the title view of navigation bar, and also bar button view
    
    TAPRoomModel *room = [TAPChatManager sharedManager].activeRoom;
    self.title = self.currentUser.fullname;
    //Edit Button
    UIColor *buttonLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorNavigationBarButtonLabel];
    UIFont *buttonLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontNavigationBarButtonLabel];
    self.editButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 33.0f, 24.0f)];
    [self.editButton setTitle:@"Edit" forState:UIControlStateNormal];
    [self.editButton setTitleColor:buttonLabelColor forState:UIControlStateNormal];
    self.editButton.titleLabel.font = buttonLabelFont;
    self.barButtonRightItem = [[UIBarButtonItem alloc] initWithCustomView:self.editButton];
    [self.editButton addTarget:self action:@selector(navigationBarActionButtonEditDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:self.barButtonRightItem];
    
    //Save Button
    self.saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 33.0f, 24.0f)];
    [self.saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [self.saveButton setTitleColor:buttonLabelColor forState:UIControlStateNormal];
    self.saveButton.titleLabel.font = buttonLabelFont;
    [self.saveButton addTarget:self action:@selector(navigationBarActionButtonSaveDidTapped) forControlEvents:UIControlEventTouchUpInside];
    
    //Back Bar Button
    UIImage *buttonImage = [UIImage imageNamed:@"TAPIconBackArrow" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    buttonImage = [buttonImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconNavigationBarBackButton]];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
}

- (void)getPhotoListApi{
    [TAPDataManager callAPIGetPhotoList:@"" success:^(NSMutableArray<TAPPhotoListModel *> * photoListArray) {
        if(photoListArray.count > 0 && photoListArray != nil){
            self.photoListArray = photoListArray;
            [self.myAccountView showMultipleProfilePicture];
            [self.myAccountView.profilImageCollectionView reloadData];
            [self.myAccountView.pageIndicatorCollectionView reloadData];
            self.lastPageIndicatorIndex = 0;
            [self.myAccountView.profilImageCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
            [self.myAccountView.pageIndicatorCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
            
            self.currentUser.imageURL.thumbnail = self.photoListArray[0].fullsizeImageURL;
            [TAPDataManager setActiveUser:self.currentUser];
            [self.myAccountView setEditPorfilPictureButtonVisible:YES];
            //[TAPChatManager sharedManager].activeUser.imageURL.thumbnail = self.photoListArray[0].fullsizeImageURL;
        }
        else{
            [self.myAccountView setProfilePictureWithImageURL:@"" userFullName:self.currentUser.fullname];
            self.currentUser.imageURL.thumbnail = @"";
            [TAPDataManager setActiveUser:self.currentUser];
            if(self.myAccountView.editViewContainer.alpha == 1){
                [self.myAccountView setEditPorfilPictureButtonVisible:NO];
            }
            
        }
        
    } failure:^(NSError *error) {
        NSString *errorMessage = [error.userInfo objectForKey:@"message"];
        errorMessage = [TAPUtil nullToEmptyString:errorMessage];
        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Get Photo List" title:NSLocalizedStringFromTableInBundle(@"Failed", nil, [TAPUtil currentBundle], @"") detailInformation:errorMessage leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
    }];
}

- (void)navigationBarActionButtonEditDidTapped{
   // [self fetchUserDataWithUser:self.currentUser];
    
    if(![self.currentUser.bio isEqualToString:@""]){
        self.myAccountView.bioTextView.text = self.currentUser.bio ;
        [self.myAccountView setCurrentWordCountWithCurrentCharCount:self.currentUser.bio .length];
        [self.myAccountView refreshViewPosition];
    }
    else{
        self.myAccountView.bioTextView.text = @"";
    }
    
    [self.myAccountView showEditAccountView];
    self.barButtonRightItem.customView = self.saveButton;
    [self.navigationItem setRightBarButtonItem:self.barButtonRightItem];
    self.title = @"Account Details";
    if(self.photoListArray.count == 0 || self.photoListArray == nil){
        [self.myAccountView setEditPorfilPictureButtonVisible:NO];
    }
}

- (void)navigationBarActionButtonSaveDidTapped{
    NSString *bio = self.myAccountView.bioTextView.text;
    bio = [TAPUtil nullToEmptyString:bio];
    [self.view endEditing:YES];
    if([bio isEqualToString:self.currentUser.bio]){
        [self.myAccountView showAccountDetailView];
        self.barButtonRightItem.customView = self.editButton;
        [self.navigationItem setRightBarButtonItem:self.barButtonRightItem];
        self.title = self.currentUser.fullname;
        return;
    }
    
    [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDefault popupIdentifier:@"upadateBio"  title:NSLocalizedStringFromTableInBundle(@"Save Changes?", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"You will be saving new changes on your profile. Are you sure you want to continue?", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:@"Cancel" singleOrRightOptionButtonTitle:@"Save"];
    
}

- (void)callUpdateBioApi{
    NSString *bio = self.myAccountView.bioTextView.text;
    bio = [TAPUtil nullToEmptyString:bio];
    [self.myAccountView setAsLoadingState:YES withType:TAPMyAccountLoadingTypeUpadating];
    [TAPDataManager callAPIUpdateBio:bio success:^(TAPUserModel *user) {
        [self.myAccountView setAsLoadingState:NO withType:TAPMyAccountLoadingTypeUpadating];
        [self.myAccountView showAccountDetailView];
        [self fetchUserDataWithUser:user];
        self.barButtonRightItem.customView = self.editButton;
        [self.navigationItem setRightBarButtonItem:self.barButtonRightItem];
        self.title = self.currentUser.fullname;
       
    } failure:^(NSError *error) {
        [self.myAccountView setAsLoadingState:NO withType:TAPMyAccountLoadingTypeUpadating];
        NSString *errorMessage = [error.userInfo objectForKey:@"message"];
        errorMessage = [TAPUtil nullToEmptyString:errorMessage];
        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Update Bio" title:NSLocalizedStringFromTableInBundle(@"Failed", nil, [TAPUtil currentBundle], @"") detailInformation:errorMessage leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
    }];
}

- (void)keyboardWillShowWithHeight:(CGFloat)keyboardHeight {
    [super keyboardWillShowWithHeight:keyboardHeight];
    _keyboardHeight = keyboardHeight;
    [UIView animateWithDuration:0.2f animations:^{
        self.myAccountView.scrollView.frame = CGRectMake(CGRectGetMinX(self.myAccountView.scrollView.frame), CGRectGetMinY(self.myAccountView.scrollView.frame), CGRectGetWidth(self.myAccountView.scrollView.frame), CGRectGetHeight(self.myAccountView.frame) - keyboardHeight);
    }];
}

- (void)keyboardWillHideWithHeight:(CGFloat)keyboardHeight {
    [super keyboardWillHideWithHeight:keyboardHeight];
    _keyboardHeight = keyboardHeight;
    [UIView animateWithDuration:0.2f animations:^{
        self.myAccountView.scrollView.frame = [TAPBaseView frameWithoutNavigationBar];
    }];
}

- (void)refreshButtonState {
    if (![TAPUtil isEmptyString:self.myAccountView.fullNameTextField.textField.text] && ![TAPUtil isEmptyString:self.myAccountView.usernameTextField.textField.text] && ![TAPUtil isEmptyString:self.myAccountView.mobileNumberTextField.textField.text] && self.isFullNameValid && self.isUsernameValid) {
        
        if (![TAPUtil isEmptyString:self.myAccountView.emailTextField.textField.text]) {
            //IF EMAIL FILLED
            if (self.isEmailValid) {
                [self.myAccountView setContinueButtonEnabled:YES];
            }
            else {
                [self.myAccountView setContinueButtonEnabled:NO];
            }
        }
        else {
            //PASSWORD AND EMAIL NOT FILLED
            [self.myAccountView setContinueButtonEnabled:YES];
        }
    }
    else {
        [self.myAccountView setContinueButtonEnabled:NO];
    }
}

- (void)checkUsername {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    NSString *username = self.lastCheckUsernameString;
    if (![TAPUtil validateUsername:username] && ![TAPUtil isEmptyString:username]) {
        [self.myAccountView.usernameTextField setAsError:YES animated:YES];
        [self.myAccountView.usernameTextField setErrorInfoText:NSLocalizedStringFromTableInBundle(@"Invalid Username", nil, [TAPUtil currentBundle], @"")];
        [self.myAccountView refreshViewPosition];
        _isUsernameValid = NO;
    }
    else if (([username length] < 4 || [username length] > 32) && ![TAPUtil isEmptyString:username]) {
        [self.myAccountView.usernameTextField setAsError:YES animated:YES];
        [self.myAccountView.usernameTextField setErrorInfoText:NSLocalizedStringFromTableInBundle(@"Username's length must be 4-32 characters", nil, [TAPUtil currentBundle], @"")];
        [self.myAccountView refreshViewPosition];
        _isUsernameValid = NO;
    }
    else {
        [self.myAccountView.usernameTextField setAsError:NO animated:YES];
        [self.myAccountView.usernameTextField setErrorInfoText:@""];
        [self.myAccountView refreshViewPosition];
        if (![TAPUtil isEmptyString:username]) {
            [self checkUsernameAPI:username];
        }
        else {
            _isUsernameValid = NO;
        }
    }
    [self refreshButtonState];
}

- (void)checkFullName {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    NSString *fullName = self.lastCheckFullNameString;
    if (![TAPUtil isAlphabetCharactersOnlyFromText:fullName] && ![TAPUtil isEmptyString:fullName]) {
        [self.myAccountView.fullNameTextField setAsError:YES animated:YES];
        [self.myAccountView.fullNameTextField setErrorInfoText:NSLocalizedStringFromTableInBundle(@"Invalid Full Name", nil, [TAPUtil currentBundle], @"")];
        [self.myAccountView refreshViewPosition];
        _isFullNameValid = NO;
    }
    else {
        [self.myAccountView.fullNameTextField setAsError:NO animated:YES];
        [self.myAccountView.fullNameTextField setErrorInfoText:@""];
        [self.myAccountView refreshViewPosition];
        _isFullNameValid = YES;
    }
    [self refreshButtonState];
}

- (void)checkUsernameAPI:(NSString *)username {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [TAPDataManager callAPICheckUsername:username success:^(BOOL isExists, NSString *checkedUsername) {
        if ([checkedUsername isEqualToString:self.myAccountView.usernameTextField.textField.text]) {
            if (isExists) {
                [self.myAccountView.usernameTextField setAsError:YES animated:YES];
                [self.myAccountView.usernameTextField setErrorInfoText:NSLocalizedStringFromTableInBundle(@"Username already exists", nil, [TAPUtil currentBundle], @"")];
                [self.myAccountView refreshViewPosition];
                _isUsernameValid = NO;
            }
            else {
                [self.myAccountView.usernameTextField setAsError:NO animated:YES];
                [self.myAccountView.usernameTextField setErrorInfoText:@""];
                [self.myAccountView refreshViewPosition];
                _isUsernameValid = YES;
            }
            [self refreshButtonState];
        }
    } failure:^(NSError *error) {
        _isUsernameValid = NO;
        [self.myAccountView.usernameTextField setAsError:YES animated:YES];
        if (error.code == 999) {
            [self.myAccountView.usernameTextField setErrorInfoText:@"Unable to verify username, please check your connection and try again"];
        }
        else {
            NSString *errorMessage = [error.userInfo objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            [self.myAccountView.usernameTextField setErrorInfoText:errorMessage];
        }
        
        [self.myAccountView refreshViewPosition];
        [self refreshButtonState];
    }];
}

- (void)checkEmail {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    NSString *email = self.lastCheckEmailString;
    if (![TAPUtil validateEmail:email] && ![TAPUtil isEmptyString:email]) {
        [self.myAccountView.emailTextField setAsError:YES animated:YES];
        [self.myAccountView.emailTextField setErrorInfoText:NSLocalizedStringFromTableInBundle(@"Invalid email address", nil, [TAPUtil currentBundle], @"")];
        [self.myAccountView refreshViewPosition];
        _isEmailValid = NO;
    }
    else {
        [self.myAccountView.emailTextField setAsError:NO animated:YES];
        [self.myAccountView.emailTextField setErrorInfoText:@""];
        [self.myAccountView refreshViewPosition];
        _isEmailValid = YES;
    }
    [self refreshButtonState];
}

- (void)removeProfilePictureButtonDidTapped {
    self.selectedProfileImage = nil;
    [self.myAccountView setProfilePictureWithImage:self.selectedProfileImage userFullName:self.currentUser.fullname];
}

- (void)setPhotoAsMain{
    NSString *userID = self.photoListArray[self.lastPageIndicatorIndex].userID;
    [self.myAccountView setAsLoadingState:YES withType:TAPMyAccountLoadingTypeUpadating];
    [TAPDataManager callAPISetProfilePhotoAsMain:[userID intValue] success:^() {
        [self.myAccountView setAsLoadingState:NO withType:TAPMyAccountLoadingTypeUpadating];
        [self getPhotoListApi];
        if ([self.delegate respondsToSelector:@selector(myAccountViewControllerDoneChangingImageProfile)]) {
            [self.delegate myAccountViewControllerDoneChangingImageProfile];
        }
    } failure:^(NSError *error) {
        [self.myAccountView setAsLoadingState:NO withType:TAPMyAccountLoadingTypeUpadating];
        NSString *errorMessage = [error.userInfo objectForKey:@"message"];
        errorMessage = [TAPUtil nullToEmptyString:errorMessage];
        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Update Bio" title:NSLocalizedStringFromTableInBundle(@"Failed", nil, [TAPUtil currentBundle], @"") detailInformation:errorMessage leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
    }];
}

- (void)removePhoto{
    NSString *userID = self.photoListArray[self.lastPageIndicatorIndex].userID;
    NSString *createdTime = self.photoListArray[self.lastPageIndicatorIndex].createdTime;
    [self.myAccountView setAsLoadingState:YES withType:TAPMyAccountLoadingTypeUpadating];
    [TAPDataManager callAPIRemovePhotoProfile:[userID intValue] createdTime:[createdTime longLongValue] success:^() {
        [self.myAccountView setAsLoadingState:NO withType:TAPMyAccountLoadingTypeUpadating];
        [self getPhotoListApi];
        if ([self.delegate respondsToSelector:@selector(myAccountViewControllerDoneChangingImageProfile)]) {
            [self.delegate myAccountViewControllerDoneChangingImageProfile];
        }
    } failure:^(NSError *error) {
        [self.myAccountView setAsLoadingState:NO withType:TAPMyAccountLoadingTypeUpadating];
        NSString *errorMessage = [error.userInfo objectForKey:@"message"];
        errorMessage = [TAPUtil nullToEmptyString:errorMessage];
        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Update Bio" title:NSLocalizedStringFromTableInBundle(@"Failed", nil, [TAPUtil currentBundle], @"") detailInformation:errorMessage leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
    }];
}

- (void)saveProfilePicture{
    TAPImagePreviewCollectionViewCell *cellActive = (TAPImagePreviewCollectionViewCell *)[self.myAccountView.profilImageCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.lastPageIndicatorIndex inSection:0]];
    
    [self.myAccountView setAsLoadingState:YES withType:TAPMyAccountLoadingTypeSaveImage];
    UIImage *currentImage = cellActive.selectedPictureImageView.image;
    if(currentImage == nil) {
        //[self showFinishSavingImageState];
        [self.myAccountView setAsLoadingState:NO withType:TAPMyAccountLoadingTypeSaveImage];
    }
    else {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized) {
                    UIImageWriteToSavedPhotosAlbum(currentImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                }
                else if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
                    //[self removeSaveImageLoadingView];
                    //No permission. Trying to normally request it
                    [self.myAccountView setAsLoadingState:NO withType:TAPMyAccountLoadingTypeSaveImage];
                    
                    NSString *accessDescription = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSPhotoLibraryUsageDescription"];
                    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:accessDescription message:NSLocalizedStringFromTableInBundle(@"To give permissions tap on 'Change Settings' button", nil, [TAPUtil currentBundle], @"") preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"") style:UIAlertActionStyleCancel handler:nil];
                                            [alertController addAction:cancelAction];
                    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"Change Settings", nil, [TAPUtil currentBundle], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                          
                        if (IS_IOS_11_OR_ABOVE) {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:[NSDictionary dictionary] completionHandler:nil];
                        }
                        else {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                        }
                    }];
                    [alertController addAction:settingsAction];
    
                    [self presentViewController:alertController animated:YES completion:nil];
                }
            });
        }];
    }
}

//Override completionSelector method of save image to gallery
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (error == nil && status == PHAuthorizationStatusAuthorized) {
        //[self showFinishSavingImageState];
        [self.myAccountView setAsLoadingState:NO withType:TAPMyAccountLoadingTypeSaveImage];
    }
    else {
        [self.myAccountView setAsLoadingState:NO withType:TAPMyAccountLoadingTypeSaveImage];
        //[self removeSaveImageLoadingView];
    }
}

- (void)setAsMainPopupView{
    [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDefault popupIdentifier:@"setAsMain"  title:NSLocalizedStringFromTableInBundle(@"Set as Main Photo?", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"You will be replacing the main photo with this photo. Are you sure you want to continue?", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:@"Cancel" singleOrRightOptionButtonTitle:@"Replace"];
}

- (void)removePhotoPopupView{
    [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDestructive popupIdentifier:@"removePhoto"  title:NSLocalizedStringFromTableInBundle(@"Remove Photo?", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"You will be removing this profile picture. Are you sure you want to continue?", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:@"Cancel" singleOrRightOptionButtonTitle:@"Remove"];
}

- (void)changeProfilePictureButtonDidTapped {
    if(self.myAccountView.editViewContainer.alpha == 1){
        //edit profil picture
        
        if(self.photoListArray.count == 0){
            [self getPhotoListApi];
            return;
        }
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
        UIAlertAction *mainPhotoAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedStringFromTableInBundle(@"Set as Main Photo", nil, [TAPUtil currentBundle], @"")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       [self setAsMainPopupView];
                                   }];
    
        UIAlertAction *saveImageAction = [UIAlertAction
                                    actionWithTitle:NSLocalizedStringFromTableInBundle(@"Save Image", nil, [TAPUtil currentBundle], @"")
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        [self saveProfilePicture];
                                    }];
        
        UIAlertAction *removeAction = [UIAlertAction
                                        actionWithTitle:NSLocalizedStringFromTableInBundle(@"Remove Photo", nil, [TAPUtil currentBundle], @"")
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            [self removePhotoPopupView];
                                        }];
    
        UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
                                       //Do some thing here
                                   }];
    
    UIImage *mainActionImage = [UIImage imageNamed:@"TAPIconGallery" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    mainActionImage = [mainActionImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconSelectPictureCamera]];
    [mainPhotoAction setValue:[mainActionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    UIImage *saveActionImage = [UIImage imageNamed:@"TAPIconSaveOrange" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    saveActionImage = [saveActionImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconSelectPictureGallery]];
    [saveImageAction setValue:[saveActionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
        
        
        UIImage *removeActionImage = [UIImage imageNamed:@"TAPIconTrash" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
       // removeActionImage = [removeActionImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconSelectPictureGallery]];
        
        [removeAction setValue:[removeActionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    [mainPhotoAction setValue:@0 forKey:@"titleTextAlignment"];
    [saveImageAction setValue:@0 forKey:@"titleTextAlignment"];
        [removeAction setValue:@0 forKey:@"titleTextAlignment"];
    
    UIColor *actionSheetDefaultColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorActionSheetDefaultLabel];
    UIColor *actionSheetCancelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorActionSheetCancelButtonLabel];
    [mainPhotoAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
    [saveImageAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
        [removeAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
    [cancelAction setValue:actionSheetCancelColor forKey:@"titleTextColor"];
    
        if(self.lastPageIndicatorIndex > 0){
            [alertController addAction:mainPhotoAction];
        }
    
    [alertController addAction:saveImageAction];
        [alertController addAction:removeAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    }
    else{
        //set new profil picture
        if(self.photoListArray.count == 10){
            [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDefault popupIdentifier:@""  title:NSLocalizedStringFromTableInBundle(@"You have reached maximum profile picture.", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"You can only have 10 profile picture at a time, remove some picture to upload new ones.", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:@"" singleOrRightOptionButtonTitle:@"OK"];
            return;
        }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cameraAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedStringFromTableInBundle(@"Camera", nil, [TAPUtil currentBundle], @"")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       [self openCamera];
                                   }];
    
    UIAlertAction *galleryAction = [UIAlertAction
                                    actionWithTitle:NSLocalizedStringFromTableInBundle(@"Gallery", nil, [TAPUtil currentBundle], @"")
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        [self openGallery];
                                    }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
                                       //Do some thing here
                                   }];
    
    UIImage *cameraActionImage = [UIImage imageNamed:@"TAPIconPhoto" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    cameraActionImage = [cameraActionImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconSelectPictureCamera]];
    [cameraAction setValue:[cameraActionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    UIImage *galleryActionImage = [UIImage imageNamed:@"TAPIconGallery" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    galleryActionImage = [galleryActionImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconSelectPictureGallery]];
    [galleryAction setValue:[galleryActionImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forKey:@"image"];
    
    [cameraAction setValue:@0 forKey:@"titleTextAlignment"];
    [galleryAction setValue:@0 forKey:@"titleTextAlignment"];
    
    UIColor *actionSheetDefaultColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorActionSheetDefaultLabel];
    UIColor *actionSheetCancelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorActionSheetCancelButtonLabel];
    [cameraAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
    [galleryAction setValue:actionSheetDefaultColor forKey:@"titleTextColor"];
    [cancelAction setValue:actionSheetCancelColor forKey:@"titleTextColor"];
    
    [alertController addAction:cameraAction];
    [alertController addAction:galleryAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)cancelButtonDidTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)openCamera {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (status == AVAuthorizationStatusAuthorized) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.allowsEditing = NO;
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:imagePicker animated:YES completion:^{
            //completion
        }];
    }
    else if (status == AVAuthorizationStatusNotDetermined) {
        //request
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self openCamera];
            });
        }];
    }
    else {
        //No permission. Trying to normally request it
        NSString *accessDescription = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSPhotoLibraryUsageDescription"];
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:accessDescription message:NSLocalizedStringFromTableInBundle(@"To give permissions tap on 'Change Settings' button", nil, [TAPUtil currentBundle], @"") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"") style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"Change Settings", nil, [TAPUtil currentBundle], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (IS_IOS_11_OR_ABOVE) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:[NSDictionary dictionary] completionHandler:nil];
            }
            else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }];
        [alertController addAction:settingsAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)openGallery {
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusAuthorized) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.allowsEditing = NO;
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:imagePicker animated:YES completion:^{
            //completion
        }];
    }
    else if (status == PHAuthorizationStatusNotDetermined) {
        //request
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self openGallery];
            });
        }];
    }
    else {
        //No permission. Trying to normally request it
        NSString *accessDescription = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSPhotoLibraryUsageDescription"];
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:accessDescription message:NSLocalizedStringFromTableInBundle(@"To give permissions tap on 'Change Settings' button", nil, [TAPUtil currentBundle], @"") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"") style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromTableInBundle(@"Change Settings", nil, [TAPUtil currentBundle], @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (IS_IOS_11_OR_ABOVE) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:[NSDictionary dictionary] completionHandler:nil];
            }
            else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }];
        [alertController addAction:settingsAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)fetchUserDataWithUser:(TAPUserModel *)user {
   
    NSDictionary *savedCountryListDictionary = [[NSUserDefaults standardUserDefaults] secureDictionaryForKey:TAP_PREFS_COUNTRY_LIST_DICTIONARY valid:nil];
    NSDictionary *countryDataDictionary = [savedCountryListDictionary objectForKey:user.countryID];
    TAPCountryModel *country = [TAPDataManager countryModelFromDictionary:countryDataDictionary];
    
    NSString *phoneNumber = user.phone;
    NSString *fullname = user.fullname;
    NSString *username = user.username;
    NSString *email = user.email;
    NSString *imageURL = user.imageURL.fullsize;
    NSString *bio = user.bio;
   
    //Set Fullname
    [self.myAccountView.fullNameTextField setTextFieldWithData:fullname];
    
    //Set Bio
    //[self.myAccountView.usernameTextField setTextFieldWithData:username];
    bio = [TAPUtil nullToEmptyString:bio];
    [self.myAccountView.bioLabelField setAccountDetailFieldString: NSLocalizedStringFromTableInBundle(@"BIO", nil, [TAPUtil currentBundle], @"") description: NSLocalizedStringFromTableInBundle(bio, nil, [TAPUtil currentBundle], @"")];
    
    if(![bio isEqualToString:@""]){
        self.myAccountView.bioTextView.text = bio;
        [self.myAccountView setCurrentWordCountWithCurrentCharCount:bio.length];
        self.myAccountView.bioLabelField.alpha = 1.0f;
        [self.myAccountView.bioLabelField setInfoDesciption:bio];
        //[self.myAccountView.bioLabelField.infoDescriptionLabel sizeToFit];
       // self.myAccountView.bioLabelField.frame = CGRectMake(0.0f, 24.0f, CGRectGetWidth(self.view.frame), 62.0f - 24.0f + CGRectGetHeight(self.myAccountView.bioLabelField.infoDescriptionLabel.frame));
        [self.myAccountView.bioLabelField showSeparatorView:YES];
        [self.myAccountView refreshViewPosition];
    }
    else{
        self.myAccountView.bioTextView.text = @"";
    }
    
    if (![[TapUI sharedInstance] getEditBioTextFieldVisible] || [bio isEqualToString:@""]) {
        // Hide if bio in chat profile is disabled in TapUI
        self.myAccountView.bioLabelField.alpha = 0.0f;
        self.myAccountView.bioLabelField.frame = CGRectMake(0.0f, CGRectGetMinY(self.myAccountView.bioLabelField.frame), 0.0f, 0.0f);
        [self.myAccountView refreshViewPosition];
    }
    
    //Set Username
    [self.myAccountView.usernameTextField setTextFieldWithData:username];
    [self.myAccountView.usernameLabelField setAccountDetailFieldString: NSLocalizedStringFromTableInBundle(@"USERNAME", nil, [TAPUtil currentBundle], @"") description: NSLocalizedStringFromTableInBundle(username, nil, [TAPUtil currentBundle], @"")];
    
    //Set Phone
    [self.myAccountView.mobileNumberTextField setPhoneNumber:phoneNumber country:country];
    [self.myAccountView.mobileNumberLabelField setAccountDetailFieldString: NSLocalizedStringFromTableInBundle(@"MOBILE NUMBER", nil, [TAPUtil currentBundle], @"") description:[NSString stringWithFormat:@"+%@ %@", country.countryCallingCode, phoneNumber]];
    
    //Set Email
    email = [TAPUtil nullToEmptyString:email];
    if([email isEqualToString:@""]){
        self.myAccountView.emailLabelField.alpha = 0.0f;
        self.myAccountView.emailLabelField.frame = CGRectMake(0.0f, CGRectGetMinY(self.myAccountView.emailLabelField.frame), 0.0f, 0.0f);
        [self.myAccountView refreshViewPosition];
    }
    else{
        self.myAccountView.emailLabelField.alpha = 1.0f;
        [self.myAccountView.emailTextField setTextFieldWithData:email];
        [self.myAccountView.emailLabelField  setAccountDetailFieldString: NSLocalizedStringFromTableInBundle(@"EMAIL ADDRESS", nil, [TAPUtil currentBundle], @"") description: NSLocalizedStringFromTableInBundle(email, nil, [TAPUtil currentBundle], @"")];
    }
    
    if(self.myAccountView.editViewContainer.alpha == 1){
        [self.myAccountView showEditAccountView];
    }
    else{
        [self.myAccountView showAccountDetailView];
    }
    
    //Set Profile Picture
    [self.myAccountView setProfilePictureWithImageURL:imageURL userFullName:fullname];
    self.currentUser = user;
    [self getPhotoListApi];
     
}

- (void)logoutButtonDidTapped {
    [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDestructive popupIdentifier:@"Logout" title:NSLocalizedStringFromTableInBundle(@"Logout", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"Are you sure you want to log out?", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"") singleOrRightOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"Logout", nil, [TAPUtil currentBundle], @"")];
}

- (void)popUpInfoTappedSingleButtonOrRightButtonWithIdentifier:(NSString *)popupIdentifier {
    [super popUpInfoTappedSingleButtonOrRightButtonWithIdentifier:popupIdentifier];

    if ([popupIdentifier isEqualToString:@"Error Upload Profile Image In Account"]) {
        //Skip Upload Image
        [self fetchUserDataWithUser:self.currentUser];
    }
    else if ([popupIdentifier isEqualToString:@"Error Logout"]) {

    }
    else if ([popupIdentifier isEqualToString:@"Logout"]) {
        //Logout
        [self.myAccountView showLogoutLoadingView:YES];
        if ([self.delegate respondsToSelector:@selector(myAccountViewControllerDidTappedLogoutButton)]) {
            [self.delegate myAccountViewControllerDidTappedLogoutButton];
        }
        
        BOOL isAuthenticated = [[TapTalk sharedInstance] isAuthenticated];
        if (!isAuthenticated) {
            return;
        }
        
        [TAPDataManager callAPILogoutWithSuccess:^{
            [self logout];
        } failure:^(NSError *error) {
            [self logout];
        }];
        
        
        //[[TapTalk sharedInstance] logoutAndClearAllTapTalkData];
        
        
        //if ([self.delegate respondsToSelector:@selector(userLogout)]) {
          //  [self.delegate userLogout];
        //}
        
        // KR NOTE: USER LOGOUT DELEGATE MOVED TO logoutAndClearAllTapTalkData
//        id<TapTalkDelegate> tapTalkDelegate = [TapTalk sharedInstance].delegate;
//        if ([tapTalkDelegate respondsToSelector:@selector(userLogout)]) {
//            [tapTalkDelegate userLogout];
//        }
    }
    else if ([popupIdentifier isEqualToString:@"setAsMain"]) {
        [self setPhotoAsMain];
    }
    else if ([popupIdentifier isEqualToString:@"removePhoto"]) {
        [self removePhoto];
    }
    else if ([popupIdentifier isEqualToString:@"upadateBio"]) {
        [self callUpdateBioApi];
    }
    else if ([popupIdentifier isEqualToString:@"unsavedChanges"]){
        [self.myAccountView showAccountDetailView];
        self.barButtonRightItem.customView = self.editButton;
        [self.navigationItem setRightBarButtonItem:self.barButtonRightItem];
        self.title = self.currentUser.fullname;
    }
}

- (void)logout{
    [[TapTalk sharedInstance] clearAllTapTalkData];
    [[TapTalk sharedInstance] disconnectWithCompletionHandler:^{
    }];
    
    [self.navigationController popToRootViewControllerAnimated:NO];
    [TapTalk sharedInstance].delegate.userLogout;
    [self dismissViewControllerAnimated:NO completion:nil];
    [self.myAccountView showLogoutLoadingView:NO];
}

- (void)popUpInfoDidTappedLeftButtonWithIdentifier:(NSString *)popupIdentifier {
    [super popUpInfoDidTappedLeftButtonWithIdentifier:popupIdentifier];
    
    if ([popupIdentifier isEqualToString:@"Error Upload Profile Image In Account"]) {
        [self.myAccountView setAsLoadingState:YES withType:TAPMyAccountLoadingTypeSetProfilPicture];
        
        [[TAPFileUploadManager sharedManager] resizeImage:self.selectedProfileImage maxImageSize:TAP_MAX_IMAGE_LARGE_SIZE success:^(UIImage * _Nonnull resizedImage) {
            
            NSData *imageData = UIImageJPEGRepresentation(resizedImage, [[TapTalk sharedInstance] getImageCompressionQuality]);
            
            [TAPDataManager callAPIUploadUserImageWithImageData:imageData completionBlock:^(TAPUserModel *user) {
                [self.myAccountView setAsLoadingState:NO withType:TAPMyAccountLoadingTypeSetProfilPicture];
            } progressBlock:^(CGFloat progress, CGFloat total) {
                [self.myAccountView animateProgressUploadingImageWithProgress:progress total:total];
            } failureBlock:^(NSError *error) {
                //Show error, retry or skip popup
                
                [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDefault popupIdentifier:@"Error Upload Profile Image In Account" title:NSLocalizedStringFromTableInBundle(@"Failed to upload image", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"An error occurred while uploading your profile picture, would you like to try again?", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"Retry", nil, [TAPUtil currentBundle], @"") singleOrRightOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"")];
                
                [self.myAccountView setAsLoadingState:NO withType:TAPMyAccountLoadingTypeSetProfilPicture];
            }];
        }];
    }
    else if ([popupIdentifier isEqualToString:@"Logout"]) {
        
    }
}



@end
