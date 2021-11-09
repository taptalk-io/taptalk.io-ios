//
//  TAPCreateGroupSubjectViewController.m
//  TapTalk
//
//  Created by Dominic Vedericho on 19/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPCreateGroupSubjectViewController.h"
#import "TAPCreateGroupSubjectView.h"

#import "TAPContactCollectionViewCell.h"

#define GROUP_NAME_MAX_LENGTH 100

@interface TAPCreateGroupSubjectViewController () <TAPCustomTextFieldViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate>

@property (strong, nonatomic) TAPCreateGroupSubjectView *createGroupSubjectView;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) UIImage *selectedImage;
@property (nonatomic) BOOL isLoading;
@property (strong, nonatomic) TAPRoomModel *roomModel;

- (void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer;
- (void)backButtonDidTapped;
- (void)cancelButtonDidTapped;
- (void)changeButtonDidTapped;
- (void)removePictureButtonDidTapped;
- (void)openCamera;
- (void)openGallery;

@end

@implementation TAPCreateGroupSubjectViewController
#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    _createGroupSubjectView = [[TAPCreateGroupSubjectView alloc] initWithFrame:[TAPBaseView frameWithoutNavigationBar]];
    [self.view addSubview:self.createGroupSubjectView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedStringFromTableInBundle(@"Group Subject", nil, [TAPUtil currentBundle], @"");
    TAPCoreConfigsModel *coreConfigs = [TAPDataManager getCoreConfigs];
    NSInteger maxGroupMember = [coreConfigs.groupMaxParticipants integerValue] - 1; // -1 for admin that created the group
    self.createGroupSubjectView.selectedContactsTitleLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"GROUP MEMBERS (%ld/%ld)", nil, [TAPUtil currentBundle], @""), [self.selectedContactArray count], (long)maxGroupMember];
    NSMutableDictionary *selectedContactsTitleAttributesDictionary = [NSMutableDictionary dictionary];
    CGFloat selectedContactsTitleLetterSpacing = 1.5f;
    [selectedContactsTitleAttributesDictionary setObject:@(selectedContactsTitleLetterSpacing) forKey:NSKernAttributeName];
    NSMutableAttributedString *selectedContactsTitleAttributedString = [[NSMutableAttributedString alloc] initWithString:self.createGroupSubjectView.selectedContactsTitleLabel.text];
    [selectedContactsTitleAttributedString addAttributes:selectedContactsTitleAttributesDictionary
                                              range:NSMakeRange(0, [self.createGroupSubjectView.selectedContactsTitleLabel.text length])];
    self.createGroupSubjectView.selectedContactsTitleLabel.attributedText = selectedContactsTitleAttributedString;
    
    self.createGroupSubjectView.selectedContactsCollectionView.delegate = self;
    self.createGroupSubjectView.selectedContactsCollectionView.dataSource = self;
    
    self.createGroupSubjectView.bgScrollView.delegate = self;
    self.createGroupSubjectView.groupNameTextField.delegate = self;
    
    [self.createGroupSubjectView.changePictureButton addTarget:self action:@selector(changeButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.createGroupSubjectView.removePictureButton addTarget:self action:@selector(removePictureButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.createGroupSubjectView.createButtonView.button addTarget:self action:@selector(createButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
     [self.createGroupSubjectView.backButton addTarget:self action:@selector(backButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.createGroupSubjectView.cancelButton addTarget:self action:@selector(cancelButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];

    if (![TAPUtil isEmptyString:self.roomModel.imageURL.thumbnail]) {
        [self.createGroupSubjectView setGroupPictureWithImageURL:self.roomModel.imageURL.thumbnail];
        if (self.tapCreateGroupSubjectControllerType == TAPCreateGroupSubjectViewControllerTypeUpdate) {
            //CS TEMP - hide remove picture button as the API is not ready yet
            self.createGroupSubjectView.removePictureButton.alpha = 0.0f;
            self.createGroupSubjectView.removePictureView.alpha = 0.0f;
        }
    }
    if (![TAPUtil isEmptyString:self.roomModel.name]) {
        self.createGroupSubjectView.groupNameTextField.textField.text = self.roomModel.name;
        //enable button create
        [self.createGroupSubjectView.createButtonView setAsActiveState:YES animated:NO];
    }
    else {
        //enable button create
        [self.createGroupSubjectView.createButtonView setAsActiveState:NO animated:NO];
    }
    
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
    
    [self setTapCreateGroupSubjectControllerType:self.tapCreateGroupSubjectControllerType];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
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
    return [self.selectedContactArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *cellID = @"TAPContactCollectionViewCell";
        
        [collectionView registerClass:[TAPContactCollectionViewCell class] forCellWithReuseIdentifier:cellID];
        TAPContactCollectionViewCell *cell = (TAPContactCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
        
        TAPUserModel *user = [self.selectedContactArray objectAtIndex:indexPath.row];

        [cell setContactCollectionViewCellWithModel:user];
        
        [cell showRemoveIcon:NO];
        
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
    [self.view endEditing:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat scrollViewHeight = CGRectGetHeight(scrollView.frame);
    CGFloat scrollContentSizeHeight = scrollView.contentSize.height;
    CGFloat currentYOffset = scrollView.contentOffset.y;
    
    if (IS_IPHONE_X_FAMILY) {
        if (currentYOffset + scrollViewHeight >= scrollContentSizeHeight) {
            //Reach bottom of scrollView
            self.createGroupSubjectView.navigationSeparatorView.alpha = 1.0f;
            self.createGroupSubjectView.shadowView.alpha = 1.0f;
        }
        else {
            CGFloat maxOffset = 120.0f;
            
            //Default position offset
            if (currentYOffset <= -44.0f) {
                self.createGroupSubjectView.navigationSeparatorView.alpha = 0.0f;
                self.createGroupSubjectView.shadowView.alpha = 0.0f;
                
                CGFloat heightDifference = fabsf(currentYOffset + 44.0f);
                self.createGroupSubjectView.additionalWhiteBounceView.frame = CGRectMake(CGRectGetMinX(self.createGroupSubjectView.additionalWhiteBounceView.frame), -heightDifference, CGRectGetWidth(self.createGroupSubjectView.additionalWhiteBounceView.frame), heightDifference);
            }
            else if (currentYOffset >= maxOffset) {
                self.createGroupSubjectView.navigationSeparatorView.alpha = 1.0f;
                self.createGroupSubjectView.shadowView.alpha = 1.0f;
            }
            else {
                CGFloat percentage = (currentYOffset + 44.0f) / 164.0f;
                self.createGroupSubjectView.navigationSeparatorView.alpha = percentage;
                self.createGroupSubjectView.shadowView.alpha = percentage;
            }
        }
    }
    else {
        if (currentYOffset + scrollViewHeight >= scrollContentSizeHeight) {
            //Reach bottom of scrollView
            self.createGroupSubjectView.navigationSeparatorView.alpha = 1.0f;
            self.createGroupSubjectView.shadowView.alpha = 1.0f;
        }
        else {
            CGFloat maxOffset = 180.0f;
            
            //Default position offset
            if (currentYOffset <= -20.0f) {
                self.createGroupSubjectView.navigationSeparatorView.alpha = 0.0f;
                self.createGroupSubjectView.shadowView.alpha = 0.0f;
                
                CGFloat heightDifference = fabsf(currentYOffset + 20.0f);
                self.createGroupSubjectView.additionalWhiteBounceView.frame = CGRectMake(CGRectGetMinX(self.createGroupSubjectView.additionalWhiteBounceView.frame), -heightDifference, CGRectGetWidth(self.createGroupSubjectView.additionalWhiteBounceView.frame), heightDifference);
                
            }
            else if (currentYOffset >= maxOffset) {
                self.createGroupSubjectView.navigationSeparatorView.alpha = 1.0f;
                self.createGroupSubjectView.shadowView.alpha = 1.0f;
            }
            else {
                CGFloat percentage = (currentYOffset + 20.0f) / 200.0f;
                self.createGroupSubjectView.navigationSeparatorView.alpha = percentage;
                self.createGroupSubjectView.shadowView.alpha = percentage;
            }
        }
    }
}

#pragma mark - Delegate
#pragma mark TAPCustomTextFieldView
- (BOOL)customTextFieldViewTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    newString = [newString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    self.roomModel.name = newString; //AS NOTE - TIDAK PERLU LANGSUNG DIUBAH
    
    if ([newString length] <= 0) {
        //disable button create
        [self.createGroupSubjectView.createButtonView setAsActiveState:NO animated:NO];
    }
    else {
        //enable button create
        [self.createGroupSubjectView.createButtonView setAsActiveState:YES animated:NO];
    }
    
    if ([newString length] > GROUP_NAME_MAX_LENGTH) {
        return NO;
    }
    
    return YES;
}

- (BOOL)customTextFieldViewTextFieldShouldReturn:(UITextField *)textField {
    [self.createGroupSubjectView.groupNameTextField.textField resignFirstResponder];
    
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


#pragma mark UIImagePickerController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:^{
        if ([[info objectForKey:@"UIImagePickerControllerMediaType"] isEqualToString:@"public.image"]) {
            //IMAGE TYPE
            UIImage *selectedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
            self.selectedImage = selectedImage;
            [self.createGroupSubjectView setGroupPictureImageViewWithImage:selectedImage];
            if (self.tapCreateGroupSubjectControllerType == TAPCreateGroupSubjectViewControllerTypeUpdate) {
                //CS TEMP - hide remove picture button as the API is not ready yet
                self.createGroupSubjectView.removePictureButton.alpha = 0.0f;
            }
           
        }
    }];
}

#pragma mark PopUpInfoViewController
- (void)popUpInfoDidTappedLeftButtonWithIdentifier:(NSString *)popupIdentifier {
    
}

- (void)popUpInfoTappedSingleButtonOrRightButtonWithIdentifier:(NSString *)popupIdentifier {
    //Error pop up tapped
    [self.createGroupSubjectView.createButtonView setAsLoading:NO animated:NO];
    if ([popupIdentifier isEqualToString:@"Error Upload Group Image"]) {
        //group created but failed to upload image, open room
    }
    else if ([popupIdentifier isEqualToString:@"Error Create Group"]) {
        
    }
    else if ([popupIdentifier isEqualToString:@"Error Update Group"]) {
        
    }
    else if ([popupIdentifier isEqualToString:@"Error Create Group Name"]) {
        
    }
}

#pragma mark - Custom Method
- (void)keyboardWillShowWithHeight:(CGFloat)keyboardHeight {
}

- (void)keyboardWillHideWithHeight:(CGFloat)keyboardHeight {
}

- (void)setRoomData:(TAPRoomModel *)room {
    _roomModel = room;
}

- (void)createButtonDidTapped {
    _isLoading = YES;
    [self.createGroupSubjectView.createButtonView setAsLoading:YES animated:YES];
    self.createGroupSubjectView.createButtonView.userInteractionEnabled = NO;
    
    NSString *groupName = self.createGroupSubjectView.groupNameTextField.textField.text;
    groupName = [groupName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([groupName isEqualToString:@""]) {
        
        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Create Group Name" title:NSLocalizedStringFromTableInBundle(@"Failed", nil, [TAPUtil currentBundle], @"") detailInformation:NSLocalizedStringFromTableInBundle(@"Group name must be filled", nil, [TAPUtil currentBundle], @"") leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
        return;
    }
    
    NSMutableDictionary *participantListDictionary = [[NSMutableDictionary alloc] init];
    if (self.tapCreateGroupSubjectControllerType == TAPCreateGroupSubjectViewControllerTypeDefault) {
        NSMutableArray *userIDArray = [NSMutableArray array];
        for (TAPUserModel *user in self.selectedContactArray) {
            [userIDArray addObject:user.userID];
            [participantListDictionary setObject:user forKey:user.username];
        }
        
        [TAPDataManager callAPICreateRoomWithName:groupName type:RoomTypeGroup userIDArray:userIDArray success:^(TAPRoomModel *room) {
            
            if (self.selectedImage != nil) {
                //has image, upload image
                UIImage *imageToSend = [self rotateImage:self.createGroupSubjectView.groupPictureImageView.image];
                NSData *imageData = UIImageJPEGRepresentation(imageToSend, [[TapTalk sharedInstance] getImageCompressionQuality]);
                [TAPDataManager callAPIUploadRoomImageWithImageData:imageData roomID:room.roomID completionBlock:^(TAPRoomModel *room) {
                    self.createGroupSubjectView.createButtonView.userInteractionEnabled = YES;
                    [self.createGroupSubjectView.createButtonView setAsLoading:NO animated:YES];
#ifdef DEBUG
                    NSLog(@"Success upload image");
#endif
                    
                    _isLoading = NO;
                    
                    //Update to group cache
                    TAPRoomModel *existingRoom = [[TAPGroupManager sharedManager] getRoomWithRoomID:room.roomID];
                    existingRoom.name = room.name;
                    existingRoom.color = room.color;
                    existingRoom.isDeleted = room.isDeleted;
                    existingRoom.deleted = room.deleted;
                    existingRoom.imageURL = room.imageURL;
                    
                    if (existingRoom != nil) {
                        [[TAPGroupManager sharedManager] setRoomWithRoomID:room.roomID room:existingRoom];
                    }

                    [self dismissViewControllerAnimated:NO completion:nil];
                    
                    [[TapUI sharedInstance] createRoomWithRoom:room success:^(TapUIChatViewController * _Nonnull chatViewController) {
                        chatViewController.hidesBottomBarWhenPushed = YES;
                        chatViewController.participantListDictionary = participantListDictionary;
                        [self.roomListViewController.navigationController pushViewController:chatViewController animated:YES];
                    }];
                    
                } progressBlock:^(CGFloat progress, CGFloat total) {
                    
                } failureBlock:^(NSError *error) {
                    self.createGroupSubjectView.createButtonView.userInteractionEnabled = YES;
                    [self.createGroupSubjectView.createButtonView setAsLoading:NO animated:YES];
                    NSString *errorMessage = [error.userInfo objectForKey:@"message"];
                    errorMessage = [TAPUtil nullToEmptyString:errorMessage];
                    [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Upload Group Image" title:NSLocalizedStringFromTableInBundle(@"Failed", nil, [TAPUtil currentBundle], @"") detailInformation:errorMessage leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
                }];
            }
            else {
                //no image, open room
                
                _isLoading = NO;
                [self.createGroupSubjectView.createButtonView setAsLoading:NO animated:YES];
                self.createGroupSubjectView.createButtonView.userInteractionEnabled = YES;
                
                //Save to group preference
                [[TAPGroupManager sharedManager] setRoomWithRoomID:room.roomID room:room];
                
                [self dismissViewControllerAnimated:NO completion:nil];
                [[TapUI sharedInstance] createRoomWithRoom:room success:^(TapUIChatViewController * _Nonnull chatViewController) {
                    chatViewController.hidesBottomBarWhenPushed = YES;
                    [self.roomListViewController.navigationController pushViewController:chatViewController animated:YES];
                }];
            }
        } failure:^(NSError *error) {
            _isLoading = NO;
            [self.createGroupSubjectView.createButtonView setAsLoading:NO animated:YES];
            self.createGroupSubjectView.createButtonView.userInteractionEnabled = YES;
            NSString *errorMessage = [error.userInfo objectForKey:@"message"];
            errorMessage = [TAPUtil nullToEmptyString:errorMessage];
            [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Create Group" title:NSLocalizedStringFromTableInBundle(@"Failed", nil, [TAPUtil currentBundle], @"") detailInformation:errorMessage leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
        }];
    }
    else if (self.tapCreateGroupSubjectControllerType == TAPCreateGroupSubjectViewControllerTypeUpdate) {
        if ([groupName isEqualToString:self.roomModel.name]) {
            //Group name not changing
            if (self.selectedImage != nil) {
                //has image, upload image
                UIImage *imageToSend = [self rotateImage:self.createGroupSubjectView.groupPictureImageView.image];
                NSData *imageData = UIImageJPEGRepresentation(imageToSend, [[TapTalk sharedInstance] getImageCompressionQuality]);
                [TAPDataManager callAPIUploadRoomImageWithImageData:imageData roomID:self.roomModel.roomID completionBlock:^(TAPRoomModel *room) {
                    self.createGroupSubjectView.createButtonView.userInteractionEnabled = YES;
                    [self.createGroupSubjectView.createButtonView setAsLoading:NO animated:YES];

                    //Save to group preference
                    TAPRoomModel *existingRoom = [[TAPGroupManager sharedManager] getRoomWithRoomID:room.roomID];
                    existingRoom.name = room.name;
                    existingRoom.color = room.color;
                    existingRoom.isDeleted = room.isDeleted;
                    existingRoom.deleted = room.deleted;
                    existingRoom.imageURL = room.imageURL;
                    
                    if (existingRoom != nil) {
                        [[TAPGroupManager sharedManager] setRoomWithRoomID:room.roomID room:existingRoom];
                    }
                    
                    _isLoading = NO;
                    
                    //image uploaded
                    //dismiss view controller
                    //back to room
                    if ([self.delegate respondsToSelector:@selector(createGroupSubjectViewControllerUpdatedRoom:)]) {
                        [self.delegate createGroupSubjectViewControllerUpdatedRoom:room];
                    }
                    [self dismissViewControllerAnimated:YES completion:nil];
                } progressBlock:^(CGFloat progress, CGFloat total) {
                    
                } failureBlock:^(NSError *error) {
                    self.createGroupSubjectView.createButtonView.userInteractionEnabled = YES;
                    [self.createGroupSubjectView.createButtonView setAsLoading:NO animated:YES];
                    NSString *errorMessage = [error.userInfo objectForKey:@"message"];
                    errorMessage = [TAPUtil nullToEmptyString:errorMessage];
                    [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Upload Group Image" title:NSLocalizedStringFromTableInBundle(@"Failed", nil, [TAPUtil currentBundle], @"") detailInformation:errorMessage leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
                }];
            }
            else {
                //no image, dismiss view controller
                //back to room detail
                _isLoading = NO;
                
                if ([self.delegate respondsToSelector:@selector(createGroupSubjectViewControllerUpdatedRoom:)]) {
                    [self.delegate createGroupSubjectViewControllerUpdatedRoom:self.roomModel];
                }
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
        else {
            //Group name change
            [TAPDataManager callAPIUpdateRoomWithRoomID:self.roomModel.roomID roomName:groupName success:^(TAPRoomModel *room) {
                if (self.selectedImage != nil) {
                    //has image, upload image
                    UIImage *imageToSend = [self rotateImage:self.createGroupSubjectView.groupPictureImageView.image];
                    NSData *imageData = UIImageJPEGRepresentation(imageToSend, [[TapTalk sharedInstance] getImageCompressionQuality]);
                    [TAPDataManager callAPIUploadRoomImageWithImageData:imageData roomID:room.roomID completionBlock:^(TAPRoomModel *room) {
                        self.createGroupSubjectView.createButtonView.userInteractionEnabled = YES;
                        [self.createGroupSubjectView.createButtonView setAsLoading:NO animated:YES];

                        //Save to group preference
                        TAPRoomModel *existingRoom = [[TAPGroupManager sharedManager] getRoomWithRoomID:room.roomID];
                        existingRoom.name = room.name;
                        existingRoom.color = room.color;
                        existingRoom.isDeleted = room.isDeleted;
                        existingRoom.deleted = room.deleted;
                        existingRoom.imageURL = room.imageURL;
                        
                        _isLoading = NO;
                        
                        if (existingRoom != nil) {
                            [[TAPGroupManager sharedManager] setRoomWithRoomID:room.roomID room:existingRoom];
                        }
                        
                        //image uploaded
                        //dismiss view controller
                        //back to room
                        if ([self.delegate respondsToSelector:@selector(createGroupSubjectViewControllerUpdatedRoom:)]) {
                            [self.delegate createGroupSubjectViewControllerUpdatedRoom:room];
                        }
                        [self dismissViewControllerAnimated:YES completion:nil];
                    } progressBlock:^(CGFloat progress, CGFloat total) {
                        
                    } failureBlock:^(NSError *error) {
                        _isLoading = NO;
                        self.createGroupSubjectView.createButtonView.userInteractionEnabled = YES;
                        [self.createGroupSubjectView.createButtonView setAsLoading:NO animated:YES];
                        NSString *errorMessage = [error.userInfo objectForKey:@"message"];
                        errorMessage = [TAPUtil nullToEmptyString:errorMessage];
                        [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Upload Group Image" title:NSLocalizedStringFromTableInBundle(@"Failed", nil, [TAPUtil currentBundle], @"") detailInformation:errorMessage leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
                    }];
                }
                else {
                    //no image, dismiss view controller
                    _isLoading = NO;
                    
                    //Save to group preference
                    TAPRoomModel *existingRoom = [[TAPGroupManager sharedManager] getRoomWithRoomID:room.roomID];
                    existingRoom.name = room.name;
                    existingRoom.color = room.color;
                    existingRoom.isDeleted = room.isDeleted;
                    existingRoom.deleted = room.deleted;
                    existingRoom.imageURL = room.imageURL;
                    
                    if (existingRoom != nil) {
                        [[TAPGroupManager sharedManager] setRoomWithRoomID:room.roomID room:existingRoom];
                    }
                    
                    //back to room detail
                    if ([self.delegate respondsToSelector:@selector(createGroupSubjectViewControllerUpdatedRoom:)]) {
                        [self.delegate createGroupSubjectViewControllerUpdatedRoom:room];
                    }
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            } failure:^(NSError *error) {
                _isLoading = NO;
                [self.createGroupSubjectView.createButtonView setAsLoading:NO animated:YES];
                self.createGroupSubjectView.createButtonView.userInteractionEnabled = YES;
                NSString *errorMessage = [error.userInfo objectForKey:@"message"];
                errorMessage = [TAPUtil nullToEmptyString:errorMessage];
                [self showPopupViewWithPopupType:TAPPopUpInfoViewControllerTypeErrorMessage popupIdentifier:@"Error Update Group" title:NSLocalizedStringFromTableInBundle(@"Failed", nil, [TAPUtil currentBundle], @"") detailInformation:errorMessage leftOptionButtonTitle:nil singleOrRightOptionButtonTitle:nil];
            }];
        }
    }
}

- (void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self.view endEditing:YES];
}

- (void)changeButtonDidTapped {
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

- (void)removePictureButtonDidTapped {
    self.selectedImage = nil;
    [self.createGroupSubjectView setGroupPictureImageViewWithImage:nil];
}

- (void)backButtonDidTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelButtonDidTapped {
    if (self.isLoading) {
        return;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setTapCreateGroupSubjectControllerType:(TAPCreateGroupSubjectViewControllerType)tapCreateGroupSubjectControllerType {
    _tapCreateGroupSubjectControllerType = tapCreateGroupSubjectControllerType;
    if (tapCreateGroupSubjectControllerType == TAPCreateGroupSubjectViewControllerTypeUpdate) {
        self.createGroupSubjectView.tapCreateGroupSubjectType = TAPCreateGroupSubjectViewTypeUpdate;
        [self.createGroupSubjectView setTapCreateGroupSubjectType:TAPCreateGroupSubjectViewTypeUpdate];
    }
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

- (UIImage*)rotateImage:(UIImage* )originalImage {
    UIImageOrientation orientation = originalImage.imageOrientation;
    UIGraphicsBeginImageContext(originalImage.size);
    [originalImage drawAtPoint:CGPointMake(0, 0)];
    CGContextRef context = UIGraphicsGetCurrentContext();

     if (orientation == UIImageOrientationRight) {
         CGContextRotateCTM (context, [self radians:90]);
     } else if (orientation == UIImageOrientationLeft) {
         CGContextRotateCTM (context, [self radians:90]);
     } else if (orientation == UIImageOrientationDown) {
         // NOTHING
     } else if (orientation == UIImageOrientationUp) {
         CGContextRotateCTM (context, [self radians:0]);
     }
      return UIGraphicsGetImageFromCurrentImageContext();
}

- (CGFloat)radians:(int)degree {
    return (degree/180)*(22/7);
}


@end
