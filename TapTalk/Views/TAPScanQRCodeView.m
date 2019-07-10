//
//  TAPScanQRCodeView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 11/4/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPScanQRCodeView.h"

@interface TAPScanQRCodeView ()

@property (strong, nonatomic) UIView *topBlackView;
@property (strong, nonatomic) UIView *leftBlackView;
@property (strong, nonatomic) UIView *rightBlackView;
@property (strong, nonatomic) UIView *bottomBlackView;
@property (strong, nonatomic) UIView *whiteBackgroundView;
@property (strong, nonatomic) UIImageView *scanBoundImageView;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UIImageView *userQRCodeImageView;

@end

@implementation TAPScanQRCodeView

#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        _readerView = [ZBarReaderView new];
        self.readerView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds));
        self.readerView.torchMode = AVCaptureTorchModeAuto;
        //set default rear camera used
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        self.readerView.device = captureDevice;
        [self addSubview:self.readerView];

        _overlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        self.overlayView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.overlayView];
        
        CGFloat leftRightBlackViewWidth = (CGRectGetWidth(self.overlayView.frame) - 300.0f) / 2.0f;
        _leftBlackView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, leftRightBlackViewWidth, CGRectGetHeight(self.overlayView.frame))];
        self.leftBlackView.backgroundColor = [[TAPUtil getColor:@"04040f"] colorWithAlphaComponent:0.4f];
        [self.overlayView addSubview:self.leftBlackView];
        
        _topBlackView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.leftBlackView.frame), 0.0f, CGRectGetWidth(self.overlayView.frame) - CGRectGetMaxX(self.leftBlackView.frame) - CGRectGetMaxX(self.leftBlackView.frame), 70.0f)];
        self.topBlackView.backgroundColor = [[TAPUtil getColor:@"04040f"] colorWithAlphaComponent:0.4f];
        [self.overlayView addSubview:self.topBlackView];

        _whiteBackgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.leftBlackView.frame), CGRectGetMaxY(self.topBlackView.frame), 300.0f, 300.0f)];
        self.whiteBackgroundView.backgroundColor = [UIColor whiteColor];
        self.whiteBackgroundView.alpha = 0.0f;
        [self.overlayView addSubview:self.whiteBackgroundView];
        
        _scanBoundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.leftBlackView.frame), CGRectGetMaxY(self.topBlackView.frame), 300.0f, 300.0f)];
        self.scanBoundImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.overlayView addSubview:self.scanBoundImageView];
        
        _rightBlackView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.scanBoundImageView.frame), CGRectGetMinY(self.leftBlackView.frame), leftRightBlackViewWidth, CGRectGetHeight(self.leftBlackView.frame))];
        self.rightBlackView.backgroundColor = [[TAPUtil getColor:@"04040f"] colorWithAlphaComponent:0.4f];
        [self.overlayView addSubview:self.rightBlackView];
        
        //300.0f = scan bound height
        _bottomBlackView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.topBlackView.frame), CGRectGetMaxY(self.scanBoundImageView.frame), CGRectGetWidth(self.topBlackView.frame), CGRectGetHeight(self.overlayView.frame) - 300.0f - CGRectGetHeight(self.topBlackView.frame))];
        self.bottomBlackView.backgroundColor = [[TAPUtil getColor:@"04040f"] colorWithAlphaComponent:0.4f];
        [self.overlayView addSubview:self.bottomBlackView];
        
        CGFloat additionalBottomGap = 12.0f;
        if (IS_IPHONE_X_FAMILY) {
            additionalBottomGap += [TAPUtil safeAreaBottomPadding];
        }
        
        
        UIFont *buttonLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontButtonLabel];
        UIColor *buttonLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorButtonLabel];
        _QRCodeButton = [[UIButton alloc] initWithFrame:CGRectMake(8.0f, CGRectGetHeight(self.frame) - 45.0f - additionalBottomGap, CGRectGetWidth(self.frame) - 16.0f, 45.0f)];
        self.QRCodeButton.layer.cornerRadius = 6.0f;
        self.QRCodeButton.clipsToBounds = YES;
        [self.QRCodeButton setTintColor:buttonLabelColor];
        self.QRCodeButton.titleLabel.font = buttonLabelFont;
        self.QRCodeButton.layer.borderWidth = 1.0f;
        self.QRCodeButton.layer.borderColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonActiveBorder].CGColor;
        [self addSubview:self.QRCodeButton];
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.QRCodeButton.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonActiveBackgroundGradientLight].CGColor, (id)[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorButtonActiveBackgroundGradientDark].CGColor, nil];
        gradient.startPoint = CGPointMake(0.0f, 0.0f);
        gradient.endPoint = CGPointMake(0.0f, 1.0f);
        gradient.cornerRadius = 6.0f;
        [self.QRCodeButton.layer insertSublayer:gradient atIndex:0];
        
        UIFont *infoLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontInfoLabelBody];
        UIColor *infoLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorInfoLabelBody];
        _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(21.0f, CGRectGetMinY(self.QRCodeButton.frame) - 20.0f - 20.0f, CGRectGetWidth(self.overlayView.frame) - 42.0f, 20.0f)];
        self.descriptionLabel.numberOfLines = 0;
        self.descriptionLabel.font = infoLabelFont;
        self.descriptionLabel.textColor = [UIColor whiteColor];
        self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
        [self.overlayView addSubview:self.descriptionLabel];
        
        CGFloat scanBoundaryGap = (CGRectGetWidth(self.scanBoundImageView.frame) - 300.0f) / 2.0f;
        _userQRCodeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.scanBoundImageView.frame) + scanBoundaryGap, CGRectGetMinY(self.scanBoundImageView.frame) + scanBoundaryGap, 300.0f, 300.0f)];
        self.userQRCodeImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.userQRCodeImageView.alpha = 0.0f;
        [self.overlayView addSubview:self.userQRCodeImageView];
    }
    
    return self;
}

