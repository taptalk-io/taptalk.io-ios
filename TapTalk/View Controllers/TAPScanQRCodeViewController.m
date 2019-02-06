//
//  TAPScanQRCodeViewController.m
//  TapTalk
//
//  Created by Dominic Vedericho on 11/4/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPScanQRCodeViewController.h"
#import "TAPScanQRCodeView.h"
#import "TAPScanQRCodePopupView.h"

#import "ZBarCaptureReader.h"
#import "ZBarReaderViewController.h"
#import "ZBarReaderView.h"
#import "ZBarImageScanner.h"

@interface TAPScanQRCodeViewController () <ZBarReaderViewDelegate>

@property (strong, nonatomic) TAPScanQRCodeView *scanQRCodeView;
@property (strong, nonatomic) TAPScanQRCodePopupView *scanQRCodePopupView;
@property (strong, nonatomic) TAPUserModel *searchedUser;
@property (nonatomic) BOOL isProcessingQRCode;

- (void)handleCodeInput:(NSString *)code;
- (void)QRCodeButtonDidTapped;

//QR Code Popup Info View
- (void)closePopupButtonDidTapped;
- (void)addContactButtonDidTapped;
- (void)chatNowButtonDidTapped;

@end

@implementation TAPScanQRCodeViewController

#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    _scanQRCodeView = [[TAPScanQRCodeView alloc] initWithFrame:[TAPBaseView frameWithNavigationBar]];
    [self.view addSubview:self.scanQRCodeView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"Scan QR Code", @"");
    [self showCustomBackButton];
    
    [self.scanQRCodeView.QRCodeButton addTarget:self action:@selector(QRCodeButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    
     self.scanQRCodeView.readerView.readerDelegate = self;
    
    [self.scanQRCodeView setScanQRCodeViewType:ScanQRCodeViewTypeScanQRCode];
    [self.view bringSubviewToFront:self.scanQRCodeView.overlayView];

    _scanQRCodePopupView = [[TAPScanQRCodePopupView alloc] initWithFrame:[TAPBaseView frameWithoutNavigationBar]];
    [self.scanQRCodePopupView.closePopupButton addTarget:self action:@selector(closePopupButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.scanQRCodePopupView.addContactButton addTarget:self action:@selector(addContactButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.scanQRCodePopupView.chatNowButton addTarget:self action:@selector(chatNowButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.scanQRCodePopupView showPopupView:NO animated:NO];
    [self.navigationController.view addSubview:self.scanQRCodePopupView];
    [self.navigationController.view bringSubviewToFront:self.scanQRCodePopupView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];    
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Delegate
#pragma mark ZBarReaderView
- (void)readerView:(ZBarReaderView *)readerView didReadSymbols:(ZBarSymbolSet *)symbols fromImage:(UIImage *)image {
    for (ZBarSymbol *symbol in symbols) {
        [self handleCodeInput:symbol.data];
    }
}

#pragma mark - Custom Method
- (void)handleCodeInput:(NSString *)code {
    if (self.isProcessingQRCode) {
        return;
    }
    
    _isProcessingQRCode = YES;
    [TAPUtil tapticNotificationFeedbackGeneratorWithType:UINotificationFeedbackTypeSuccess];
    
    [self.scanQRCodePopupView showPopupView:YES animated:YES];
    [self.scanQRCodePopupView setIsLoading:YES animated:YES];
    [TAPDataManager callAPIGetUserByUserID:code success:^(TAPUserModel *user) {
        
        //Upsert User to Contact Manager
        [[TAPContactManager sharedManager] addContactWithUserModel:user saveToDatabase:NO];
        
        _searchedUser = user;
//        _isProcessingQRCode = NO;
//        [self.scanQRCodePopupView setIsLoading:NO animated:YES];
//        [self.scanQRCodePopupView setPopupInfoWithUserData:user];
        
        //DV Temp
        //Note - Temporary query for friend data from db, if found means isContact = 1 until API response showing isContact
        [TAPDataManager getDatabaseContactByUserID:user.userID success:^(BOOL isContact, TAPUserModel *obtainedUser) {
            _isProcessingQRCode = NO;
            [self.scanQRCodePopupView setIsLoading:NO animated:YES];
            [self.scanQRCodePopupView setPopupInfoWithUserData:user isContact:isContact];
        } failure:^(NSError *error) {
#ifdef DEBUG
            NSLog(@"%@", error);
#endif
        }];
        //END DV Temp
        
    } failure:^(NSError *error) {
        _isProcessingQRCode = NO;
        [self.scanQRCodePopupView setIsLoading:NO animated:YES];
        [self.scanQRCodePopupView showPopupView:NO animated:YES];
        [self showPopupView:YES withPopupType:TAPPopUpInfoViewControllerTypeErrorMessage title:NSLocalizedString(@"Failed", @"") detailInformation:error.domain];
    }];
}

- (CIImage *)createQRForString:(NSString *)qrString {
    NSData *stringData = [qrString dataUsingEncoding: NSISOLatin1StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    
    return qrFilter.outputImage;
}

- (void)QRCodeButtonDidTapped {
    
    self.scanQRCodeView.QRCodeButton.selected = !self.scanQRCodeView.QRCodeButton.selected;
    
    if (self.scanQRCodeView.QRCodeButton.selected) {
        //Display user QR Code
        
        self.title = NSLocalizedString(@"My QR Code", @"");
        
        NSString *userID = [TAPDataManager getActiveUser].userID;
        userID = [TAPUtil nullToEmptyString:userID];
        
        NSString *qrString = [NSString stringWithFormat:@"%@", userID];
        CIImage *image = [self createQRForString:qrString];
        
        CGAffineTransform transform = CGAffineTransformMakeScale(20.0f, 20.0f); // Scale by 20 times along both dimensions
        CIImage *output = [image imageByApplyingTransform: transform];
        UIImage *outputUIImage = [[UIImage alloc] initWithCIImage:output];
        
        [self.scanQRCodeView setUserQRCodeImage:outputUIImage];
        [self.scanQRCodeView setScanQRCodeViewType:ScanQRCodeViewTypeDisplayQRCode];
    }
    else {
         //Display scan QR Code menu
        [self.scanQRCodeView setScanQRCodeViewType:ScanQRCodeViewTypeScanQRCode];
        self.title = NSLocalizedString(@"Scan QR Code", @"");
    }
}

- (void)setScanQRCodeViewControllerSourceType:(ScanQRCodeViewControllerSourceType)scanQRCodeViewControllerSourceType {
    _scanQRCodeViewControllerSourceType = scanQRCodeViewControllerSourceType;
}

- (void)closePopupButtonDidTapped {
    _isProcessingQRCode = NO;
    [self.scanQRCodePopupView setPopupViewToDefault];
    [self.scanQRCodePopupView showPopupView:NO animated:NO];
}

- (void)addContactButtonDidTapped {
    [self.scanQRCodePopupView animateExpandingView];
    
    [TAPDataManager callAPIAddContactWithUserID:self.searchedUser.userID success:^(NSString *message) {
//        [self.addNewContactView.searchBarView.searchTextField resignFirstResponder];
//        [self.addContactPopupView setPopupInfoWithUserData:self.searchedUser isContact:YES];
//        [self.addContactPopupView showPopupView:YES animated:YES];
//        [self.addContactPopupView animateExpandingView];
//        [self.addNewContactView setSearchUserButtonWithType:ButtonTypeChat];
        
        //Add user to Contact Manager
        self.searchedUser.isContact = YES;
        [[TAPContactManager sharedManager] addContactWithUserModel:self.searchedUser saveToDatabase:YES];
        
        //Refresh Contact List From API
        [TAPDataManager callAPIGetContactList:^(NSArray *userArray) {
        } failure:^(NSError *error) {
        }];
        
    } failure:^(NSError *error) {
#ifdef DEBUG
        NSLog(@"%@", error);
#endif
    }];
}

- (void)chatNowButtonDidTapped {
    _isProcessingQRCode = NO;
    [self.scanQRCodePopupView setPopupViewToDefault];
    [self.scanQRCodePopupView showPopupView:NO animated:NO];
    
    [[TapTalk sharedInstance] openRoomWithOtherUser:self.searchedUser fromNavigationController:self.navigationController];
    
    //CS Note - Remove this VC in Navigation Stack to skip on pop
    NSMutableArray *navigationArray = [[NSMutableArray alloc] initWithArray: self.navigationController.viewControllers];
    [navigationArray removeObject:self];
    self.navigationController.viewControllers = navigationArray;
}

- (void)popUpInfoTappedSingleButtonOrRightButton {
    [self showPopupView:NO withPopupType:TAPPopUpInfoViewControllerTypeErrorMessage title:@"" detailInformation:@""];
}

@end
