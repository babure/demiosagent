#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject

+ (instancetype)sharedInstance;
- (void)fetchLocationWithCompletion:(void(^)(NSDictionary *locationDetails))completion;

@end
