//
//  TAPRegisterViewController.m
//  TapTalk
//
//  Created by Dominic Vedericho on 02/04/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPRegisterViewController.h"
#import "TAPRegisterView.h"

@interface TAPRegisterViewController () <TAPCustomTextFieldViewDelegate, UIScrollViewDelegate, TAPCustomButtonViewDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) TAPRegisterView *registerView;

@property (nonatomic) BOOL passwordTextFieldJustEndEditing;

@property (nonatomic) BOOL isUsernameValid;
@property (nonatomic) BOOL isFullNameValid;
@property (nonatomic) BOOL isEmailValid;
@property (nonatomic) BOOL isPasswordValid;

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
- (void)openCamera;
- (void)openGallery;

@end

@implementation TAPRegisterViewController

#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    _registerView = [[TAPRegisterView alloc] initWithFrame:[TAPBaseView frameWithNavigationBar]];
    [self.view addSubview:self.registerView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showCustomBackButtonOrange];

    self.registerView.scrollView.delegate = self;
    self.registerView.fullNameTextField.delegate = self;
    self.registerView.usernameTextField.delegate = self;
    self.registerView.mobileNumberTextField.delegate = self;
    self.registerView.emailTextField.delegate = self;
    self.registerView.passwordTextField.delegate = self;
    self.registerView.retypePasswordTextField.delegate = self;
    self.registerView.continueButtonView.delegate = self;
    
    //set mobile number obtained from otp login
    [self.registerView.mobileNumberTextField setPhoneNumber:self.phoneNumber country:self.country];
    
    [self.registerView.changeProfilePictureButton addTarget:self action:@selector(changeProfilePictureButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.registerView.removeProfilePictureButton addTarget:self action:@selector(removeProfilePictureButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showNavigationSeparator:NO];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
   [super viewWillDisappear:animated];
}

#pragma mark - Delegate
#pragma mark TAPCustomTextFieldView
- (BOOL)customTextFieldViewTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];

    if (textField == self.registerView.fullNameTextField.textField) {
        _isFullNameValid = NO;
        _lastCheckFullNameString = newText;
        [self performSelector:@selector(checkFullName) withObject:newText afterDelay:1.0f];
    }
    else if (textField == self.registerView.usernameTextField.textField) {
        _isUsernameValid = NO;
        _lastCheckUsernameString = newText;
        [self performSelector:@selector(checkUsername) withObject:nil afterDelay:1.0f];
    }
    else if (textField == self.registerView.emailTextField.textField) {
        _isEmailValid = NO;
        _lastCheckEmailString = newText;
        [self performSelector:@selector(checkEmail) withObject:newText afterDelay:1.0f];
    }
    else if (textField == self.registerView.passwordTextField.textField) {
        if ([TAPUtil isEmptyString:string] && [self.registerView.passwordTextField.textField isSecureTextEntry] && self.passwordTextFieldJustEndEditing) {
            [self.registerView.passwordTextField setAsError:NO animated:YES];
            [self.registerView.passwordTextField setErrorInfoText:NSLocalizedString(@"", @"")];
            [self.registerView refreshViewPosition];
            _isPasswordValid = YES;
        }
        else if (![TAPUtil validatePassword:newText] && ![TAPUtil isEmptyString:newText]) {
            [self.registerView.passwordTextField setAsError:YES animated:YES];
            [self.registerView.passwordTextField setErrorInfoText:NSLocalizedString(@"Invalid password", @"")];
            [self.registerView refreshViewPosition];
            _isPasswordValid = NO;
        }
        else {
            [self.registerView.passwordTextField setAsError:NO animated:YES];
            [self.registerView.passwordTextField setErrorInfoText:NSLocalizedString(@"", @"")];
            [self.registerView refreshViewPosition];
            _isPasswordValid = YES;
        }
        
        if (![TAPUtil isEmptyString:self.registerView.retypePasswordTextField.textField.text]) {
         
            if (![self.registerView.retypePasswordTextField.textField.text isEqualToString:newText]) {
                [self.registerView.retypePasswordTextField setAsError:YES animated:YES];
                [self.registerView.retypePasswordTextField setErrorInfoText:NSLocalizedString(@"Password does not match", @"")];
                [self.registerView refreshViewPosition];
                _isPasswordValid = NO;
            }
            else {
                [self.registerView.retypePasswordTextField setAsError:NO animated:YES];
                [self.registerView.retypePasswordTextField setErrorInfoText:NSLocalizedString(@"", @"")];
                [self.registerView refreshViewPosition];
                _isPasswordValid = YES;
            }
        }
        _passwordTextFieldJustEndEditing = NO;
    }
    else if (textField == self.registerView.retypePasswordTextField.textField) {
        if (![newText isEqualToString:self.registerView.passwordTextField.textField.text] && ![TAPUtil isEmptyString:newText]) {
            [self.registerView.retypePasswordTextField setAsError:YES animated:YES];
            [self.registerView.retypePasswordTextField setErrorInfoText:NSLocalizedString(@"Password does not match", @"")];
            [self.registerView refreshViewPosition];
        }
        else {
            [self.registerView.retypePasswordTextField setAsError:NO animated:YES];
            [self.registerView.retypePasswordTextField setErrorInfoText:NSLocalizedString(@"", @"")];
            [self.registerView refreshViewPosition];
        }
    }
    
    [self refreshButtonState];
    
    return YES;
}

