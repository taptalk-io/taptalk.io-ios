//
//  TAPYourImageBubbleTableViewCell.m
//  TapTalk
//
//  Created by Welly Kencana on 29/10/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPYourImageBubbleTableViewCell.h"
#import "ZSWTappableLabel.h"

@interface TAPYourImageBubbleTableViewCell () <ZSWTappableLabelTapDelegate, ZSWTappableLabelLongPressDelegate>

@property (strong, nonatomic) IBOutlet UIView *progressBackgroundView;
@property (strong, nonatomic) IBOutlet UIView *progressBarView;
@property (strong, nonatomic) IBOutlet UIImageView *downloadImageView;

@property (strong, nonatomic) IBOutlet TAPImageView *thumbnailBubbleImageView;
@property (strong, nonatomic) IBOutlet TAPImageView *quoteImageView;

@property (strong, nonatomic) IBOutlet UIView *bubbleView;
@property (strong, nonatomic) IBOutlet UIView *replyView;
@property (strong, nonatomic) IBOutlet UIView *replyInnerView;
@property (strong, nonatomic) IBOutlet UIView *quoteView;
@property (strong, nonatomic) IBOutlet UIView *fileView;

@property (strong, nonatomic) IBOutlet UIButton *replyButton;
@property (strong, nonatomic) IBOutlet UIButton *openImageButton;

@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet ZSWTappableLabel *captionLabel;
@property (strong, nonatomic) IBOutlet UILabel *replyNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *replyMessageLabel;
@property (strong, nonatomic) IBOutlet UILabel *forwardTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *forwardFromLabel;
@property (strong, nonatomic) IBOutlet UILabel *quoteTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *quoteSubtitleLabel;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *captionLabelTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *captionLabelBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *captionLabelHeightConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *statusLabelTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *statusLabelHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyButtonLeftConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyViewHeightContraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyViewInnerViewLeadingContraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyNameLabelLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyNameLabelTrailingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyMessageLabelLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyMessageLabelTrailingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyButtonLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyButtonTrailingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *quoteViewLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *quoteViewTrailingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *quoteViewTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *quoteViewBottomConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyViewLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyViewTrailingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyViewTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *replyViewBottomConstraint;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *forwardTitleLabelHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *forwardFromLabelHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *forwardTitleLabelLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *forwardFromLabelLeadingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *forwardTitleLabelTopConstraint;

@property (strong, nonatomic) UILongPressGestureRecognizer *bubbleViewLongPressGestureRecognizer;

@property (nonatomic) BOOL isShowForwardView;

@property (strong, nonatomic) UIVisualEffectView *blurView;
@property (strong, nonatomic) UIView *syncProgressSubView;
@property (strong, nonatomic) CAShapeLayer *progressLayer;
@property (nonatomic) CGFloat lastProgress;

@property (nonatomic) BOOL isDownloaded;
@property (nonatomic) CGFloat maxWidth;
@property (nonatomic) CGFloat maxHeight;
@property (nonatomic) CGFloat minWidth;
@property (nonatomic) CGFloat minHeight;
@property (nonatomic) CGFloat cellWidth;
@property (nonatomic) CGFloat cellHeight;

@property (nonatomic) CGFloat startAngle;
@property (nonatomic) CGFloat endAngle;
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic) CGFloat pathWidth;
@property (nonatomic) CGFloat newProgress;
@property (nonatomic) NSInteger updateInterval;

- (IBAction)replyButtonDidTapped:(id)sender;
- (IBAction)quoteViewButtonDidTapped:(id)sender;
- (IBAction)replyViewButtonDidTapped:(id)sender;
- (void)getImageSizeFromImage:(UIImage *)image;
- (void)getResizedImageSizeWithHeight:(CGFloat)height width:(CGFloat)width;
- (void)showImageCaption:(BOOL)show;
- (void)setImageCaptionWithString:(NSString *)captionString;

- (void)handleBubbleViewLongPress:(UILongPressGestureRecognizer *)recognizer;

- (void)showReplyView:(BOOL)show withMessage:(TAPMessageModel *)message;
- (void)showQuoteView:(BOOL)show;
- (void)showForwardView:(BOOL)show;
- (void)setForwardData:(TAPForwardFromModel *)forwardData;
- (void)setQuote:(TAPQuoteModel *)quote;
- (void)setBubbleCellColor;

@end

@implementation TAPYourImageBubbleTableViewCell

