//
//  SystemInfoHelper.m
//  ActionCamera
//
//  Created by 范桂盛 on 16/5/6.
//  Copyright © 2016年 AC. All rights reserved.
//

#import "SystemInfoHelper.h"
#import "sys/utsname.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <ifaddrs.h>
#import <arpa/inet.h>

@implementation SystemInfoHelper


+ (NSString *)getCurrentWifiName
{
    NSArray *ifs = CFBridgingRelease(CNCopySupportedInterfaces());
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = CFBridgingRelease(CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam));
        if (info && [info count]) {
            break;
        }
    }
    return [info objectForKey:@"SSID"];
}

+(NSString*)getCurrentMacAddress
{
    NSArray *ifs = CFBridgingRelease(CNCopySupportedInterfaces());
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = CFBridgingRelease(CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam));
        if (info && [info count]) {
            break;
        }
    }
    return [info objectForKey:@"BSSID"];
}


+(BOOL)isSportCamera
{
#if TARGET_OS_SIMULATOR
    return YES;
#else
    NSString *macAddress = [self getCurrentMacAddress];
    NSString *wifiName = [self getCurrentWifiName];
    
    //NSLog(@"isSportCamera: MAC:%@, WiFi_name:%@", macAddress, wifiName);
    
    if (macAddress && [[macAddress substringToIndex:7] isEqualToString:@"4:e6:76"]) {
        return YES;
    }
    
    if (!wifiName) {
        //NSLog(@"no wifiName");
        return NO;
    }
    
    if ([wifiName rangeOfString:@"Z13"].location != NSNotFound) {
        return YES;
    }
    
    if ([wifiName rangeOfString:@"YDXJ"].location != NSNotFound && ![wifiName containsString:@"YDXJ_giraffe"]) {
        return YES;
    }
    
    if ([wifiName rangeOfString:@"SportsCamera"].location != NSNotFound) {
        return YES;
    }
    
    return NO;
#endif
}
@end
