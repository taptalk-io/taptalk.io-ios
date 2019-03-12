//
//  TAPScanQRCodePopupViewController.h
//  TapTalk
//
//  Created by Welly Kencana on 11/3/19.
//

#import <TapTalk/TapTalk.h>

NS_ASSUME_NONNULL_BEGIN

//@protocol TAPScanQRCodePopupViewControllerDelegate <NSObject>
//
//- (void)scanQRCodePopupViewControllerIsProcessing:(BOOL)isProcessing;
//
//@end

@interface TAPScanQRCodePopupViewController : TAPBaseViewController

@property (strong, nonatomic) NSString *code;

//@property (weak, nonatomic) id<TAPScanQRCodePopupViewControllerDelegate> delegate;
@property (weak, nonatomic) UINavigationController *previousNavigationController;

- (void)animatePopupWithSuccess:(void (^)(void))success
                        failure:(void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
