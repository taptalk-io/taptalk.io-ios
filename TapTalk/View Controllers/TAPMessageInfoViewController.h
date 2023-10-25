//
//  TAPMessageInfoViewController.h
//  TapTalk
//
//  Created by TapTalk.io on 26/10/22.
//

#import "TAPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPMessageInfoViewController : TAPBaseViewController

@property (strong, nonnull) TAPMessageModel *message;
@property (strong, nonatomic) NSMutableDictionary *participantListDictionary;
@property (strong, nonatomic) NSArray *mentionArray;
@property (nonatomic) BOOL showStar;
@property (nonatomic) BOOL showPin;

@end

NS_ASSUME_NONNULL_END
