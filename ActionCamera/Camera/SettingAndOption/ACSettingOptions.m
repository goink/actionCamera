//
//  ACSettingOptions.m
//  ActionCamera
//
//  Created by Guisheng on 16/1/20.
//  Copyright © 2016年 AC. All rights reserved.
//

#import "ACSettingOptions.h"
#import <objc/runtime.h>
#import "CameraHAM.h"

@interface ACSettingOptions () <NSCopying>
@property (strong, nonatomic) NSMutableDictionary *properties;
@end

@implementation ACSettingOptions
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    
    self.video_stamp                    = [NSArray arrayWithObjects:@"off", @"date", @"time", @"date/time", nil];
    self.timelapse_video                = [NSArray arrayWithObjects:@"0.5", @"1", @"2", @"5", @"10", @"30", @"60", nil];//延时摄像时间间隔,second
    self.timelapse_video_duration       = [NSArray arrayWithObjects:@"off", @"6s", @"8s", @"10s", @"20s", @"30s", @"60s", @"120s",nil];//延时摄像拍摄视频长度
    self.video_photo                    = [NSArray arrayWithObjects:@"5", @"10", @"30", @"60",nil];
    self.video_quality                  = [NSArray arrayWithObjects:@"S.Fine", @"Fine", @"Normal", nil];
    self.photo_stamp                    = [NSArray arrayWithObjects:@"off", @"date", @"time", @"date/time", nil];
    self.video_standard                 = [NSArray arrayWithObjects:@"NTSC", @"PAL", nil];
    self.meter_mode                     = nil;//[NSArray arrayWithObjects:@"center", @"spot", nil];
    self.buzzer_volume                  = [NSArray arrayWithObjects:@"high", @"low", @"mute", nil];
    self.precise_cont_time              = [NSArray arrayWithObjects:@"0.5 sec", @"1.0 sec", @"2.0 sec", @"5.0 sec", @"10.0 sec", @"30.0 sec", @"60.0 sec", nil];
    self.precise_selftime               = [NSArray arrayWithObjects:@"3s",@"5s",@"10s",@"15s", nil];
    self.video_output_dev_type          = [NSArray arrayWithObjects:@"hdmi", @"tv", @"off", nil];
    self.led_mode                       = [NSArray arrayWithObjects:@"all enable", @"all disable", @"status enable", nil];
    self.auto_power_off                 = [NSArray arrayWithObjects:@"off", @"3 minutes", @"5 minutes", @"10 minutes", nil];
    self.auto_low_light                 = [NSArray arrayWithObjects:@"on", @"off", nil];
    self.loop_record                    = [NSArray arrayWithObjects:@"on", @"off", nil];
    self.warp_enable                    = [NSArray arrayWithObjects:@"on", @"off", nil];
    self.preview_status                 = [NSArray arrayWithObjects:@"on", @"off", nil];
    self.buzzer_ring                    = [NSArray arrayWithObjects:@"on", @"off", nil];
    self.start_wifi_while_booted        = [NSArray arrayWithObjects:@"on", @"off", nil];
    self.video_output_status            = [NSArray arrayWithObjects:@"on", @"off", nil];
    self.video_rotate                   = [NSArray arrayWithObjects:@"on", @"off", nil];
    self.emergency_file_backup          = [NSArray arrayWithObjects:@"on", @"off", nil];
    self.restore_factory_settings       = [NSArray arrayWithObjects:@"on", @"off", nil];
    self.btc_delete_all_binded_dev      = [NSArray arrayWithObjects:@"on", @"off", nil];
    self.camera_save_log                = [NSArray arrayWithObjects:@"on", @"off", nil];
    
    self.protune                        = [NSArray arrayWithObjects:@"on", @"off", nil];
    self.iq_eis_enable                  = [NSArray arrayWithObjects:@"on", @"off", nil];
    self.iq_video_ev                    = [NSArray arrayWithObjects:@"-2.0", @"-1.5", @"-1.0", @"-0.5", @"0", @"+0.5", @"+1.0", @"+1.5", @"+2.0", nil];
    self.iq_video_iso                   = [NSArray arrayWithObjects:@"auto", @"400", @"1600", @"6400", nil];
    self.iq_video_wb                    = [NSArray arrayWithObjects:@"auto", @"native", @"3000k", @"5500k", @"6500k", nil];
    self.iq_photo_ev                    = [NSArray arrayWithObjects:@"-2.0", @"-1.5", @"-1.0", @"-0.5", @"0", @"+0.5", @"+1.0", @"+1.5", @"+2.0", nil];
    self.iq_photo_iso                   = [NSArray arrayWithObjects:@"auto", @"100", @"200", @"400", @"800", nil];
    self.iq_photo_wb                    = [NSArray arrayWithObjects:@"auto", @"native", @"3000k", @"5500k", @"6500k", nil];
    self.iq_photo_shutter               = [NSArray arrayWithObjects:@"auto", @"2s", @"5s", @"10s", @"20s", @"30s", nil];

    self.slow_motion_rate               = [NSArray arrayWithObjects:@"2", @"4", @"8", nil];
    self.slow_motion_resolution         = [NSArray arrayWithObjects:@"1280x720 60P 16:9", @"1280x720 120P 16:9", @"1280x720 240P 16:9",nil];
    self.slow_motion_resolution_pal     = [NSArray arrayWithObjects:@"1280x720 50P 16:9", @"1280x720 100P 16:9", @"1280x720 200P 16:9",nil];

    self.record_photo_time              = [NSArray arrayWithObjects:@"5",@"10",@"30",@"60", nil];//second
    self.loop_rec_duration              = [NSArray arrayWithObjects:@"5 minutes", @"20 minutes", @"60 minutes", @"120 minutes", @"max", nil];

    //在startSession回调中会根据相机型号重新初始化，此处初始化被忽略
    self.default_record_mode            = [NSArray arrayWithObjects:@"record", @"record_timelapse", @"record_slow_motion", @"record_loop", @"record_photo", nil];
    self.capture_default_mode           = [NSArray arrayWithObjects:@"precise quality", @"precise quality cont.", @"precise self quality", @"burst quality", nil];
    self.system_default_mode            = [NSArray arrayWithObjects:@"capture", @"record", nil];
    
    self.burst_capture_number           = nil;
    
    self.video_photo_resolution         = nil;
    
    self.photo_size                     = nil;
    self.timelapse_video_resolution     = nil;
    self.timelapse_video_resolution_pal = nil;
    self.video_resolution               = nil;
    
    return self;
}

