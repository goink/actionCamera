//
//  ACDefines.h
//  ActionCamera
//
//  Created by Guisheng on 16/1/20.
//  Copyright © 2016年 AC. All rights reserved.
//

#ifndef ACDefines_h
#define ACDefines_h

#import "Defines.h"

#define CAMERA_IP @"192.168.42.1"
#define CAMERA_IP_RTSP @"rtsp://192.168.42.1/live"

#define CAMERA_CMD_PORT 7878
#define CAMERA_DAT_PORT 8787

#define TIMEOUT 20

//VLC 参数设置
#define kVLCSettingNetworkCaching @"network-caching"
#define NetworkCachingValue @"333"
#define CameraNetworkCachingValue @"300"
#define CacheingTime 24*60*60

#define SCREEN_FACTOR (10.0/36.0)
#define MAINBUTTON_WIDTH ([UIScreen mainScreen].bounds.size.width*(8.6/36.0))
#define TOP_SECTION_HEIGHT ([UIScreen mainScreen].bounds.size.height*(50.0/667))
#define TOOL_SECTION_HEIGHT ([UIScreen mainScreen].bounds.size.height*(40.0/667))

#define   kDegreesToRadians(degrees)  ((M_PI * (degrees))/ 180)

#define STATUS_LOADING @"status_loading"
#define STATUS_WAITING @"status_waiting"
#define STATUS_PREPARE @"status_prepare"
#define STATUS_CANCEL @"status_cancel"

#define MSGID_START_SESSION              0x0101   //257
#define MSGID_STOP_SESSION               0x0102   //258
#define MSGID_BOSS_RESETVF               0x0103   //259
#define MSGID_STOP_VF                    0x0104   //260
#define MSGID_SET_CLNT_INFO              0x0105   //261

#define MSGID_GET_SETTING                0x0001   //1
#define MSGID_SET_SETTING                0x0002   //2
#define MSGID_GET_ALL_CURRENT_SETTINGS   0x0003   //3
#define MSGID_FORMAT                     0x0004   //4
#define MSGID_GET_SPACE                  0x0005   //5
#define MSGID_CALLBACK_NOTIFICATION      0x0007   //7
#define MSGID_GET_SINGLE_SETTING_OPTIONS 0x0009   //9

#define MSGID_GET_BATTERY_LEVEL          0x000d   //13

#define MSGID_RECORD_START               0x0201   //513
#define MSGID_RECORD_STOP                0x0202   //514
#define MSGID_GET_RECORD_TIME            0x0203   //515
#define MSGID_GET_TIMELAPSE_RECORD_TIME  16777241 //0x1000019
#define MSGID_TAKE_PHOTO                 0x00301  //769

#define MSGID_GET_THUM                   0x0401   //1025
#define MSGID_GET_MEDIAINFO              0x0402   //1026

#define MSGID_DEL_FILE                   0x0501   //1281
#define MSGID_LS                         0x0502   //1282
#define MSGID_CD                         0x0503   //1283
#define MSGID_GET_FILE                   0x0505   //1285
#define MSGID_PUT_FILE                   0x0506   //1286
#define MSGID_CANCEL_GET_FILE            0x0507   //1287

#define MSGID_QUERY_SESSION_HOLDER       0x0701   // 1793

#define MSGID_E_TAKE_PHOTO               16777220  //0x1000004
#define MSGID_E_CAPTURE_STOP             770
#define MSGID_E_TAKE_PIV                 16777227  //0x100000B
#define MSGID_E_START_QUICK_RECORD       16777221  //0x1000005
#define MSGID_E_START_UPDATE_FIRMWARE    16777219  //0x1000003
#define MSGID_E_GET_FOCUSING             15
#define MSGID_E_GET_SD_CARD_TYPE         16777217  //0x1000001

#define MSGID_E_SET_PHOTO_TYPE           16777228  //0x100000C
#define MSGID_UNBIND_BLUETOOTH_DEV       16777232  //0x1000010
#define MSGID_DOWNLOAD_CAMERA_LOG        16777242  //0x100001A

#define MSGID_STOP_TIMING_CAPTURE        16777238

#define MSGID_SD_CAPACITY_COUNT          16777243


