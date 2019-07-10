//
//  TAPScanQRCodeViewController.m
//  TapTalk
//
//  Created by Dominic Vedericho on 11/4/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPScanQRCodeViewController.h"
#import "TAPScanQRCodeView.h"
#import "TAPScanQRCodePopupViewController.h"

#import "ZBarCaptureReader.h"
#import "ZBarReaderViewController.h"
#import "ZBarReaderView.h"
#import "ZBarImageScanner.h"

@interface TAPScanQRCodeViewController () <ZBarReaderViewDelegate>

@property (strong, nonatomic) TAPScanQRCodeView *scanQRCodeView;
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _isProcessingQRCode = NO;
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
    
    //remove key id: or xc: to obtain userID
    NSString *obtainedUserID = [code stringByReplacingOccurrencesOfString:@"id:" withString:@""];
    obtainedUserID = [obtainedUserID stringByReplacingOccurrencesOfString:@"xc:" withString:@""];
    
    TAPScanQRCodePopupViewController *scanQRCodePopupViewController = [[TAPScanQRCodePopupViewController alloc] init];
    scanQRCodePopupViewController.code = obtainedUserID;
    scanQRCodePopupViewController.previousNavigationController = self.navigationController;
    scanQRCodePopupViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:scanQRCodePopupViewController animated:NO completion:^{
        //completion
        [scanQRCodePopupViewController animatePopupWithSuccess:^{
            _isProcessingQRCode = NO;
        } failure:^(NSError * _Nonnull error) {
            _isProcessingQRCode = NO;
        }];
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
        
        NSString *qrString = [NSString stringWithFormat:@"id:%@", userID];
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

@end
