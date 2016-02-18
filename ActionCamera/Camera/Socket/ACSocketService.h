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
#import "ACCommandObject.h"

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
@property (strong, nonatomic) ACSettings  *settings;
@property (strong, nonatomic) ACSettingOptions *settingOptions;

+ (ACSocketService *)sharedSocketService;

- (void)startCommandSocketSession;
- (void)stopCommandSocketSession;

- (void)addObserverForMsgId:(NSString *)msg_id
                  success:(void (^)(id responseObject))success
                  failure:(void (^)(id errorObject))failure;

- (void)sendCommandWithSocketObject:(ACSocketObject *)socketObj
                  success:(void (^)(id responseObject))success
                  failure:(void (^)(id errorObject))failure;

@end
