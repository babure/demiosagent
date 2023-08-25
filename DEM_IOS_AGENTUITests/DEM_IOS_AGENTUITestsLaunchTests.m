//
//  DEM_IOS_AGENTUITestsLaunchTests.m
//  DEM_IOS_AGENTUITests
//
//  Created by AppNeura Avekshaa on 25/08/23.
//

#import <XCTest/XCTest.h>

@interface DEM_IOS_AGENTUITestsLaunchTests : XCTestCase

@end

@implementation DEM_IOS_AGENTUITestsLaunchTests

+ (BOOL)runsForEachTargetApplicationUIConfiguration {
    return YES;
}

- (void)setUp {
    self.continueAfterFailure = NO;
}

- (void)testLaunch {
    XCUIApplication *app = [[XCUIApplication alloc] init];
    [app launch];

    // Insert steps here to perform after app launch but before taking a screenshot,
    // such as logging into a test account or navigating somewhere in the app

    XCTAttachment *attachment = [XCTAttachment attachmentWithScreenshot:XCUIScreen.mainScreen.screenshot];
    attachment.name = @"Launch Screen";
    attachment.lifetime = XCTAttachmentLifetimeKeepAlways;
    [self addAttachment:attachment];
}

@end