#pragma mark - Lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
    
    _startAngle = M_PI * 1.5;
    _endAngle = self.startAngle + (M_PI * 2);
    _borderWidth = 0.0f;
    _pathWidth = 4.0f;
    _newProgress = 0.0f;
    _updateInterval = 1;
    
    _maxWidth = (CGRectGetWidth([UIScreen mainScreen].bounds) * 2.0f / 3.0f) - 16.0f; //two third of screen, and 16.0f is right padding.
    _maxHeight = self.maxWidth / 234.0f * 300.0f; //234.0f and 300.0f are width and height constraint on design
    _minWidth = (self.maxWidth / 3.0f); //one third of max Width
    _minHeight = self.minWidth / 78.0f * 100.0f; //78.0f and 100.0f are width and height constraint on design

    self.bubbleImageViewWidthConstraint.constant = self.maxWidth;
    self.bubbleImageViewHeightConstraint.constant = self.maxHeight;
    
    self.statusLabelTopConstraint.constant = 0.0f;
    self.statusLabelHeightConstraint.constant = 0.0f;
    self.statusLabel.alpha = 0.0f;
    
    self.bubbleView.clipsToBounds = YES;
    
    self.thumbnailBubbleImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.bubbleImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    self.progressBackgroundView.layer.cornerRadius = CGRectGetHeight(self.progressBackgroundView.bounds) / 2.0f;
    self.progressBarView.layer.cornerRadius = CGRectGetHeight(self.progressBarView.bounds) / 2.0f;
    
    self.bubbleView.layer.cornerRadius = 8.0f;
    self.bubbleView.layer.maskedCorners = kCALayerMaxXMaxYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner;
    self.bubbleView.clipsToBounds = YES;
    
    self.bubbleImageView.backgroundColor = [UIColor clearColor];
    
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    _blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.blurView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.bubbleImageView.bounds), CGRectGetHeight(self.bubbleImageView.bounds));
    
    self.progressBackgroundView.alpha = 0.0f;
    
    self.replyView.layer. cornerRadius = 4.0f;
    
    self.quoteImageView.layer.cornerRadius = 8.0f;
    self.quoteView.layer.cornerRadius = 8.0f;
    self.fileView.layer.cornerRadius = 8.0f;
    
    [self showQuoteView:NO];
    [self showReplyView:NO withMessage:nil];
    [self showForwardView:NO];
    
    self.captionLabel.tapDelegate = self;
    self.captionLabel.longPressDelegate = self;
    self.captionLabel.longPressDuration = 0.05f;
    
    [self setBubbleCellColor];
}

- (void)prepareForReuse {
    [super prepareForReuse];

    self.thumbnailBubbleImageView.image = nil;
    self.bubbleImageView.image = nil;
    self.progressBackgroundView.alpha = 0.0f;
    self.captionLabel.text = @"";
    self.openImageButton.alpha = 0.0f;
    
    [self showQuoteView:NO];
    [self showReplyView:NO withMessage:nil];
    
    _bubbleViewLongPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(handleBubbleViewLongPress:)];
    self.bubbleViewLongPressGestureRecognizer.minimumPressDuration = 0.2f;
    [self.bubbleView addGestureRecognizer:self.bubbleViewLongPressGestureRecognizer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - ZSWTappedLabelDelegate
- (void)tappableLabel:(ZSWTappableLabel *)tappableLabel
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
            case NSTextCheckingTypeAddress:
                NSLog(@"Address components: %@", result.addressComponents);
                break;
                
            case NSTextCheckingTypePhoneNumber:
                NSLog(@"Phone number: %@", result.phoneNumber);
                if([self.delegate respondsToSelector:@selector(yourImageDidTappedPhoneNumber:originalString:)]) {
                    [self.delegate yourImageDidTappedPhoneNumber:result.phoneNumber originalString:selectedWord];
                }
                break;
                
            case NSTextCheckingTypeDate:
                NSLog(@"Date: %@", result.date);
                break;
                
            case NSTextCheckingTypeLink:
                NSLog(@"Link: %@", result.URL);
                if([self.delegate respondsToSelector:@selector(yourImageDidTappedUrl:originalString:)]) {
                    [self.delegate yourImageDidTappedUrl:result.URL originalString:selectedWord];
                }
                break;
                
            default:
                break;
        }
    }
}

- (void)tappableLabel:(ZSWTappableLabel *)tappableLabel longPressedAtIndex:(NSInteger)idx withAttributes:(NSDictionary<NSAttributedStringKey,id> *)attributes {
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
            case NSTextCheckingTypeAddress:
                NSLog(@"Address components: %@", result.addressComponents);
                break;
                
            case NSTextCheckingTypePhoneNumber:
                NSLog(@"Phone number: %@", result.phoneNumber);
                if([self.delegate respondsToSelector:@selector(yourImageLongPressedPhoneNumber:originalString:)]) {
                    [self.delegate yourImageLongPressedPhoneNumber:result.phoneNumber originalString:selectedWord];
                }
                break;
                
            case NSTextCheckingTypeDate:
                NSLog(@"Date: %@", result.date);
                break;
                
            case NSTextCheckingTypeLink:
                NSLog(@"Link: %@", result.URL);
                if([self.delegate respondsToSelector:@selector(yourImageLongPressedUrl:originalString:)]) {
                    [self.delegate yourImageLongPressedUrl:result.URL originalString:selectedWord];
                }
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - Custom Method
- (void)setBubbleCellColor {
    self.bubbleView.backgroundColor = [TAPUtil getColor:TAP_COLOR_WHITE];
    self.quoteView.backgroundColor = [TAPUtil getColor:TAP_COLOR_WHITE_F3];
    self.replyInnerView.backgroundColor = [TAPUtil getColor:TAP_COLOR_WHITE_F3];
    self.replyView.backgroundColor = [TAPUtil getColor:TAP_COLOR_ORANGE_45];
    self.fileView.backgroundColor = [TAPUtil getColor:TAP_COLOR_ORANGE_00];
    
    self.replyNameLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_19];
    self.replyMessageLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_19];
    self.quoteTitleLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_19];
    self.quoteSubtitleLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_19];
    self.forwardTitleLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_19];
    self.forwardFromLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_19];
    
    self.captionLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_19];
}

