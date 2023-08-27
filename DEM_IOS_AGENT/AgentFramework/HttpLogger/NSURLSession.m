#import "NSURLSession.h"

static NSString *const NetworkMonitorHandledKey = @"NetworkMonitorHandledKey";

@interface NetworkMonitorProtocol () <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSDate *requestStartTime;

@end

@implementation NetworkMonitorProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if ([NSURLProtocol propertyForKey:NetworkMonitorHandledKey inRequest:request]) {
        return NO;
    }
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    self.requestStartTime = [NSDate date];
    NSLog(@"Request URL: %@", self.request.URL.absoluteString);

    NSMutableURLRequest *mutableRequest = [self.request mutableCopy];
    [NSURLProtocol setProperty:@(YES) forKey:NetworkMonitorHandledKey inRequest:mutableRequest];

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    self.dataTask = [session dataTaskWithRequest:mutableRequest];
    [self.dataTask resume];
}

- (void)stopLoading {
    self.dataTask = nil;
    self.requestStartTime = nil;
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSDate *requestEndTime = [NSDate date];
    NSTimeInterval responseTimeSeconds = [requestEndTime timeIntervalSinceDate:self.requestStartTime];
    NSInteger responseTimeMilliseconds = responseTimeSeconds * 1000;
    NSInteger startTimeEpochMilliseconds = self.requestStartTime.timeIntervalSince1970 * 1000;
    NSInteger endTimeEpochMilliseconds = requestEndTime.timeIntervalSince1970 * 1000;

    if (error) {
        NSLog(@"Request to %@ failed with error: %@, Response Time: %ld ms, Start Time: %ld GMT epoch, End Time: %ld GMT epoch",
              self.request.URL.absoluteString,
              error.localizedDescription,
              (long)responseTimeMilliseconds,
              (long)startTimeEpochMilliseconds,
              (long)endTimeEpochMilliseconds);
    } else {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        NSLog(@"Request to %@ finished with status code: %ld, Response Time: %ld ms, Start Time: %ld GMT epoch, End Time: %ld GMT epoch",
              self.request.URL.absoluteString,
              (long)response.statusCode,
              (long)responseTimeMilliseconds,
              (long)startTimeEpochMilliseconds,
              (long)endTimeEpochMilliseconds);
    }

    [self.client URLProtocol:self didFailWithError:error];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    completionHandler(NSURLSessionResponseAllow);
}

@end
