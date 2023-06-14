//
//  TAPReportUserViewController.m
//  TapTalk
//
//  Created by TapTalk.io on 19/10/22.
//

#import "TAPReportUserViewController.h"

@interface TAPReportUserViewController ()<UITextFieldDelegate, UITextViewDelegate, TAPPopUpInfoViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *reportReasonSendingFalseButton;
@property (weak, nonatomic) IBOutlet UILabel *reportReasonSendingFalseLabel;
@property (weak, nonatomic) IBOutlet UIButton *reportReasonPretendingButton;
@property (weak, nonatomic) IBOutlet UILabel *reportReasonPretendingLabel;
@property (weak, nonatomic) IBOutlet UIButton *reportReasonScamButton;
@property (weak, nonatomic) IBOutlet UILabel *reportReasonScamLabel;
@property (weak, nonatomic) IBOutlet UIButton *reportReasonDangerousButton;
@property (weak, nonatomic) IBOutlet UILabel *reportReasonDangerousLabel;
@property (weak, nonatomic) IBOutlet UIButton *reportReasonOtherButton;
@property (weak, nonatomic) IBOutlet UILabel *reportReasonOtherLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectCategoryErrorLabel;


@property (weak, nonatomic) IBOutlet UIView *reportReasonFieldView;
@property (weak, nonatomic) IBOutlet UILabel *reportTitleLabel;
@property (weak, nonatomic) IBOutlet UITextField *reportReasonOtherTextField;
@property (weak, nonatomic) IBOutlet UITextView *reportReasonTextView;
@property (weak, nonatomic) IBOutlet UILabel *reasonFieldPlaceholderLabel;
@property (weak, nonatomic) IBOutlet UIView *submitButtonView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UILabel *textViewCounterLabel;
@property (weak, nonatomic) IBOutlet UILabel *errorTextFieldLabel;


@property (weak, nonatomic) IBOutlet UIImageView *loadingIconImageView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reportReasonOtherFieldHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *errorTextFieldLabelHeightConstraint;

@property (strong, nonatomic) NSArray *optionalArray;
@property (nonatomic) CGFloat keyboardHeight;
@property (nonatomic) NSInteger selectedReasonIndex;
@property (nonatomic) BOOL isSubmitCanceled;
@property (nonatomic) BOOL isLoadingState;
@property (strong, nonatomic) TAPPopUpInfoViewController *backLoadingPopupInfoViewController;

@property (weak, nonatomic) IBOutlet UILabel *reportReasonBottomLabel;


@end

