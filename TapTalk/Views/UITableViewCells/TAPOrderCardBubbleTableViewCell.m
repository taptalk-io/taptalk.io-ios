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
@property (strong, nonatomic) IBOutlet UILabel *orderStatusLabel;
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
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *activeOrderViewHeightLayoutConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *markFinishViewHeightLayoutConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *userActionViewHeightLayoutConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *recipientViewHeightLayoutConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *totalPriceViewHeightLayoutConstraint;

- (void)showMoreProductView:(BOOL)isShow;
- (void)showCourierView:(BOOL)isShow;
- (void)showNotesView:(BOOL)isShow;
- (void)showAdditionalCostView:(BOOL)isShow;
- (void)showDiscountView:(BOOL)isShow;
- (void)showAdditionalCostDotView:(BOOL)isShow;
- (void)showDiscountDotView:(BOOL)isShow;
- (void)showActiveOrderView:(BOOL)isShow;
- (void)showMarkFinishView:(BOOL)isShow;
- (void)showUserActionView:(BOOL)isShow;
- (void)showRecipientView:(BOOL)isShow;
- (void)showTotalPriceView:(BOOL)isShow;
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
    [self setTAPOrderCardSenderType:TAPOrderCardSenderTypeMy];
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
        self.courierView.alpha = 1.0f;
        self.courierViewHeightLayoutConstraint.constant = 48.0f;
    }
    else {
        self.courierView.alpha = 0.0f;
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

- (void)showActiveOrderView:(BOOL)isShow {
    if (isShow) {
        self.activeOrderViewHeightLayoutConstraint.constant = 40.0f;
    }
    else {
        self.activeOrderViewHeightLayoutConstraint.constant = 0.0f;
    }
}

- (void)showMarkFinishView:(BOOL)isShow {
    if (isShow) {
        self.markFinishViewHeightLayoutConstraint.constant = 92.0f;
    }
    else {
        self.markFinishViewHeightLayoutConstraint.constant = 0.0f;
    }
}

- (void)showUserActionView:(BOOL)isShow {
    if (isShow) {
        self.userActionViewHeightLayoutConstraint.constant = 40.0f;
    }
    else {
        self.userActionViewHeightLayoutConstraint.constant = 0.0f;
    }
}

- (void)showRecipientView:(BOOL)isShow {
    if (isShow) {
        self.recipientViewHeightLayoutConstraint.active = NO;
        self.recipientView.alpha = 1.0f;
    }
    else {
        self.recipientViewHeightLayoutConstraint.active = YES;
        self.recipientViewHeightLayoutConstraint.constant = 0.0f;
        self.recipientView.alpha = 0.0f;
    }
}

- (void)showTotalPriceView:(BOOL)isShow {
    if (isShow) {
        self.totalPriceViewHeightLayoutConstraint.constant = 48.0f;
        self.totalPriceView.alpha = 1.0f;
    }
    else {
        self.totalPriceViewHeightLayoutConstraint.constant = 0.0f;
        self.totalPriceView.alpha = 0.0f;
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

- (void)setTAPOrderCardSenderType:(TAPOrderCardSenderType *)tapOrderCardSenderType {
    _orderCardSenderType = tapOrderCardSenderType;
    if (self.orderCardSenderType == TAPOrderCardSenderTypeMy) {
        self.orderCardView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
        self.orderCardViewLeadingConstraint.constant = 16.0f;

    }
    else if (self.orderCardSenderType == TAPOrderCardSenderTypeYour){
        self.orderCardView.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
        self.orderCardViewLeadingConstraint.constant = CGRectGetWidth([UIScreen mainScreen].bounds) - CGRectGetWidth(self.orderCardView.frame) - 16.0f;
    }
}

- (void)setOrderCardWithType:(NSInteger)type { //CS TEMP - Dummy Set Data
    //1 - Review and Confirm
    //2 - Waiting Confirmation
    //3 - Pay Now
    //4 - Order Expired
    //5 - Order Overpaid
    //6 - Order Declined
    //7 - Order Canceled
    //8 - Order Reported
    //9 - Write Review
    //10 - Mark as Finish
    //11 - Waiting User Confirmation
    //12 - Active Order
    //13 - Waiting Payment

    self.orderIDLabel.text = @"MD-7WN5PAR1";
    [self.productImageView setImageWithURLString:TAP_DUMMY_IMAGE_URL];
    self.productNameLabel.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit…";
    self.productPriceLabel.text = @"Rp. 1.930.000";
    
    NSInteger qty = 3;
    self.quantityLabel.text = [NSString stringWithFormat:@"%@ %ld", NSLocalizedString(@"Quantity:", @""), qty];
    
    NSInteger itemQty = 5;
    if(itemQty > 1) {
        [self showMoreProductView:YES];
        self.moreProductLabel.text = [NSString stringWithFormat:@"And %ld more items", itemQty - 1];
    }
    else {
        [self showMoreProductView:NO];
        self.moreProductLabel.text = @"";
    }
    
    self.recipientLabel.text = @"Bernama Badi Sabur\n081297304401\nJalan Kyai Maja No. 25C, Gunung, Kebayoran Baru, RT.12/RW.2, Gunung, Kby. Baru, Kota Jakarta Selatan, Daerah Khusus Ibukota Jakarta 12120";
    
    self.courierTypeLabel.text = @"Instant Courier";
    self.courierCostLabel.text = @"Rp 30.000";
    [self.courierLogoImageView setImageWithURLString:@"https://www.keestore.com/wp-content/uploads/2018/05/go-send-by-go-jek-logo.png"];
    
    self.totalPriceLabel.text = @"Rp. 3.890.000";
    
    self.dateLabel.text = @"Fri 09 Nov 2018";
    self.timeLabel.text = @"18:30";
    
    self.additionalCostLabel.text = @"Rp. 100.000";
    self.discountLabel.text = @"(Rp. 100.000)";
    
    self.notesLabel.text = @"Mauris non tempor quam, et lacinia sapien. Mau…";
    
    BOOL isAdditional = YES;
    BOOL isDiscount = YES;
    BOOL isHasNotes = YES;
    BOOL isHasCourier = YES;
    
    if (type == 1) {
        //1 - Review and Confirm
        if (isHasNotes) {
            [self showNotesView:YES];
        }
        else {
            [self showNotesView:NO];

        }
        
        if (isAdditional) {
            [self showAdditionalCostView:YES];
        }
        else {
            [self showAdditionalCostView:NO];
        }
        
        if (isDiscount) {
            [self showDiscountView:YES];
        }
        else {
            [self showDiscountView:NO];
        }
        
        if (isHasCourier) {
            [self showCourierView:YES];
        }
        else {
            [self showCourierView:NO];
        }
        
        [self showMarkFinishView:NO];
        [self showActiveOrderView:NO];
        [self showRecipientView:YES];
        [self showTotalPriceView:YES];
        self.orderStatusView.alpha = 0.0f;
        self.updateCostActionView.alpha = 0.0f;
        self.confirmPaymentActionView.alpha = 0.0f;
        self.reviewOrderActionView.alpha = 0.0f;
        self.reviewConfirmActionView.alpha = 1.0f;
        self.markFinishedActionView.alpha = 0.0f;
    }
    else if (type == 2) {
        //2 - Waiting Confirmation
        if (isHasNotes) {
            [self showNotesView:YES];
        }
        else {
            [self showNotesView:NO];
        }
        
        if (isAdditional) {
            [self showAdditionalCostView:YES];
        }
        else {
            [self showAdditionalCostView:NO];
        }
        
        if (isDiscount) {
            [self showDiscountView:YES];
        }
        else {
            [self showDiscountView:NO];
        }
        
        if (isHasCourier) {
            [self showCourierView:YES];
        }
        else {
            [self showCourierView:NO];
        }
        
        [self showMarkFinishView:NO];
        [self showActiveOrderView:NO];
        [self showRecipientView:YES];
        [self showTotalPriceView:YES];
        self.orderStatusView.alpha = 1.0f;
        self.updateCostActionView.alpha = 0.0f;
        self.confirmPaymentActionView.alpha = 0.0f;
        self.reviewOrderActionView.alpha = 0.0f;
        self.reviewConfirmActionView.alpha = 0.0f;
        self.markFinishedActionView.alpha = 0.0f;
        
        self.orderStatusLabel.text = NSLocalizedString(@"Waiting Confirmation", @"");
        self.orderStatusLabel.textColor = [TAPUtil getColor:@"FF9049"];
    }
    else if (type == 3) {
        //3 - Pay Now
        if (isHasNotes) {
            [self showNotesView:YES];
        }
        else {
            [self showNotesView:NO];
            
        }
        
        if (isAdditional) {
            [self showAdditionalCostView:YES];
        }
        else {
            [self showAdditionalCostView:NO];
        }
        
        if (isDiscount) {
            [self showDiscountView:YES];
        }
        else {
            [self showDiscountView:NO];
        }
        
        if (isHasCourier) {
            [self showCourierView:YES];
        }
        else {
            [self showCourierView:NO];
        }
        
        [self showMarkFinishView:NO];
        [self showActiveOrderView:NO];
        [self showRecipientView:YES];
        [self showTotalPriceView:YES];
        self.orderStatusView.alpha = 0.0f;
        self.updateCostActionView.alpha = 0.0f;
        self.confirmPaymentActionView.alpha = 1.0f;
        self.reviewOrderActionView.alpha = 0.0f;
        self.reviewConfirmActionView.alpha = 0.0f;
        self.markFinishedActionView.alpha = 0.0f;
    }
    else if (type == 4) {
        //4 - Order Expired
        [self showNotesView:NO];
        [self showAdditionalCostView:NO];
        [self showDiscountView:NO];
        [self showMarkFinishView:NO];
        [self showActiveOrderView:NO];
        [self showNotesView:NO];
        [self showCourierView:NO];
        [self showRecipientView:NO];
        [self showTotalPriceView:NO];
        self.orderStatusView.alpha = 1.0f;
        self.updateCostActionView.alpha = 0.0f;
        self.confirmPaymentActionView.alpha = 0.0f;
        self.reviewOrderActionView.alpha = 0.0f;
        self.reviewConfirmActionView.alpha = 0.0f;
        self.markFinishedActionView.alpha = 0.0f;
        
        self.orderStatusLabel.text = NSLocalizedString(@"Order Expired", @"");
        self.orderStatusLabel.textColor = [TAPUtil getColor:@"EC2C2B"];
    }
    else if (type == 5) {
        //5 - Order Overpaid
        [self showNotesView:NO];
        [self showAdditionalCostView:NO];
        [self showDiscountView:NO];
        [self showMarkFinishView:NO];
        [self showActiveOrderView:NO];
        [self showNotesView:NO];
        [self showCourierView:NO];
        [self showRecipientView:NO];
        [self showTotalPriceView:NO];
        self.orderStatusView.alpha = 1.0f;
        self.updateCostActionView.alpha = 0.0f;
        self.confirmPaymentActionView.alpha = 0.0f;
        self.reviewOrderActionView.alpha = 0.0f;
        self.reviewConfirmActionView.alpha = 0.0f;
        self.markFinishedActionView.alpha = 0.0f;
        
        self.orderStatusLabel.text = NSLocalizedString(@"Order Overpaid", @"");
        self.orderStatusLabel.textColor = [TAPUtil getColor:@"EC2C2B"];
    }
    else if (type == 6) {
        //6 - Order Declined
        [self showNotesView:NO];
        [self showAdditionalCostView:NO];
        [self showDiscountView:NO];
        [self showMarkFinishView:NO];
        [self showActiveOrderView:NO];
        [self showNotesView:NO];
        [self showCourierView:NO];
        [self showRecipientView:NO];
        [self showTotalPriceView:NO];
        self.orderStatusView.alpha = 1.0f;
        self.updateCostActionView.alpha = 0.0f;
        self.confirmPaymentActionView.alpha = 0.0f;
        self.reviewOrderActionView.alpha = 0.0f;
        self.reviewConfirmActionView.alpha = 0.0f;
        self.markFinishedActionView.alpha = 0.0f;
        
        self.orderStatusLabel.text = NSLocalizedString(@"Order Declined", @"");
        self.orderStatusLabel.textColor = [TAPUtil getColor:@"EC2C2B"];
    }
    else if (type == 7) {
        //7 - Order Canceled
        [self showNotesView:NO];
        [self showAdditionalCostView:NO];
        [self showDiscountView:NO];
        [self showMarkFinishView:NO];
        [self showActiveOrderView:NO];
        [self showNotesView:NO];
        [self showCourierView:NO];
        [self showRecipientView:NO];
        [self showTotalPriceView:NO];
        self.orderStatusView.alpha = 1.0f;
        self.updateCostActionView.alpha = 0.0f;
        self.confirmPaymentActionView.alpha = 0.0f;
        self.reviewOrderActionView.alpha = 0.0f;
        self.reviewConfirmActionView.alpha = 0.0f;
        self.markFinishedActionView.alpha = 0.0f;
        
        self.orderStatusLabel.text = NSLocalizedString(@"Order Canceled", @"");
        self.orderStatusLabel.textColor = [TAPUtil getColor:@"EC2C2B"];
    }
    else if (type == 8) {
        //8 - Order Reported
        [self showNotesView:NO];
        [self showAdditionalCostView:NO];
        [self showDiscountView:NO];
        [self showMarkFinishView:NO];
        [self showActiveOrderView:NO];
        [self showNotesView:NO];
        [self showCourierView:NO];
        [self showRecipientView:NO];
        [self showTotalPriceView:NO];
        self.orderStatusView.alpha = 1.0f;
        self.updateCostActionView.alpha = 0.0f;
        self.confirmPaymentActionView.alpha = 0.0f;
        self.reviewOrderActionView.alpha = 0.0f;
        self.reviewConfirmActionView.alpha = 0.0f;
        self.markFinishedActionView.alpha = 0.0f;
        
        self.orderStatusLabel.text = NSLocalizedString(@"Order Reported", @"");
        self.orderStatusLabel.textColor = [TAPUtil getColor:@"EC2C2B"];
    }
    else if (type == 9) {
        //9 - Write Review
        [self showNotesView:NO];
        [self showAdditionalCostView:NO];
        [self showDiscountView:NO];
        [self showMarkFinishView:YES];
        [self showActiveOrderView:NO];
        [self showNotesView:NO];
        [self showCourierView:NO];
        [self showRecipientView:NO];
        [self showTotalPriceView:NO];
        self.orderStatusView.alpha = 0.0f;
        self.updateCostActionView.alpha = 0.0f;
        self.confirmPaymentActionView.alpha = 0.0f;
        self.reviewOrderActionView.alpha = 1.0f;
        self.reviewConfirmActionView.alpha = 0.0f;
        self.markFinishedActionView.alpha = 0.0f;
    }
    else if (type == 10) {
        //10 - Mark as Finish
        [self showNotesView:NO];
        [self showAdditionalCostView:NO];
        [self showDiscountView:NO];
        [self showMarkFinishView:NO];
        [self showActiveOrderView:YES];
        [self showNotesView:NO];
        [self showCourierView:NO];
        [self showRecipientView:NO];
        [self showTotalPriceView:NO];
        self.orderStatusView.alpha = 0.0f;
        self.updateCostActionView.alpha = 0.0f;
        self.confirmPaymentActionView.alpha = 0.0f;
        self.reviewOrderActionView.alpha = 0.0f;
        self.reviewConfirmActionView.alpha = 0.0f;
        self.markFinishedActionView.alpha = 1.0f;
    }
    else if (type == 11) {
        //11 - Waiting User Confirmation
        if (isHasNotes) {
            [self showNotesView:YES];
        }
        else {
            [self showNotesView:NO];
        }
        
        if (isAdditional) {
            [self showAdditionalCostView:YES];
        }
        else {
            [self showAdditionalCostView:NO];
        }
        
        if (isDiscount) {
            [self showDiscountView:YES];
        }
        else {
            [self showDiscountView:NO];
        }
        
        if (isHasCourier) {
            [self showCourierView:YES];
        }
        else {
            [self showCourierView:NO];
        }
        
        [self showMarkFinishView:NO];
        [self showActiveOrderView:NO];
        [self showRecipientView:YES];
        [self showTotalPriceView:YES];
        self.orderStatusView.alpha = 1.0f;
        self.updateCostActionView.alpha = 0.0f;
        self.confirmPaymentActionView.alpha = 0.0f;
        self.reviewOrderActionView.alpha = 0.0f;
        self.reviewConfirmActionView.alpha = 0.0f;
        self.markFinishedActionView.alpha = 0.0f;
        
        self.orderStatusLabel.text = NSLocalizedString(@"Waiting User Confirmation", @"");
        self.orderStatusLabel.textColor = [TAPUtil getColor:@"FF9049"];
    }
    else if (type == 13) {
        //13 - Waiting Payment
        if (isHasNotes) {
            [self showNotesView:YES];
        }
        else {
            [self showNotesView:NO];
        }
        
        if (isAdditional) {
            [self showAdditionalCostView:YES];
        }
        else {
            [self showAdditionalCostView:NO];
        }
        
        if (isDiscount) {
            [self showDiscountView:YES];
        }
        else {
            [self showDiscountView:NO];
        }
        
        if (isHasCourier) {
            [self showCourierView:YES];
        }
        else {
            [self showCourierView:NO];
        }
        
        [self showMarkFinishView:NO];
        [self showActiveOrderView:NO];
        [self showRecipientView:YES];
        [self showTotalPriceView:YES];
        self.orderStatusView.alpha = 1.0f;
        self.updateCostActionView.alpha = 0.0f;
        self.confirmPaymentActionView.alpha = 0.0f;
        self.reviewOrderActionView.alpha = 0.0f;
        self.reviewConfirmActionView.alpha = 0.0f;
        self.markFinishedActionView.alpha = 0.0f;
        
        self.orderStatusLabel.text = NSLocalizedString(@"Waiting Payment", @"");
        self.orderStatusLabel.textColor = [TAPUtil getColor:@"FF9049"];
    }
    else if (type == 12) {
        //12 - Active Order
        [self showNotesView:NO];
        [self showAdditionalCostView:NO];
        [self showDiscountView:NO];
        [self showMarkFinishView:NO];
        [self showActiveOrderView:NO];
        [self showNotesView:NO];
        [self showCourierView:NO];
        [self showRecipientView:NO];
        [self showTotalPriceView:NO];
        self.orderStatusView.alpha = 1.0f;
        self.updateCostActionView.alpha = 0.0f;
        self.confirmPaymentActionView.alpha = 0.0f;
        self.reviewOrderActionView.alpha = 0.0f;
        self.reviewConfirmActionView.alpha = 0.0f;
        self.markFinishedActionView.alpha = 0.0f;
        
        self.orderStatusLabel.text = NSLocalizedString(@"Active Order", @"");
        self.orderStatusLabel.textColor = [TAPUtil getColor:@"2ECCAD"];
    }
    
}
@end
