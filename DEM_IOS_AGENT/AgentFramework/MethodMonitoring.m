#import "MethodMonitoring.h"
#import "DeviceDetails.h"

@implementation MethodMonitoring

+ (instancetype)shared {
    static MethodMonitoring *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MethodMonitoring alloc] init];
    });
    return sharedInstance;
}

- (void)monitorAndExecuteBlock:(void (^)(void))block withIdentifier:(NSString *)identifier {
    NSTimeInterval startTime = [NSDate date].timeIntervalSince1970;
    
    block();  // Execute the provided block
    
    NSTimeInterval endTime = [NSDate date].timeIntervalSince1970;
    NSTimeInterval duration = endTime - startTime;
    
    NSDictionary *deviceDetails = [DeviceDetails fetchDeviceDetails];
    NSLog(@"Device details %@",deviceDetails);
    NSLog(@"Method with identifier: %@ took %f ms to execute.", identifier, duration*1000);
}

@end
