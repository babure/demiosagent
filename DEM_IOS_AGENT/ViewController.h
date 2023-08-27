//
//  ViewController.h
//  DEM_IOS_AGENT
//
//  Created by AppNeura Avekshaa on 25/08/23.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface ViewController : UIViewController
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;


@end

