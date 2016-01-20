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
    NSString *cmd  = @"{\"token\":0,\"msg_id\":257}";
    [[ACSocketService sharedSocketService] sendCommandToSocket:cmd];
}

+ (void)getAllCurrentSettings
{
    ACSocketService *socketService = [ACSocketService sharedSocketService];
    NSLog(@"socketService:%@, token:%d", socketService, socketService.tokenNumber);
    NSString *cmd  = [NSString stringWithFormat:@"{\"token\":%d,\"msg_id\":3}", [ACSocketService sharedSocketService].tokenNumber];
    [[ACSocketService sharedSocketService] sendCommandToSocket:cmd];
}
+ (void)getSettingOptions:(NSString *)setting
{
    NSString *cmd  = [NSString stringWithFormat:@"{\"token\":%d,\"msg_id\":9,\"param\":\"%@\"}", [ACSocketService sharedSocketService].tokenNumber, setting];
    [[ACSocketService sharedSocketService] sendCommandToSocket:cmd];
}
+ (void)setSettingWithType:(NSString *)type param:(NSString *)param
{
    NSString *cmd = [NSString stringWithFormat:@"{\"token\":%d,\"msg_id\":2,\"type\":\"%@\",\"param\":\"%@\"}",[ACSocketService sharedSocketService].tokenNumber, type, param];
    [[ACSocketService sharedSocketService] sendCommandToSocket:cmd];
}
+ (void)getSettingWithType:(NSString *)type
{
    NSString *cmd = [NSString stringWithFormat:@"{\"token\":%d,\"msg_id\":1,\"type\":\"%@\"}",[ACSocketService sharedSocketService].tokenNumber, type];
    [[ACSocketService sharedSocketService] sendCommandToSocket:cmd];
}
@end
