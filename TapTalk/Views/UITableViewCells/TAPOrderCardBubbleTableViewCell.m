//
//  TAPOrderCardBubbleTableViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 07/11/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPOrderCardBubbleTableViewCell.h"

@interface TAPOrderCardBubbleTableViewCell ()

@property (strong, nonatomic) IBOutlet UIView *orderCardView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UILabel *orderIDLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailsLabel;
@property (strong, nonatomic) IBOutlet UIButton *headerButton;

@property (strong, nonatomic) IBOutlet UIView *productView;
@property (strong, nonatomic) IBOutlet UILabel *productNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *productPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *quantityLabel;
@property (strong, nonatomic) IBOutlet RNImageView *productImageView;

@property (strong, nonatomic) IBOutlet UIView *moreProductView;
@property (strong, nonatomic) IBOutlet UILabel *moreProductLabel;

@property (strong, nonatomic) IBOutlet UIView *dateTimeView;
@property (strong, nonatomic) IBOutlet UIView *dateView;
@property (strong, nonatomic) IBOutlet UILabel *datePlaceholderLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIView *timeView;
@property (strong, nonatomic) IBOutlet UILabel *timePlaceholderLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

@property (strong, nonatomic) IBOutlet UIView *recipientView;
@property (strong, nonatomic) IBOutlet UILabel *recipientPlaceholderLabel;
@property (strong, nonatomic) IBOutlet UILabel *recipientLabel;

@property (strong, nonatomic) IBOutlet UIView *courierView;
@property (strong, nonatomic) IBOutlet UILabel *courierCostPlaceholderLabel;
@property (strong, nonatomic) IBOutlet UILabel *courierTypeLabel;
@property (strong, nonatomic) IBOutlet UILabel *courierCostLabel;
@property (strong, nonatomic) IBOutlet RNImageView *courierLogoImageView;

@property (strong, nonatomic) IBOutlet UIView *notesView;
@property (strong, nonatomic) IBOutlet UILabel *notesPlaceholderLabel;
@property (strong, nonatomic) IBOutlet UILabel *notesLabel;

@property (strong, nonatomic) IBOutlet UIView *additionalCostView;
@property (strong, nonatomic) IBOutlet UIView *additionalCostDotView;
@property (strong, nonatomic) IBOutlet UILabel *additionalCostPlaceholderLabel;
@property (strong, nonatomic) IBOutlet UILabel *additionalCostLabel;

@property (strong, nonatomic) IBOutlet UIView *discountView;
@property (strong, nonatomic) IBOutlet UIView *discountDotView;
@property (strong, nonatomic) IBOutlet UILabel *discountPlaceholderLabel;
@property (strong, nonatomic) IBOutlet UILabel *discountLabel;

@property (strong, nonatomic) IBOutlet UIView *totalPriceView;
@property (strong, nonatomic) IBOutlet UILabel *totalPricePlaceholderLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalPriceLabel;

@property (strong, nonatomic) IBOutlet UIView *activeOrderView;
@property (strong, nonatomic) IBOutlet UIView *activeOrderLabel;

@property (strong, nonatomic) IBOutlet UIView *userActionView;

@property (strong, nonatomic) IBOutlet UIView *orderStatusView;
@property (strong, nonatomic) IBOutlet UIView *orderStatusLabel;
@property (strong, nonatomic) IBOutlet UIButton *orderStatusButton;

@property (strong, nonatomic) IBOutlet UIView *reviewConfirmActionView;
@property (strong, nonatomic) IBOutlet UIView *reviewConfirmActionLabel;
@property (strong, nonatomic) IBOutlet UIButton *reviewConfirmActionButton;

@property (strong, nonatomic) IBOutlet UIView *updateCostActionView;
@property (strong, nonatomic) IBOutlet UIView *updateCostActionLabel;
@property (strong, nonatomic) IBOutlet UIButton *updateCostActionButton;

@property (strong, nonatomic) IBOutlet UIView *confirmPaymentActionView;
@property (strong, nonatomic) IBOutlet UIView *confirmPaymentActionLabel;
@property (strong, nonatomic) IBOutlet UIButton *confirmPaymentActionButton;

