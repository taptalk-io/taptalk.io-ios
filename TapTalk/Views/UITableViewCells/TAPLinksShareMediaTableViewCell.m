//
//  TAPLinksShareMediaTableViewCell.m
//  TapTalk-TapTalk
//
//  Created by TapTalk.io on 18/08/22.
//

#import "TAPLinksShareMediaTableViewCell.h"
#import "PowerTalk.h"

@interface TAPLinksShareMediaTableViewCell () <ZSWTappableLabelTapDelegate, ZSWTappableLabelLongPressDelegate>

@property (weak, nonatomic) IBOutlet TappableLabel *linkLabel;
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

#pragma mark - ZSWTappedLabelDelegate

- (void)tappableLabel:(TappableLabel *)tappableLabel
        tappedAtIndex:(NSInteger)idx
       withAttributes:(NSDictionary<NSAttributedStringKey, id> *)attributes {
    
    //get selected word by tapped/selected index
    NSArray *wordArray = [tappableLabel.text componentsSeparatedByString:@" "];
    NSInteger currentWordLength = 0;
    NSString *selectedWord = @"";
    for (NSString *word in wordArray) {
        currentWordLength = currentWordLength + [word length];
        if(idx <= currentWordLength) {
            selectedWord = word;
            break;
        }
    }
    
    NSTextCheckingResult *result = attributes[@"NSTextCheckingResult"];
    if (result) {
        switch (result.resultType) { 
            case NSTextCheckingTypeLink:
                if ([self.delegate respondsToSelector:@selector(sharedLinkUrlDidTappedWithMessage:url:)]) {
                    [self.delegate sharedLinkUrlDidTappedWithMessage:self.message url:result.URL];
                }
                break;
            default:
                break;
        }
    }
}

- (void)tappableLabel:(TappableLabel *)tappableLabel 
   longPressedAtIndex:(NSInteger)idx
       withAttributes:(NSDictionary<NSAttributedStringKey,id> *)attributes {
    
    //get selected word by tapped/selected index
    NSArray *wordArray = [tappableLabel.text componentsSeparatedByString:@" "];
    NSInteger currentWordLength = 0;
    NSString *selectedWord = @"";
    for (NSString *word in wordArray) {
        currentWordLength = currentWordLength + [word length];
        if(idx <= currentWordLength) {
            selectedWord = word;
            break;
        }
    }
    
    NSTextCheckingResult *result = attributes[@"NSTextCheckingResult"];
    if (result) {
        switch (result.resultType) {
            case NSTextCheckingTypeLink:
                if ([self.delegate respondsToSelector:@selector(sharedLinkUrlDidLongPressedWithMessage:url:)]) {
                    [self.delegate sharedLinkUrlDidLongPressedWithMessage:self.message url:result.URL];
                }
                break;
                
            default:
                break;
        }
    }
}

- (void)setLinkLabelWithString:(NSString *)linkUrlString {
    linkUrlString = [TAPUtil nullToEmptyString:linkUrlString];
    
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:NULL];
    UIColor *highlightedTextColor = [[TAPStyleManager sharedManager] getTextColorForType:TAPTextColorRightBubbleMessageBodyURLHighlighted];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:linkUrlString attributes:nil];
    [linkDetector enumerateMatchesInString:linkUrlString options:0 range:NSMakeRange(0, linkUrlString.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        attributes[ZSWTappableLabelTappableRegionAttributeName] = @YES;
        attributes[ZSWTappableLabelHighlightedBackgroundAttributeName] = highlightedTextColor;
        attributes[@"NSTextCheckingResult"] = result;

        [attributedString addAttributes:attributes range:result.range];
    }];
    
    // Add line spacing
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:self.linkLabel.font.pointSize * 0.25f];
    [attributedString addAttribute:NSParagraphStyleAttributeName
                             value:style
                             range:NSMakeRange(0, [attributedString length])];
    
    self.linkLabel.attributedText = attributedString;
    self.linkLabel.tapDelegate = self;
    self.linkLabel.longPressDelegate = self;
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer {
    if(recognizer.state = UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(linkShareManagerLongPressedWithMessage:)]) {
            [self.delegate linkShareManagerLongPressedWithMessage:self.message];
        }
    }
}

@end