- (IBAction)replyButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(yourImageReplyDidTappedWithMessage:)]) {
        [self.delegate yourImageReplyDidTappedWithMessage:self.message];
    }
}

- (IBAction)openImageButtonDidTapped:(id)sender  {
    if ([self.delegate respondsToSelector:@selector(yourImageDidTapped:)]) {
        [self.delegate yourImageDidTapped:self];
    }
}

- (void)setMessage:(TAPMessageModel *)message {
    _message = message;
    
    NSDictionary *dataDictionary = message.data;
    dataDictionary = [TAPUtil nullToEmptyDictionary:dataDictionary];
    
    NSString *captionString = [dataDictionary objectForKey:@"caption"];
    captionString = [TAPUtil nullToEmptyString:captionString];
    
    [self setImageCaptionWithString:captionString];
    
    NSString *fileID = [dataDictionary objectForKey:@"fileID"];

    UIImage *selectedImage = nil;
    if (fileID == nil || [fileID isEqualToString:@""]) {
        [TAPImageView imageFromCacheWithKey:message.localID message:message success:^(UIImage *savedImage, TAPMessageModel *resultMessage) {
            if (savedImage != nil) {
                [self getImageSizeFromImage:savedImage];
                
                self.bubbleImageViewWidthConstraint.constant = self.cellWidth;
                self.bubbleImageViewHeightConstraint.constant = self.cellHeight;
                [self.bubbleImageView setImage:savedImage];
            }
            else {
                self.bubbleImageViewWidthConstraint.constant = 0.0f;
                self.bubbleImageViewHeightConstraint.constant = 0.0f;
            }
        }];

//        selectedImage = [dataDictionary objectForKey:@"dummyImage"];
//        [self getImageSizeFromImage:selectedImage];
//
//        self.bubbleImageViewWidthConstraint.constant = self.cellWidth;
//        self.bubbleImageViewHeightConstraint.constant = self.cellHeight;
//        [self.bubbleImageView setImage:selectedImage];
//        [TAPImageView imageFromCacheWithKey:message.localID message:message success:^(UIImage *savedImage, TAPMessageModel *resultMessage) {
//            if (savedImage != nil) {
//                [self getImageSizeFromImage:savedImage];
//                
//                self.bubbleImageViewWidthConstraint.constant = self.cellWidth;
//                self.bubbleImageViewHeightConstraint.constant = self.cellHeight;
//                [self.bubbleImageView setImage:savedImage];
//            }
//            else {
//                self.bubbleImageViewWidthConstraint.constant = 0.0f;
//                self.bubbleImageViewHeightConstraint.constant = 0.0f;
//            }
//        }];
    }
    else {
        //already called fetchImageDataWithMessage function in view controller for fetch image
        //so no need to set the image here
        //just save the height and width constraint
        
        CGFloat obtainedCellWidth = [[message.data objectForKey:@"width"] floatValue];
        CGFloat obtainedCellHeight = [[message.data objectForKey:@"height"] floatValue];
        [self getResizedImageSizeWithHeight:obtainedCellHeight width:obtainedCellWidth];
        self.bubbleImageViewWidthConstraint.constant = self.cellWidth;
        self.bubbleImageViewHeightConstraint.constant = self.cellHeight;
        
        //        [TAPImageView imageFromCacheWithKey:fileID success:^(UIImage *savedImage) {
        //            self.bubbleImageView.image = savedImage;
        //        }];
    }
    
    NSString *thumbnailImageString = [message.data objectForKey:@"thumbnail"];
    thumbnailImageString = [TAPUtil nullToEmptyString:thumbnailImageString];
    
    if (![thumbnailImageString isEqualToString:@""]) {
        NSData *thumbnailImageData = [[NSData alloc]
                                      initWithBase64EncodedString:thumbnailImageString options:0];
        UIImage *thumbnailImage = [UIImage imageWithData:thumbnailImageData];
        self.thumbnailBubbleImageView.image = thumbnailImage;
        
    }
    
    //    if (!self.isDownloaded) {
    //        self.blurView.frame = CGRectMake(CGRectGetMinX(self.blurView.frame), CGRectGetMinY(self.blurView.frame), self.bubbleImageViewWidthConstraint.constant, self.bubbleImageViewHeightConstraint.constant);
    //        [self.bubbleImageView insertSubview:self.blurView atIndex:0];
    //    }
    
    if (![message.forwardFrom.localID isEqualToString:@""] && message.forwardFrom != nil) {
        [self showForwardView:YES];
        [self setForwardData:message.forwardFrom];
        _isShowForwardView = YES;
    }
    else {
        [self showForwardView:NO];
        _isShowForwardView = NO;
    }
    
    if ((![message.replyTo.messageID isEqualToString:@"0"] && ![message.replyTo.messageID isEqualToString:@""]) && ![message.quote.title isEqualToString:@""] && message.quote != nil && message.replyTo != nil) {
        //reply to exists
        
        //if reply exists check if image in quote exists
        //if image exists  change view to Quote View
        
        if (self.isShowForwardView) {
            self.forwardTitleLabelTopConstraint.constant = 10.0f;
        }
        else {
            self.forwardTitleLabelTopConstraint.constant = 11.0f;
        }
        
        if((message.quote.fileID && ![message.quote.fileID isEqualToString:@""]) || (message.quote.imageURL  && ![message.quote.fileID isEqualToString:@""])) {
            [self showReplyView:NO withMessage:nil];
            [self showQuoteView:YES];
            [self setQuote:message.quote];
        }
        else {
            [self showReplyView:YES withMessage:message];
            [self showQuoteView:NO];
        }
    }
    else if (![message.quote.title isEqualToString:@""] && message.quote != nil) {
        //quote exists
        
        if (self.isShowForwardView) {
            self.forwardTitleLabelTopConstraint.constant = 10.0f;
        }
        else {
            self.forwardTitleLabelTopConstraint.constant = 11.0f;
        }
        
        [self showReplyView:NO withMessage:nil];
        [self setQuote:message.quote];
        [self showQuoteView:YES];
    }
    else {
        
        if (self.isShowForwardView) {
            self.forwardTitleLabelTopConstraint.constant = 10.0f;
        }
        else {
            self.forwardTitleLabelTopConstraint.constant = 0.0f;
        }
        
        [self showReplyView:NO withMessage:nil];
        [self showQuoteView:NO];
    }
    
    if (![message.forwardFrom.localID isEqualToString:@""] && message.forwardFrom != nil) {
        [self showForwardView:YES];
        [self setForwardData:message.forwardFrom];
    }
    else {
        [self showForwardView:NO];
    }
}

