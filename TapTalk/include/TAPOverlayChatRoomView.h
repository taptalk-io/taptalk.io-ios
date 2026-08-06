//
//  TAPOverlayChatRoomView.h
//  TapTalk
//
//  Created by TapTalk.io on 05/10/22.
//

#import "TAPBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TAPOverlayChatRoomViewDelegate <NSObject>

- (void)overlayScheduleMessageButtonDidTapped;
- (void)overlayBackgroundButtonDidTapped;

@end

@interface TAPOverlayChatRoomView : TAPBaseView
@property (weak, nonatomic) id <TAPOverlayChatRoomViewDelegate> delegate;
- (void)showOverlay:(BOOL)isShow;
@end

NS_ASSUME_NONNULL_END
