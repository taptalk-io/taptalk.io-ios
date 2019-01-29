//
//  TAPProductModel.h
//  TapTalk
//
//  Created by Dominic Vedericho on 29/01/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPProductModel : TAPBaseModel

@property (strong, nonatomic) NSString *productDataID;
@property (strong, nonatomic) NSString *productName;
@property (strong, nonatomic) NSString *productCurrency;
@property (strong, nonatomic) NSString *productPrice;
@property (strong, nonatomic) NSString *productRating;
@property (strong, nonatomic) NSString *productDescription;
@property (strong, nonatomic) NSString *productImageURL;
@property (strong, nonatomic) NSString *buttonOption1Text;
@property (strong, nonatomic) NSString *buttonOption2Text;
@property (strong, nonatomic) NSString *buttonOption1Color;
@property (strong, nonatomic) NSString *buttonOption2Color;

@end

NS_ASSUME_NONNULL_END