- (void)showStatusLabel:(BOOL)isShowed animated:(BOOL)animated {
//    self.chatBubbleButton.userInteractionEnabled = NO;
    
    if (isShowed) {
        NSTimeInterval lastMessageTimeInterval = [self.message.created doubleValue] / 1000.0f; //change to second from milisecond
        
        NSDate *currentDate = [NSDate date];
        NSTimeInterval currentTimeInterval = [currentDate timeIntervalSince1970];
        
        NSTimeInterval timeGap = currentTimeInterval - lastMessageTimeInterval;
        NSDateFormatter *midnightDateFormatter = [[NSDateFormatter alloc] init];
        [midnightDateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]]; // POSIX to avoid weird issues
        midnightDateFormatter.dateFormat = @"dd-MMM-yyyy";
        NSString *midnightFormattedCreatedDate = [midnightDateFormatter stringFromDate:currentDate];
        
        NSDate *todayMidnightDate = [midnightDateFormatter dateFromString:midnightFormattedCreatedDate];
        NSTimeInterval midnightTimeInterval = [todayMidnightDate timeIntervalSince1970];
        
        NSTimeInterval midnightTimeGap = currentTimeInterval - midnightTimeInterval;
        
        NSDate *lastMessageDate = [NSDate dateWithTimeIntervalSince1970:lastMessageTimeInterval];
        NSString *lastMessageDateString = @"";
        if (timeGap <= midnightTimeGap) {
            //Today
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"HH:mm";
            NSString *dateString = [dateFormatter stringFromDate:lastMessageDate];
            lastMessageDateString = [NSString stringWithFormat:NSLocalizedString(@"at %@", @""), dateString];
        }
        else if (timeGap <= 86400.0f + midnightTimeGap) {
            //Yesterday
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"HH:mm";
            NSString *dateString = [dateFormatter stringFromDate:lastMessageDate];
            lastMessageDateString = [NSString stringWithFormat:NSLocalizedString(@"yesterday at %@", @""), dateString];
        }
        else {
            //Set date
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"dd/MM/yyyy HH:mm";
            
            NSString *dateString = [dateFormatter stringFromDate:lastMessageDate];
            lastMessageDateString = [NSString stringWithFormat:NSLocalizedString(@"at %@", @""), dateString];
        }
        
        NSString *statusString = [NSString stringWithFormat:NSLocalizedString(@"Sent %@", @""), lastMessageDateString];
        self.statusLabel.text = statusString;
        
        CGFloat animationDuration = 0.2f;
        
        if (!animated) {
            animationDuration = 0.0f;
        }
        
        [UIView animateWithDuration:animationDuration animations:^{
            self.statusLabel.alpha = 1.0f;
//            self.chatBubbleButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.18f];
            self.statusLabelTopConstraint.constant = 2.0f;
            self.statusLabelHeightConstraint.constant = 13.0f;
            self.replyButton.alpha = 1.0f;
            self.replyButtonLeftConstraint.constant = 2.0f;
        } completion:^(BOOL finished) {
//            self.chatBubbleButton.userInteractionEnabled = YES;
        }];
    }
    else {
        CGFloat animationDuration = 0.2f;
        
        if (!animated) {
            animationDuration = 0.0f;
        }
        
        [UIView animateWithDuration:animationDuration animations:^{
//            self.chatBubbleButton.backgroundColor = [UIColor clearColor];
            self.statusLabelTopConstraint.constant = 0.0f;
            self.statusLabelHeightConstraint.constant = 0.0f;
            self.replyButton.alpha = 0.0f;
            self.replyButtonLeftConstraint.constant = -28.0f;
        } completion:^(BOOL finished) {
//            self.chatBubbleButton.userInteractionEnabled = YES;
            self.statusLabel.alpha = 0.0f;
        }];
    }
}