- (BOOL)customTextFieldViewTextFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.registerView.fullNameTextField.textField) {
        [self.registerView.usernameTextField.textField becomeFirstResponder];
    }
    else if (textField == self.registerView.usernameTextField.textField) {
        [self.registerView.usernameTextField.textField resignFirstResponder];
    }
    
    return YES;
}

- (BOOL)customTextFieldViewTextFieldShouldBeginEditing:(UITextField *)textField {
 
    return YES;
}

- (void)customTextFieldViewTextFieldDidBeginEditing:(UITextField *)textField {
    
}

- (BOOL)customTextFieldViewTextFieldShouldEndEditing:(UITextField *)textField {
    if (textField == self.registerView.passwordTextField.textField) {
        _passwordTextFieldJustEndEditing = YES;
    }
    return YES;
}

- (void)customTextFieldViewTextFieldDidEndEditing:(UITextField *)textField {

}

- (BOOL)customTextFieldViewTextFieldShouldClear:(UITextField *)textField {
    return YES;
}

#pragma mark TAPCustomButtonView
- (void)customButtonViewDidTappedButton {
    [self.registerView.continueButtonView setAsLoading:YES animated:NO];
    [self.registerView setContentEditable:NO];
    
    [TAPDataManager callAPIRegisterWithFullName:self.registerView.fullNameTextField.textField.text countryID:self.country.countryID phone:self.phoneNumber username:self.registerView.usernameTextField.textField.text email:self.registerView.emailTextField.textField.text password:self.registerView.passwordTextField.textField.text success:^(NSString *userID, NSString *ticket) {
        //Already Registered
        [[TapTalk sharedInstance] authenticateWithAuthTicket:ticket connectWhenSuccess:YES success:^{

            [[TAPContactManager sharedManager] saveUserCountryCode:self.country.countryCallingCode];
        if (self.selectedProfileImage == nil) {
         //no Image
            [self.registerView.continueButtonView setAsLoading:NO animated:YES];
            [self.registerView setContentEditable:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else {
         //upload Image
            [[TAPFileUploadManager sharedManager] resizeImage:self.selectedProfileImage maxImageSize:TAP_MAX_IMAGE_LARGE_SIZE success:^(UIImage * _Nonnull resizedImage) {
                
                NSData *imageData = UIImageJPEGRepresentation(resizedImage, 1.0f);
                
                [TAPDataManager callAPIUploadUserImageWithImageData:imageData completionBlock:^(TAPUserModel *user) {
                    [self.registerView.continueButtonView setAsLoading:NO animated:YES];
                    [self.registerView setContentEditable:YES];
                    [self dismissViewControllerAnimated:YES completion:nil];
                } progressBlock:^(CGFloat progress, CGFloat total) {
                } failureBlock:^(NSError *error) {
                    //Show error, retry or skip popup
                     [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDefault popupIdentifier:@"Error Upload Profile Image In Register" title:NSLocalizedString(@"Failed to upload image", @"") detailInformation:NSLocalizedString(@"An error occurred while uploading your profile picture, would you like to try again?", @"") leftOptionButtonTitle:@"Retry" singleOrRightOptionButtonTitle:@"Skip"];
                    
                    [self.registerView.continueButtonView setAsLoading:NO animated:YES];
                    [self.registerView setContentEditable:YES];
                }];
            }];
        }

    
        } failure:^(NSError *error) {
            
            //DV Temp
            //DV Note - show error with custom popup
            //        NSInteger errorCode = error.code;
            //        if (errorCode != 999) {
            //            [self showFailAPIWithMessageString:error.domain show:YES];
            //        }
            //END DV Temp
            
            NSString *errorMessage = [error.userInfo objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Failed", @"") message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            
            [alertController addAction:okAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }];
    } failure:^(NSError *error) {
        [self.registerView.continueButtonView setAsLoading:NO animated:YES];
        NSString *errorMessage = [error.userInfo objectForKey:@"message"];
        errorMessage = [TAPUtil nullToEmptyString:errorMessage];
        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Register" title:NSLocalizedString(@"Error", @"") detailInformation:errorMessage leftOptionButtonTitle:@"" singleOrRightOptionButtonTitle:@""];
        [self.registerView setContentEditable:YES];
    }];
}

#pragma mark UIScrollView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
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
            [self.registerView setProfilePictureWithImage:self.selectedProfileImage];
        }
    }];
}