@implementation TAPReportUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    _selectedReasonIndex = -1;
    //delegate
    self.reportReasonTextView.delegate = self;
    self.scrollView.delegate = self;
    
    //setup ui
    self.reportReasonFieldView.layer.borderWidth = 1.0f;
    self.reportReasonFieldView.layer.borderColor = [UIColor separatorColor].CGColor;
    self.reportReasonFieldView.layer.cornerRadius = 8.0f;
    
    UIFont *labelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontFormTextField];
    
    self.reportTitleLabel.font = labelFont;
    
    self.reportReasonSendingFalseLabel.font = labelFont;
    self.reportReasonPretendingLabel.font = labelFont;
    self.reportReasonScamLabel.font = labelFont;
    self.reportReasonDangerousLabel.font = labelFont;
    self.reportReasonOtherLabel.font = labelFont;
    
    self.reportReasonOtherTextField.font = labelFont;
    self.reportReasonOtherTextField.delegate = self;
    self.reportReasonTextView.font = labelFont;
    
    self.textViewCounterLabel.font = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontAlbumCountLabel];
    self.textViewCounterLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
    
    self.errorTextFieldLabel.font = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontAlbumCountLabel];
    self.errorTextFieldLabel.textColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPTextColorWarningLabel];
    
    self.selectCategoryErrorLabel.font = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontAlbumCountLabel];
    self.selectCategoryErrorLabel.textColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPTextColorWarningLabel];
    self.selectCategoryErrorLabel.text = @"";
    [self.selectCategoryErrorLabel sizeToFit];
    
    self.reasonFieldPlaceholderLabel.font = labelFont;
    self.reasonFieldPlaceholderLabel.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
    
    [self.submitButton setTitle:@"Submit Report" forState:UIControlStateNormal];
    
    self.submitButtonView.backgroundColor = [TAPUtil getColor:@"FF3F57"];
    self.submitButtonView.layer.cornerRadius = 8.0f;
    
    self.loadingIconImageView.image = [UIImage imageNamed:@"TAPIconLoadingSmall" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    self.loadingIconImageView.image = [self.loadingIconImageView.image setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonIcon]];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];

    [self.view addGestureRecognizer:tap];
    
    
    if(self.reportType == TAPReportTypeUser) {
        self.optionalArray = @[
            @"Sending false information",
            @"Pretending to be someone else",
            @"Scam or fraud",
            @"Dangerous Organization",
            @"Others"];
    }
    else if(self.reportType == TAPReportTypeMessage) {
        self.optionalArray = @[
            @"Hate speech",
            @"Nudity or sexual activity",
            @"Bullying or harrasment",
            @"Violence",
            @"Others"];
    }
    
    self.reportReasonSendingFalseLabel.text = [self.optionalArray objectAtIndex:0];
    self.reportReasonPretendingLabel.text = [self.optionalArray objectAtIndex:1];
    self.reportReasonScamLabel.text = [self.optionalArray objectAtIndex:2];
    self.reportReasonDangerousLabel.text = [self.optionalArray objectAtIndex:3];
    self.reportReasonOtherLabel.text = [self.optionalArray objectAtIndex:4];
    
    
    self.reportReasonBottomLabel.font = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontDeleteAccountTitleLabel];
    
    NSString *opsionalString = @"(Optional)";
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:self.reportReasonBottomLabel.text];
    
    //UIFont *symbolRequiredLabelString = [UIFont fontWithName:FONT_LATO_BOLD size:13.0f];
    NSRange opsionalStringRange = [self.reportReasonBottomLabel.text rangeOfString:opsionalString];
    //[mutableAttributedString addAttribute:NSFontAttributeName value:symbolRequiredLabelString range:symbolStringRange];
    
    // Set background color, again for entire range
    [mutableAttributedString addAttribute:NSForegroundColorAttributeName
                                    value:[[UIColor blackColor] colorWithAlphaComponent:0.4f]
                                    range:opsionalStringRange];
    
    self.reportReasonBottomLabel.attributedText = mutableAttributedString;
    
    self.reportReasonBottomLabel.font = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontDeletedChatRoomInfoTitleLabel];;
    
    
    [self showLoadingState:NO];
    
    [self setupNavigationView];
}

#pragma mark Delegates

#pragma mark TextField Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if(newString.length > 100) {
        return NO;
    }
    
    return YES;
    
}

#pragma mark TextView Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self setTextViewState:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self setTextViewState:NO];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    if(newString.length == 0){
        self.reasonFieldPlaceholderLabel.alpha = 1.0f;
    }
    else {
        self.reasonFieldPlaceholderLabel.alpha = 0.0f;
    }
    
    NSInteger stringCount = newString.length;
    
    NSString *counterTextView = [NSString stringWithFormat:@"%ld/2000", stringCount];
    self.textViewCounterLabel.text = counterTextView;
    
    if(stringCount > 2000) {
        return NO;
    }
    
    return YES;
    
}

#pragma mark Popup Delegate
- (void)popUpInfoDidTappedLeftButtonWithIdentifier:(NSString *)popupIdentifier {
   
}