- (void)showImageCaption:(BOOL)show {
    if (show) {
        self.captionLabelTopConstraint.constant = 10.0f;
        self.captionLabelBottomConstraint.constant = 10.0f;
        
        CGSize captionLabelSize = [self.captionLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.captionLabel.bounds), CGFLOAT_MAX)];
        self.captionLabelHeightConstraint.constant = captionLabelSize.height;
    }
    else {
        self.captionLabelTopConstraint.constant = 0.0f;
        self.captionLabelBottomConstraint.constant = 0.0f;
        self.captionLabelHeightConstraint.constant = 0.0f;
    }
}

- (void)setImageCaptionWithString:(NSString *)captionString {
    captionString = [TAPUtil nullToEmptyString:captionString];
    
    self.captionLabel.text = captionString;
    
    if ([captionString isEqualToString:@""]) {
        [self showImageCaption:NO];
        return;
    }
    
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:NULL];
    NSDataDetector *detectorPhoneNumber = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber error:NULL];
    
    NSString *messageText = [TAPUtil nullToEmptyString:self.captionLabel.text];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:messageText attributes:nil];
    // the next line throws an exception if string is nil - make sure you check
    [linkDetector enumerateMatchesInString:messageText options:0 range:NSMakeRange(0, messageText.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        attributes[ZSWTappableLabelTappableRegionAttributeName] = @YES;
        attributes[NSUnderlineStyleAttributeName] = @(NSUnderlineStyleSingle);
        attributes[NSForegroundColorAttributeName] = [TAPUtil getColor:TAP_COLOR_LINK_BASE_COLOR];
        attributes[ZSWTappableLabelHighlightedBackgroundAttributeName] = [TAPUtil getColor:TAP_COLOR_LINK_HIGHLIGHTED_COLOR];
        attributes[@"NSTextCheckingResult"] = result;
        
        [attributedString addAttributes:attributes range:result.range];
    }];
    [detectorPhoneNumber enumerateMatchesInString:messageText options:0 range:NSMakeRange(0, messageText.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        attributes[ZSWTappableLabelTappableRegionAttributeName] = @YES;
        attributes[NSUnderlineStyleAttributeName] = @(NSUnderlineStyleSingle);
        attributes[NSForegroundColorAttributeName] = [TAPUtil getColor:TAP_COLOR_LINK_BASE_COLOR];
        attributes[ZSWTappableLabelHighlightedBackgroundAttributeName] = [TAPUtil getColor:TAP_COLOR_LINK_HIGHLIGHTED_COLOR];
        attributes[@"NSTextCheckingResult"] = result;
        
        [attributedString addAttributes:attributes range:result.range];
    }];
    self.captionLabel.attributedText = attributedString;
    
    [self showImageCaption:YES];
}

- (void)getImageSizeFromImage:(UIImage *)image {
    
    if ((![self.message.replyTo.messageID isEqualToString:@"0"] && ![self.message.replyTo.messageID isEqualToString:@""] && self.message.replyTo != nil) || (![self.message.quote.title isEqualToString:@""] && self.message.quote != nil)) {
        //if replyTo or quote exists set image width and height to default width = maxWidth height = 244.0f
        _cellWidth = self.maxWidth;
        _cellHeight = self.cellWidth / image.size.width * image.size.height;
        if (self.cellHeight > self.maxHeight) {
            _cellHeight = self.maxHeight;
        }
        else if (self.cellHeight < self.minHeight) {
            _cellHeight = self.minHeight;
        }
        return;
    }
    
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    
    _cellWidth = imageWidth;
    _cellHeight = imageHeight;
    
    if (imageWidth > imageHeight) {
        if (imageWidth > self.maxWidth) {
            imageWidth = self.maxWidth;
            _cellWidth = imageWidth;
            
            imageHeight = (imageWidth / image.size.width) * image.size.height;
            _cellHeight = imageHeight;
            if (imageHeight > self.maxHeight) {
                imageHeight = self.maxHeight;
                _cellHeight = imageHeight;
            }
            else if (imageHeight < self.minHeight) {
                imageHeight = self.minHeight;
                _cellHeight = imageHeight;
            }
        }
        else if (imageWidth < self.minWidth) {
            imageWidth = self.minWidth;
            _cellWidth = imageWidth;
            
            imageHeight = (imageWidth / image.size.width) * image.size.height;
            _cellHeight = imageHeight;
            if (imageHeight > self.maxHeight) {
                imageHeight = self.maxHeight;
                _cellHeight = imageHeight;
            }
            else if (imageHeight < self.minHeight) {
                imageHeight = self.minHeight;
                _cellHeight = imageHeight;
            }
        }
    }
    else {
        if (imageHeight > self.maxHeight) {
            imageHeight = self.maxHeight;
            _cellHeight = imageHeight;
            
            imageWidth = (imageHeight / image.size.height) * image.size.width;
            _cellWidth = imageWidth;
            if (imageWidth > self.maxWidth) {
                imageWidth = self.maxWidth;
                _cellWidth = imageWidth;
            }
            else if (imageWidth < self.minWidth) {
                imageWidth = self.minWidth;
                _cellWidth = imageWidth;
            }
        }
        else if (imageHeight < self.minHeight) {
            imageHeight = self.minHeight;
            _cellHeight = imageHeight;
            
            imageWidth = (imageHeight / image.size.height) * image.size.width;
            _cellWidth = imageWidth;
            if (imageWidth > self.maxWidth) {
                imageWidth = self.maxWidth;
                _cellWidth = imageWidth;
            }
            else if (imageWidth < self.minWidth) {
                imageWidth = self.minWidth;
                _cellWidth = imageWidth;
            }
        }
    }
}

