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
#import "ACSettings.h"
#import "ACSettingOptions.h"

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
@property (strong, nonatomic) ACSettings  *allSettings;
@property (strong, nonatomic) ACSettingOptions *settingOptions;

+ (ACSocketService *)sharedSocketService;

- (void)startCommandSocketSession;
- (void)stopCommandSocketSession;
- (void)sendCommandWithMsgID:(int)msg_id;
- (void)sendCommandWithMsgID:(int)msg_id type:(NSString *)type;
- (void)sendCommandWithMsgID:(int)msg_id type:(NSString *)type param:(NSString *)param;




@end
