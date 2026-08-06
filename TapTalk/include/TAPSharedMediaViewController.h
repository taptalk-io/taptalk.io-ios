//
//  TAPSharedMediaViewController.h
//  TapTalk
//
//  Created by TapTalk.io on 16/08/22.
//

#import "TAPBaseViewController.h"
#import "TAPRoomModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPShareMediaTabType) {
    TAPShareMediaTabTypeMedia = 0,
    TAPShareMediaTabTypeLink = 1,
    TAPShareMediaTabTypeDocument = 2,
};

@protocol TAPSharedMediaViewControllerDelegate <NSObject>

@optional

- (void)scrollToMessageShareMediaWithLocalID:(NSString *)localID;


@end

@interface TAPSharedMediaViewController : TAPBaseViewController

@property (strong, nonatomic) TAPRoomModel *room;
@property (weak, nonatomic) id<TAPSharedMediaViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
