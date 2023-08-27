//
//  NetworkDetails.m
//  CallRestApi Prectice
//
//  Created by AppNeura Avekshaa on 24/08/23.
//  Copyright © 2023 Shalitha Senanayaka. All rights reserved.
//

#import "NetworkDetails.h"
#import <Foundation/Foundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#include <ifaddrs.h>
#include <net/if.h>

@implementation NetworkDetails

+ (NSDictionary *)fetchNetworkDetails {
    NSMutableDictionary *networkDetails = [NSMutableDictionary dictionary];
    
    // Fetch Network Data Usage
    NSDictionary *dataUsage = [self getDataUsage];
    [networkDetails addEntriesFromDictionary:dataUsage];
    
    return networkDetails;
}

+ (NSDictionary *)getDataUsage {
    struct ifaddrs *ifAddrs;
    struct ifaddrs *current;
    uint32_t bytesIn = 0;
    uint32_t bytesOut = 0;

    if (getifaddrs(&ifAddrs) == 0) {
        current = ifAddrs;
        while (current != NULL) {
            if (current->ifa_addr->sa_family == AF_LINK) {
                struct if_data *ifData = (struct if_data *)current->ifa_data;
                if (strcmp(current->ifa_name, "lo0") != 0) {  // Exclude local loopback interface
                    bytesIn += ifData->ifi_ibytes;
                    bytesOut += ifData->ifi_obytes;
                }
            }
            current = current->ifa_next;
        }
        freeifaddrs(ifAddrs);
    }

    return @{
        @"inbound_data": [NSString stringWithFormat:@"%u", bytesIn],
        @"outbound_data": [NSString stringWithFormat:@"%u", bytesOut]
    };
}

@end

