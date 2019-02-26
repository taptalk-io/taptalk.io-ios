//
//  TAPLocationManager.m
//  TapTalk
//
//  Created by Dominic Vedericho on 20/02/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPLocationManager.h"

@interface TAPLocationManager () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSArray *regionArray;

@end

@implementation TAPLocationManager

#pragma mark - Lifecycle
+ (TAPLocationManager *)sharedManager {
    static TAPLocationManager *sharedLocationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLocationManager = [[self alloc] init];
    });
    return sharedLocationManager;
}

- (id)init {
    self = [super init];
    
    if(self) {
        _locationManager = [[CLLocationManager alloc] init];
        [self.locationManager setDelegate:self];
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [self.locationManager setPausesLocationUpdatesAutomatically:YES];
        
        [self.locationManager startUpdatingLocation];
    }
    
    return self;
}

#pragma mark - Delegate
#pragma mark CLLocationManager
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CGFloat lastLongitude = self.userCoordinate.longitude;
    CGFloat lastLatitude = self.userCoordinate.latitude;
    
    _userCoordinate = [locations lastObject].coordinate;
    
    if(floor(lastLongitude) == 0.0f && floor(lastLatitude) == 0.0f) {
        CGFloat currentLongitude = self.userCoordinate.longitude;
        CGFloat currentLatitude = self.userCoordinate.latitude;
        
        if(floor(currentLongitude) != 0.0f || floor(currentLatitude) != 0.0f) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerDidGetLocationForFirstTimeNotificationKey object:nil];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerDidUpdateLocationNotificationKey object:nil];
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if(status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationManagerAuthorizationStatusChangedNotificationKey object:nil];
}

#pragma mark - Custom Method
- (void)requestAuthorization {
    if([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

+ (CLAuthorizationStatus)authorizationStatus {
    return [CLLocationManager authorizationStatus];
}

@end

