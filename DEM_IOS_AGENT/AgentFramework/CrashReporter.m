//
//  CrashReporting.m
//  CallRestApi Prectice
//
//  Created by AppNeura Avekshaa on 24/08/23.
//  Copyright © 2023 Shalitha Senanayaka. All rights reserved.
//

#import "CrashReporter.h"
#include <signal.h>
#include <execinfo.h>
#import "DeviceDetails.h"
#import "LocationManager.h"
#import "NetworkDetails.h"



@implementation CrashReporter

void customSignalHandler(int signal, siginfo_t *info, void *context) {
    NSMutableString *crashString = [NSMutableString string];
    [crashString appendFormat:@"Signal: %d\n", signal];
    
    NSLog(@"Crash Detected: %@", crashString);


    void *callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    for (int i = 0; i < frames; i++) {
        [crashString appendFormat:@"%s\n", strs[i]];
    }
    free(strs);

    // TODO: Save or send the crash report here

    exit(1);
}

void uncaughtExceptionHandler(NSException *exception) {
    NSString *reason = [exception reason];
    NSArray *callStack = [exception callStackSymbols];

    NSDictionary *deviceDetails = [DeviceDetails fetchDeviceDetails];
    //NSDictionary *locationDetails = [LocationManager fetchUserLocationDetails];
    NSDictionary *networkDetails = [NetworkDetails fetchNetworkDetails];

    NSMutableDictionary *crashReport = [NSMutableDictionary dictionaryWithDictionary:deviceDetails];
    [crashReport setObject:reason forKey:@"Reason"];
    [crashReport setObject:callStack forKey:@"CallStack"];
    //[crashReport setObject:locationDetails forKey:@"address"];
    [crashReport setObject:networkDetails forKey:@"network"];
    [crashReport setObject:@"crashData" forKey:@"metric"];

    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:crashReport options:NSJSONWritingPrettyPrinted error:&error];

    if (!jsonData) {
        NSLog(@"Error converting crash report to JSON: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"Exception Detected: %@", jsonString);
    }
    exit(1);
}





+ (void)installCrashReporter {
    struct sigaction action;
    action.sa_sigaction = &customSignalHandler;
    action.sa_flags = SA_SIGINFO;

    // SIGSEGV (Segmentation Fault)
    //  Occurs when a process tries to access an invalid memory location or memory it doesn't have permission to access.
    sigaction(SIGSEGV, &action, NULL);

    // SIGILL (Illegal Instruction)
    //  Sent when a process tries to execute an illegal, unrecognized, or invalid instruction.
    sigaction(SIGILL, &action, NULL);

    // SIGABRT (Abort)
    //  Usually sent when an application encounters an internal inconsistency or assertion violation. Often triggered by calling the `abort()` function.
    sigaction(SIGABRT, &action, NULL);

    // SIGFPE (Floating Point Exception)
    //  Generated when a floating-point arithmetic exception occurs, such as division by zero or an overflow/underflow condition.
    sigaction(SIGFPE, &action, NULL);

    // SIGBUS (Bus Error)
    //  Sent when a process tries to access a memory location that cannot be accessed, typically due to hardware-related issues.
    sigaction(SIGBUS, &action, NULL);

    // SIGTRAP (Trap)
    //  Used by debuggers to break into the program, allowing debugging operations.
    sigaction(SIGTRAP, &action, NULL);

    // SIGSYS (Bad System Call)
    //  Sent when a process makes an invalid or unsupported system call.
    sigaction(SIGSYS, &action, NULL);

    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
}


@end
