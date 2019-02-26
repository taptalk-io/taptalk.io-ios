//
//  TAPPickLocationView.m
//  TapTalk
//
//  Created by Dominic Vedericho on 15/02/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPPickLocationView.h"
#import "TAPPinLocationView.h"

@interface TAPPickLocationView ()

@property (strong, nonatomic) UIView *addressView;
@property (strong, nonatomic) UIView *mapContainerView;
@property (strong, nonatomic) UIImageView *addressIconImageView;
@property (strong, nonatomic) UIImageView *pinIconImageView;
@property (strong, nonatomic) UILabel *addressLabel;
@property (strong, nonatomic) TAPPinLocationView *pinLocationView;

@end

@implementation TAPPickLocationView
#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        CGFloat additionalBottomSpacing = 0.0f;
        if (IS_IPHONE_X_FAMILY) {
            additionalBottomSpacing = [TAPUtil safeAreaBottomPadding];
        }
        
        _addressView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetHeight(frame) - (96.0f + additionalBottomSpacing), CGRectGetWidth(frame), 96.0f + additionalBottomSpacing)];
        self.addressView.backgroundColor = [UIColor whiteColor];
        self.addressView.layer.shadowOffset = CGSizeMake(0.0f, -1.0f);
        self.addressView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.addressView.layer.shadowOpacity = 0.18f;
        [self addSubview:self.addressView];
        
        _addressIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16.0f, 16.0f, 20.0f, 20.0f)];
        self.addressIconImageView.image = [UIImage imageNamed:@"TAPIconLocationLoading" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.addressView addSubview:self.addressIconImageView];
        
        _addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.addressIconImageView.frame) + 8.0f, 16.0f, CGRectGetWidth(self.addressView.frame) - (CGRectGetMaxX(self.addressIconImageView.frame) + 8.0f) - 16.0f, 64.0f)];
        self.addressLabel.font = [UIFont fontWithName:TAP_FONT_LATO_REGULAR size:12.0f];
        self.addressLabel.textColor = [TAPUtil getColor:TAP_COLOR_GREY_AA];
        self.addressLabel.numberOfLines = 0;
        [self.addressView addSubview:self.addressLabel];
        
        _mapContainerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame) - CGRectGetHeight(self.addressView.frame))];
        [self addSubview:self.mapContainerView];
        
        _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.mapContainerView.frame), CGRectGetHeight(self.mapContainerView.frame))];
        [self.mapView setShowsUserLocation:YES];
        [self.mapView setShowsPointsOfInterest:YES];
        [self.mapView setShowsBuildings:YES];
        self.mapView.autoresizingMask = UIViewAutoresizingNone;
        [self.mapContainerView addSubview:self.mapView];
        
        _goToCurrentLocationButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame) - 16.0f - 56.0f, CGRectGetHeight(frame) - CGRectGetHeight(self.addressView.frame) - 16.0f - 56.0f, 56.0f, 56.0f)];
        self.goToCurrentLocationButton.backgroundColor = [UIColor whiteColor];
        self.goToCurrentLocationButton.layer.cornerRadius = CGRectGetHeight(self.goToCurrentLocationButton.frame) / 2.0f;
        self.goToCurrentLocationButton.layer.shadowOffset = CGSizeMake(0.0f, 6.0f);
        self.goToCurrentLocationButton.layer.shadowColor = [UIColor blackColor].CGColor;
        self.goToCurrentLocationButton.layer.shadowRadius = 6.0f;
        self.goToCurrentLocationButton.layer.shadowOpacity = 0.24f;
        [self.goToCurrentLocationButton setImage:[UIImage imageNamed:@"TAPIconGetLocation" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
        [self addSubview:self.goToCurrentLocationButton];
        
        _searchBarView = [[TAPLocationSearchBarView alloc] initWithFrame:CGRectMake(16.0f, 16.0f, CGRectGetWidth(frame) - 16.0f - 16.0f, 36.0f)];
        self.searchBarView.placeholder = NSLocalizedString(@"Search Address", @"");
        self.searchBarView.leftViewImage = [UIImage imageNamed:@"TAPIconSearchBlack" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self.searchBarView setReturnKeyType:UIReturnKeySearch];
        [self addSubview:self.searchBarView];
        
        _pinIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.mapView.frame) - 36.0f) / 2.0f, (CGRectGetHeight(self.mapView.frame) / 2.0f) - 32.0f - 5.0f, 36.0f, 47.0f)]; //32.0 is height of icon without shadow and 5.0f is top shadow of the icon. meanwhile 47 is height of icon with shadow
        self.pinIconImageView.image = [UIImage imageNamed:@"TAPIconLocationSelect" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        [self addSubview:self.pinIconImageView];
        
        _pinLocationView = [[TAPPinLocationView alloc] initWithFrame:CGRectMake((CGRectGetWidth(frame) - 122.0f) / 2.0f, CGRectGetMinY(self.pinIconImageView.frame) - 45.0f, 122.0f, 45.0f)];
        self.pinLocationButton.frame = CGRectMake(CGRectGetMinX(self.pinLocationView.frame), CGRectGetMinY(self.pinLocationView.frame), CGRectGetWidth(self.pinLocationView.frame), CGRectGetHeight(self.pinLocationView.frame) - 15.0f);
        self.pinLocationView.clipsToBounds = YES;
        [self addSubview:self.pinLocationView];
        
        _pinLocationButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.pinLocationView.frame), CGRectGetMinY(self.pinLocationView.frame), CGRectGetWidth(self.pinLocationView.frame), CGRectGetHeight(self.pinLocationView.frame) - 15.0f)];
        self.pinLocationButton.backgroundColor = [UIColor clearColor];
        [self addSubview:self.pinLocationButton];
        
        _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.searchBarView.frame), CGRectGetMaxY(self.searchBarView.frame) + 5.0f, CGRectGetWidth(self.searchBarView.frame), 0.0f)];
        self.searchTableView.showsVerticalScrollIndicator = NO;
        self.searchTableView.showsHorizontalScrollIndicator = NO;
        self.searchTableView.layer.borderColor = [TAPUtil getColor:TAP_COLOR_GREY_E4].CGColor;
        self.searchTableView.layer.borderWidth = 1.0f;
        self.searchTableView.layer.cornerRadius = 10.0f;
        [self.searchTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        _searchTableViewShadowView = [[UIView alloc] initWithFrame:self.searchTableView.frame]; //this is to show shadow of searchTableView
        self.searchTableViewShadowView.backgroundColor = [UIColor whiteColor];
        self.searchTableViewShadowView.layer.cornerRadius = 10.0f;
        self.searchTableViewShadowView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.searchTableViewShadowView.layer.shadowOpacity = 0.1f;
        self.searchTableViewShadowView.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
        self.searchTableViewShadowView.layer.shadowRadius = 12.0f;
        
        [self addSubview:self.searchTableViewShadowView];
        [self addSubview:self.searchTableView];
    }
    
    return self;
}