#pragma mark - Custom Method
- (void)keyboardWillShowWithHeight:(CGFloat)keyboardHeight {
    [super keyboardWillShowWithHeight:keyboardHeight];
    [UIView animateWithDuration:0.2f animations:^{
         self.registerView.scrollView.frame = CGRectMake(CGRectGetMinX(self.registerView.scrollView.frame), CGRectGetMinY(self.registerView.scrollView.frame), CGRectGetWidth(self.registerView.scrollView.frame), CGRectGetHeight(self.registerView.frame) - keyboardHeight);
    }];
}

- (void)keyboardWillHideWithHeight:(CGFloat)keyboardHeight {
    [super keyboardWillHideWithHeight:keyboardHeight];
    [UIView animateWithDuration:0.2f animations:^{
        self.registerView.scrollView.frame = [TAPBaseView frameWithNavigationBar];
    }];
}

- (void)refreshButtonState {
    if (![TAPUtil isEmptyString:self.registerView.fullNameTextField.textField.text] && ![TAPUtil isEmptyString:self.registerView.usernameTextField.textField.text] && ![TAPUtil isEmptyString:self.registerView.mobileNumberTextField.textField.text] && self.isFullNameValid && self.isUsernameValid) {
        
        if (![TAPUtil isEmptyString:self.registerView.passwordTextField.textField.text] || ![TAPUtil isEmptyString:self.registerView.retypePasswordTextField.textField.text]) {
            //IF PASSWORD FILLED
            if (self.isPasswordValid) {
                [self.registerView setContinueButtonEnabled:YES];
            }
            else {
                [self.registerView setContinueButtonEnabled:NO];
            }
        }
        else if (![TAPUtil isEmptyString:self.registerView.emailTextField.textField.text]) {
            //IF EMAIL FILLED
            if (self.isEmailValid) {
                [self.registerView setContinueButtonEnabled:YES];
            }
            else {
                [self.registerView setContinueButtonEnabled:NO];
            }
        }
        else {
            //PASSWORD AND EMAIL NOT FILLED
            [self.registerView setContinueButtonEnabled:YES];
        }
    }
    else {
        [self.registerView setContinueButtonEnabled:NO];
    }
}

- (void)checkUsername {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    NSString *username = self.lastCheckUsernameString;
    if (![TAPUtil validateUsername:username] && ![TAPUtil isEmptyString:username]) {
        [self.registerView.usernameTextField setAsError:YES animated:YES];
        [self.registerView.usernameTextField setErrorInfoText:NSLocalizedString(@"Invalid Username", @"")];
        [self.registerView refreshViewPosition];
        _isUsernameValid = NO;
    }
    else if (([username length] < 4 || [username length] > 32) && ![TAPUtil isEmptyString:username]) {
        [self.registerView.usernameTextField setAsError:YES animated:YES];
        [self.registerView.usernameTextField setErrorInfoText:NSLocalizedString(@"Username's length must be 4-32 characters", @"")];
        [self.registerView refreshViewPosition];
        _isUsernameValid = NO;
    }
    else {
        [self.registerView.usernameTextField setAsError:NO animated:YES];
        [self.registerView.usernameTextField setErrorInfoText:NSLocalizedString(@"", @"")];
        [self.registerView refreshViewPosition];
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
        [self.registerView.fullNameTextField setAsError:YES animated:YES];
        [self.registerView.fullNameTextField setErrorInfoText:NSLocalizedString(@"Invalid Full Name", @"")];
        [self.registerView refreshViewPosition];
        _isFullNameValid = NO;
    }
    else {
        [self.registerView.fullNameTextField setAsError:NO animated:YES];
        [self.registerView.fullNameTextField setErrorInfoText:NSLocalizedString(@"", @"")];
        [self.registerView refreshViewPosition];
        _isFullNameValid = YES;
    }
    [self refreshButtonState];
}

