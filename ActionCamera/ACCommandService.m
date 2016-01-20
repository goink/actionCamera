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
    NSString *cmd  = @"{\"token\":0,\"msg_id\":257}";//[NSString stringWithFormat:@"%@", @"{\"token\":0,\"msg_id\":257}"];//
    [[ACSocketService sharedSocketService] sendCommandToSocket:cmd];
}
@end
