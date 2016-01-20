//
//  ACSocketService.h
//  ActionCamera
//
//  Created by 范桂盛 on 16/1/18.
//  Copyright © 2016年 AC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

#define CAMERA_IP @"192.168.42.1"
#define CAMERA_CMD_PORT 7878
#define CMAERA_DAT_PORT 8787

#define TIMEOUT 20

enum{
    SocketOfflineByServer,
    SocketOfflineByUser,
    SocketOfflineByOffline,//wifi 断开
};

@protocol AsyncSocketDelegate;

@interface ACSocketService : NSObject <AsyncSocketDelegate>

@property (nonatomic, strong) AsyncSocket *cmdSocket;
@property (nonatomic, strong) AsyncSocket *datSocket;
@property (nonatomic, assign) int         tokenNumber;

+ (ACSocketService *)sharedSocketService;

- (void)startCommandSocketSession;
- (void)stopCommandSocketSession;
- (void)sendCommandToSocket:(NSString *)cmd;
@end