- (void)popUpInfoViewControllerDidTappedSingleButtonOrRightButtonWithIdentifier:(NSString *)identifier {
    NSString *category = @"";
    BOOL isOtherSelected = NO;
    if(self.selectedReasonIndex >= 0) {
        category = [self.optionalArray objectAtIndex:self.selectedReasonIndex];
    }
    else {
        category = self.reportReasonOtherTextField.text;
        isOtherSelected = YES;
    }
    
    NSString *reason = self.reportReasonTextView.text;
    reason = [TAPUtil nullToEmptyString:reason];
    
    if([identifier isEqualToString:@"Report Confirmation"] && self.reportType == TAPReportTypeMessage) {
        [self showLoadingState:YES];
        self.isLoadingState = YES;
        [TAPDataManager callAPIReportMessage:self.messageID roomID:self.roomID category:category isOtherCategory:isOtherSelected reason:reason success:^(BOOL success) {
            if(self.isSubmitCanceled) {
                return;
            }
            [self.backLoadingPopupInfoViewController dismissViewControllerAnimated:NO completion:^{
                [self showReportResultPopup:success];
                [self showLoadingState:NO];
                self.isLoadingState = NO;
            }];
            [self showReportResultPopup:success];
            [self showLoadingState:NO];
            self.isLoadingState = NO;
        } failure:^(NSError *error) {
            [self.backLoadingPopupInfoViewController dismissViewControllerAnimated:NO completion:^{
                [self showLoadingState:NO];
                [self showReportResultPopup:NO];
                self.isLoadingState = NO;
            }];
            [self showLoadingState:NO];
            [self showReportResultPopup:NO];
            self.isLoadingState = NO;
        }];
    }
    else if([identifier isEqualToString:@"Report Confirmation"] && self.reportType == TAPReportTypeUser) {
        [self showLoadingState:YES];
        self.isLoadingState = YES;
        [TAPDataManager callAPIReportUser:self.userID category:category isOtherCategory:isOtherSelected reason:reason success:^(BOOL success) {
            if(self.isSubmitCanceled) {
                return;
            }
            [self.backLoadingPopupInfoViewController dismissViewControllerAnimated:NO completion:^{
                [self showReportResultPopup:success];
                [self showLoadingState:NO];
                self.isLoadingState = NO;
            }];
            [self showReportResultPopup:success];
            [self showLoadingState:NO];
            self.isLoadingState = NO;
        } failure:^(NSError *error) {
            [self.backLoadingPopupInfoViewController dismissViewControllerAnimated:NO completion:^{
                [self showLoadingState:NO];
                [self showReportResultPopup:NO];
                self.isLoadingState = NO;
            }];
            [self showLoadingState:NO];
            [self showReportResultPopup:NO];
            self.isLoadingState = NO;
        }];
    }
    else if([identifier isEqualToString:@"Report Success"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if([identifier isEqualToString:@"Report Failed"]) {
        
    }
    else if([identifier isEqualToString:@"Back Confirmation"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if([identifier isEqualToString:@"Cancel Submit Confirmation"]) {
        [self.navigationController popViewControllerAnimated:YES];
        self.isSubmitCanceled = YES;
    }
}

#pragma mark ScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark ScrollView Delegate
- (void)keyboardWillHideWithHeight:(CGFloat)keyboardHeight {
    [super keyboardWillHideWithHeight:keyboardHeight];
    _keyboardHeight = keyboardHeight;
    [UIView animateWithDuration:0.2f animations:^{
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), CGRectGetMaxY(self.submitButtonView.frame) + 16.0f + [TAPUtil safeAreaBottomPadding]);
    } completion:^(BOOL finished) {
        //completion
    }];
}

- (void)keyboardWillShowWithHeight:(CGFloat)keyboardHeight{
    [super keyboardWillShowWithHeight:keyboardHeight];
    
    _keyboardHeight = keyboardHeight;
    [UIView animateWithDuration:0.2f animations:^{
        self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.frame), CGRectGetMaxY(self.submitButtonView.frame) + 16.0f + keyboardHeight + [TAPUtil safeAreaBottomPadding]);
        
    } completion:^(BOOL finished) {
        //completion
    }];
}

