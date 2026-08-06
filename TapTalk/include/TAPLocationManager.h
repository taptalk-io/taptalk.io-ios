//
//  TAPLocationManager.h
//  TapTalk
//
//  Created by Dominic Vedericho on 20/02/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

static  NSString * const kLocationManagerAuthorizationStatusChangedNotificationKey = @"notification.locationManagerAuthorizationStatusChanged";
static  NSString * const kLocationManagerDidGetLocationForFirstTimeNotificationKey = @"notification.locationManagerDidGetLocationForFirstTime";
static  NSString * const kLocationManagerDidUpdateLocationNotificationKey = @"notification.locationManagerDidUpdateLocation";

@interface TAPLocationManager : NSObject

@property (nonatomic) CLLocationCoordinate2D userCoordinate;

+ (TAPLocationManager *)sharedManager;
+ (CLAuthorizationStatus)authorizationStatus;
- (void)requestAuthorization;

@end

NS_ASSUME_NONNULL_END
