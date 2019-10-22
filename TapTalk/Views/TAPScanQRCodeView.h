//
//  TAPScanQRCodeView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 11/4/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseView.h"
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, ScanQRCodeViewType) {
    ScanQRCodeViewTypeScanQRCode = 0,
    ScanQRCodeViewTypeDisplayQRCode = 1
};

@interface TAPScanQRCodeView : TAPBaseView

@property (strong, nonatomic) UIView *cameraView;
@property (strong, nonatomic) UIButton *QRCodeButton;
@property (strong, nonatomic) UIView *overlayView;
@property (strong, nonatomic) UIView *showCodeContainerView;
@property (nonatomic) ScanQRCodeViewType scanQRCodeViewType;

- (void)setUserQRCodeImage:(UIImage *)qrCodeImage;

@end