- (void)backButtonDidTapped {
    if(self.isLoadingState) {
        self.backLoadingPopupInfoViewController = [[TAPPopUpInfoViewController alloc] init];
        self.backLoadingPopupInfoViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.backLoadingPopupInfoViewController.popupIdentifier = @"Cancel Submit Confirmation";
        self.backLoadingPopupInfoViewController.delegate = self;
        [self.backLoadingPopupInfoViewController setPopUpInfoViewControllerType:TAPPopUpInfoViewControllerTypeInfoDefault withTitle:NSLocalizedStringFromTableInBundle(@"Your report might have not been submitted", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"Your report might have not been submitted because you clicked back while we are trying to submit your report, are you sure you want to go back?", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"") singleOrRightOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"Yes", nil, [TAPUtil currentBundle], @"")];

        [self presentViewController:self.backLoadingPopupInfoViewController animated:NO completion:^{
        }];
        
       // [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDefault popupIdentifier:@"Back Confirmation" title:NSLocalizedStringFromTableInBundle(@"Your report might have not been submitted", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"Your report might have not been submitted because you clicked back while we are trying to submit your report, are you sure you want to go back?", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"") singleOrRightOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"Yes", nil, [TAPUtil currentBundle], @"")];
        
        
    }
    else if(self.selectedReasonIndex >= 0 || (self.reportReasonOtherTextField.alpha == 1 && self.reportReasonOtherTextField.text.length > 0)) {
        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDefault popupIdentifier:@"Back Confirmation" title:NSLocalizedStringFromTableInBundle(@"You haven’t submitted your report", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"Your report has not been submitted, are you sure you want to cancel and discard the report?", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"") singleOrRightOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"Yes", nil, [TAPUtil currentBundle], @"")];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)swipeBackGestureAction {
    [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDefault popupIdentifier:@"Back Confirmation" title:NSLocalizedStringFromTableInBundle(@"You haven’t submit your report", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"Your report has not been submitted, are you sure you want to cancel and discard the report?", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"") singleOrRightOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"Yes", nil, [TAPUtil currentBundle], @"")];
}

- (IBAction)submitReportButtonDidTapped:(id)sender {
    if(self.reportReasonOtherTextField.alpha == 1) {
        if(self.reportReasonOtherTextField.text.length == 0) {
            [self setTextFieldToError:YES];
            self.selectCategoryErrorLabel.text = @"";
            [self.selectCategoryErrorLabel sizeToFit];
        }
        else {
            [self setTextFieldToError:NO];
            [self showConfirmationPopup];
            self.selectCategoryErrorLabel.text = @"";
            [self.selectCategoryErrorLabel sizeToFit];
        }
    }
    else {
        if(self.selectedReasonIndex >= 0) {
            [self showConfirmationPopup];
            self.selectCategoryErrorLabel.text = @"";
            [self.selectCategoryErrorLabel sizeToFit];
        }
        else {
            self.selectCategoryErrorLabel.text = @"This field is required.";
            [self.selectCategoryErrorLabel sizeToFit];
        }
    }
    
    
}

- (void)showConfirmationPopup {
    [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeInfoDestructive popupIdentifier:@"Report Confirmation" title:NSLocalizedStringFromTableInBundle(@"Submit Report", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"You will submit a report for this user, you can tell us why so we can help you. Are you sure you want to submit now?", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"Cancel", nil, [TAPUtil currentBundle], @"") singleOrRightOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"Submit", nil, [TAPUtil currentBundle], @"")];
}

