//
//  ACSettingOptions.m
//  ActionCamera
//
//  Created by Guisheng on 16/1/20.
//  Copyright © 2016年 AC. All rights reserved.
//

#import "ACSettingOptions.h"

@implementation ACSettingOptions
- (instancetype)init
{
    if (self = [super init]) {
        
    }
    
    self.video_stamp                    = [NSArray arrayWithObjects:@"off", @"date", @"time", @"date/time", nil];
    self.timelapse_video                = [NSArray arrayWithObjects:@"0.5", @"1", @"2", @"5", @"10", @"30", @"60", nil];
    self.timelapse_duration             = [NSArray arrayWithObjects:@"off", @"6s", @"8s", @"10s", @"20s", @"30s", @"60s", @"120s",nil];
    self.video_photo                    = [NSArray arrayWithObjects:@"5", @"10", @"30", @"60",nil];
    self.video_quality                  = [NSArray arrayWithObjects:@"S.Fine", @"Fine", @"Normal", nil];
    self.photo_stamp                    = [NSArray arrayWithObjects:@"off", @"date", @"time", @"date/time", nil];
    self.video_standard                 = [NSArray arrayWithObjects:@"NTSC", @"PAL", nil];
    self.buzzer_volume                  = [NSArray arrayWithObjects:@"high", @"low", @"mute", nil];
    self.default_record_mode            = [NSArray arrayWithObjects:@"record", @"record_timelapse", @"record_photo", nil];
    self.capture_default_mode           = [NSArray arrayWithObjects:@"precise quality", @"precise quality cont.", @"precise self quality", @"burst quality", nil];
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
    
    self.burst_capture_number           = nil;
    self.meter_mode                     = nil;
    self.video_photo_resolution         = nil;
    self.video_photo_time               = nil;
    self.loop_rec_duration              = nil;
    self.system_default_mode            = nil;
    self.photo_size                     = nil;
    self.timelapse_video_resolution     = nil;
    self.timelapse_video_resolution_pal = nil;
    self.video_resolution               = nil;
    
    return self;
}

@end