- (void)checkUsernameAPI:(NSString *)username {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [TAPDataManager callAPICheckUsername:username success:^(BOOL isExists, NSString *checkedUsername) {
        if ([checkedUsername isEqualToString:self.registerView.usernameTextField.textField.text]) {
            if (isExists) {
                [self.registerView.usernameTextField setAsError:YES animated:YES];
                [self.registerView.usernameTextField setErrorInfoText:NSLocalizedString(@"Username already exists", @"")];
                [self.registerView refreshViewPosition];
                _isUsernameValid = NO;
            }
            else {
                [self.registerView.usernameTextField setAsError:NO animated:YES];
                [self.registerView.usernameTextField setErrorInfoText:NSLocalizedString(@"", @"")];
                [self.registerView refreshViewPosition];
                _isUsernameValid = YES;
            }
            [self refreshButtonState];
        }
    } failure:^(NSError *error) {
        //        NSLog(@"ERROR - %@", error);
        _isUsernameValid = NO;
        [self.registerView.usernameTextField setAsError:YES animated:YES];
        if (error.code == 999) {
            [self.registerView.usernameTextField setErrorInfoText:@"Unable to verify username, please check your connection and try again"];
        }
        else {
            NSString *errorMessage = [error.userInfo objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            [self.registerView.usernameTextField setErrorInfoText:errorMessage];
        }
        
        [self.registerView refreshViewPosition];
        [self refreshButtonState];
    }];
}

- (void)checkEmail {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    NSString *email = self.lastCheckEmailString;
    if (![TAPUtil validateEmail:email] && ![TAPUtil isEmptyString:email]) {
        [self.registerView.emailTextField setAsError:YES animated:YES];
        [self.registerView.emailTextField setErrorInfoText:NSLocalizedString(@"Invalid email address", @"")];
        [self.registerView refreshViewPosition];
        _isEmailValid = NO;
    }
    else {
        [self.registerView.emailTextField setAsError:NO animated:YES];
        [self.registerView.emailTextField setErrorInfoText:NSLocalizedString(@"", @"")];
        [self.registerView refreshViewPosition];
        _isEmailValid = YES;
    }
    [self refreshButtonState];
}

- (void)removeProfilePictureButtonDidTapped {
    self.selectedProfileImage = nil;
    [self.registerView setProfilePictureWithImage:self.selectedProfileImage];
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

- (void)popUpInfoTappedSingleButtonOrRightButtonWithIdentifier:(NSString *)popupIdentifier {
    [super popUpInfoTappedSingleButtonOrRightButtonWithIdentifier:popupIdentifier];
    
    if ([popupIdentifier isEqualToString:@"Error Upload Profile Image In Register"]) {
        //Skip Upload Image
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if ([popupIdentifier isEqualToString:@"Error Register"]) {
        
    }
}

- (void)popUpInfoDidTappedLeftButtonWithIdentifier:(NSString *)popupIdentifier {
    [super popUpInfoDidTappedLeftButtonWithIdentifier:popupIdentifier];
    
    if ([popupIdentifier isEqualToString:@"Error Upload Profile Image In Register"]) {
        [self.registerView.continueButtonView setAsLoading:YES animated:NO];
        [self.registerView setContentEditable:NO];
        
        [[TAPFileUploadManager sharedManager] resizeImage:self.selectedProfileImage maxImageSize:TAP_MAX_IMAGE_LARGE_SIZE success:^(UIImage * _Nonnull resizedImage) {
            
            NSData *imageData = UIImageJPEGRepresentation(resizedImage, 1.0f);
            
            [TAPDataManager callAPIUploadUserImageWithImageData:imageData completionBlock:^(TAPUserModel *user) {
                [self.registerView.continueButtonView setAsLoading:NO animated:YES];
                [self.registerView setContentEditable:YES];
                [self dismissViewControllerAnimated:YES completion:nil];
            } progressBlock:^(CGFloat progress, CGFloat total) {
            } failureBlock:^(NSError *error) {
                //Show error, retry or skip popup
                
                [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDefault popupIdentifier:@"Error Upload Profile Image In Register" title:NSLocalizedString(@"Failed to upload image", @"") detailInformation:NSLocalizedString(@"An error occurred while uploading your profile picture, would you like to try again?", @"") leftOptionButtonTitle:@"Retry" singleOrRightOptionButtonTitle:@"Skip"];
                
                [self.registerView.continueButtonView setAsLoading:NO animated:YES];
                [self.registerView setContentEditable:YES];
            }];
        }];
    }
    else if ([popupIdentifier isEqualToString:@"Error Register"]) {
        
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
