//
//  TAPYourChatBubbleTableViewCell.h
//  TapTalk
//
//  Created by Welly Kencana on 1/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseXIBRotatedTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TAPYourChatBubbleTableViewCellDelegate <NSObject>

- (void)yourChatBubbleViewDidTapped:(TAPMessageModel *)tappedMessage;
- (void)yourChatQuoteViewDidTapped:(TAPMessageModel *)tappedMessage;
- (void)yourChatReplyDidTapped;
- (void)yourChatBubbleDidTappedUrl:(NSURL *)url
                  originalString:(NSString*)originalString;
- (void)yourChatBubbleDidTappedPhoneNumber:(NSString *)phoneNumber
                          originalString:(NSString*)originalString;
- (void)yourChatBubbleLongPressedUrl:(NSURL *)url
                    originalString:(NSString*)originalString;
- (void)yourChatBubbleLongPressedPhoneNumber:(NSString *)phoneNumber
                            originalString:(NSString*)originalString;
- (void)yourChatBubbleLongPressedWithMessage:(TAPMessageModel *)longPressedMessage;

@end

@interface TAPYourChatBubbleTableViewCell : TAPBaseXIBRotatedTableViewCell

@property (weak, nonatomic) id<TAPYourChatBubbleTableViewCellDelegate> delegate;
@property (weak, nonatomic) TAPMessageModel *message;

- (void)setMessage:(TAPMessageModel *)message;
- (void)showStatusLabel:(BOOL)isShowed animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