- (NSArray *)slow_motion_resolution
{
    if ([[CameraHAM shared] isVideoStandardNTSC]) {
        return _slow_motion_resolution;
    } else {
        return _slow_motion_resolution_pal;
    }
}

- (NSArray *)meter_mode
{
    if ([CameraHAM shared].isZ16) {
        return [NSArray arrayWithObjects:@"center", @"spot", nil];
    } else {
        return [NSArray arrayWithObjects:@"center", @"spot", @"average", nil];
    }
}
- (void)setValue:(NSString *)name withOptions:(NSArray *)options
{
    if (!name || !options) {
        NSLog(@"name or option is null");
        return;
    }
    
    if ([self containsOf:name]) {
        [self setValue:options forKey:name];
    }
    else {
        NSLog(@"%@ not defined.", name);
    }
}

- (BOOL)containsOf:(NSString *)key
{
    if (!key) return NO;
    
    if (self.properties) {
        if (_properties[key]) {
            return YES;
        }
    }
    return NO;
}

- (NSMutableDictionary *)properties
{
    if (!_properties) {
        
        _properties = [NSMutableDictionary dictionary];
        
        unsigned int count = 0;
        Ivar *ivars = class_copyIvarList([self class], &count);
        NSString *ivarName;
        
        for (int i = 0; i < count; i++) {
            ivarName = [[NSString stringWithUTF8String:ivar_getName(ivars[i])] substringFromIndex:1];
            if ([ivarName isEqualToString:@"properties"]) continue;
            _properties[ivarName] = ivarName;
        }
        
    }
    return _properties;
}
@end
