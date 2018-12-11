//
//  TAPBaseMyBubbleTableViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 28/11/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseGeneralBubbleTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TAPBaseMyBubbleStatus) {
    TAPBaseMyBubbleStatusSending,
    TAPBaseMyBubbleStatusSent,
    TAPBaseMyBubbleStatusDelivered,
    TAPBaseMyBubbleStatusRead
};

@protocol TAPBaseMyBubbleTableViewCellDelegate <NSObject>

- (void)baseMyBubbleTableViewCellDidCompleteAnimateSending;

@end

@interface TAPBaseMyBubbleTableViewCell : TAPBaseGeneralBubbleTableViewCell

@property (weak, nonatomic) id<TAPBaseMyBubbleTableViewCellDelegate> delegate;
@property (strong, nonatomic) TAPMessageModel *message;

- (void)setMessage:(TAPMessageModel *)message;
- (void)receiveSentEvent;
- (void)receiveDeliveredEvent;
- (void)receiveReadEvent;
- (void)showStatusLabel:(BOOL)isShowed animated:(BOOL)animated updateStatusIcon:(BOOL)updateStatusIcon;
- (void)handleBubbleViewTap:(UITapGestureRecognizer *)recognizer;
- (IBAction)replyButtonDidTapped:(id)sender;
- (IBAction)retryButtonDidTapped:(id)sender;

@end

NS_ASSUME_NONNULL_END