@property (strong, nonatomic) IBOutlet UIView *reviewOrderActionView;
@property (strong, nonatomic) IBOutlet UIView *reviewOrderActionLabel;
@property (strong, nonatomic) IBOutlet UIButton *reviewOrderActionButton;

@property (strong, nonatomic) IBOutlet UIView *markFinishedActionView;
@property (strong, nonatomic) IBOutlet UIView *markFinishedActionLabel;
@property (strong, nonatomic) IBOutlet UIButton *markFinishedActionButton;

@property (strong, nonatomic) IBOutlet UIView *expertMarkFinishView;
@property (strong, nonatomic) IBOutlet UIButton *expertMarkFinishButton;

@property (strong, nonatomic) IBOutlet UIView *currentStatusView;
@property (strong, nonatomic) IBOutlet UIView *currentStatusButton;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *moreProductHeightLayoutConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *courierViewHeightLayoutConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *notesViewHeightLayoutConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *additionalCostViewHeightLayoutConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *discountViewHeightLayoutConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *orderCardViewLeadingConstraint;

- (void)showMoreProductView:(BOOL)isShow;
- (void)showCourierView:(BOOL)isShow;
- (void)showNotesView:(BOOL)isShow;
- (void)showAdditionalCostView:(BOOL)isShow;
- (void)showDiscountView:(BOOL)isShow;
- (void)showAdditionalCostDotView:(BOOL)isShow;
- (void)showDiscountDotView:(BOOL)isShow;
- (void)showUserActionViewWithType:(NSInteger)type;

- (IBAction)headerButtonDidTapped:(id)sender;
- (IBAction)orderStatusButtonDidTapped:(id)sender;
- (IBAction)reviewConfirmActionButtonDidTapped:(id)sender;
- (IBAction)updateCostActionButtonDidTapped:(id)sender;
- (IBAction)confirmPaymentActionButtonDidTapped:(id)sender;
- (IBAction)reviewOrderActionButtonDidTapped:(id)sender;
- (IBAction)markFinishedActionButtonDidTapped:(id)sender;
- (IBAction)expertMarkFinishedButtonDidTapped:(id)sender;
- (IBAction)currentStatusButton:(id)sender;

@end

@implementation TAPOrderCardBubbleTableViewCell

