//
//  TAPPickLocationView.h
//  TapTalk
//
//  Created by Dominic Vedericho on 15/02/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPBaseView.h"
#import <MapKit/MapKit.h>
#import "TAPLocationSearchBarView.h"
#import "TAPCustomButtonView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TAPPickLocationView : TAPBaseView

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) UITableView *searchTableView;
@property (strong, nonatomic) UIView *searchTableViewShadowView;
@property (strong, nonatomic) TAPLocationSearchBarView *searchBarView;
@property (strong, nonatomic) UIButton *goToCurrentLocationButton;
@property (strong, nonatomic) TAPCustomButtonView *sendLocationButton;

- (void)setAsLoading:(BOOL)isLoading;
- (void)setAddress:(NSString *)addressString;

@end

NS_ASSUME_NONNULL_END
