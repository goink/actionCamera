//
//  ACSettingOptions.h
//  ActionCamera
//
//  Created by Guisheng on 16/1/20.
//  Copyright © 2016年 AC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACSettingOptions : NSObject
@property(nonatomic,strong) NSArray *video_resolution;
@property(nonatomic,strong) NSArray *video_stamp;
@property(nonatomic,strong) NSArray *timelapse_video;
@property(nonatomic,strong) NSArray *timelapse_duration;
@property(nonatomic,strong) NSArray *timelapse_video_resolution;
@property(nonatomic,strong) NSArray *timelapse_video_resolution_pal;
@property(nonatomic,strong) NSArray *video_photo;
@property(nonatomic,strong) NSArray *video_quality;
@property(nonatomic,strong) NSArray *photo_size;
@property(nonatomic,strong) NSArray *photo_stamp;
@property(nonatomic,strong) NSArray *video_standard;
@property(nonatomic,strong) NSArray *preview_status;
@property(nonatomic,strong) NSArray *buzzer_ring;
@property(nonatomic,strong) NSArray *buzzer_volume;
@property(nonatomic,strong) NSArray *default_record_mode;
@property(nonatomic,strong) NSArray *capture_default_mode;
@property(nonatomic,strong) NSArray *system_default_mode;
@property(nonatomic,strong) NSArray *precise_cont_time;
@property(nonatomic,strong) NSArray *precise_selftime;
@property(nonatomic,strong) NSArray *burst_capture_number;
@property(nonatomic,strong) NSArray *meter_mode;
@property(nonatomic,strong) NSArray *video_output_dev_type;
@property(nonatomic,strong) NSArray *led_mode;
@property(nonatomic,strong) NSArray *auto_low_light;
@property(nonatomic,strong) NSArray *loop_record;
@property(nonatomic,strong) NSArray *warp_enable;
@property(nonatomic,strong) NSArray *auto_power_off;
@property(nonatomic,strong) NSArray *start_wifi_while_booted;
@property(nonatomic,strong) NSArray *video_output_status;
@property(nonatomic,strong) NSArray *video_rotate;
@property(nonatomic,strong) NSArray *emergency_file_backup;
@property(nonatomic,strong) NSArray *restore_factory_settings;
@property(nonatomic,strong) NSArray *btc_delete_all_binded_dev;
@property(nonatomic,strong) NSArray *camera_save_log;
@property(nonatomic,strong) NSArray *protune;
@property(nonatomic,strong) NSArray *iq_eis_enable;
@property(nonatomic,strong) NSArray *iq_video_ev;
@property(nonatomic,strong) NSArray *iq_video_iso;
@property(nonatomic,strong) NSArray *iq_video_wb;
@property(nonatomic,strong) NSArray *iq_photo_shutter;
@property(nonatomic,strong) NSArray *iq_photo_ev;
@property(nonatomic,strong) NSArray *iq_photo_iso;
@property(nonatomic,strong) NSArray *iq_photo_wb;
@property(nonatomic,strong) NSArray *video_photo_resolution;
@property(nonatomic,strong) NSArray *video_photo_time;
@property(nonatomic,strong) NSArray *loop_rec_duration;

- (void)setValue:(NSString *)name withOptions:(NSArray *)options;

@end
