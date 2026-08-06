//
//  TapCustomNavigationBarButton.h
//  TapTalk
//
//  Created by Kevin on 10/28/22.
//

#import <UIKit/UIKit.h>
#import "TapUIChatViewController.h"
#import "TAPRoomModel.h"
#import "TAPUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TapCustomNavigationBarButton : UIButton

@property (strong, nonatomic) TapUIChatViewController *chatViewController;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) TAPRoomModel *room;
@property (strong, nonatomic) TAPUserModel *activeUser;
@property (strong, nonatomic) TAPUserModel *recipientUser;

@end

NS_ASSUME_NONNULL_END
