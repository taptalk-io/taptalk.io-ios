//
//  TAPYourChatBubbleTableViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 1/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseXIBRotatedTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TAPYourChatBubbleTableViewCellDelegate <NSObject>

- (void)yourChatCheckmarkDidTapped:(TAPMessageModel *)tappedMessage;
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
- (void)yourChatBubbleDidTappedProfilePictureWithMessage:(TAPMessageModel *)tappedMessage;
- (void)yourChatBubbleDidTriggerSwipeToReplyWithMessage:(TAPMessageModel *)message;
- (void)yourChatBubblePressedMentionWithWord:(NSString*)word
                               tappedAtIndex:(NSInteger)index
                                     message:(TAPMessageModel *)message
                         mentionIndexesArray:(NSArray *)mentionIndexesArray;
- (void)yourChatBubbleLongPressedMentionWithWord:(NSString*)word
                                   tappedAtIndex:(NSInteger)index
                                         message:(TAPMessageModel *)message
                             mentionIndexesArray:(NSArray *)mentionIndexesArray;

@end

@interface TAPYourChatBubbleTableViewCell : TAPBaseXIBRotatedTableViewCell

@property (weak, nonatomic) id<TAPYourChatBubbleTableViewCellDelegate> delegate;
@property (weak, nonatomic) TAPMessageModel *message;
@property (strong, nonatomic) NSArray *mentionIndexesArray;

- (void)setMessage:(TAPMessageModel *)message;
- (void)showStatusLabel:(BOOL)isShowed animated:(BOOL)animated;
- (void)showBubbleHighlight;
- (void)showStarMessageView;
- (void)showSeperator;
- (void)showCheckMarkIcon:(BOOL)isShow;
- (void)setCheckMarkState:(BOOL)isSelected;
- (void)setSwipeGestureEnable:(BOOL)enable;

@end

NS_ASSUME_NONNULL_END
