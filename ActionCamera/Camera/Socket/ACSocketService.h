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
#import <CocoaLumberjack/CocoaLumberjack.h>

@protocol AsyncSocketDelegate;

@interface ACSocketService : NSObject <AsyncSocketDelegate>

@property (nonatomic, strong) AsyncSocket *cmdSocket;
@property (nonatomic, strong) AsyncSocket *datSocket;
@property (nonatomic, assign) int         tokenNumber;

+ (ACSocketService *)shared;

- (void)resetQueue;

- (void)startCommandSocketSession;
- (void)stopCommandSocketSession;

- (void)addObserverForMsgId:(NSString *)msg_id
                  success:(void (^)(id responseObject))success
                  failure:(void (^)(id errorObject))failure;

- (void)sendCommandWithSocketObject:(ACSocketObject *)socketObj
                  success:(void (^)(id responseObject))success
                  failure:(void (^)(id errorObject))failure;


- (void)listenOnNotification:(NSString *)notification
                   forTarget:(id)target
                     success:(void (^)(id responseObject))success
                     failure:(void (^)(id errorObject))failure;

- (void)removeListener:(NSObject *)notification forTarget:(id)target;

#pragma mark - output for wapper
- (void)handleCommandSocket:(AsyncSocket *)sock data:(NSData *)data tag:(long)tag;

@end
