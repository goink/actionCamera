//
//  ACCommandService.m
//  ActionCamera
//
//  Created by Guisheng on 16/1/18.
//  Copyright © 2016年 AC. All rights reserved.
//

#import "ACCommandService.h"
#import "ACSocketService.h"
#import "AsyncSocket.h"
#import "ACDefines.h"
#import "CameraHAM.h"
#import "UIDevice+YYAdd.h"

@implementation ACCommandService

#pragma mark - 执行相机命令，带回调注册
+ (void)execute:(int)msgid params:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(id))failure
{
    ACSocketObject *socObj = [ACSocketObject objectWithMsgID:msgid type:params[@"type"] param:params[@"param"]];
    [[ACSocketService shared] sendCommandWithSocketObject:socObj success:success failure:failure];
}

#pragma mark - 注册相机命令监听器，带回调注册
+ (void)listen:(int)msgid success:(void (^)(id))success failure:(void (^)(id))failure
{
    NSString *msgidString = [NSString stringWithFormat:@"%u", msgid];
    //注册回调
    [[ACSocketService shared] addObserverForMsgId:msgidString success:success failure:failure];
}

#pragma mark - session管理相关
+ (void)startCommandSocketSession
{
    [ACSocketService shared].cmdSocket.userData = SocketOfflineByUser;
    [[ACSocketService shared].cmdSocket disconnect];
    [ACSocketService shared].cmdSocket.userData = SocketOfflineByServer;
    [[ACSocketService shared] startCommandSocketSession];
}

+(void)stopCommandSocketSession
{
    [[ACSocketService shared] stopCommandSocketSession];
}

+ (void)startSession
{
#if HEARTBEAT_ENABLE
    ACSocketObject *socObj = [ACSocketObject objectWithMsgID:MSGID_START_SESSION heartbeat:@"1"];
    [[ACSocketService shared] sendCommandWithSocketObject:socObj success:nil failure:nil];
#else
    [ACCommandService execute:MSGID_START_SESSION params:nil success:nil failure:nil];
#endif
    
}

#pragma mark - 无回调快捷命令接口
+ (void)getAllCurrentSettings
{
    [ACCommandService execute:MSGID_GET_ALL_CURRENT_SETTINGS params:nil success:nil failure:nil];
}

+ (void)getSettingOptions:(NSString *)setting
{
    if (setting) {
        NSDictionary *params = @{@"param":setting};
        [ACCommandService execute:MSGID_GET_SETTING params:params success:nil failure:nil];
    }
}

+ (void)setSettingWithType:(NSString *)type param:(NSString *)param
{
    if (type && param) {
        NSDictionary *params = @{@"param":param, @"type":type};
        [ACCommandService execute:MSGID_SET_SETTING params:params success:nil failure:nil];
    }
}

+ (void)getSettingWithType:(NSString *)type
{
    if (type) {
        NSDictionary *params = @{@"type":type};
        [ACCommandService execute:MSGID_GET_SETTING params:params success:nil failure:nil];
    }
}

+ (void)resetVideoFlow
{
    NSDictionary *params = @{@"param":@"none_force"};
    [ACCommandService execute:MSGID_BOSS_RESETVF params:params success:nil failure:nil];
}

+ (void)stopVideoFlow
{
    [ACCommandService execute:MSGID_STOP_VF params:nil success:nil failure:nil];
}

+ (void)syncCameraClock
{
    [ACCommandService syncCameraClockWithSuccess:nil failure:nil];
}

+ (void)syncCameraClockWithSuccess:(void (^)(id))success failure:(void (^)(id))failure
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *twentyFour = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
    dateFormatter.locale = twentyFour;
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [NSDate date];
    NSString *time = [dateFormatter stringFromDate:date];
    
    NSString *type = getSettingName(camera_clock);
    NSDictionary *params = @{@"param":time, @"type":type};
    [ACCommandService execute:MSGID_SET_SETTING params:params success:success failure:failure];
}

+ (void)getOptionsListPhase1
{
    NSMutableArray *nameList = [NSMutableArray array];

    NSString *name = nil;
 
    //photo_size放在请求列表最后，作为相机状态同步完成的标志
    name = getOptionName(photo_size);
    [nameList addObject:name];
    
    name = getOptionName(burst_capture_number);
    [nameList addObject:name];
    
    name = getOptionName(video_resolution);
    [nameList addObject:name];
    
    name = getOptionName(video_photo_resolution);
    [nameList addObject:name];
    
    name = getOptionName(timelapse_video_resolution);
    [nameList addObject:name];
    
    name = getOptionName(record_photo_time);
    [nameList addObject:name];
    
    name = getOptionName(system_default_mode);
    [nameList addObject:name];
    
    [nameList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *params = @{@"param":obj};
        [ACCommandService execute:MSGID_GET_SINGLE_SETTING_OPTIONS params:params success:nil failure:nil];
    }];
    
}

+ (void)getOptionsListPhase2
{
    NSMutableArray *nameList = [NSMutableArray array];
    
    NSString *name = nil;
    
    if (![CameraHAM shared].settingOptions.video_resolution) {
        name = getOptionName(video_resolution);
        [nameList addObject:name];
    }
    
    if (![CameraHAM shared].settingOptions.video_photo_resolution) {
        name = getOptionName(video_photo_resolution);
        [nameList addObject:name];
    }
    
    if (![CameraHAM shared].settingOptions.timelapse_video_resolution) {
        name = getOptionName(timelapse_video_resolution);
        [nameList addObject:name];
    }
    
    if (![CameraHAM shared].settingOptions.record_photo_time) {
        name = getOptionName(record_photo_time);
        [nameList addObject:name];
    }
    
    name = getOptionName(system_default_mode);
    [nameList addObject:name];
    
    if (nameList.count > 0) {
        [nameList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *params = @{@"param":obj};
            [ACCommandService execute:MSGID_GET_SINGLE_SETTING_OPTIONS params:params success:nil failure:nil];
        }];
    }
    
}

+ (void)getVideoResolutionsListForce
{
    NSMutableArray *nameList = [NSMutableArray array];
    
    NSString *name = nil;
    
    name = getOptionName(video_resolution);
    [nameList addObject:name];

    name = getOptionName(video_photo_resolution);
    [nameList addObject:name];

    name = getOptionName(timelapse_video_resolution);
    [nameList addObject:name];

    
    if (nameList.count > 0) {
        [nameList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *params = @{@"param":obj};
            [ACCommandService execute:MSGID_GET_SINGLE_SETTING_OPTIONS params:params success:nil failure:nil];
        }];
    }
}

+ (void)getBatteryStatus
{
    [ACCommandService execute:MSGID_GET_BATTERY_LEVEL params:nil success:nil failure:nil];
}

+ (void)getPIVSupport
{
    NSDictionary *params = @{@"type":@"piv_enable"};
    [ACCommandService execute:MSGID_GET_SETTING params:params success:nil failure:nil];
}

+ (void)getAutoLowLightSupport
{
    NSDictionary *params = @{@"type":@"support_auto_low_light"};
    [ACCommandService execute:MSGID_GET_SETTING params:params success:nil failure:nil];
}

+ (void)quitIdelSendMsg_Id
{
    //16777230
    [ACCommandService execute:16777230 params:nil success:nil failure:nil];
}

+ (void)syncCameraParams
{
    [ACCommandService getAllCurrentSettings];
}

+ (void)setClientinfo
{
    NSDictionary *params = @{@"type":@"TCP", @"param":[UIDevice currentDevice].ipAddressWIFI};
    [ACCommandService execute:MSGID_SET_CLNT_INFO params:params success:nil failure:nil];
}


@end