#pragma mark - Custom Method
- (void)setAsLoading:(BOOL)isLoading {
    if (isLoading) {
        NSString *addressString = NSLocalizedString(@"Searching for address", @"");
        self.addressLabel.text = addressString;
        NSMutableAttributedString *addressAttributedString = [[NSMutableAttributedString alloc] initWithString:self.addressLabel.text];
        NSMutableParagraphStyle *addressLabelStyle = [[NSMutableParagraphStyle alloc] init];
        addressLabelStyle.maximumLineHeight = 16.0f;
        addressLabelStyle.minimumLineHeight = 16.0f;
        [addressAttributedString addAttribute:NSParagraphStyleAttributeName
                                        value:addressLabelStyle
                                        range:NSMakeRange(0, [self.addressLabel.text length])];
        self.addressLabel.attributedText = addressAttributedString;
        self.addressLabel.textColor = [TAPUtil getColor:TAP_COLOR_GREY_AA];
        CGSize addressLabelSize = [self.addressLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.addressLabel.frame), CGFLOAT_MAX)];
        self.addressLabel.frame = CGRectMake(CGRectGetMinX(self.addressLabel.frame), CGRectGetMinY(self.addressLabel.frame), CGRectGetWidth(self.addressLabel.frame), addressLabelSize.height);
        
        self.addressIconImageView.image = [UIImage imageNamed:@"TAPIconLocationLoading" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        
        [UIView animateWithDuration:0.2f animations:^{
            CGRect setLocationViewFrame = self.pinLocationView.frame;
            self.pinLocationView.frame = CGRectMake(CGRectGetWidth(self.frame) / 2.0f, CGRectGetMinY(self.pinIconImageView.frame), 0.0f, 0.0f);
            self.pinLocationView.layer.cornerRadius = CGRectGetHeight(setLocationViewFrame) / 2.0f;
            self.pinLocationButton.frame = self.pinLocationView.frame;
            [self.pinLocationView hideSendLocationView:YES];
        } completion:^(BOOL finished) {
            
        }];
    }
    else {
        self.addressLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
        self.addressIconImageView.image = [UIImage imageNamed:@"TAPIconLocationActive" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
        
        [UIView animateWithDuration:0.2f animations:^{
            self.pinLocationView.frame = CGRectMake((CGRectGetWidth(self.frame) - 122.0f) / 2.0f, CGRectGetMinY(self.pinIconImageView.frame) - 45.0f, 122.0f, 45.0f);
            self.pinLocationView.layer.cornerRadius = 0.0f;
            self.pinLocationButton.frame = CGRectMake(CGRectGetMinX(self.pinLocationView.frame), CGRectGetMinY(self.pinLocationView.frame), CGRectGetWidth(self.pinLocationView.frame), CGRectGetHeight(self.pinLocationView.frame) - 15.0f);
            [self.pinLocationView hideSendLocationView:NO];
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)setAddress:(NSString *)addressString {
    self.addressLabel.textColor = [TAPUtil getColor:TAP_COLOR_BLACK_44];
    self.addressIconImageView.image = [UIImage imageNamed:@"TAPIconLocationActive" inBundle:[TAPUtil currentBundle] compatibleWithTraitCollection:nil];
    
    self.addressLabel.text = addressString;
    NSMutableAttributedString *addressAttributedString = [[NSMutableAttributedString alloc] initWithString:self.addressLabel.text];
    NSMutableParagraphStyle *addressLabelStyle = [[NSMutableParagraphStyle alloc] init];
    addressLabelStyle.maximumLineHeight = 16.0f;
    addressLabelStyle.minimumLineHeight = 16.0f;
    [addressAttributedString addAttribute:NSParagraphStyleAttributeName
                                    value:addressLabelStyle
                                    range:NSMakeRange(0, [self.addressLabel.text length])];
    self.addressLabel.attributedText = addressAttributedString;
    
    CGSize addressLabelSize = [self.addressLabel sizeThatFits:CGSizeMake(CGRectGetWidth(self.addressLabel.frame), CGFLOAT_MAX)];
    CGFloat addressLabelHeight = addressLabelSize.height;
    if (addressLabelHeight > 64.0f) {
        addressLabelHeight = 64.0f;
    }
    self.addressLabel.frame = CGRectMake(CGRectGetMinX(self.addressLabel.frame), CGRectGetMinY(self.addressLabel.frame), CGRectGetWidth(self.addressLabel.frame), addressLabelHeight);
}

@end