#define momo ([ACSocketService sharedSocketService].allSettings)
#define getSettingName(property) [[(@""#property) componentsSeparatedByString:@"."] lastObject];([CameraHAM shared].settings.property)
#define getOptionName(property) [[(@""#property) componentsSeparatedByString:@"."] lastObject];([CameraHAM shared].settingOptions.property)


typedef NS_ENUM(NSUInteger, CurrentMode) {
    CurrentModeRecord      = 0,      // 录像
    CurrentModeSnapshot    = 1,      // 快拍
    CurrentModePhoto       = 2,      // 拍照
};

typedef NS_ENUM(NSUInteger, CurrentPhotoMode) {
    CurrentPhotoModeNormal      = 0,     // 普通拍照
    CurrentPhotoModePrecise     = 1,     // 延时拍照
    CurrentPhotoModeTiming      = 2,     // 定时拍照
    CurrentPhotoModeBurst       = 3,     // 连续拍照
};

typedef NS_ENUM(NSUInteger, CurrentRecordMode) {//不要与拍照模式重复
    CurrentRecordModeNormal        = 4,     // 普通录像
    CurrentRecordModeTimeLapse     = 5,     // 延时录像
    CurrentRecordModeVideoPhoto    = 6,     // 录像拍照
    CurrentRecordModeLoopVideo     = 7,     // 循环录像
    CurrentRecordModeSlowMotion     = 8,     // 慢动作
};

typedef NS_ENUM(NSUInteger, CameraPowerType) {
    CameraPowerBattery,
    CameraPowerAdapter
};

typedef NS_ENUM(NSInteger, CameraStatus){
    CameraStatusNormal                =1,           // 正常状态什么事没干
    CameraStatusSending               =1 << 1,      // 正在发送命令
    CameraStatusNormalRecording       =1 << 2,      // 正在普通摄像
    CameraStatusTimelapseRecording    =1 << 3,      // 正在延时摄像
    CameraStatusPhotoRecording        =1 << 4,      // 正在拍照+摄像
    CameraStatusPhotoing              =1 << 5,      // 正在普通拍照
    CameraStatusPrecising             =1 << 6,      // 正在延时拍照
    CameraStatusTiming                =1 << 7,      // 正在倒计时拍照
    CameraStatusBursting              =1 << 8,      // 正在连续拍照
    CameraStatusQuikckRecording       =1 << 9,      // 正在快拍
    CameraStatusLoopRecording         =1 << 10,     // 正在循环摄像
    CameraStatusSlowMotionRecording   =1 << 11,     // 正在慢动作摄像
    
};

typedef NS_ENUM(NSUInteger, CameraAspectRatio) {
    CameraAspectRatioNone        = 0,      // 未知
    CameraAspectRatio4T3         = 1,      // 4:3
    CameraAspectRatio16T9        = 2,      // 16:9
};

#define CameraStatusGeneralRecording (CameraStatusNormalRecording | CameraStatusTimelapseRecording | CameraStatusPhotoRecording | CameraStatusLoopRecording | CameraStatusSlowMotionRecording) //摄像状态的并集
#define CameraStatusGeneralPhotoing  (CameraStatusPhotoing | CameraStatusPrecising | CameraStatusTiming | CameraStatusBursting)


#define NOTI_CAMERA_IS_READY @"noti_camera_isReady"
#define NOTI_SYSTEM_NETWORK_CHANGED @"noti_system_network_changed"

/**
 *  相机控制
 */
#define CAMERA_MODE_SWITCH_NOTIFICATION @"camera_mode_switch"
#define FLOAT_SETTINGS_NEED_UPDATE_NOTIFICATION @"float_settings_need_update"

#define CAMERA_ALBUM_STATUS @"camera_album_status"
#define ENTER_ALBUM  @"enter_album"
#define EXIT_ALBUM  @"exit_album"

#define MODEL @"model" //相机model
#define ALBUM @"album"

#define ON @"on"
#define OFF @"off"


#define PRECISE_QUALITY         @"precise quality"          //普通拍照
#define PRECISE_QUALITY_CONT    @"precise quality cont."    //延时拍照
#define BURST_QUALITY           @"burst quality"            //连续拍照
#define PRECISE_SELF_QUALITY    @"precise self quality"     //定时拍照

