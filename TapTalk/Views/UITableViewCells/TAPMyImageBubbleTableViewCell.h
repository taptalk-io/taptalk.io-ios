//
//  TAPMyImageBubbleTableViewCell.h
//  TapTalk
//
//  Created by Welly Kencana on 29/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseXIBRotatedTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TAPMyImageBubbleTableViewCellDelegaate <NSObject>

- (void)myImageCancelDidTapped;
- (void)myImageReplyDidTapped;

@end

@interface TAPMyImageBubbleTableViewCell : TAPBaseXIBRotatedTableViewCell

@property (weak, nonatomic) id<TAPMyImageBubbleTableViewCellDelegaate> delegate;
@property (weak, nonatomic) TAPMessageModel *message;

- (void)animateSendingIcon;

@end

NS_ASSUME_NONNULL_END
