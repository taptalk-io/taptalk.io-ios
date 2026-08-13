//
//  TAPCountryPickerTableViewCell.h
//  TapTalk
//
//  Created by Dominic Vedericho on 02/05/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseTableViewCell.h"
#import "TAPCountryModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPCountryPickerTableViewCell : TAPBaseTableViewCell

- (void)setCountryData:(TAPCountryModel *)country;
//- (void)showSeparatorView:(BOOL)show;
- (void)setAsSelected:(BOOL)selected animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