#define REC_MODE                @"rec_mode"
#define RECORD                  @"record"                   //普通摄像
#define RECORD_TIMELAPSE        @"record_timelapse"         //延时摄像
#define RECORD_RECORD_PHOTO     @"record_photo"             //摄像+拍照
#define RECORD_RECORD_LOOP      @"record_loop"              //循环摄像
#define RECORD_SLOW_MOTION      @"record_slow_motion"       //慢动作


#define DUAL_STREAM_STATUS @"dual_stream_status"
#define AUTO_LOW_LIGHT @"auto_low_light"//自动低光
#define LOOP_RECORD @"loop_record"//循环录像
#define WARP_ENABLE @"warp_enable"
#define DEWARP_SUPPORT_STATUS @"dewarp_support_status"

#define START_WIFI_WHILE_BOOTED @"start_wifi_while_booted"
#define VIDEO_OUTPUT_STATUS @"video_output_dev_type"
#define VIDEO_ROTATE @"video_rotate"
#define EMERGENCY_FILE_BACKUP @"emergency_file_backup"
#define AUTO_POWER_OFF @"auto_power_off"
#define SUPPORT_AUTO_LOW_LIGHT @"support_auto_low_light"
#define SAVE_LOG @"save_log"


#define PHOTO_QUALITY @"photo_quality"
#define TIMELAPSE_PHOTO @"timelapse_photo"
#define PREVIEW_STATUS @"preview_status"
#define BUZZER_VOLUME @"buzzer_volume"//蜂鸣器音量
#define DEFAULT_RECORD_MODE @"rec_default_mode"//开机默认录像模式设置
#define BUZZER_RING @"buzzer_ring"
#define PRECISE_CONT_TIME @"precise_cont_time"//延时拍照间隔
#define BURST_CAPTURE_NUMBER @"burst_capture_number"//连拍张数
#define PRECISE_SELFTIME @"precise_selftime"//定时拍照时间
#define PRECISE_SELF_RUNNING @"precise_self_running"//是否在定时拍照
#define PRECISE_SELF_REMAIN_TIME @"precise_self_remain_time"//定时拍照剩余时间
#define QUICK_RECORD_TIME @"quick_record_time"//快拍时间



#define PRECISE_CONT_CAPTURING @"precise_cont_capturing"
#define BURST_CAPTURING @"burst_capturing"
#define START_VIDEO_RECORD @"start_video_record"
#define VIDEO_RECORD_COMPLETE @"video_record_complete"
#define VIDEO_RECORD_SPLIT @"video_record_split"
#define PHOTO_TAKEN @"photo_taken"
#define PRECISE_CAPTURE_DATA_READY @"precise_capture_data_ready"
#define PIV_COMPLETE @"piv_complete"
#define START_QUICK_RECORD @"start_quick_record"
#define SWITCH_TO_CAP_MODE @"switch_to_cap_mode"
#define SWITCH_TO_REC_MODE @"switch_to_rec_mode"
#define PUT_FILE_COMPLETE @"put_file_complete"
#define PUT_FILE_FAIL @"put_file_fail"
#define PUT_FILE_NOSPACE @"no_space"
#define PUT_FILE_TIMEDOUT @"timed_out"
#define FIRMWARE_UNZIP_SUCCESS @"firmware_unzip_success"
#define ADAPTER @"adapter"
#define BATTERY @"battery"
#define ADAPTER_STATUS @"adapter_status"
#define BATTERY_STATUS @"battery_status"

#define SETTING_CHANGED @"setting_changed"


//IQ相关设置项，见“2015-11-19（IQ相关设置项）”章节
#define IQ_EIS_ENABLE       @"iq_eis_enable"    //EIS（电子防抖）开关
#define IQ_PHOTO_ISO        @"iq_photo_iso"     //PHOTO ISO（感光度）
#define IQ_VIDEO_ISO        @"iq_video_iso"     //VIDEO ISO（感光度）
#define IQ_PHOTO_SHUTTER    @"iq_photo_shutter" //PHOTO SHUTTER（快门时长）
#define IQ_PHOTO_EV         @"iq_photo_ev"      //PHOTO EV（曝光增益）
#define IQ_VIDEO_EV         @"iq_video_ev"      //VIDEO EV（曝光增益）
#define IQ_PHOTO_WB         @"iq_photo_wb"      //PHOTO WB（白平衡）
#define IQ_VIDEO_WB         @"iq_video_wb"      //VIDEO WB（白平衡）
#define PROTUNE             @"protune"          //IQ相关设置项总开关

