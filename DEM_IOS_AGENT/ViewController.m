//
//  ViewController.m
//  DEM_IOS_AGENT
//
//  Created by AppNeura Avekshaa on 25/08/23.
//

#import "ViewController.h"
#import "LocationManager.h"
#import "MethodMonitoring.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[MethodMonitoring shared] monitorAndExecuteBlock:^{

    [[LocationManager sharedInstance] fetchLocationWithCompletion:^(NSDictionary *locationDetails) {
        // Here you will receive the location details or error/denial status
        NSString *status = locationDetails[@"status"];
        if ([status isEqualToString:@"accepted"]) {
            NSLog(@"Location Details: %@", locationDetails);
        } else if ([status isEqualToString:@"denied"]) {
            NSLog(@"Location access denied.");
        } else if ([status isEqualToString:@"error"]) {
            NSLog(@"An error occurred while fetching location.");
        }
    }];
        
    } withIdentifier:@"ViewOnload"];

    
}


- (IBAction)crashTheApp:(id)sender {
    [[MethodMonitoring shared] monitorAndExecuteBlock:^{
        // Any method or code you want to monitor
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURL *url = [NSURL URLWithString:@"https://api.openbrewerydb.org/breweries?by_name=cooper"];
        
        // Asynchronously API is hit here
        NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                    //NSLog(@"%@",data);
                                                    if (error)
                                                        NSLog(@"");
                                                    else {
                                                        NSMutableArray *json  = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                                                        NSLog(@"");
                                             }
                                                }];
        [dataTask resume];    // Executed First

        // Continue executing any further code after the pause
//        NSArray *array = @[@1, @2, @3];
//        NSLog(@"%@", array[3]);  // Intentional index out-of-range for demonstration purposes
    } withIdentifier:@"crashTheApp"];
}




@end
