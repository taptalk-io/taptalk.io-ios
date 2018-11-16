//
//  TAPConnectionStatusViewController.h
//  TapTalk
//
//  Created by Welly Kencana on 8/10/18.
//

#import <TapTalk/TapTalk.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TAPConnectionStatusViewControllerDelegate <NSObject>

- (void)connectionStatusViewControllerDelegateHeightChange:(CGFloat)height;

@end

@interface TAPConnectionStatusViewController : TAPBaseViewController

@property (weak, nonatomic) id<TAPConnectionStatusViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
