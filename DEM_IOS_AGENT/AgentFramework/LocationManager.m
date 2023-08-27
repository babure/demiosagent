#import "LocationManager.h"

@interface LocationManager() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, copy) void (^locationFetchCompletion)(NSDictionary *locationDetails);

@end

@implementation LocationManager

+ (instancetype)sharedInstance {
    static LocationManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[LocationManager alloc] init];
    });
    return sharedInstance;
}

- (void)fetchLocationWithCompletion:(void(^)(NSDictionary *locationDetails))completion {
    self.locationFetchCompletion = completion;
    
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    
    CLAuthorizationStatus status = CLLocationManager.authorizationStatus;
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        if (self.locationFetchCompletion) {
            self.locationFetchCompletion(@{
                @"status": @"denied",
                @"name": @"",
                @"street": @"",
                @"city": @"",
                @"state": @"",
                @"postalCode": @"",
                @"country": @"",
                @"latitude": @"",
                @"longitude": @""
            });
        }
        return;
    }

    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = [locations lastObject];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> *placemarks, NSError *error) {
        if (error) {
            if (self.locationFetchCompletion) {
                self.locationFetchCompletion(@{
                    @"status": @"error",
                    @"name": @"",
                    @"street": @"",
                    @"city": @"",
                    @"state": @"",
                    @"postalCode": @"",
                    @"country": @"",
                    @"latitude": @"",
                    @"longitude": @""
                });
            }
            return;
        }
        
        if (placemarks.count > 0) {
            CLPlacemark *placemark = placemarks.firstObject;
            NSDictionary *details = @{
                @"status": @"accepted",
                @"name": placemark.name ?: @"",
                @"street": placemark.thoroughfare ?: @"",
                @"city": placemark.locality ?: @"",
                @"state": placemark.administrativeArea ?: @"",
                @"postalCode": placemark.postalCode ?: @"",
                @"country": placemark.country ?: @"",
                @"latitude": @(location.coordinate.latitude).stringValue,
                @"longitude": @(location.coordinate.longitude).stringValue
            };
            if (self.locationFetchCompletion) {
                self.locationFetchCompletion(details);
            }
        }
    }];

    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (self.locationFetchCompletion) {
        self.locationFetchCompletion(@{
            @"status": @"error",
            @"name": @"",
            @"street": @"",
            @"city": @"",
            @"state": @"",
            @"postalCode": @"",
            @"country": @"",
            @"latitude": @"",
            @"longitude": @""
        });
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        if (self.locationFetchCompletion) {
            self.locationFetchCompletion(@{
                @"status": @"denied",
                @"name": @"",
                @"street": @"",
                @"city": @"",
                @"state": @"",
                @"postalCode": @"",
                @"country": @"",
                @"latitude": @"",
                @"longitude": @""
            });
        }
    }
}

@end
