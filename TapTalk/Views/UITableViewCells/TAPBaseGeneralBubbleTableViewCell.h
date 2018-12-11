//
//  TAPBaseGeneralBubbleTableViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 28/11/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseXIBRotatedTableViewCell.h"
#import "TAPMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPBaseGeneralBubbleTableViewCell : TAPBaseXIBRotatedTableViewCell

@property (weak, nonatomic) id delegate;

- (void)setMessage:(TAPMessageModel *)message;
- (void)receiveSentEvent;
- (void)receiveDeliveredEvent;
- (void)receiveReadEvent;

@end

NS_ASSUME_NONNULL_END
