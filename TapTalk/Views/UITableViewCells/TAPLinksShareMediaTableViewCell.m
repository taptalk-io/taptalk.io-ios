//
//  TAPLinksShareMediaTableViewCell.m
//  TapTalk-TapTalk
//
//  Created by TapTalk.io on 18/08/22.
//

#import "TAPLinksShareMediaTableViewCell.h"

@interface TAPLinksShareMediaTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *linkLabel;
@property (weak, nonatomic) IBOutlet UIView *linkIconView;
@property (weak, nonatomic) IBOutlet UIImageView *linkIcomImageView;

@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;

@end

@implementation TAPLinksShareMediaTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.linkIconView.backgroundColor = [[TAPStyleManager sharedManager] getComponentColorForType:TAPComponentColorPinBackground];
    self.linkIconView.layer.cornerRadius = 8.0f;
    
    UIFont *linkFont = [[TAPStyleManager sharedManager] getComponentFontForType:TAPComponentFontImageDetailSenderName];
    
    self.linkLabel.textColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorChatRoomPinTitleLabel];
    self.linkLabel.font = linkFont;
    
    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(handleLongPress:)];
    self.longPressGestureRecognizer.minimumPressDuration = 0.2f;
    [self.contentView addGestureRecognizer:self.longPressGestureRecognizer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setLinkLabelWithString:(NSString *)linkUrlString {
    self.linkLabel.text = linkUrlString;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    if(recognizer.state = UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(linkShareManagerLongPressedWithMessage:)]) {
            [self.delegate linkShareManagerLongPressedWithMessage:self.message];
        }
    }
}

@end
