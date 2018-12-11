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

@property (strong, nonatomic) IBOutlet UIButton *detailButton;
@property (strong, nonatomic) IBOutlet UIButton *orderNowButton;

- (void)setProductListWithData; //DV Temp

@end

NS_ASSUME_NONNULL_END
