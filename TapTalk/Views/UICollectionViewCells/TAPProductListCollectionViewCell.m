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
@property (strong, nonatomic) IBOutlet UILabel *productDescriptionLabel;
@property (strong, nonatomic) IBOutlet UIView *leftOptionView;
@property (strong, nonatomic) IBOutlet UIView *rightOptionView;
@property (strong, nonatomic) IBOutlet UILabel *leftOptionLabel;
@property (strong, nonatomic) IBOutlet UILabel *rightOptionLabel;

@end

@implementation TAPProductListCollectionViewCell
#pragma mark - Lifecycle
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundContentView.clipsToBounds = YES;
    self.backgroundContentView.layer.borderColor = [TAPUtil getColor:TAP_COLOR_GREY_ED].CGColor;
    self.backgroundContentView.layer.borderWidth = 1.0f;
    self.backgroundContentView.layer.cornerRadius = 8.0f;
    self.backgroundContentView.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMaxXMaxYCorner | kCALayerMinXMaxYCorner;
    
    if (IS_IPHONE_4_7_INCH_AND_ABOVE) {
        self.leftOptionLabel.font = [UIFont fontWithName:TAP_FONT_LATO_BOLD size:14.0f];
        self.rightOptionLabel.font = [UIFont fontWithName:TAP_FONT_LATO_BOLD size:14.0f];
    }
    else {
        self.leftOptionLabel.font = [UIFont fontWithName:TAP_FONT_LATO_BOLD size:12.0f];
        self.rightOptionLabel.font = [UIFont fontWithName:TAP_FONT_LATO_BOLD size:12.0f];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.productImageView.image = nil;
    self.productNameLabel.text = @"";
    self.priceLabel.text = @"";
    self.ratingLabel.text = @"";
    self.productDescriptionLabel.text = @"";
    self.leftOptionLabel.text = @"";
    self.rightOptionLabel.text = @"";
}

#pragma mark - Custom Method
- (void)setProductCellWithData:(NSDictionary *)product {

    NSString *productNameString = [product objectForKey:@"name"];
    productNameString = [TAPUtil nullToEmptyString:productNameString];
    
    NSString *currencyString = [product objectForKey:@"currency"];
    currencyString = [TAPUtil nullToEmptyString:currencyString];
    
    NSString *priceString = [product objectForKey:@"price"];
    productNameString = [TAPUtil nullToEmptyString:productNameString];
    
    NSString *ratingString = [product objectForKey:@"rating"];
    ratingString = [TAPUtil nullToEmptyString:ratingString];
    
    NSString *productDescriptionString = [product objectForKey:@"description"];
    productDescriptionString = [TAPUtil nullToEmptyString:productDescriptionString];
    
    NSString *productImageURLString = [product objectForKey:@"imageURL"];
    productImageURLString = [TAPUtil nullToEmptyString:productImageURLString];
    
    NSString *leftOptionTextString = [product objectForKey:@"buttonOption1Text"];
    leftOptionTextString = [TAPUtil nullToEmptyString:leftOptionTextString];
    
    NSString *rightOptionTextString = [product objectForKey:@"buttonOption1Text"];
    rightOptionTextString = [TAPUtil nullToEmptyString:rightOptionTextString];
    
    NSString *leftOptionColorString = [product objectForKey:@"buttonOption1Color"];
    leftOptionColorString = [TAPUtil nullToEmptyString:leftOptionColorString];
    
    NSString *rightOptionColorString = [product objectForKey:@"buttonOption2Color"];
    rightOptionColorString = [TAPUtil nullToEmptyString:rightOptionColorString];
    
    self.productNameLabel.text = productNameString;
    self.priceLabel.text = [TAPUtil formattedCurrencyWithCurrencySign:currencyString value:[priceString floatValue]];
    [self.productImageView setImageWithURLString:productImageURLString];
    self.ratingLabel.text = ratingString;
    self.productDescriptionLabel.text = productDescriptionString;
    self.leftOptionLabel.text = leftOptionTextString;
    self.leftOptionLabel.textColor = [TAPUtil getColor:leftOptionColorString];
    self.rightOptionLabel.text = rightOptionTextString;
    self.rightOptionLabel.textColor = [TAPUtil getColor:rightOptionColorString];
}

@end
