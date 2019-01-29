//
//  TAPProductListCollectionViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 05/11/18.
//  Copyright © 2018 Moselo. All rights reserved.
//

#import "TAPBaseCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPProductListCollectionViewCell : TAPBaseCollectionViewCell

@property (strong, nonatomic) IBOutlet UIButton *leftOptionButton;
@property (strong, nonatomic) IBOutlet UIButton *rightOptionButton;

- (void)setProductCellWithData:(NSDictionary *)product;

@end

NS_ASSUME_NONNULL_END
