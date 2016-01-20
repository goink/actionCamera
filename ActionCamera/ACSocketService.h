//
//  ACSocketService.h
//  ActionCamera
//
//  Created by Guisheng on 16/1/18.
//  Copyright © 2016年 AC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "ACDefines.h"

enum{
    SocketOfflineByServer,
    SocketOfflineByUser,
    SocketOfflineByOffline,
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