- (void)getResizedImageSizeWithHeight:(CGFloat)height width:(CGFloat)width {
    
    if ((![self.message.replyTo.messageID isEqualToString:@"0"] && ![self.message.replyTo.messageID isEqualToString:@""] && self.message.replyTo != nil) || (![self.message.quote.title isEqualToString:@""] && self.message.quote != nil)) {
        //if replyTo or quote exists set image width and height to default width = maxWidth height = 244.0f
        _cellWidth = self.maxWidth;
        _cellHeight = self.cellWidth / width * height;
        
        if (self.cellHeight > self.maxHeight) {
            _cellHeight = self.maxHeight;
        }
        else if (self.cellHeight < self.minHeight) {
            _cellHeight = self.minHeight;
        }
        return;
    }
    
    CGFloat previousImageWidth = width;
    CGFloat previousImageHeight = height;
    
    CGFloat imageWidth = width;
    CGFloat imageHeight = height;
    
    _cellWidth = imageWidth;
    _cellHeight = imageHeight;
    
    if (imageWidth > imageHeight) {
        if (imageWidth > self.maxWidth) {
            imageWidth = self.maxWidth;
            _cellWidth = imageWidth;
            
            imageHeight = (imageWidth / previousImageWidth) * previousImageHeight;
            _cellHeight = imageHeight;
            if (imageHeight > self.maxHeight) {
                imageHeight = self.maxHeight;
                _cellHeight = imageHeight;
            }
            else if (imageHeight < self.minHeight) {
                imageHeight = self.minHeight;
                _cellHeight = imageHeight;
            }
        }
        else if (imageWidth < self.minWidth) {
            imageWidth = self.minWidth;
            _cellWidth = imageWidth;
            
            imageHeight = (imageWidth / previousImageWidth) * previousImageHeight;
            _cellHeight = imageHeight;
            if (imageHeight > self.maxHeight) {
                imageHeight = self.maxHeight;
                _cellHeight = imageHeight;
            }
            else if (imageHeight < self.minHeight) {
                imageHeight = self.minHeight;
                _cellHeight = imageHeight;
            }
        }
    }
    else {
        if (imageHeight > self.maxHeight) {
            imageHeight = self.maxHeight;
            _cellHeight = imageHeight;
            
            imageWidth = (imageHeight / previousImageHeight) * previousImageWidth;
            _cellWidth = imageWidth;
            if (imageWidth > self.maxWidth) {
                imageWidth = self.maxWidth;
                _cellWidth = imageWidth;
            }
            else if (imageWidth < self.minWidth) {
                imageWidth = self.minWidth;
                _cellWidth = imageWidth;
            }
        }
        else if (imageHeight < self.minHeight) {
            imageHeight = self.minHeight;
            _cellHeight = imageHeight;
            
            imageWidth = (imageHeight / previousImageHeight) * previousImageWidth;
            _cellWidth = imageWidth;
            if (imageWidth > self.maxWidth) {
                imageWidth = self.maxWidth;
                _cellWidth = imageWidth;
            }
            else if (imageWidth < self.minWidth) {
                imageWidth = self.minWidth;
                _cellWidth = imageWidth;
            }
        }
    }
}

- (void)animateFinishedDownloadingImage {
    self.lastProgress = 0.0f;
    self.progressLayer.strokeEnd = 0.0f;
    self.progressLayer.strokeStart = 0.0f;
    [self.progressLayer removeAllAnimations];
    [self.syncProgressSubView removeFromSuperview];
    _progressLayer = nil;
    _syncProgressSubView = nil;
    
    [UIView animateWithDuration:0.2f animations:^{
        self.blurView.alpha = 0.0f;
        self.progressBackgroundView.alpha = 0.0f;
        self.openImageButton.alpha = 1.0f;
    }];
}