- (void)showReportResultPopup:(BOOL)success {
    
    NSString *title = @"";
    NSString *body = @"";
    NSString *identifier = @"";
    
    if(success) {
        title = @"Report has been submitted";
        body = @"Thank you for reporting!";
        identifier = @"Report Success";
    }
    else {
        title = @"Failed to submit report";
        body = @"There has been an error while submitting, please try again.";
        identifier = @"Report Failed";
    }
    
    [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeSuccessMessage popupIdentifier:identifier title:NSLocalizedStringFromTableInBundle(title, nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(body, nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:NSLocalizedStringFromTableInBundle(@"OK", nil, [TAPUtil currentBundle], @"")];
}

- (IBAction)reportReasonButtonDidTapped:(id)sender {
    UIButton *reasonButton = sender;
    
    [self resetReasonButtons];
    
    self.selectCategoryErrorLabel.text = @"";
    [self.selectCategoryErrorLabel sizeToFit];
    
    UIImage *selectedIconImage = [UIImage imageNamed:@"TAPIconSelected" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    
    if(reasonButton == self.reportReasonSendingFalseButton) {
        [self.reportReasonSendingFalseButton setImage:selectedIconImage forState:UIControlStateNormal];
        self.selectedReasonIndex = 0;
    }
    else if(reasonButton == self.reportReasonPretendingButton) {
        [self.reportReasonPretendingButton setImage:selectedIconImage forState:UIControlStateNormal];
        self.selectedReasonIndex = 1;
    }
    else if(reasonButton == self.reportReasonScamButton) {
        [self.reportReasonScamButton setImage:selectedIconImage forState:UIControlStateNormal];
        self.selectedReasonIndex = 2;
    }
    else if(reasonButton == self.reportReasonDangerousButton) {
        [self.reportReasonDangerousButton setImage:selectedIconImage forState:UIControlStateNormal];
        self.selectedReasonIndex = 3;
    }
    else if(reasonButton == self.reportReasonOtherButton) {
        [self.reportReasonOtherButton setImage:selectedIconImage forState:UIControlStateNormal];
        
        self.reportReasonOtherFieldHeightConstraint.constant = 38.0f;
        self.reportReasonOtherTextField.alpha = 1.0f;
        [self setTextFieldToError:NO];
    }
    
}

- (void)setTextFieldToError:(BOOL)isError {
    if(isError) {
        self.reportReasonOtherTextField.layer.borderWidth = 1.0f;
        self.reportReasonOtherTextField.layer.cornerRadius = 8.0f;
        self.reportReasonOtherTextField.layer.borderColor = [UIColor redColor].CGColor;
        self.errorTextFieldLabelHeightConstraint.constant = 16.0f;
    }
    else {
        self.reportReasonOtherTextField.layer.borderWidth = 0.0f;
        self.errorTextFieldLabelHeightConstraint.constant = 0.0f;
    }
}

- (void)setTextViewState:(BOOL)isActive {
    if(isActive) {
        self.reportReasonFieldView.layer.borderColor = [TAPUtil getColor:@"FF7E00"].CGColor;
    }
    else {
        self.reportReasonFieldView.layer.borderColor = [UIColor separatorColor].CGColor;
    }
}

- (void)radioButtonLoadingState:(BOOL)isLoading {
    UIImage *selectedIconImageGray = [UIImage imageNamed:@"TAPIconSelectedGray" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    UIImage *selectedIconImage = [UIImage imageNamed:@"TAPIconSelected" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    if(isLoading) {
        if(self.selectedReasonIndex == 0) {
            [self.reportReasonSendingFalseButton setImage:selectedIconImageGray forState:UIControlStateNormal];
        }
        else if(self.selectedReasonIndex == 1) {
            [self.reportReasonPretendingButton setImage:selectedIconImageGray forState:UIControlStateNormal];
        }
        else if(self.selectedReasonIndex == 2) {
            [self.reportReasonScamButton setImage:selectedIconImageGray forState:UIControlStateNormal];
        }
        else if(self.selectedReasonIndex == 3) {
            [self.reportReasonDangerousButton setImage:selectedIconImageGray forState:UIControlStateNormal];
        }
        else if(self.reportReasonOtherButton.imageView.image == selectedIconImage){
            [self.reportReasonOtherButton setImage:selectedIconImageGray forState:UIControlStateNormal];
        }
    }
    else {
        if(self.selectedReasonIndex == 0) {
            [self.reportReasonSendingFalseButton setImage:selectedIconImage forState:UIControlStateNormal];
        }
        else if(self.selectedReasonIndex == 1) {
            [self.reportReasonPretendingButton setImage:selectedIconImage forState:UIControlStateNormal];
        }
        else if(self.selectedReasonIndex == 2) {
            [self.reportReasonScamButton setImage:selectedIconImage forState:UIControlStateNormal];
        }
        else if(self.selectedReasonIndex == 3) {
            [self.reportReasonDangerousButton setImage:selectedIconImage forState:UIControlStateNormal];
        }
        else if(self.reportReasonOtherButton.imageView.image == selectedIconImageGray){
            [self.reportReasonOtherButton setImage:selectedIconImage forState:UIControlStateNormal];
        }
    }
}

- (void)showLoadingState:(BOOL)isLoading {
    [self radioButtonLoadingState:isLoading];
    if(isLoading) {
        //ADD ANIMATION
        self.loadingIconImageView.alpha = 1.0f;
        self.submitButton.titleLabel.alpha = 0;
        [self setTextViewState:NO];
        self.reportReasonFieldView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorDefaultBackground];
        
        self.reportReasonSendingFalseButton.userInteractionEnabled = NO;
        self.reportReasonPretendingButton.userInteractionEnabled = NO;
        self.reportReasonScamButton.userInteractionEnabled = NO;
        self.reportReasonDangerousButton.userInteractionEnabled = NO;
        self.reportReasonOtherButton.userInteractionEnabled = NO;
        
        self.reportReasonOtherTextField.userInteractionEnabled = NO;
        self.reportReasonTextView.userInteractionEnabled = NO;
        
        if ([self.loadingIconImageView.layer animationForKey:@"SpinAnimation"] == nil) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            animation.fromValue = [NSNumber numberWithFloat:0.0f];
            animation.toValue = [NSNumber numberWithFloat:(2*M_PI)];
            animation.duration = 1.5f;
            animation.repeatCount = INFINITY;
            animation.cumulative = YES;
            animation.removedOnCompletion = NO;
            [self.loadingIconImageView.layer addAnimation:animation forKey:@"SpinAnimation"];
        }
    }
    else {
        self.loadingIconImageView.alpha = 0.0f;
        self.submitButton.titleLabel.alpha = 1.0f;
        self.reportReasonFieldView.backgroundColor = [UIColor whiteColor];
        self.reportReasonSendingFalseButton.userInteractionEnabled = YES;
        self.reportReasonPretendingButton.userInteractionEnabled = YES;
        self.reportReasonScamButton.userInteractionEnabled = YES;
        self.reportReasonDangerousButton.userInteractionEnabled = YES;
        self.reportReasonOtherButton.userInteractionEnabled = YES;
        
        self.reportReasonOtherTextField.userInteractionEnabled = YES;
        self.reportReasonTextView.userInteractionEnabled = YES;
        //REMOVE ANIMATION
        if ([self.loadingIconImageView.layer animationForKey:@"SpinAnimation"] != nil) {
            [self.loadingIconImageView.layer removeAnimationForKey:@"SpinAnimation"];
        }
    }
}

- (void)resetReasonButtons {
    UIImage *unselectedIconImage = [UIImage imageNamed:@"TAPIconUnselectedGray" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    
    self.reportReasonOtherFieldHeightConstraint.constant = 0;
    self.reportReasonOtherTextField.alpha = 0.0f;
    
    [self.reportReasonSendingFalseButton setImage:unselectedIconImage forState:UIControlStateNormal];
    [self.reportReasonPretendingButton setImage:unselectedIconImage forState:UIControlStateNormal];
    [self.reportReasonScamButton setImage:unselectedIconImage forState:UIControlStateNormal];
    [self.reportReasonDangerousButton setImage:unselectedIconImage forState:UIControlStateNormal];
    [self.reportReasonOtherButton setImage:unselectedIconImage forState:UIControlStateNormal];
    
    [self setTextFieldToError:NO];
}

- (void)setupNavigationView {
    //This method is used to setup the title view of navigation bar, and also bar button view
    
    //Title View
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds) - 56.0f - 56.0f, 43.0f)];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(titleView.frame), CGRectGetHeight(titleView.frame))];
    
    UIFont *chatRoomNameLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontChatRoomNameLabel];
    UIColor *chatRoomNameLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorChatRoomNameLabel];
    
    
    if(self.reportType == TAPReportTypeUser) {
        nameLabel.text = NSLocalizedStringFromTableInBundle(@"Report User", nil, [TAPUtil currentBundle], @"");
    }
    else {
        nameLabel.text = NSLocalizedStringFromTableInBundle(@"Report Message", nil, [TAPUtil currentBundle], @"");
    }
    
   // self.nameLabel.text = [NSString stringWithFormat:@"%ld Members", [self.room.participants count]];
    nameLabel.textColor = chatRoomNameLabelColor;
    nameLabel.font = chatRoomNameLabelFont;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [titleView addSubview:nameLabel];
  
    
    [self.navigationItem setTitleView:titleView];
    
    //Back Bar Button
    UIImage *buttonImage = [UIImage imageNamed:@"TAPIconBackArrow" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    buttonImage = [buttonImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconNavigationBarBackButton]];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 30.0f)];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
}

-(void)dismissKeyboard {
    [self.reportReasonOtherTextField resignFirstResponder];
    [self.reportReasonTextView resignFirstResponder];
}

@end
