//
//  TAPScanQRCodePopupView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 22/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseView.h"
#import "TAPUserModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ScanQRCodePopupViewType) {
    ScanQRCodePopupViewTypeDefault = 0,
    ScanQRCodePopupViewTypeNewFriend = 1,
    ScanQRCodePopupViewTypeAlreadyFriend = 2,
    ScanQRCodePopupViewTypeSelf = 3
};

@interface TAPScanQRCodePopupView : TAPBaseView

@property (nonatomic) ScanQRCodePopupViewType scanQRCodePopupViewType;
@property (strong, nonatomic) UIButton *closePopupButton;
@property (strong, nonatomic) UIButton *chatNowButton;
@property (strong, nonatomic) UIButton *addContactButton;
@property (strong, nonatomic) UIView *loadingView;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorLoading;

- (void)animateExpandingView;
- (void)setPopupViewToDefault;
- (void)showPopupView:(BOOL)isVisible animated:(BOOL)isAnimated;
//- (void)setPopupInfoWithUserData:(TAPUserModel *)user;
- (void)setPopupInfoWithUserData:(TAPUserModel *)user isContact:(BOOL)isContact; //DV Temp
- (void)setScanQRCodePopupViewType:(ScanQRCodePopupViewType)scanQRCodePopupViewType;
- (void)setIsLoading:(BOOL)isLoading animated:(BOOL)isAnimated;

@end

NS_ASSUME_NONNULL_END
