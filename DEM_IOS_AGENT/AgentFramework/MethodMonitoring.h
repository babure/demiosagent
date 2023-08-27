#import <Foundation/Foundation.h>

@interface MethodMonitoring : NSObject

+ (instancetype)shared;
- (void)monitorAndExecuteBlock:(void (^)(void))block withIdentifier:(NSString *)identifier;

@end