#define EIS_SUPPORT_STATUS          @"eis_support_status"

#define NEED_LS_NOTIFICATION        @"need_LS_notification"       //需要ls
#define DO_NOT_NEED_LS_NOTIFICATION @"do_not_need_LS_notification"//不需要ls

#define CAPTURE                 @"capture"
#define PRECISE_QUALITY         @"precise quality"          //普通拍照
#define PRECISE_QUALITY_CONT    @"precise quality cont."    //延时拍照
#define BURST_QUALITY           @"burst quality"            //连续拍照
#define PRECISE_SELF_QUALITY    @"precise self quality"     //定时拍照

#define REC_MODE                @"rec_mode"
#define RECORD                  @"record"                   //普通摄像
#define RECORD_TIMELAPSE        @"record_timelapse"         //延时摄像
#define RECORD_RECORD_PHOTO     @"record_photo"             //摄像+拍照
#define RECORD_RECORD_LOOP      @"record_loop"              //循环摄像
#define RECORD_SLOW_MOTION      @"record_slow_motion"       //慢动作

#define VIDEO_LOOP_REC_DURATION @"loop_rec_duration" //循环录像时间间隔
#define SLOW_MOTION_RATE        @"slow_motion_rate"
#define SLOW_MOTION_RESOLUTION  @"slow_motion_resolution"

#define NOTIFICATION_REC_TIME @"rec_time" //视频文件的时长
#define NOTIFICATION_REC_COUNT_TIME @"rec_count_time" //录像时间的时长


#define IDLE @"idle"
#define VF_START @"vf_start"
#define VF_STOP @"vf_stop"
#define START_PHOTO_CAPTURE @"start_photo_capture"
#define PRECISE_CONT_COMPLETE @"precise_cont_complete"
#define BURST_COMPLETE @"burst_complete"
#define SELF_CAPTURE_STOP @"self_capture_stop"

#define VIDEO_QUALITY @"video_quality"//视频质量
#define VIDEO_STAMP @"video_stamp"//视频戳
#define VIDEO_TIMELAPSE @"timelapse_video"//延时录像
#define TIMELAPSE_VIDEO_DURATION @"timelapse_video_duration"
#define TIMELAPSE_VIDEO_RESOLUTION @"timelapse_video_resolution"
#define VIDEO_PHOTO_TIME @"record_photo_time"//录像+拍照 时间间隔
#define VIDEO_PHOTO_RESOLUTION @"video_photo_resolution" //录像+拍照 模式分辨率
#define VIDEO_PHOTO_FPS @"video_photo_fps"

#define VIDEO_RESOLUTION @"video_resolution"//视频分辨率
#define VIDEO_STANDARD @"video_standard"//制式
#define METER_MODE @"meter_mode"//测光模式
#define PHOTO_SIZE @"photo_size"//照片分辨率
#define CAPTURE_DEFAULT_MODE @"capture_default_mode"//开机拍照模式
#define SYSTEM_DEFAULT_MODE @"system_default_mode"//开机默认模式
#define PHOTO_STAMP @"photo_stamp"//照片戳
#define CAMERA_CLOCK @"camera_clock"
#define STREAM_OUT_TYPE @"stream_out_type"
#define SAVE_LOW_RESOLUTION_CLIP @"save_low_resolution_clip"
#define TIMELAPSE_VIDEO @"timelapse_video"
#define CAPTURE_MODE @"capture_mode"//拍照模式选择

#define SYSTEM_MODE @"system_mode"//设备当前拍照/摄像大模式
#define CURRENT_PHOTO_MODE  @"current_photo_mode"  //设备当前拍照小模式
#define CURRENT_RECORD_MODE @"current_record_mode" //设备当前摄像小模式


#endif /* ACDefines_h */
