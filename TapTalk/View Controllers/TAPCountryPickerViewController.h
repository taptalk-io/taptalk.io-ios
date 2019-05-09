//
//  TAPCountryPickerViewController.h
//  TapTalk
//
//  Created by Dominic Vedericho on 02/05/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TAPCountryPickerViewControllerDelegate <NSObject>

- (void)countryPickerDidSelectCountryWithData:(TAPCountryModel *)country;

@end

@interface TAPCountryPickerViewController : TAPBaseViewController

@property (strong, nonatomic) NSArray *countryDataArray;
@property (strong, nonatomic) TAPCountryModel *selectedCountry;
@property (weak, nonatomic) id <TAPCountryPickerViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