- (void)animateFailedDownloadingImage {
    self.lastProgress = 0.0f;
    self.progressLayer.strokeEnd = 0.0f;
    self.progressLayer.strokeStart = 0.0f;
    [self.progressLayer removeAllAnimations];
    [self.syncProgressSubView removeFromSuperview];
    _progressLayer = nil;
    _syncProgressSubView = nil;
}

- (void)animateProgressDownloadingImageWithProgress:(CGFloat)progress total:(CGFloat)total {
    CGFloat lastProgress = self.lastProgress;
    _newProgress = progress/total;
    
    NSInteger lastPercentage = (NSInteger)floorf((100.0f * lastProgress));
    NSLog(@"PERCENT %@",[NSString stringWithFormat:@"%ld%%", (long)lastPercentage]);
    
    //Circular Progress Bar using CAShapeLayer and UIBezierPath
    _progressLayer = [CAShapeLayer layer];
    [self.progressLayer setFrame:self.progressBarView.bounds];
    UIBezierPath *progressPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(CGRectGetMidX(self.progressBarView.bounds), CGRectGetMidY(self.progressBarView.bounds)) radius:(self.progressBarView.bounds.size.height - self.borderWidth - self.pathWidth) / 2 startAngle:self.startAngle endAngle:self.endAngle clockwise:YES];
    
    self.progressLayer.lineCap = kCALineCapRound;
    self.progressLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.progressLayer.lineWidth = 3.0f;
    self.progressLayer.path = progressPath.CGPath;
    self.progressLayer.anchorPoint = CGPointMake(0.5f, 0.5f);
    self.progressLayer.fillColor = [UIColor clearColor].CGColor;
    self.progressLayer.position = CGPointMake(self.progressBarView.layer.frame.size.width / 2 - self.borderWidth / 2, self.progressBarView.layer.frame.size.height / 2 - self.borderWidth / 2);
    [self.progressLayer setStrokeEnd:0.0f];
    [self.syncProgressSubView.layer addSublayer:self.progressLayer];
    
    [self.progressLayer setStrokeEnd:self.newProgress];
    CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    strokeEndAnimation.duration = self.updateInterval;
    [strokeEndAnimation setFillMode:kCAFillModeForwards];
    strokeEndAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    strokeEndAnimation.removedOnCompletion = NO;
    strokeEndAnimation.fromValue = [NSNumber numberWithFloat:self.lastProgress];
    strokeEndAnimation.toValue = [NSNumber numberWithFloat:self.newProgress];
    _lastProgress = self.newProgress;
    [self.progressLayer addAnimation:strokeEndAnimation forKey:@"progressStatus"];
}

- (void)showProgressDownloadView:(BOOL)show {
    if (show) {
        self.progressBackgroundView.alpha = 1.0f;
    }
    else {
        self.progressBackgroundView.alpha = 0.0f;
    }
}

- (void)setInitialAnimateDownloadingImage {
    
    self.progressBackgroundView.alpha = 1.0f;
    
    // borderWidth is a float representing a value used as a margin (outer border).
    // pathwidth is the width of the progress path (inner).
    _startAngle = M_PI * 1.5;
    _endAngle = self.startAngle + (M_PI * 2);
    _borderWidth = 0.0f;
    _pathWidth = 4.0f;
    
    // progress is a float storing current progress
    // newProgress is a float storing updated progress
    // updateInterval is a float specifying the duration of the animation.
    _newProgress = 0.0f;
    _updateInterval = 1;
    
    // set initial
    _syncProgressSubView = [[UIView alloc] initWithFrame:self.progressBarView.bounds];
    [self.progressBarView addSubview:self.syncProgressSubView];
    _progressLayer = [CAShapeLayer layer];
    _lastProgress = 0.0f;
}

- (void)setFullImage:(UIImage *)image {
    self.bubbleImageView.image = image;
}

- (void)setThumbnailImage:(UIImage *)thumbnailImage {
    self.thumbnailBubbleImageView.image = thumbnailImage;
}

