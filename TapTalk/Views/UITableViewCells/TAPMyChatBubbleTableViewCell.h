//
//  TAPMyChatBubbleTableViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 25/9/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseMyBubbleTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TAPMyChatBubbleTableViewCellDelegate <NSObject>

- (void)myChatBubbleViewDidTapped:(TAPMessageModel *)tappedMessage;
- (void)myChatQuoteViewDidTapped:(TAPMessageModel *)tappedMessage;
- (void)myChatReplyDidTapped;
- (void)myChatBubbleDidTappedUrl:(NSURL *)url
                  originalString:(NSString*)originalString;
- (void)myChatBubbleDidTappedPhoneNumber:(NSString *)phoneNumber
                          originalString:(NSString*)originalString;
- (void)myChatBubbleLongPressedUrl:(NSURL *)url
                    originalString:(NSString*)originalString;
- (void)myChatBubbleLongPressedPhoneNumber:(NSString *)phoneNumber
                            originalString:(NSString*)originalString;
- (void)myChatBubbleLongPressedWithMessage:(TAPMessageModel *)longPressedMessage;

@end

@interface TAPMyChatBubbleTableViewCell : TAPBaseMyBubbleTableViewCell

@property (weak, nonatomic) id<TAPMyChatBubbleTableViewCellDelegate> delegate;
@property (strong, nonatomic) TAPMessageModel *message;

- (void)setMessage:(TAPMessageModel *)message;
- (void)receiveSentEvent;
- (void)receiveDeliveredEvent;
- (void)receiveReadEvent;
- (void)showStatusLabel:(BOOL)isShowed animated:(BOOL)animated updateStatusIcon:(BOOL)updateStatusIcon message:(TAPMessageModel *)message;

@end

NS_ASSUME_NONNULL_END
