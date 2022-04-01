//
//  TAPStarredMessageViewController.h
//  TapTalk
//
//  Created by TapTalk.io on 21/03/22.
//

#import "TAPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TAPStarredMessageViewControllerDelegate <NSObject>

@optional

- (void)starMessageBubbleCliked:(TAPMessageModel *)message;

@end

@interface TAPStarredMessageViewController : TAPBaseViewController

@property (strong, nonatomic) TAPRoomModel *currentRoom;
@property (weak, nonatomic) id<TAPStarredMessageViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
