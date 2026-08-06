//
//  TAPStarredMessageViewController.h
//  TapTalk
//
//  Created by TapTalk.io on 21/03/22.
//

#import "TAPBaseViewController.h"
#import "TAPMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPUIMessageListType) {
    TAPSecondaryChatTypeStarMessage = 0,
    TAPSecondaryChatTypePinMessage = 1,
    TAPSecondaryChatTypeScheduleMessage = 2,
};

@protocol TAPSecondaryChatViewControllerDelegate <NSObject>

@optional

- (void)starMessageBubbleCliked:(TAPMessageModel *)message;
- (void)unpinAllButtonCliked;

@end

@interface TAPSecondaryChatViewController : TAPBaseViewController

@property (strong, nonatomic) TAPRoomModel *currentRoom;
@property (weak, nonatomic) id<TAPSecondaryChatViewControllerDelegate> delegate;
@property (nonatomic) TAPUIMessageListType messageListType;
@property (strong, atomic) NSMutableArray *messageArray;
@property (strong, atomic) NSMutableArray *messageIDs;
@property (strong, nonatomic) NSString *chatroomScheduleContentString;
@property (strong, nonatomic) NSString *chatRoomScheduleTimne;

@end

NS_ASSUME_NONNULL_END
