//
//  ACSettings.h
//  ActionCamera
//
//  Created by Guisheng on 16/1/20.
//  Copyright © 2016年 AC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACSettings : NSObject

@property (strong, nonatomic) NSString *camera_clock; // "2016-01-16 18:08:19";
@property (strong, nonatomic) NSString *video_standard; // NTSC;
@property (strong, nonatomic) NSString *app_status; // idle;
@property (strong, nonatomic) NSString *video_resolution; // "2304x1296 30P 16:9";
@property (strong, nonatomic) NSString *video_stamp; // time;
@property (strong, nonatomic) NSString *video_quality; // "S.Fine";
@property (strong, nonatomic) NSString *timelapse_video; // 1;
@property (strong, nonatomic) NSString *capture_mode; // "precise quality cont.";
@property (strong, nonatomic) NSString *photo_size; // "16M (4608x3456 4:3)";
@property (strong, nonatomic) NSString *photo_stamp; // time;
@property (strong, nonatomic) NSString *photo_quality; // "S.Fine";
@property (strong, nonatomic) NSString *timelapse_photo; // 2;
@property (strong, nonatomic) NSString *preview_status; // on;
@property (strong, nonatomic) NSString *buzzer_volume; // low;
@property (strong, nonatomic) NSString *buzzer_ring; // off;
@property (strong, nonatomic) NSString *capture_default_mode; // "precise quality cont.";
@property (strong, nonatomic) NSString *precise_cont_time; // "2.0 sec";
@property (strong, nonatomic) NSString *burst_capture_number; // "7 p / 2s";
@property (strong, nonatomic) NSString *wifi_ssid; // 0007000;
@property (strong, nonatomic) NSString *wifi_password; // 1234567890;
@property (strong, nonatomic) NSString *led_mode; // "all enable";
@property (strong, nonatomic) NSString *meter_mode; // center;
@property (strong, nonatomic) NSString *sd_card_status; // insert;
@property (strong, nonatomic) NSString *video_output_dev_type; // tv;
@property (strong, nonatomic) NSString *sw_version; // "YDXJv22L_1.2.13_build-20150906142851_b1049_i841_s1120"
@property (strong, nonatomic) NSString *hw_version; // "YDXJ_v23L";
@property (strong, nonatomic) NSString *dual_stream_status; // on;
@property (strong, nonatomic) NSString *streaming_status; // off;
@property (strong, nonatomic) NSString *precise_cont_capturing; // off;
@property (strong, nonatomic) NSString *piv_enable; // on;
@property (strong, nonatomic) NSString *auto_low_light; // off;
@property (strong, nonatomic) NSString *loop_record; // off;
@property (strong, nonatomic) NSString *warp_enable; // on;
@property (strong, nonatomic) NSString *support_auto_low_light; // on;
@property (strong, nonatomic) NSString *precise_selftime; // 3s;
@property (strong, nonatomic) NSString *precise_self_running; // off;
@property (strong, nonatomic) NSString *auto_power_off; // off;
@property (strong, nonatomic) NSString *serial_number; // Z23L534A3394765;
@property (strong, nonatomic) NSString *system_mode; // capture;
@property (strong, nonatomic) NSString *system_default_mode; // capture;
@property (strong, nonatomic) NSString *start_wifi_while_booted; // on;
@property (strong, nonatomic) NSString *quick_record_time; // 0;
@property (strong, nonatomic) NSString *precise_self_remain_time; // 0;
@property (strong, nonatomic) NSString *sdcard_need_format; // "no-need";
@property (strong, nonatomic) NSString *video_rotate; // off;
@property (strong, nonatomic) NSString *emergency_file_backup; // on;
@property (strong, nonatomic) NSString *osd_enable; // off;
@property (strong, nonatomic) NSString *rec_default_mode; // record;
@property (strong, nonatomic) NSString *rec_mode; // record;
@property (strong, nonatomic) NSString *record_photo_time; // 5;
@property (strong, nonatomic) NSString *dev_functions; // 7743;
@property (strong, nonatomic) NSString *rc_button_mode; // "mode_shutter";
@property (strong, nonatomic) NSString *timelapse_video_duration; // 8s;
@property (strong, nonatomic) NSString *timelapse_video_resolution; // "1920x1080 60P 16:9";
@property (strong, nonatomic) NSString *save_log; // off;
@property (strong, nonatomic) NSString *restore_factory_settings; // on
@property (strong, nonatomic) NSString *sta_ssid; //
@property (strong, nonatomic) NSString *sta_password; //
@property (strong, nonatomic) NSString *sta_connect_password; //
@property (strong, nonatomic) NSString *sta_ip; //
@property (strong, nonatomic) NSString *wifi_mode; // AP
@property (strong, nonatomic) NSString *video_photo_resolution; // 1920x1080 60P 16:9
@property (strong, nonatomic) NSString *slow_motion_rate; // 4
@property (strong, nonatomic) NSString *loop_rec_duration; // 5 minutes
@property (strong, nonatomic) NSString *iq_eis_enable; // off
@property (strong, nonatomic) NSString *iq_photo_iso; // auto
@property (strong, nonatomic) NSString *iq_video_iso; // auto
@property (strong, nonatomic) NSString *iq_photo_shutter; // auto
@property (strong, nonatomic) NSString *iq_photo_ev; // 0
@property (strong, nonatomic) NSString *iq_video_ev; // 0
@property (strong, nonatomic) NSString *iq_photo_wb; // auto
@property (strong, nonatomic) NSString *iq_video_wb; // auto
@property (strong, nonatomic) NSString *protune; // on
@property (strong, nonatomic) NSString *screen_auto_lock; // 60s
@property (strong, nonatomic) NSString *dewarp_support_status; // off
@property (strong, nonatomic) NSString *eis_support_status; // off
@property (strong, nonatomic) NSString *video_mute_set; // on

- (instancetype)initWithArray:(NSArray *)settingDics;
- (void)reset;

@end
