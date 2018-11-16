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
@property (strong, nonatomic) IBOutlet RNImageView *productImageView;
@property (strong, nonatomic) IBOutlet UILabel *productNameLabel;
@property (strong, nonatomic) IBOutlet UIView *priceView;
@property (strong, nonatomic) IBOutlet UILabel *pricePlaceholderLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UIView *ratingView;
@property (strong, nonatomic) IBOutlet UIImageView *starRatingImageView;
@property (strong, nonatomic) IBOutlet UILabel *ratingPlaceholderLabel;
@property (strong, nonatomic) IBOutlet UILabel *ratingLabel;
@property (strong, nonatomic) IBOutlet UILabel *productDescriptionLabel;
@property (strong, nonatomic) IBOutlet UIView *detailView;
@property (strong, nonatomic) IBOutlet UIView *orderNowView;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;
@property (strong, nonatomic) IBOutlet UILabel *orderNowLabel;

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
    
    if(IS_IPHONE_4_7_INCH_AND_ABOVE) {
        self.orderNowLabel.font = [UIFont fontWithName:TAP_FONT_LATO_BOLD size:14.0f];
        self.detailLabel.font = [UIFont fontWithName:TAP_FONT_LATO_BOLD size:14.0f];
    }
    else {
        self.orderNowLabel.font = [UIFont fontWithName:TAP_FONT_LATO_BOLD size:12.0f];
        self.detailLabel.font = [UIFont fontWithName:TAP_FONT_LATO_BOLD size:12.0f];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.productImageView.image = nil;
    self.productNameLabel.text = @"";
    self.priceLabel.text = @"";
    self.ratingLabel.text = @"";
    self.productDescriptionLabel.text = @"";
}

#pragma mark - Custom Method
//DV Temp
- (void)setProductListWithData {
    [self.productImageView setImageWithURLString:TAP_DUMMY_IMAGE_URL];
    
    self.productNameLabel.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit Aliquam aliquet urna eget ante consectetur quis elementum arcu fringilla Etiam ornare metus vitae risus dictum id pulvinar tellus eleifend";
    self.priceLabel.text = [TAPUtil formattedCurrencyWithCurrencySign:@"Rp " value:999999999];
    self.ratingLabel.text = @"4.9";
    self.productDescriptionLabel.text = @"Suspendisse potenti. Ut arcu nulla, sodales quis hendrerit id, mattis a tellus. Morbi vel ligula quam. Ut volutpat in orci tincidunt cursus. Ut laoreet felis et risus sollicitudin pulvinar. In molestie feugiat mi, ac sodales metus volutpat at. Aenean tempus nisl ut nulla faucibus fermentum. Nunc maximus blandit luctus. Phasellus felis ex, hendrerit dapibus erat nec, aliquam suscipit arcu. Ut fermentum ornare magna, at bibendum orci posuere in. Morbi sagittis ornare mattis. Quisque consectetur sem id diam ultricies euismod.";
}
//END DV Temp

@end
