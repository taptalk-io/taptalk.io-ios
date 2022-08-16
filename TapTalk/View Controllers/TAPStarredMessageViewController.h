//
//  TAPStarredMessageViewController.h
//  TapTalk
//
//  Created by TapTalk.io on 21/03/22.
//

#import "TAPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPUIMessageListType) {
    TAPUIMessageListTypeStar = 0,
    TAPUIMessageListTypePin = 1,
};

@protocol TAPStarredMessageViewControllerDelegate <NSObject>

@optional

- (void)starMessageBubbleCliked:(TAPMessageModel *)message;
- (void)unpinAllButtonCliked;


@end

@interface TAPStarredMessageViewController : TAPBaseViewController

@property (strong, nonatomic) TAPRoomModel *currentRoom;
@property (weak, nonatomic) id<TAPStarredMessageViewControllerDelegate> delegate;
@property (nonatomic) TAPUIMessageListType messageListType;
@property (strong, atomic) NSMutableArray *messageArray;
@property (strong, atomic) NSMutableArray *messageIDs;

@end

NS_ASSUME_NONNULL_END
