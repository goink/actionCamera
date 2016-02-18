//
//  ACDefines.h
//  ActionCamera
//
//  Created by Guisheng on 16/1/20.
//  Copyright © 2016年 AC. All rights reserved.
//

#ifndef ACDefines_h
#define ACDefines_h

#define CAMERA_IP @"192.168.42.1"
#define CAMERA_IP_RTSP @"rtsp://192.168.42.1/live"

#define CAMERA_CMD_PORT 7878
#define CAMERA_DAT_PORT 8787

#define TIMEOUT 20

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
    //    CameraBatteryDanger,              // 1-5
    //    CameraBatteryLow,                 // 6-35
    //    CameraBatteryMid,                 // 36-65
    //    CameraBatteryHigh,                // 66-100
    //    CameraBatteryCharge,              // 充电中
    //    CameraBatteryNone                 // 没有电池
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



#endif /* ACDefines_h */
