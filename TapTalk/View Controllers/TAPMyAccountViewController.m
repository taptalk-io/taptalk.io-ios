//
//  TAPMyAccountViewController.m
//  TapTalk
//
//  Created by Dominic Vedericho on 04/05/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPMyAccountViewController.h"
#import "TAPMyAccountView.h"

@interface TAPMyAccountViewController () <TAPCustomTextFieldViewDelegate, UIScrollViewDelegate, TAPCustomButtonViewDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) TAPMyAccountView *myAccountView;

@property (strong, nonatomic) TAPUserModel *currentUser;

@property (nonatomic) BOOL isUsernameValid;
@property (nonatomic) BOOL isFullNameValid;
@property (nonatomic) BOOL isEmailValid;

@property (strong, nonatomic) NSString *lastCheckUsernameString;
@property (strong, nonatomic) NSString *lastCheckFullNameString;
@property (strong, nonatomic) NSString *lastCheckEmailString;

@property (strong, nonatomic) UIImage *selectedProfileImage;

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
    self.myAccountView.scrollView.delegate = self;
    self.myAccountView.fullNameTextField.delegate = self;
    self.myAccountView.usernameTextField.delegate = self;
    self.myAccountView.mobileNumberTextField.delegate = self;
    self.myAccountView.emailTextField.delegate = self;
    self.myAccountView.continueButtonView.delegate = self;
    
    [self.myAccountView.changeProfilePictureButton addTarget:self action:@selector(changeProfilePictureButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.myAccountView.removeProfilePictureButton addTarget:self action:@selector(removeProfilePictureButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.myAccountView.cancelButton addTarget:self action:@selector(cancelButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.myAccountView.logoutButton addTarget:self action:@selector(logoutButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self.myAccountView setContinueButtonEnabled:YES];
    
    _currentUser = [TAPDataManager getActiveUser];
    [self fetchUserDataWithUser:self.currentUser];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //DV Note
    //Temporary disabled all waiting for API update user
    [self.myAccountView setContentEditable:NO];
    //END DV Note
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - Delegate
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {     

    CGFloat scrollViewHeight = CGRectGetHeight(scrollView.frame);
    CGFloat scrollContentSizeHeight = scrollView.contentSize.height;
    CGFloat currentYOffset = scrollView.contentOffset.y;
   
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
            [self.myAccountView setProfilePictureWithImage:self.selectedProfileImage];
            
            [self.myAccountView setAsLoading:YES];
            //upload Image
            [[TAPFileUploadManager sharedManager] resizeImage:self.selectedProfileImage maxImageSize:TAP_MAX_IMAGE_LARGE_SIZE success:^(UIImage * _Nonnull resizedImage) {
                
                NSData *imageData = UIImageJPEGRepresentation(resizedImage, 1.0f);
                
                [TAPDataManager callAPIUploadUserImageWithImageData:imageData completionBlock:^(TAPUserModel *user) {
                    [self.myAccountView setAsLoading:NO];
                } progressBlock:^(CGFloat progress, CGFloat total) {
                    [self.myAccountView animateProgressUploadingImageWithProgress:progress total:total];
                } failureBlock:^(NSError *error) {
                    //Show error, retry or skip popup
                    [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDefault popupIdentifier:@"Error Upload Profile Image In Account" title:NSLocalizedString(@"Failed to upload image", @"") detailInformation:NSLocalizedString(@"An error occurred while uploading your profile picture, would you like to try again?", @"") leftOptionButtonTitle:@"Retry" singleOrRightOptionButtonTitle:@"Cancel"];
                    
                    [self.myAccountView setAsLoading:NO];
                }];
            }];
            
        }
    }];
}

#pragma mark - Custom Method
- (void)keyboardWillShowWithHeight:(CGFloat)keyboardHeight {
    [super keyboardWillShowWithHeight:keyboardHeight];
    [UIView animateWithDuration:0.2f animations:^{
        self.myAccountView.scrollView.frame = CGRectMake(CGRectGetMinX(self.myAccountView.scrollView.frame), CGRectGetMinY(self.myAccountView.scrollView.frame), CGRectGetWidth(self.myAccountView.scrollView.frame), CGRectGetHeight(self.myAccountView.frame) - keyboardHeight);
    }];
}

- (void)keyboardWillHideWithHeight:(CGFloat)keyboardHeight {
    [super keyboardWillHideWithHeight:keyboardHeight];
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
        [self.myAccountView.usernameTextField setErrorInfoText:NSLocalizedString(@"Invalid Username", @"")];
        [self.myAccountView refreshViewPosition];
        _isUsernameValid = NO;
    }
    else if (([username length] < 4 || [username length] > 32) && ![TAPUtil isEmptyString:username]) {
        [self.myAccountView.usernameTextField setAsError:YES animated:YES];
        [self.myAccountView.usernameTextField setErrorInfoText:NSLocalizedString(@"Username's length must be 4-32 characters", @"")];
        [self.myAccountView refreshViewPosition];
        _isUsernameValid = NO;
    }
    else {
        [self.myAccountView.usernameTextField setAsError:NO animated:YES];
        [self.myAccountView.usernameTextField setErrorInfoText:NSLocalizedString(@"", @"")];
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
        [self.myAccountView.fullNameTextField setErrorInfoText:NSLocalizedString(@"Invalid Full Name", @"")];
        [self.myAccountView refreshViewPosition];
        _isFullNameValid = NO;
    }
    else {
        [self.myAccountView.fullNameTextField setAsError:NO animated:YES];
        [self.myAccountView.fullNameTextField setErrorInfoText:NSLocalizedString(@"", @"")];
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
                [self.myAccountView.usernameTextField setErrorInfoText:NSLocalizedString(@"Username already exists", @"")];
                [self.myAccountView refreshViewPosition];
                _isUsernameValid = NO;
            }
            else {
                [self.myAccountView.usernameTextField setAsError:NO animated:YES];
                [self.myAccountView.usernameTextField setErrorInfoText:NSLocalizedString(@"", @"")];
                [self.myAccountView refreshViewPosition];
                _isUsernameValid = YES;
            }
            [self refreshButtonState];
        }
    } failure:^(NSError *error) {
        //        NSLog(@"ERROR - %@", error);
        _isUsernameValid = NO;
        [self.myAccountView.usernameTextField setAsError:YES animated:YES];
        if (error.code == 999) {
            [self.myAccountView.usernameTextField setErrorInfoText:@"Unable to verify username, please check your connection and try again"];
        }
        else {
            [self.myAccountView.usernameTextField setErrorInfoText:error.domain];
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
        [self.myAccountView.emailTextField setErrorInfoText:NSLocalizedString(@"Invalid email address", @"")];
        [self.myAccountView refreshViewPosition];
        _isEmailValid = NO;
    }
    else {
        [self.myAccountView.emailTextField setAsError:NO animated:YES];
        [self.myAccountView.emailTextField setErrorInfoText:NSLocalizedString(@"", @"")];
        [self.myAccountView refreshViewPosition];
        _isEmailValid = YES;
    }
    [self refreshButtonState];
}

