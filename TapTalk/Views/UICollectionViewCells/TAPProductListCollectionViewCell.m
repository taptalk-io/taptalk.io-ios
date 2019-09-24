//
//  TAPProductListCollectionViewCell.m
//  TapTalk
//
//  Created by Dominic Vedericho on 05/11/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPProductListCollectionViewCell.h"

@interface TAPProductListCollectionViewCell ()

@property (strong, nonatomic) IBOutlet UIView *paddingView;
@property (strong, nonatomic) IBOutlet UIView *backgroundContentView;
@property (strong, nonatomic) IBOutlet TAPImageView *productImageView;
@property (strong, nonatomic) IBOutlet UILabel *productNameLabel;
@property (strong, nonatomic) IBOutlet UIView *priceView;
@property (strong, nonatomic) IBOutlet UILabel *pricePlaceholderLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UIView *ratingView;
@property (strong, nonatomic) IBOutlet UIImageView *starRatingImageView;
@property (strong, nonatomic) IBOutlet UILabel *ratingPlaceholderLabel;
@property (strong, nonatomic) IBOutlet UILabel *ratingLabel;
@property (strong, nonatomic) IBOutlet UILabel *noRatingLabel;
@property (strong, nonatomic) IBOutlet UILabel *productDescriptionLabel;
@property (strong, nonatomic) IBOutlet UIView *leftOptionView;
@property (strong, nonatomic) IBOutlet UIView *rightOptionView;
@property (strong, nonatomic) IBOutlet UILabel *leftOptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *rightOptionLabel;
@property (strong, nonatomic) IBOutlet UIView *singleOptionView;
@property (strong, nonatomic) IBOutlet UILabel *singleOptionLabel;

- (IBAction)leftOptionButtonDidTapped:(id)sender;
- (IBAction)rightOptionButtonDidTapped:(id)sender;
- (IBAction)singleOptionButtonDidTapped:(id)sender;

@end

@implementation TAPProductListCollectionViewCell
#pragma mark - Lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.noRatingLabel.alpha = 0.0f;
    
    self.singleOptionView.alpha = 0.0f;
    self.singleOptionButton.alpha = 0.0f;
    self.singleOptionButton.userInteractionEnabled = NO;
    
    self.leftOptionView.alpha = 1.0f;
    self.leftOptionButton.alpha = 1.0f;
    self.leftOptionButton.userInteractionEnabled = YES;
    
    self.rightOptionView.alpha = 1.0f;
    self.rightOptionButton.alpha = 1.0f;
    self.rightOptionButton.userInteractionEnabled = YES;
    
    self.backgroundContentView.clipsToBounds = YES;
    self.backgroundContentView.layer.borderColor = [TAPUtil getColor:@"EDEDED"].CGColor;
    self.backgroundContentView.layer.borderWidth = 1.0f;
    self.backgroundContentView.layer.cornerRadius = 8.0f;
    
    if (IS_IPHONE_4_7_INCH_AND_ABOVE) {
        UIFont *obtainedFont = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
        obtainedFont = [obtainedFont fontWithSize:14.0f];
        self.leftOptionLabel.font = obtainedFont;
        self.rightOptionLabel.font = obtainedFont;
        self.singleOptionLabel.font = obtainedFont;
    }
    else {
        UIFont *obtainedFont = [[TAPStyleManager sharedManager] getDefaultFontForType:TAPDefaultFontBold];
        obtainedFont = [obtainedFont fontWithSize:12.0f];
        self.leftOptionLabel.font = obtainedFont;
        self.rightOptionLabel.font = obtainedFont;
        self.singleOptionLabel.font = obtainedFont;
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.starRatingImageView.alpha = 1.0f;
    self.ratingLabel.alpha = 1.0f;
    self.noRatingLabel.alpha = 0.0f;
    self.productImageView.image = nil;
    self.productNameLabel.text = @"";
    self.priceLabel.text = @"";
    self.ratingLabel.text = @"";
    self.productDescriptionLabel.text = @"";
    self.leftOptionLabel.text = @"";
    self.rightOptionLabel.text = @"";
    self.singleOptionLabel.text = @"";
}