- (void)showReplyView:(BOOL)show withMessage:(TAPMessageModel *)message {
    if (show) {
        //check id message sender is equal to active user id, if yes change the title to "You"
        if ([message.replyTo.userID isEqualToString:[TAPDataManager getActiveUser].userID]) {
            self.replyNameLabel.text = NSLocalizedString(@"You", @"");
        }
        else {
            self.replyNameLabel.text = message.quote.title;
        }

        self.replyMessageLabel.text = message.quote.content;
        self.replyViewHeightContraint.constant = 60.0f;
        self.replyViewBottomConstraint.constant = 10.0f;
        self.replyViewTopConstraint.constant = 10.0f;
        self.replyViewInnerViewLeadingContraint.constant = 4.0f;
        self.replyNameLabelLeadingConstraint.constant = 4.0f;
        self.replyNameLabelTrailingConstraint.constant = 8.0f;
        self.replyMessageLabelLeadingConstraint.constant = 4.0f;
        self.replyMessageLabelTrailingConstraint.constant = 8.0f;
        self.replyButtonLeadingConstraint.active = YES;
        self.replyButtonTrailingConstraint.active = YES;
        self.replyView.alpha = 1.0f;
    }
    else {
        self.replyNameLabel.text = @"";
        self.replyMessageLabel.text = @"";
        self.replyViewHeightContraint.constant = 0.0f;
        self.replyViewTopConstraint.constant = 0.0f;
        
        if (self.isShowForwardView) {
            self.replyViewBottomConstraint.constant = 8.0f;
        }
        else {
            self.replyViewBottomConstraint.constant = 0.0f;
        }
        
        self.replyViewInnerViewLeadingContraint.constant = 0.0f;
        self.replyNameLabelLeadingConstraint.constant = 0.0f;
        self.replyNameLabelTrailingConstraint.constant = 0.0f;
        self.replyMessageLabelLeadingConstraint.constant = 0.0f;
        self.replyMessageLabelTrailingConstraint.constant = 0.0f;
        self.replyButtonLeadingConstraint.active = NO;
        self.replyButtonTrailingConstraint.active = NO;
        self.replyView.alpha = 0.0f;
    }
}

- (void)showQuoteView:(BOOL)show {
    if (show) {
        self.quoteViewLeadingConstraint.active = YES;
        self.quoteViewTrailingConstraint.active = YES;
        self.quoteViewTopConstraint.active = YES;
        self.quoteViewBottomConstraint.active = YES;
        self.quoteView.alpha = 1.0f;
        self.replyViewBottomConstraint.active = NO;
    }
    else {
        self.quoteViewLeadingConstraint.active = NO;
        self.quoteViewTrailingConstraint.active = NO;
        self.quoteViewTopConstraint.active = NO;
        self.quoteViewBottomConstraint.active = NO;
        self.quoteView.alpha = 0.0f;
        self.replyViewBottomConstraint.active = YES;
    }
}

- (void)showForwardView:(BOOL)show {
    if (show) {
        self.forwardFromLabelHeightConstraint.constant = 16.0f;
        self.forwardTitleLabelHeightConstraint.constant = 16.0f;
        self.forwardFromLabelLeadingConstraint.active = YES;
        self.forwardTitleLabelLeadingConstraint.active = YES;
        
    }
    else {
        self.forwardFromLabelHeightConstraint.constant = 0.0f;
        self.forwardTitleLabelHeightConstraint.constant = 0.0f;
        self.forwardFromLabelLeadingConstraint.active = NO;
        self.forwardTitleLabelLeadingConstraint.active = NO;
        
    }
}

- (void)setForwardData:(TAPForwardFromModel *)forwardData {
    
    NSString *appendedFullnameString = [NSString stringWithFormat:@"From: %@", forwardData.fullname];
    
    //check id message sender is equal to active user id, if yes change the title to "You"
    if ([forwardData.userID isEqualToString:[TAPDataManager getActiveUser].userID]) {
        appendedFullnameString = NSLocalizedString(@"From: You", @"");
    }
    
    self.forwardFromLabel.text = appendedFullnameString;
    
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc]
     initWithAttributedString:[[NSAttributedString alloc] initWithString:self.forwardFromLabel.text]];
    
    [attributedText addAttribute:NSFontAttributeName
                           value:[UIFont fontWithName:TAP_FONT_NAME_BOLD size:12.0f]
                           range:NSMakeRange(6, [self.forwardFromLabel.text length] - 6)];
    
    self.forwardFromLabel.attributedText = attributedText;
}

- (void)setQuote:(TAPQuoteModel *)quote {
    if ([quote.fileType isEqualToString:[NSString stringWithFormat:@"%ld", TAPChatMessageTypeFile]]) {
        //TYPE FILE
        self.fileView.alpha = 1.0f;
        self.quoteImageView.alpha = 0.0f;
    }
    else {
        if (quote.imageURL != nil && ![quote.imageURL isEqualToString:@""]) {
            [self.quoteImageView setImageWithURLString:quote.imageURL];
        }
        else if (quote.fileID != nil && ![quote.fileID isEqualToString:@""]) {
            [self.quoteImageView setImageWithURLString:quote.fileID];
        }
        self.fileView.alpha = 0.0f;
        self.quoteImageView.alpha = 1.0f;
    }
    
    self.quoteTitleLabel.text = [TAPUtil nullToEmptyString:quote.title];
    self.quoteSubtitleLabel.text = [TAPUtil nullToEmptyString:quote.content];
}

- (IBAction)quoteViewButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(yourImageQuoteDidTappedWithMessage:)]) {
        [self.delegate yourImageQuoteDidTappedWithMessage:self.message];
    }
}

- (IBAction)replyViewButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(yourImageQuoteDidTappedWithMessage:)]) {
        [self.delegate yourImageQuoteDidTappedWithMessage:self.message];
    }
}

- (void)handleBubbleViewLongPress:(UILongPressGestureRecognizer *)recognizer {
    if(recognizer.state = UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(yourImageBubbleLongPressedWithMessage:)]) {
            [self.delegate yourImageBubbleLongPressedWithMessage:self.message];
        }
    }
}

@end
