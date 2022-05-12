//
//  TAPMyChatDeletedBubbleTableViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 28/05/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPMyChatDeletedBubbleTableViewCell.h"

@interface TAPMyChatDeletedBubbleTableViewCell ()

@property (strong, nonatomic) IBOutlet UIView *bubbleView;
@property (strong, nonatomic) IBOutlet UILabel *bubbleLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UIImageView *sendingIconImageView;
@property (strong, nonatomic) IBOutlet UIImageView *statusIconImageView;
@property (strong, nonatomic) IBOutlet UIImageView *deletedIconImageView;
@property (strong, nonatomic) IBOutlet UIButton *chatBubbleButton;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *statusLabelTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *statusLabelHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *chatBubbleRightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sendingIconLeftConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sendingIconBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *statusIconBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *statusIconRightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *deletedIconImageViewWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *deletedIconImageViewTrailingConstraint;

- (IBAction)chatBubbleButtonDidTapped:(id)sender;
- (void)setBubbleCellStyle;

@end

@implementation TAPMyChatDeletedBubbleTableViewCell
#pragma mark - Lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
    self.bubbleView.clipsToBounds = YES;
    self.statusLabelTopConstraint.constant = 0.0f;
    self.statusLabelHeightConstraint.constant = 0.0f;
    [self.contentView layoutIfNeeded];

    self.statusLabel.alpha = 0.0f;
    self.statusIconImageView.alpha = 0.0f;
    self.sendingIconImageView.alpha = 0.0f;
    self.bubbleView.clipsToBounds = YES;
    
    self.bubbleView.layer.cornerRadius = 16.0f;
    if (@available(iOS 11.0, *)) {
        self.bubbleView.layer.maskedCorners = kCALayerMaxXMaxYCorner | kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner;
    } else {
        // Fallback on earlier versions
    }
    
    [self setBubbleCellStyle];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.chatBubbleRightConstraint.constant = 16.0f;
    self.statusLabelTopConstraint.constant = 0.0f;
    self.statusLabelHeightConstraint.constant = 0.0f;
    self.statusLabel.alpha = 0.0f;
    self.statusIconImageView.alpha = 0.0f;
    self.sendingIconImageView.alpha = 0.0f;
    self.sendingIconLeftConstraint.constant = 4.0f;
    self.sendingIconBottomConstraint.constant = -5.0f;
    self.deletedIconImageViewWidthConstraint.constant = 0.0f;
    self.deletedIconImageViewTrailingConstraint.constant = 0.0f;
    self.bubbleLabel.text = @"";
    [self setBubbleCellStyle];
    [self.contentView layoutIfNeeded];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - Custom Method
- (void)setBubbleCellStyle {
    self.contentView.backgroundColor = [UIColor clearColor];
    self.bubbleView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorRightBubbleBackground];
        
    UIFont *bubbleLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontRightBubbleDeletedMessageBody];
    UIColor *bubbleLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRightBubbleDeletedMessageBody];
    
    UIFont *statusLabelFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontBubbleMessageStatus];
    UIColor *statusLabelColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorBubbleMessageStatus];
    
    self.bubbleLabel.textColor = bubbleLabelColor;
    self.bubbleLabel.font = bubbleLabelFont;
    
    self.statusLabel.textColor = statusLabelColor;
    self.statusLabel.font = statusLabelFont;
    
//    UIImage *sendingImage = [UIImage imageNamed:@"TAPIconSending" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
//    self.sendingIconImageView.image = sendingImage;
}

- (void)setMessage:(TAPMessageModel *)message {
    if(message == nil) {
        return;
    }

    //    _message = message;
    [super setMessage:message];
    
    if (self.type == TAPMyChatDeletedBubbleTableViewCellTypeDefault) {
        UIImage *deletedImage = [UIImage imageNamed:@"TAPIconBlock" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        deletedImage = [deletedImage setImageTintColor:[[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorIconDeletedRightMessageBubble]];
        self.deletedIconImageView.image = deletedImage;
        self.deletedIconImageViewWidthConstraint.constant = 16.0f;
        self.deletedIconImageViewTrailingConstraint.constant = 4.0f;
        self.bubbleLabel.text = NSLocalizedStringFromTableInBundle(@"You deleted this message.", nil, [TAPUtil currentBundle], @"");
    }
    else if (self.type == TAPMyChatDeletedBubbleTableViewCellTypeUnsupported) {
        self.deletedIconImageView.image = nil;
        self.deletedIconImageViewWidthConstraint.constant = 0.0f;
        self.deletedIconImageViewTrailingConstraint.constant = 0.0f;
        self.bubbleLabel.text = NSLocalizedStringFromTableInBundle(@"This message type is unsupported in the current app version.", nil, [TAPUtil currentBundle], @"");
    }
    else {
        self.deletedIconImageView.image = nil;
        self.deletedIconImageViewWidthConstraint.constant = 0.0f;
        self.deletedIconImageViewTrailingConstraint.constant = 0.0f;
        self.bubbleLabel.text = @"";
    }
}

- (void)receiveSentEvent {
//    [super receiveSentEvent];
}

- (void)receiveDeliveredEvent {
//    [super receiveDeliveredEvent];
}

- (void)receiveReadEvent {
//    [super receiveReadEvent];
}

- (void)showStatusLabel:(BOOL)isShowed animated:(BOOL)animated updateStatusIcon:(BOOL)updateStatusIcon message:(TAPMessageModel *)message {
    [super showStatusLabel:isShowed animated:animated updateStatusIcon:updateStatusIcon message:message];
    
    if (isShowed) {
        self.chatBubbleButton.alpha = 1.0f;
        
        self.chatBubbleButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.18f];
        self.chatBubbleButton.userInteractionEnabled = YES;
    }
    else {
        self.chatBubbleButton.backgroundColor = [UIColor clearColor];
        self.chatBubbleButton.alpha = 0.0f;
        self.chatBubbleButton.userInteractionEnabled = YES;
    }
}

- (IBAction)chatBubbleButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(myChatDeletedBubbleViewDidTapped:)]) {
        [self.delegate myChatDeletedBubbleViewDidTapped:self.message];
    }
}

@end
