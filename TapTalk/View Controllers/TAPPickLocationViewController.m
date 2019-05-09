//
//  TAPPickLocationViewController.m
//  TapTalk
//
//  Created by Dominic Vedericho on 15/02/19.
//  Copyright © 2019 Moselo. All rights reserved.
//

#import "TAPPickLocationViewController.h"
#import "TAPPickLocationView.h"
#import "TAPPinLocationSearchResultTableViewCell.h"
#import <MapKit/MapKit.h>

@import GooglePlaces;
@import GoogleMaps;

@interface TAPPickLocationViewController () <TAPLocationSearchBarViewDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (strong, nonatomic) TAPPickLocationView *pickLocationView;

@property (strong, nonatomic) NSMutableArray *searchResultArray;
@property (strong, nonatomic) NSString *searchKeyword;
@property (strong, nonatomic) NSString *selectedLocationAddress;
@property (strong, nonatomic) NSString *selectedPostalCode;
@property (nonatomic) CLLocationCoordinate2D firstCoordinate;
@property (nonatomic) BOOL updatedLocationFirstTime;
@property (nonatomic) BOOL isFirstLoad;
@property (nonatomic) BOOL hideSearchResult;

//Custom method
- (void)locationAuthorizationStatusChanged;
- (void)checkLocationPermission;
- (void)centerMapToUserLocation;
- (void)centerMapToLocationWithLatitude:(CGFloat)latitude Longitude:(CGFloat)longitude Radius:(NSInteger)radiusInMeters;
- (void)didUpdateLocation;
- (void)goToCurrentLocation;
- (void)searchLocationByKeyword;
- (void)cancelButtonDidTapped;

@end

@implementation TAPPickLocationViewController
#pragma mark - Lifecycle
- (void)loadView {
    [super loadView];
    self.title = NSLocalizedString(@"Send Location", @"");
    
    _pickLocationView = [[TAPPickLocationView alloc] initWithFrame:[TAPBaseView frameWithNavigationBar]];
    [self.view addSubview:self.pickLocationView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    UIButton *leftBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 51.0f, 40.0f)];
    [leftBarButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [leftBarButton setTitleColor:[TAPUtil getColor:TAP_COLOR_PRIMARY_COLOR_1] forState:UIControlStateNormal];
    leftBarButton.contentEdgeInsets  = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    leftBarButton.titleLabel.font = [UIFont fontWithName:TAP_FONT_NAME_REGULAR size:17.0f];
    [leftBarButton addTarget:self action:@selector(cancelButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
    [self.navigationItem setLeftBarButtonItem:leftBarButtonItem];
    
    self.pickLocationView.mapView.delegate = self;
    self.pickLocationView.searchTableView.delegate = self;
    
    [self.pickLocationView.goToCurrentLocationButton addTarget:self action:@selector(goToCurrentLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.pickLocationView.pinLocationButton addTarget:self action:@selector(setLocationButtonDidTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self.pickLocationView setAsLoading:YES];
    _searchResultArray = [NSMutableArray array];
    _searchKeyword = @"";
    _updatedLocationFirstTime = NO;
    _isFirstLoad = YES;
    _hideSearchResult = NO;
    
    self.pickLocationView.searchTableView.dataSource = self;
    self.pickLocationView.searchTableView.delegate = self;
    self.pickLocationView.searchBarView.delegate = self;

    [self goToCurrentLocation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationAuthorizationStatusChanged) name:kLocationManagerAuthorizationStatusChangedNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateLocation) name:kLocationManagerDidUpdateLocationNotificationKey object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLocationManagerAuthorizationStatusChangedNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLocationManagerDidUpdateLocationNotificationKey object:nil];
}

#pragma mark - Data Source
#pragma mark TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.searchResultArray count] > 5) {
        return 5;
    }
    
    return [self.searchResultArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 36.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *cellID = @"TAPPinLocationSearchResultTableViewCell";
        TAPPinLocationSearchResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        
        if(nil == cell) {
            cell = [[TAPPinLocationSearchResultTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                                  reuseIdentifier:cellID];
        }
        
        GMSAutocompletePrediction *prediction = [self.searchResultArray objectAtIndex:indexPath.row];
        NSString *addressString = prediction.attributedFullText.string;
        
        [cell setSearchResult:addressString];
        
        [cell hideSeparatorView:NO];
        if ([self.searchResultArray count] > 5) {
            if (indexPath.row == 4) {
                [cell hideSeparatorView:YES];
            }
        }
        else {
            if (indexPath.row == [self.searchResultArray count] - 1) {
                [cell hideSeparatorView:YES];
            }
        }
        
        return cell;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] init];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footer = [[UIView alloc] init];
    return footer;
}

