//
//  TAPPickLocationViewController.h
//  TapTalk
//
//  Created by Dominic Vedericho on 15/02/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN


@protocol TAPPickLocationViewControllerDelegate <NSObject>

- (void)pickLocationViewControllerSetLocationWithLatitude:(CGFloat)latitude
                                                longitude:(CGFloat)longitude
                                                  address:(NSString *)address
                                               postalCode:(NSString *)postalCode;

@end

@interface TAPPickLocationViewController : TAPBaseViewController

@property (weak, nonatomic) id<TAPPickLocationViewControllerDelegate> delegate;
@property (nonatomic) CLLocationCoordinate2D selectedLocationCoordinate;

@end

NS_ASSUME_NONNULL_END