#pragma mark - Custom Method
- (void)setProductCellWithData:(NSDictionary *)dataDictionary {
    NSString *productIDString = [dataDictionary objectForKey:@"id"];
    productIDString = [TAPUtil nullToEmptyString:productIDString];
    
    NSString *productNameString = [dataDictionary objectForKey:@"name"];
    productNameString = [TAPUtil nullToEmptyString:productNameString];
    
    NSString *currencyString = [dataDictionary objectForKey:@"currency"];
    currencyString = [TAPUtil nullToEmptyString:currencyString];
    
    NSString *priceString = [dataDictionary objectForKey:@"price"];
    priceString = [TAPUtil nullToEmptyString:priceString];
    
    NSString *ratingString = [dataDictionary objectForKey:@"rating"];
    ratingString = [TAPUtil nullToEmptyString:ratingString];
    
    NSString *weightString = [dataDictionary objectForKey:@"weight"];
    weightString = [TAPUtil nullToEmptyString:weightString];
    
    NSString *productDescriptionString = [dataDictionary objectForKey:@"description"];
    productDescriptionString = [TAPUtil nullToEmptyString:productDescriptionString];
    
    NSString *productImageURLString = [dataDictionary objectForKey:@"imageURL"];
    productImageURLString = [TAPUtil nullToEmptyString:productImageURLString];
    
    NSString *leftOptionTextString = [dataDictionary objectForKey:@"buttonOption1Text"];
    leftOptionTextString = [TAPUtil nullToEmptyString:leftOptionTextString];
    
    NSString *rightOptionTextString = [dataDictionary objectForKey:@"buttonOption2Text"];
    rightOptionTextString = [TAPUtil nullToEmptyString:rightOptionTextString];
    
    NSString *leftOptionColorString = [dataDictionary objectForKey:@"buttonOption1Color"];
    leftOptionColorString = [TAPUtil nullToEmptyString:leftOptionColorString];
    
    NSString *rightOptionColorString = [dataDictionary objectForKey:@"buttonOption2Color"];
    rightOptionColorString = [TAPUtil nullToEmptyString:rightOptionColorString];
    
    if ([productDescriptionString isEqualToString:@""]) {
        productDescriptionString = @"No description";
    }
    
    if ([ratingString isEqualToString:@""] || [ratingString isEqualToString:@"0.0"] || [ratingString isEqualToString:@"0"]) {
        self.starRatingImageView.alpha = 0.0f;
        self.ratingLabel.alpha = 0.0f;
        self.noRatingLabel.alpha = 1.0f;
    }
    else {
        self.starRatingImageView.alpha = 1.0f;
        self.ratingLabel.alpha = 1.0f;
        self.noRatingLabel.alpha = 0.0f;
    }
    
    self.productNameLabel.text = productNameString;
    self.priceLabel.text = [TAPUtil formattedCurrencyWithCurrencySign:currencyString value:[priceString doubleValue]];
    [self.productImageView setImageWithURLString:productImageURLString];
    self.ratingLabel.text = ratingString;
    self.productDescriptionLabel.text = productDescriptionString;
    self.leftOptionLabel.text = leftOptionTextString;
    self.leftOptionLabel.textColor = [TAPUtil getColor:leftOptionColorString];
    self.singleOptionLabel.text = leftOptionTextString;
    self.singleOptionLabel.textColor = [TAPUtil getColor:leftOptionColorString];
    self.rightOptionLabel.text = rightOptionTextString;
    self.rightOptionLabel.textColor = [TAPUtil getColor:rightOptionColorString];
}

- (void)setAsSingleButtonView:(BOOL)isSetAsSingleButtonView {
    _isSetAsSingleButtonView = isSetAsSingleButtonView;
    
    if (isSetAsSingleButtonView) {
        self.singleOptionView.alpha = 1.0f;
        self.singleOptionButton.alpha = 1.0f;
        self.singleOptionButton.userInteractionEnabled = YES;
        
        self.leftOptionView.alpha = 0.0f;
        self.leftOptionButton.alpha = 0.0f;
        self.leftOptionButton.userInteractionEnabled = NO;
        
        self.rightOptionView.alpha = 0.0f;
        self.rightOptionButton.alpha = 0.0f;
        self.rightOptionButton.userInteractionEnabled = NO;
    }
    else {
        self.singleOptionView.alpha = 0.0f;
        self.singleOptionButton.alpha = 0.0f;
        self.singleOptionButton.userInteractionEnabled = NO;
        
        self.leftOptionView.alpha = 1.0f;
        self.leftOptionButton.alpha = 1.0f;
        self.leftOptionButton.userInteractionEnabled = YES;
        
        self.rightOptionView.alpha = 1.0f;
        self.rightOptionButton.alpha = 1.0f;
        self.rightOptionButton.userInteractionEnabled = YES;
    }
}

- (IBAction)leftOptionButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(leftOrSingleOptionButtonDidTappedWithIndexPath:isSingleOptionView:)]) {
        [self.delegate leftOrSingleOptionButtonDidTappedWithIndexPath:self.selectedIndexPath isSingleOptionView:self.isSetAsSingleButtonView];
    }
}

- (IBAction)rightOptionButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(rightOptionButtonDidTappedWithIndexPath:isSingleOptionView:)]) {
        [self.delegate rightOptionButtonDidTappedWithIndexPath:self.selectedIndexPath isSingleOptionView:self.isSetAsSingleButtonView];
    }
}

- (IBAction)singleOptionButtonDidTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(leftOrSingleOptionButtonDidTappedWithIndexPath:isSingleOptionView:)]) {
        [self.delegate leftOrSingleOptionButtonDidTappedWithIndexPath:self.selectedIndexPath isSingleOptionView:self.isSetAsSingleButtonView];
    }
}

- (void)setCellCornerRadiusPositionWithCurrentActiveUserProduct:(BOOL)isCurrentActiveUserProduct {
    //Indicate whether the product is belong to current active user
    if (isCurrentActiveUserProduct) {
        self.backgroundContentView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
    }
    else {
        self.backgroundContentView.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner | kCALayerMinXMaxYCorner;
    }
}

@end
