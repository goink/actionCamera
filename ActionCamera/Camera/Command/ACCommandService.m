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

@implementation ACCommandService

#pragma mark - 执行相机命令，带回调注册
+ (void)execute:(int)msgid params:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    ACSocketObject *socObj = [ACSocketObject objectWithMsgID:msgid type:params[@"type"] param:params[@"param"]];
    [[ACSocketService sharedSocketService] sendCommandWithSocketObject:socObj success:success failure:failure];
}
#pragma mark - 注册相机命令监听器，带回调注册
+(void)listen:(int)msgid success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSString *msgidString = [NSString stringWithFormat:@"%u", msgid];
    //注册回调
    [[ACSocketService sharedSocketService] addObserverForMsgId:msgidString success:success failure:failure];
}

#pragma mark - session管理相关
+ (void)startCommandSocketSession
{
    [ACSocketService sharedSocketService].cmdSocket.userData = SocketOfflineByUser;
    [[ACSocketService sharedSocketService].cmdSocket disconnect];
    [ACSocketService sharedSocketService].cmdSocket.userData = SocketOfflineByServer;
    [[ACSocketService sharedSocketService] startCommandSocketSession];
}

+(void)stopCommandSocketSession
{
    [[ACSocketService sharedSocketService] stopCommandSocketSession];
}

+ (void)startSession
{
    [ACCommandService execute:MSGID_START_SESSION params:nil success:nil failure:nil];
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

@end
