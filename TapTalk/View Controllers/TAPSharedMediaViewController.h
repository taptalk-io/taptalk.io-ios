//
//  TAPSharedMediaViewController.h
//  TapTalk
//
//  Created by TapTalk.io on 16/08/22.
//

#import "TAPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPShareMediaTabType) {
    TAPShareMediaTabTypeMedia = 0,
    TAPShareMediaTabTypeLink = 1,
    TAPShareMediaTabTypeDocument = 2,
};

@interface TAPSharedMediaViewController : TAPBaseViewController

@property (strong, nonatomic) TAPRoomModel *room;

@end

NS_ASSUME_NONNULL_END
