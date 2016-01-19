//
//  ACCommandService.m
//  ActionCamera
//
//  Created by 范桂盛 on 16/1/18.
//  Copyright © 2016年 AC. All rights reserved.
//

#import "ACCommandService.h"
#import "ACSocketService.h"

@implementation ACCommandService

+ (void)startCommandSocketSession
{
    [[ACSocketService sharedSocketService] startCommandSocketSession];
}

+(void)stopCommandSocketSession
{
    [[ACSocketService sharedSocketService] stopCommandSocketSession];
}

+ (void)startSession
{
    NSString *cmd  = [NSString stringWithFormat:@"%@", @"{\"token\":0,\"msg_id\":257}"];//@"{\"token\":0,\"msg_id\":257}";
    [[ACSocketService sharedSocketService] sendCommandToSocket:cmd];
}
@end