#pragma mark - Delegate
#pragma mark TableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    _hideSearchResult = YES;
    
    if (indexPath.row <= [self.searchResultArray count] - 1) {
        GMSAutocompletePrediction *prediction = [self.searchResultArray objectAtIndex:indexPath.row];
        
        
        NSString *placeName = prediction.attributedPrimaryText.string;
        self.pickLocationView.searchBarView.text = placeName;
        _searchKeyword = placeName;
        
        [self searchLocationByKeyword];
        [self.view endEditing:YES];
        
        [[GMSPlacesClient sharedClient]lookUpPlaceID:prediction.placeID callback:^(GMSPlace * _Nullable result, NSError * _Nullable error) {
            [self centerMapToLocationWithLatitude:result.coordinate.latitude Longitude:result.coordinate.longitude Radius:1000];
        }];
    }
}

#pragma mark MoseloSearchBarView
- (void)searchBarViewAfterClearTextField {
    [self.pickLocationView.searchBarView becomeFirstResponder];
    
    _searchResultArray = [NSMutableArray array];
    [UIView animateWithDuration:0.2f animations:^{
        self.pickLocationView.searchTableView.frame = CGRectMake(CGRectGetMinX(self.pickLocationView.searchTableView.frame), CGRectGetMinY(self.pickLocationView.searchTableView.frame), CGRectGetWidth(self.pickLocationView.searchTableView.frame), 0.0f);
        self.pickLocationView.searchTableViewShadowView.frame = self.pickLocationView.searchTableView.frame;
    } completion:^(BOOL finished) {
        [self.pickLocationView.searchTableView reloadData];
    }];
}

- (BOOL)searchBarViewTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    _searchKeyword = newText;
    
    [UIView animateWithDuration:0.2f animations:^{
        self.pickLocationView.searchTableView.frame = CGRectMake(CGRectGetMinX(self.pickLocationView.searchTableView.frame), CGRectGetMinY(self.pickLocationView.searchTableView.frame), CGRectGetWidth(self.pickLocationView.searchTableView.frame), 0.0f);
        self.pickLocationView.searchTableViewShadowView.frame = self.pickLocationView.searchTableView.frame;
    } completion:^(BOOL finished) {
        [self.pickLocationView.searchTableView reloadData];
    }];
    
    if (![newText isEqualToString:@""]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(searchLocationByKeyword) object:nil];
        [self performSelector:@selector(searchLocationByKeyword) withObject:nil afterDelay:0.3];
    }
    
    return YES;
}

- (BOOL)searchBarViewTextFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    
    return YES;
}

- (BOOL)searchBarViewTextFieldShouldEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.2f animations:^{
        self.pickLocationView.searchTableView.frame = CGRectMake(CGRectGetMinX(self.pickLocationView.searchTableView.frame), CGRectGetMinY(self.pickLocationView.searchTableView.frame), CGRectGetWidth(self.pickLocationView.searchTableView.frame), 0.0f);
        self.pickLocationView.searchTableViewShadowView.frame = self.pickLocationView.searchTableView.frame;
    } completion:^(BOOL finished) {
        [self.pickLocationView.searchTableView reloadData];
    }];
    
    return YES;
}

