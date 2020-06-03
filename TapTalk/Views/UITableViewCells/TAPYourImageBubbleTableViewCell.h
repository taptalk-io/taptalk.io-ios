//
//  TAPYourImageBubbleTableViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 29/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseXIBRotatedTableViewCell.h"

@class TAPYourImageBubbleTableViewCell;

NS_ASSUME_NONNULL_BEGIN

@protocol TAPYourImageBubbleTableViewCellDelegate <NSObject>

- (void)yourImageReplyDidTappedWithMessage:(TAPMessageModel *)message;
- (void)yourImageQuoteDidTappedWithMessage:(TAPMessageModel *)message;
- (void)yourImageDidTapped:(TAPYourImageBubbleTableViewCell *)yourImageBubbleCell;
- (void)yourImageDidTappedUrl:(NSURL *)url
               originalString:(NSString*)originalString;
- (void)yourImageDidTappedPhoneNumber:(NSString *)phoneNumber
                       originalString:(NSString*)originalString;
- (void)yourImageLongPressedUrl:(NSURL *)url
                 originalString:(NSString*)originalString;
- (void)yourImageLongPressedPhoneNumber:(NSString *)phoneNumber
                         originalString:(NSString*)originalString;
- (void)yourImageBubbleLongPressedWithMessage:(TAPMessageModel *)longPressedMessage;
- (void)yourImageBubbleDidTappedProfilePictureWithMessage:(TAPMessageModel *)tappedMessage;
- (void)yourImageBubbleDidTriggerSwipeToReplyWithMessage:(TAPMessageModel *)message;
- (void)yourImageBubblePressedMentionWithWord:(NSString*)word
                                tappedAtIndex:(NSInteger)index
                                      message:(TAPMessageModel *)message
                          mentionIndexesArray:(NSArray *)mentionIndexesArray;
- (void)yourImageBubbleLongPressedMentionWithWord:(NSString*)word
                                    tappedAtIndex:(NSInteger)index
                                          message:(TAPMessageModel *)message
                              mentionIndexesArray:(NSArray *)mentionIndexesArray;

@end

@interface TAPYourImageBubbleTableViewCell : TAPBaseXIBRotatedTableViewCell

@property (weak, nonatomic) id<TAPYourImageBubbleTableViewCellDelegate> delegate;

@property (weak, nonatomic) TAPMessageModel *message;
@property (strong, nonatomic) NSArray *mentionIndexesArray;

@property (strong, nonatomic) IBOutlet TAPImageView *bubbleImageView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bubbleImageViewWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bubbleImageViewHeightConstraint;

- (void)setMessage:(TAPMessageModel *)message;
- (void)showStatusLabel:(BOOL)isShowed animated:(BOOL)animated;

- (void)showProgressDownloadView:(BOOL)show;
- (void)animateFailedDownloadingImage;
- (void)animateProgressDownloadingImageWithProgress:(CGFloat)progress total:(CGFloat)total;
- (void)animateFinishedDownloadingImage;
- (void)setInitialAnimateDownloadingImage;
- (void)setFullImage:(UIImage *)image;
- (void)setThumbnailImage:(UIImage *)thumbnailImage;

@end

NS_ASSUME_NONNULL_END