- (void)removeProfilePictureButtonDidTapped {
    self.selectedProfileImage = nil;
    [self.myAccountView setProfilePictureWithImage:self.selectedProfileImage];
}

- (void)changeProfilePictureButtonDidTapped {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cameraAction = [UIAlertAction
                                   actionWithTitle:@"Camera"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       [self openCamera];
                                   }];
    
    UIAlertAction *galleryAction = [UIAlertAction
                                    actionWithTitle:@"Gallery"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        [self openGallery];
                                    }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
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
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:accessDescription message:@"To give permissions tap on 'Change Settings' button" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Change Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (IS_IOS_10_OR_ABOVE) {
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
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:accessDescription message:@"To give permissions tap on 'Change Settings' button" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        
        UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Change Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (IS_IOS_10_OR_ABOVE) {
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
    NSString *imageURL = user.imageURL.thumbnail;
   
    //Set Fullname
    [self.myAccountView.fullNameTextField setTextFieldWithData:fullname];
    
    //Set Username
    [self.myAccountView.usernameTextField setTextFieldWithData:username];
    
    //Set Phone
    [self.myAccountView.mobileNumberTextField setPhoneNumber:phoneNumber country:country];
    
    //Set Email
    [self.myAccountView.emailTextField setTextFieldWithData:email];
    
    //Set Profile Picture
    [self.myAccountView setProfilePictureWithImageURL:imageURL];
}

- (void)logoutButtonDidTapped {
    [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDestructive popupIdentifier:@"Logout" title:NSLocalizedString(@"Log Out", @"") detailInformation:NSLocalizedString(@"Are you sure you want to log out?", @"") leftOptionButtonTitle:@"Cancel" singleOrRightOptionButtonTitle:@"Logout"];
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
        
            [[TapTalk sharedInstance] logoutAndClearAllDataWithSuccess:^{
                [self dismissViewControllerAnimated:NO completion:nil];
                [self.myAccountView showLogoutLoadingView:NO];
            } failure:^(NSError *error) {
                //Show alert
                [self.myAccountView showLogoutLoadingView:NO];
                [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Logout" title:NSLocalizedString(@"Error", @"") detailInformation:NSLocalizedString(@"Something went wrong, please try again.", @"") leftOptionButtonTitle:@"" singleOrRightOptionButtonTitle:@"OK"];
            }];
    }
}

- (void)popUpInfoDidTappedLeftButtonWithIdentifier:(NSString *)popupIdentifier {
    [super popUpInfoDidTappedLeftButtonWithIdentifier:popupIdentifier];
    
    if ([popupIdentifier isEqualToString:@"Error Upload Profile Image In Account"]) {
        [self.myAccountView setAsLoading:YES];
        
        [[TAPFileUploadManager sharedManager] resizeImage:self.selectedProfileImage maxImageSize:TAP_MAX_IMAGE_LARGE_SIZE success:^(UIImage * _Nonnull resizedImage) {
            
            NSData *imageData = UIImageJPEGRepresentation(resizedImage, 1.0f);
            
            [TAPDataManager callAPIUploadUserImageWithImageData:imageData completionBlock:^(TAPUserModel *user) {
                [self.myAccountView setAsLoading:NO];
            } progressBlock:^(CGFloat progress, CGFloat total) {
                [self.myAccountView animateProgressUploadingImageWithProgress:progress total:total];
            } failureBlock:^(NSError *error) {
                //Show error, retry or skip popup
                
                [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDefault popupIdentifier:@"Error Upload Profile Image In Account" title:NSLocalizedString(@"Failed to upload image", @"") detailInformation:NSLocalizedString(@"An error occurred while uploading your profile picture, would you like to try again?", @"") leftOptionButtonTitle:@"Retry" singleOrRightOptionButtonTitle:@"Cancel"];
                
                [self.myAccountView setAsLoading:NO];
            }];
        }];
    }
    else if ([popupIdentifier isEqualToString:@"Logout"]) {
        
    }
}

@end