- (BOOL)searchBarViewTextFieldShouldBeginEditing:(UITextField *)textField {
    CGFloat heightCounter = 0.0f;
    if ([self.searchResultArray count] > 3) {
        heightCounter = 3.5f;
    }
    else {
        heightCounter = [self.searchResultArray count];
    }
    
    [self.pickLocationView.searchTableView reloadData];
    [UIView animateWithDuration:0.2f animations:^{
        self.pickLocationView.searchTableView.frame = CGRectMake(CGRectGetMinX(self.pickLocationView.searchTableView.frame), CGRectGetMinY(self.pickLocationView.searchTableView.frame), CGRectGetWidth(self.pickLocationView.searchTableView.frame), 36.0f * heightCounter);
        self.pickLocationView.searchTableViewShadowView.frame = self.pickLocationView.searchTableView.frame;
    } completion:^(BOOL finished) {
        
    }];
    
    return YES;
}

#pragma mark MKMapView
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    [self.view endEditing:YES];
    [self.pickLocationView setAsLoading:YES];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self.view endEditing:YES];
    CLLocationCoordinate2D center = [mapView centerCoordinate];
    [self.pickLocationView setAsLoading:YES];
    
     
    
    [[GMSGeocoder geocoder] reverseGeocodeCoordinate:center completionHandler:
     ^(GMSReverseGeocodeResponse *response, NSError *error){
         if ([[response.firstResult valueForKey:@"lines"] objectAtIndex:0]) {
             NSString *currentLocation = [NSString stringWithFormat:@"%@", [[response.firstResult valueForKey:@"lines"] objectAtIndex:0]];
             NSString *currentPostalCode = [NSString stringWithFormat:@"%@", [response.firstResult valueForKey:@"postalCode"]];
             
             if(![currentLocation isEqualToString:@""]) {
                 _selectedLocationCoordinate = center;
                 _selectedLocationAddress = currentLocation;
                 _selectedPostalCode = currentPostalCode;
                 [self.pickLocationView setAsLoading:NO];
                 [self.pickLocationView setAddress:currentLocation];
             }
             else {
                 //Location not found
                 [self.pickLocationView setAsLoading:YES];
                 [self.pickLocationView setAddress:NSLocalizedString(@"Location not found", @"")];
             }
         }
         else {
             //Location not found
             [self.pickLocationView setAsLoading:YES];
             [self.pickLocationView setAddress:NSLocalizedString(@"Location not found", @"")];
         }
     }];
    
}

