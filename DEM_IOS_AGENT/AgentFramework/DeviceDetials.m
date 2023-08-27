//
//  DeviceDetials.m
//  CallRestApi Prectice
//
//  Created by AppNeura Avekshaa on 24/08/23.
//  Copyright © 2023 Shalitha Senanayaka. All rights reserved.
//

#import "DeviceDetails.h"
#import <mach/mach.h>
#import <sys/sysctl.h>

@implementation DeviceDetails

+ (NSDictionary *)memoryUsage {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if (kerr == KERN_SUCCESS) {
        return @{
            @"used_memory_bytes": @(info.resident_size),
            @"total_memory_bytes": @(info.virtual_size)
        };
    } else {
        return nil;
    }
}

+ (float)cpuUsage {
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;

    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }

    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;

    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;

    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads

    basic_info = (task_basic_info_t)tinfo;

    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;

    float total_cpu = 0;
    for (int j = 0; j < thread_count; j++) {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO, (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }

        basic_info_th = (thread_basic_info_t)thinfo;

        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            total_cpu += basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
    } // for each thread

    return total_cpu;
}


+ (NSDictionary *)fetchDeviceDetails {
    UIDevice *device = [UIDevice currentDevice];

    NSString *batteryState;
    switch (device.batteryState) {
        case UIDeviceBatteryStateUnknown:
            batteryState = @"Unknown";
            break;
        case UIDeviceBatteryStateUnplugged:
            batteryState = @"Unplugged";
            break;
        case UIDeviceBatteryStateCharging:
            batteryState = @"Charging";
            break;
        case UIDeviceBatteryStateFull:
            batteryState = @"Full";
            break;
        default:
            batteryState = @"N/A";
            break;
    }

    NSString *proximityState = device.proximityState ? @"Near" : @"Far";

    NSString *deviceOrientation;
    switch (device.orientation) {
        case UIDeviceOrientationPortrait:
            deviceOrientation = @"Portrait";
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            deviceOrientation = @"Portrait Upside Down";
            break;
        case UIDeviceOrientationLandscapeLeft:
            deviceOrientation = @"Landscape Left";
            break;
        case UIDeviceOrientationLandscapeRight:
            deviceOrientation = @"Landscape Right";
            break;
        case UIDeviceOrientationFaceUp:
            deviceOrientation = @"Face Up";
            break;
        case UIDeviceOrientationFaceDown:
            deviceOrientation = @"Face Down";
            break;
        case UIDeviceOrientationUnknown:
        default:
            deviceOrientation = @"Unknown";
            break;
    }


    NSString *uiIdiom;
    switch (device.userInterfaceIdiom) {
        case UIUserInterfaceIdiomPhone:
            uiIdiom = @"Phone";
            break;
        case UIUserInterfaceIdiomPad:
            uiIdiom = @"Pad";
            break;
        case UIUserInterfaceIdiomTV:
            uiIdiom = @"TV";
            break;
        case UIUserInterfaceIdiomCarPlay:
            uiIdiom = @"CarPlay";
            break;
        case UIUserInterfaceIdiomMac:
            uiIdiom = @"Mac";
            break;
        default:
            uiIdiom = @"Unknown";
            break;
    }


        NSDictionary *memoryDetails = [self memoryUsage];
    
        float cpu_percent = [self cpuUsage];
    
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
        NSInteger epochTime = (NSInteger)timeInterval*1000;

        NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:@{
            @"device_name": device.name,
            @"device_model": device.model,
            @"localized_model": device.localizedModel,
            @"system_name": device.systemName,
            @"system_version": device.systemVersion,
            @"vendor_id": device.identifierForVendor.UUIDString,
            @"battery_monitoring_nabled": device.isBatteryMonitoringEnabled ? @"YES" : @"NO",
            @"battery_state": batteryState,
            @"battery_level": @(device.batteryLevel),
            @"proximity_monitoring_enabled": device.isProximityMonitoringEnabled?@"YES":@"NO",
            @"proximity_state": proximityState,
            @"device_orientation": deviceOrientation,
            @"multitasking_supported": device.isMultitaskingSupported?@"YES":@"NO",
            @"user_interface_idiom": uiIdiom,
            @"event_time": @(epochTime),
            @"cpu_usage_percentage": @(cpu_percent)
        }];

        [result addEntriesFromDictionary:memoryDetails];

        return result;
}

@end