#pragma mark - Lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.orderCardView.layer.borderColor = [TAPUtil getColor:TAP_COLOR_GREY_ED].CGColor;
    self.orderCardView.layer.borderWidth = 1.0f;
    self.orderCardView.layer.cornerRadius = 10.0f;
    self.orderCardView.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
    self.orderCardView.clipsToBounds = YES;
    
    self.additionalCostDotView.layer.cornerRadius = CGRectGetHeight(self.additionalCostDotView.frame) / 2.0f;
    self.discountDotView.layer.cornerRadius = CGRectGetHeight(self.additionalCostDotView.frame) / 2.0f;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.detailsLabel.text];
    float spacing = 1.5f;
    [attributedString addAttribute:NSKernAttributeName
                             value:@(spacing)
                             range:NSMakeRange(0, [self.detailsLabel.text length])];
    self.detailsLabel.attributedText = attributedString;
    self.detailsLabel.font = [UIFont fontWithName:TAP_FONT_LATO_BOLD size:10.0f];
    
    CAGradientLayer *reviewConfirmBackgroundGradientLayer = [CAGradientLayer layer];
    reviewConfirmBackgroundGradientLayer.frame = self.reviewConfirmActionView.bounds;
    reviewConfirmBackgroundGradientLayer.colors = @[(id)[TAPUtil getColor:TAP_COLOR_AQUAMARINE_C1].CGColor, (id)[TAPUtil getColor:TAP_COLOR_MOSELO_GREEN].CGColor];
    [self.reviewConfirmActionView.layer insertSublayer:reviewConfirmBackgroundGradientLayer atIndex:0];
    
    CAGradientLayer *updateCostBackgroundGradientLayer = [CAGradientLayer layer];
    updateCostBackgroundGradientLayer.frame = self.updateCostActionView.bounds;
    updateCostBackgroundGradientLayer.colors = @[(id)[TAPUtil getColor:TAP_COLOR_AQUAMARINE_C1].CGColor, (id)[TAPUtil getColor:TAP_COLOR_MOSELO_GREEN].CGColor];
    [self.updateCostActionView.layer insertSublayer:updateCostBackgroundGradientLayer atIndex:0];
    
    CAGradientLayer *confirmPaymentBackgroundGradientLayer = [CAGradientLayer layer];
    confirmPaymentBackgroundGradientLayer.frame = self.confirmPaymentActionView.bounds;
    confirmPaymentBackgroundGradientLayer.colors = @[(id)[TAPUtil getColor:TAP_COLOR_AQUAMARINE_C1].CGColor, (id)[TAPUtil getColor:TAP_COLOR_MOSELO_GREEN].CGColor];
    [self.confirmPaymentActionView.layer insertSublayer:confirmPaymentBackgroundGradientLayer atIndex:0];
    
    CAGradientLayer *reviewOrderBackgroundGradientLayer = [CAGradientLayer layer];
    reviewOrderBackgroundGradientLayer.frame = self.reviewOrderActionView.bounds;
    reviewOrderBackgroundGradientLayer.colors = @[(id)[TAPUtil getColor:TAP_COLOR_AQUAMARINE_C1].CGColor, (id)[TAPUtil getColor:TAP_COLOR_MOSELO_GREEN].CGColor];
    [self.reviewOrderActionView.layer insertSublayer:reviewOrderBackgroundGradientLayer atIndex:0];
    
    CAGradientLayer *markFinishedBackgroundGradientLayer = [CAGradientLayer layer];
    markFinishedBackgroundGradientLayer.frame = self.markFinishedActionView.bounds;
    markFinishedBackgroundGradientLayer.colors = @[(id)[TAPUtil getColor:TAP_COLOR_AQUAMARINE_C1].CGColor, (id)[TAPUtil getColor:TAP_COLOR_MOSELO_GREEN].CGColor];
    [self.markFinishedActionView.layer insertSublayer:markFinishedBackgroundGradientLayer atIndex:0];
    
    self.currentStatusView.layer.cornerRadius = 6.0f;
    self.currentStatusView.clipsToBounds = YES;
    self.currentStatusView.layer.borderColor = [TAPUtil getColor:@"CCE7E2"].CGColor;
    self.currentStatusView.layer.borderWidth = 1.0f;
    
    self.datePlaceholderLabel.text = NSLocalizedString(@"Due Date", @"");
    self.timePlaceholderLabel.text = NSLocalizedString(@"Due Time", @"");
    
    //CS Temp
    [self setOrderCardSenderType:OrderCardSenderTypeMy];
    //END CS Temp
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

#pragma mark - Custom Method
- (void)showMoreProductView:(BOOL)isShow {
    if (isShow) {
        self.moreProductHeightLayoutConstraint.constant = 25.0f;
    }
    else {
        self.moreProductHeightLayoutConstraint.constant = 0.0f;
    }
}

- (void)showCourierView:(BOOL)isShow {
    if (isShow) {
        self.courierViewHeightLayoutConstraint.constant = 48.0f;
    }
    else {
        self.courierViewHeightLayoutConstraint.constant = 0.0f;
    }
}

- (void)showNotesView:(BOOL)isShow {
    if (isShow) {
        self.notesViewHeightLayoutConstraint.constant = 48.0f;
    }
    else {
        self.notesViewHeightLayoutConstraint.constant = 0.0f;
    }
}

- (void)showAdditionalCostView:(BOOL)isShow {
    if (isShow) {
        self.additionalCostViewHeightLayoutConstraint.constant = 29.0f;
    }
    else {
        self.additionalCostViewHeightLayoutConstraint.constant = 0.0f;
    }
}

- (void)showDiscountView:(BOOL)isShow {
    if (isShow) {
        self.discountViewHeightLayoutConstraint.constant = 29.0f;
    }
    else {
        self.discountViewHeightLayoutConstraint.constant = 0.0f;
    }
}

- (void)showAdditionalCostDotView:(BOOL)isShow {
    if (isShow) {
        self.additionalCostDotView.alpha = 1.0f;
    }
    else {
        self.additionalCostDotView.alpha = 0.0f;
    }
}