#pragma mark - LocationManager Method
- (void)locationAuthorizationStatusChanged {
    if([TAPLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [TAPLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted ) {
    }
    else {
        [self performSelector:@selector(centerMapToUserLocation) withObject:nil afterDelay:0.3f];
//        [self centerMapToUserLocation];
    }
}

- (void)didUpdateLocation {
    
}

#pragma mark - Custom Method
- (void)checkLocationPermission {
    if([TAPLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [TAPLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Location Disabled", @"") message:NSLocalizedString(@"Please allow Location Services to Continue", @"") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Go to Settings", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if (url != nil) {
                if(IS_IOS_10_OR_ABOVE) {
                    [[UIApplication sharedApplication] openURL:url options:[NSDictionary dictionary] completionHandler:nil];
                }
                else {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else if ([TAPLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [[TAPLocationManager sharedManager] requestAuthorization];
    }
}

- (void)centerMapToUserLocation {
    NSInteger radiusInMeters = 1000;
    
    if([TAPLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [TAPLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted || [TAPLocationManager authorizationStatus] ==  kCLAuthorizationStatusNotDetermined) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(-6.175392, 106.827153); //location in Monas
        [self centerMapToLocationWithLatitude:coordinate.latitude Longitude:coordinate.longitude Radius:radiusInMeters];
    }
    else {
        CLLocationCoordinate2D coordinate = [TAPLocationManager sharedManager].userCoordinate;
        [self centerMapToLocationWithLatitude:coordinate.latitude Longitude:coordinate.longitude Radius:radiusInMeters];
    }
}

- (void)centerMapToLocationWithLatitude:(CGFloat)latitude Longitude:(CGFloat)longitude Radius:(NSInteger)radiusInMeters {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(coordinate, radiusInMeters, radiusInMeters);
    
    [self.pickLocationView.mapView setRegion:mapRegion animated:YES];
}

- (void)goToCurrentLocation {
    _firstCoordinate = [TAPLocationManager sharedManager].userCoordinate;
    if([TAPLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [TAPLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted || [TAPLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        if (self.isFirstLoad) {
            _isFirstLoad = NO;
            if (self.selectedLocationCoordinate.latitude == -999 && self.selectedLocationCoordinate.longitude == -999) {
                [self centerMapToUserLocation];
            }
            else {
                [self centerMapToLocationWithLatitude:self.selectedLocationCoordinate.latitude Longitude:self.selectedLocationCoordinate.longitude Radius:1000];
            }
        }
        else {
            [self checkLocationPermission];
        }
    }
    else {
        if (self.isFirstLoad) {
            _isFirstLoad = NO;
            if (self.selectedLocationCoordinate.latitude == -999 && self.selectedLocationCoordinate.longitude == -999) {
                [self centerMapToUserLocation];
            }
            else {
                [self centerMapToLocationWithLatitude:self.selectedLocationCoordinate.latitude Longitude:self.selectedLocationCoordinate.longitude Radius:1000];
            }
        }
        else {
            [self centerMapToUserLocation];
        }
    }
}

- (void)searchLocationByKeyword {
    NSString *keyword = self.searchKeyword;
    _searchResultArray = [NSMutableArray array];
    
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:CLLocationCoordinate2DMake(-90.0, 90.0) coordinate:CLLocationCoordinate2DMake(-180.0, 180.0)];
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.country = @"ID";
    
    if ([keyword length] > 1) {
        [[GMSPlacesClient sharedClient] autocompleteQuery:keyword bounds:bounds filter:filter callback:^(NSArray *result, NSError *error) {
            _searchResultArray = [result mutableCopy];
            CGFloat heightCounter = 0.0f;
            if ([self.searchResultArray count] > 3) {
                heightCounter = 3.5f;
            }
            else {
                heightCounter = [self.searchResultArray count];
            }
            
            if (self.hideSearchResult) {
                _hideSearchResult = NO;
                [UIView animateWithDuration:0.2f animations:^{
                    self.pickLocationView.searchTableView.frame = CGRectMake(CGRectGetMinX(self.pickLocationView.searchTableView.frame), CGRectGetMinY(self.pickLocationView.searchTableView.frame), CGRectGetWidth(self.pickLocationView.searchTableView.frame), 0.0f);
                    self.pickLocationView.searchTableViewShadowView.frame = self.pickLocationView.searchTableView.frame;
                } completion:^(BOOL finished) {
                    [self.pickLocationView.searchTableView reloadData];
                    
                    
                }];
            }
            else {
                [self.pickLocationView.searchTableView reloadData];
                [UIView animateWithDuration:0.2f animations:^{
                    self.pickLocationView.searchTableView.frame = CGRectMake(CGRectGetMinX(self.pickLocationView.searchTableView.frame), CGRectGetMinY(self.pickLocationView.searchTableView.frame), CGRectGetWidth(self.pickLocationView.searchTableView.frame), 36.0f * heightCounter);
                    self.pickLocationView.searchTableViewShadowView.frame = self.pickLocationView.searchTableView.frame;
                } completion:^(BOOL finished) {
                    if (YES) {
                        [self.pickLocationView.searchBarView becomeFirstResponder];
                    }
                }];
            }
        }];
    }
}

- (void)setLocationButtonDidTapped {
#ifdef DEBUG
    NSLog(@"===== PICK LOCATION =====");
    NSLog(@"===== lat: %lf, long: %lf =====", self.selectedLocationCoordinate.latitude, self.selectedLocationCoordinate.longitude);
    NSLog(@"===== address: %@ =====", self.selectedLocationAddress);
    NSLog(@"===== postal code: %@ =====", self.selectedPostalCode);
#endif
    
    if ([self.delegate respondsToSelector:@selector(pickLocationViewControllerSetLocationWithLatitude:longitude:address:postalCode:)]) {
        [self.delegate pickLocationViewControllerSetLocationWithLatitude:self.selectedLocationCoordinate.latitude longitude:self.selectedLocationCoordinate.longitude address:self.selectedLocationAddress postalCode:self.selectedPostalCode];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelButtonDidTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
