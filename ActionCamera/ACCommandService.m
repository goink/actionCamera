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
    [[ACSocketService sharedSocketService] sendCommandWithMsgID:257];
}

+ (void)getAllCurrentSettings
{
    [[ACSocketService sharedSocketService] sendCommandWithMsgID:3];
}
+ (void)getSettingOptions:(NSString *)setting
{
    [[ACSocketService sharedSocketService] sendCommandWithMsgID:9 type:nil param:setting];
}
+ (void)setSettingWithType:(NSString *)type param:(NSString *)param
{
    [[ACSocketService sharedSocketService] sendCommandWithMsgID:2 type:type param:param];
}
+ (void)getSettingWithType:(NSString *)type
{
    [[ACSocketService sharedSocketService] sendCommandWithMsgID:1 type:type];
}
+ (void)resetVideoFlow
{
    [[ACSocketService sharedSocketService] sendCommandWithMsgID:259 type:nil param:@"none_force"];
}
@end
