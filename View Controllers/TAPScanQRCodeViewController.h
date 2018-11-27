//
//  TAPScanQRCodeViewController.h
//  TapTalk
//
//  Created by Dominic Vedericho on 11/4/18.
//  Copyright © 2017 Moselo. All rights reserved.
//

#import "TAPBaseViewController.h"

typedef NS_ENUM(NSInteger, ScanQRCodeViewControllerSourceType) {
    ScanQRCodeViewControllerSourceTypeSearch = 0,
    ScanQRCodeViewControllerSourceTypeDiscover = 1
};

@protocol TAPScanQRCodeViewControllerDelegate <NSObject>

- (void)scanQRCodeViewControllerDoneAddFriend;

@optional
- (void)startChatFromQRCodeDidHandleTapped;

@end

@interface TAPScanQRCodeViewController : TAPBaseViewController

@property (strong, nonatomic) UIViewController *popViewController;
@property (weak, nonatomic) id <TAPScanQRCodeViewControllerDelegate> delegate;
@property (nonatomic) ScanQRCodeViewControllerSourceType scanQRCodeViewControllerSourceType;
- (CIImage *)createQRForString:(NSString *)qrString;

@end