#pragma mark - Custom Method
- (void)setScanQRCodeViewType:(ScanQRCodeViewType)scanQRCodeViewType {
    _scanQRCodeViewType = scanQRCodeViewType;
    if (self.scanQRCodeViewType == ScanQRCodeViewTypeScanQRCode) {
        [UIView animateWithDuration:0.2f animations:^{
            [self.readerView start];
            
            self.whiteBackgroundView.alpha = 0.0f;
            self.userQRCodeImageView.alpha = 0.0f;
            
            self.backgroundColor = [UIColor clearColor];
            self.topBlackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
            self.bottomBlackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
            self.leftBlackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
            self.rightBlackView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f];
            
            self.scanBoundImageView.image = [UIImage imageNamed:@"TAPIconQRBounds" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
            [self.QRCodeButton setTitle:NSLocalizedString(@"Show QR Code", @"") forState:UIControlStateNormal];
            self.descriptionLabel.text = NSLocalizedString(@"Show your QR code by tapping the button below", @"");
            self.descriptionLabel.textColor = [UIColor whiteColor];
            
            //Resize description label height
            CGSize descriptionLabelSize = [self.descriptionLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.descriptionLabel.frame), CGFLOAT_MAX)];
            self.descriptionLabel.frame = CGRectMake(CGRectGetMinX(self.descriptionLabel.frame), CGRectGetMinY(self.QRCodeButton.frame) - ceilf(descriptionLabelSize.height) - 20.0f, CGRectGetWidth(self.descriptionLabel.frame), ceilf(descriptionLabelSize.height));

        }];
    }
    else if (self.scanQRCodeViewType == ScanQRCodeViewTypeDisplayQRCode) {
        [UIView animateWithDuration:0.2f animations:^{
            [self.readerView stop];
            
            self.whiteBackgroundView.alpha = 1.0f;
            self.userQRCodeImageView.alpha = 1.0f;
            
            self.backgroundColor = [UIColor whiteColor];
            self.topBlackView.backgroundColor = [UIColor whiteColor];
            self.bottomBlackView.backgroundColor = [UIColor whiteColor];
            self.leftBlackView.backgroundColor = [UIColor whiteColor];
            self.rightBlackView.backgroundColor = [UIColor whiteColor];
            
            UIColor *infoLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorInfoLabelBody];
            self.scanBoundImageView.image = nil;
            self.descriptionLabel.text = NSLocalizedString(@"To scan other's QR code, please tap the button below", @"");
            [self.QRCodeButton setTitle:NSLocalizedString(@"Scan QR Code", @"") forState:UIControlStateNormal];
            self.descriptionLabel.textColor = infoLabelColor;
            
            //Resize description label height
            CGSize descriptionLabelSize = [self.descriptionLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.descriptionLabel.frame), CGFLOAT_MAX)];
            self.descriptionLabel.frame = CGRectMake(CGRectGetMinX(self.descriptionLabel.frame), CGRectGetMinY(self.QRCodeButton.frame) - ceilf(descriptionLabelSize.height) - 20.0f, CGRectGetWidth(self.descriptionLabel.frame), ceilf(descriptionLabelSize.height));

        }];
    }
}

- (void)setUserQRCodeImage:(UIImage *)qrCodeImage {
    self.userQRCodeImageView.image = qrCodeImage;
}

@end
