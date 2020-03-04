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
#import <AVFoundation/AVFoundation.h>

@interface TAPScanQRCodeViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) TAPScanQRCodeView *scanQRCodeView;
@property (strong, nonatomic) TAPUserModel *searchedUser;
@property (nonatomic) BOOL isProcessingQRCode;

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

- (BOOL)startReading;
- (void)stopReading;
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
    
    self.title = NSLocalizedStringFromTableInBundle(@"Scan QR Code", nil, [TAPUtil currentBundle], @"");
    [self showCustomBackButton];
    
    [self.scanQRCodeView.QRCodeButton addTarget:self action:@selector(QRCodeButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    
    _captureSession = nil;
    
    [self.scanQRCodeView setScanQRCodeViewType:ScanQRCodeViewTypeScanQRCode];
    [self.view bringSubviewToFront:self.scanQRCodeView.overlayView];
    [self startReading];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _isProcessingQRCode = NO;
    [self.navigationController setNavigationBarHidden:NO];
    [self startReading];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Delegate
#pragma mark AVCaptureMetadataOutputObjects
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            NSString *codeValue = [metadataObj stringValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleCodeInput:codeValue];
            });
       }
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
        [self stopReading];
        
        self.title = NSLocalizedStringFromTableInBundle(@"My QR Code", nil, [TAPUtil currentBundle], @"");
        
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
        [self startReading];
        [self.scanQRCodeView setScanQRCodeViewType:ScanQRCodeViewTypeScanQRCode];
        self.title = NSLocalizedStringFromTableInBundle(@"Scan QR Code", nil, [TAPUtil currentBundle], @"");
    }
}

- (BOOL)startReading {
     NSError *error;
     AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
     AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
     if (!input) {
         NSLog(@"%@", [error localizedDescription]);
         return NO;
     }

     _captureSession = [[AVCaptureSession alloc] init];
     [_captureSession addInput:input];
     AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
     [_captureSession addOutput:captureMetadataOutput];
     
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];

    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:self.scanQRCodeView.cameraView.layer.bounds];
    [self.scanQRCodeView.cameraView.layer addSublayer:_videoPreviewLayer];
    [_captureSession startRunning];
    return YES;
}

- (void)stopReading {
    [_captureSession stopRunning];
    _captureSession = nil;
    [_videoPreviewLayer removeFromSuperlayer];
}

@end