- (void)showDiscountDotView:(BOOL)isShow {
    if (isShow) {
        self.discountDotView.alpha = 1.0f;
    }
    else {
        self.discountDotView.alpha = 0.0f;
    }
}

- (void)showUserActionViewWithType:(NSInteger)type {
//    //Type 1 = Waiting Confirmation
//    //Type 2 = Review & Confirm
//    switch (type) {
//        case 1:
//        {
//            self.waitingConfirmationView.alpha = 1.0f;
//            self.waitingConfirmationButton.alpha = 1.0f;
//            self.waitingConfirmationButton.userInteractionEnabled = YES;
//
//            self.reviewConfirmView.alpha = 0.0f;
//            self.reviewConfirmButton.alpha = 0.0f;
//            self.reviewConfirmButton.userInteractionEnabled = NO;
//            break;
//        }
//        case 2:
//        {
//            self.waitingConfirmationView.alpha = 0.0f;
//            self.waitingConfirmationButton.alpha = 0.0f;
//            self.waitingConfirmationButton.userInteractionEnabled = NO;
//
//            self.reviewConfirmView.alpha = 1.0f;
//            self.reviewConfirmButton.alpha = 1.0f;
//            self.reviewConfirmButton.userInteractionEnabled = YES;
//            break;
//        }
//        default:
//            break;
//    }
}

- (IBAction)headerButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(orderCardBubbleDidTappedHeaderButtonDidTapped)]) {
        [self.delegate orderCardBubbleDidTappedHeaderButtonDidTapped];
    }
}

- (IBAction)orderStatusButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(orderCardBubbleDidTappedOrderStatusButtonDidTapped)]) {
        [self.delegate orderCardBubbleDidTappedOrderStatusButtonDidTapped];
    }
}

- (IBAction)reviewConfirmActionButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(orderCardBubbleDidTappedReviewConfirmActionButtonDidTapped)]) {
        [self.delegate orderCardBubbleDidTappedReviewConfirmActionButtonDidTapped];
    }
}

- (IBAction)updateCostActionButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(orderCardBubbleDidTappedUpdateCostActionButtonDidTapped)]) {
        [self.delegate orderCardBubbleDidTappedUpdateCostActionButtonDidTapped];
    }
}

- (IBAction)confirmPaymentActionButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(orderCardBubbleDidTappedConfirmPaymentActionButtonDidTapped)]) {
        [self.delegate orderCardBubbleDidTappedConfirmPaymentActionButtonDidTapped];
    }
}

- (IBAction)reviewOrderActionButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(orderCardBubbleDidTappedReviewOrderActionButtonDidTapped)]) {
        [self.delegate orderCardBubbleDidTappedReviewOrderActionButtonDidTapped];
    }
}

- (IBAction)markFinishedActionButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(orderCardBubbleDidTappedMarkFinishedActionButtonDidTapped)]) {
        [self.delegate orderCardBubbleDidTappedMarkFinishedActionButtonDidTapped];
    }
}

- (IBAction)expertMarkFinishedButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(orderCardBubbleDidTappedExpertMarkFinishedButtonDidTapped)]) {
        [self.delegate orderCardBubbleDidTappedExpertMarkFinishedButtonDidTapped];
    }
}

- (IBAction)currentStatusButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(orderCardBubbleDidTappedCurrentStatusButton)]) {
        [self.delegate orderCardBubbleDidTappedCurrentStatusButton];
    }
}

- (void)setOrderCardSenderType:(OrderCardSenderType *)orderCardSenderType {
    _orderCardSenderType = orderCardSenderType;
    if (self.orderCardSenderType == OrderCardSenderTypeMy) {
        self.orderCardView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
        self.orderCardViewLeadingConstraint.constant = 16.0f;

    }
    else if (self.orderCardSenderType == OrderCardSenderTypeYour){
        self.orderCardView.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
        self.orderCardViewLeadingConstraint.constant = CGRectGetWidth([UIScreen mainScreen].bounds) - CGRectGetWidth(self.orderCardView.frame) - 16.0f;
    }
}

@end
