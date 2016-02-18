//
//  ACSocketService.m
//  ActionCamera
//
//  Created by Guisheng on 16/1/18.
//  Copyright © 2016年 AC. All rights reserved.
//

#import "ACSocketService.h"
#import "ACSocketObject.h"
#import "ACCommandService.h"
#import "ACCommandObject.h"
#import "ACSettings.h"
#import "ACSettingOptions.h"
#import "CameraHAM.h"

#import "NSObject+YYModel.h"

@interface ACSocketService ()
@property (nonatomic, strong) NSMutableArray *queue;
@property (nonatomic, assign) BOOL _continue;
@property (nonatomic, strong) ACCommandObject *cmdObject;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *stopTime;
@property (strong, nonatomic) NSMutableData *cmdSocketData;
@property (strong, nonatomic) NSMutableData *datSocketData;
@property (nonatomic, strong) NSMutableDictionary *successHandlers;
@property (nonatomic, strong) NSMutableDictionary *failureHanlders;
//@property (nullable, copy) void (^completionBlock)(void);
@end

@implementation ACSocketService
static ACSocketService *socketService = nil;

#pragma mark - life cycle
+ (ACSocketService *)sharedSocketService {
    @synchronized(self) {
        if(!socketService) {
            socketService = [[self alloc] init];
        }
    }
    return socketService;
}

+(id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (socketService == nil)
        {
            socketService = [super allocWithZone:zone];
            return socketService;
        }
    }
    return nil;
}

- (id)init
{
    self = [super init];
    if (self) {
//        self.settingOptions = [[ACSettingOptions alloc] init];
        [NSThread detachNewThreadSelector:@selector(commandLoop) toTarget:self withObject:nil];
        
        self.successHandlers = [NSMutableDictionary dictionary];
        self.failureHanlders = [NSMutableDictionary dictionary];
        [self systemProbe];
    }
    return self;
}
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark - command queue operation
- (NSMutableArray *)queue
{
    if (!_queue) {
        self.queue = [[NSMutableArray alloc] init];
    }
    return _queue;
}
- (void)enQueue:(id)object
{
    if (_queue) {
        [_queue addObject:object];
    }
}
- (id)deQueue
{
    id object = nil;
    
    if (_queue) {
        if (_queue.count > 0) {
            object = [_queue objectAtIndex:0];
            if (object) {
                [_queue removeObjectAtIndex:0];
            }
        }
    }
    return object;
}

- (void)resetQueue
{
    if (_queue) {
        [_queue removeAllObjects];
    }
}

#pragma mark - socket operation
- (void)commandLoop
{
    while (YES)
    {
        if ( self.queue.count != 0 && self._continue )
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ( self.queue.count == 0 || !self._continue ) return;
                self._continue = NO;
                id object = [self deQueue];
                _startTime = [NSDate date];
                _cmdObject = (ACCommandObject *)object;
                
                NSData *cmdData = [[_cmdObject.socketObject modelToJSONString] dataUsingEncoding:NSUTF8StringEncoding];
                if (!cmdData) return;
                [self.cmdSocket writeData:cmdData withTimeout:-1 tag:0];
                
                NSLog(@"[sendMsg]:%@", [_cmdObject.socketObject modelToJSONString]);

            });
        }
        else
        {
            [NSThread sleepForTimeInterval:0.4];
        }
    }
}

- (void)startCommandSocketSession
{
    self.cmdSocket = [[AsyncSocket alloc] initWithDelegate:self];
    [self.cmdSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    
    if (![self.cmdSocket isConnected]) {
        [self.cmdSocket connectToHost:CAMERA_IP onPort:CAMERA_CMD_PORT withTimeout:TIMEOUT error:nil];
    }
    [self resetQueue];
    __continue = YES;
}

- (void)stopCommandSocketSession
{
    [_cmdSocket disconnect];
    _cmdSocket.userData = SocketOfflineByUser;
}

- (void)startDataSocketSession
{
    self.datSocket = [[AsyncSocket alloc] init];
    [self.datSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    
    if (![self.datSocket isConnected]) {
        [self.datSocket connectToHost:CAMERA_IP onPort:CAMERA_CMD_PORT withTimeout:TIMEOUT error:nil];
    }
}

- (void)stopDataSocketSession
{
    [_datSocket disconnect];
    _datSocket.userData = SocketOfflineByUser;
}


#pragma mark - delegate
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    if (sock == self.cmdSocket) {
        NSLog(@"didConnectToHost  7878");
        [ACCommandService startSession];
        [sock readDataWithTimeout:-1 tag:0];
    } else {
        NSLog(@"didConnectToHost  8787");
    }
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    if (sock == _cmdSocket) {
        [self handleCommandSocket:sock data:data tag:tag];
        self._continue = YES;
        [self.cmdSocket readDataWithTimeout:-1 buffer:nil bufferOffset:0 maxLength:0 tag:0];
    } else if (sock == _datSocket) {
        [self handleDataSocket:sock data:data tag:tag];
    }
}

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
    NSLog(@"didAcceptNewSocket");
}

#pragma mark - handle
- (void)handleCommandSocket:(AsyncSocket *)sock data:(NSData *)data tag:(long)tag
{
    if (!_cmdSocketData) {
        _cmdSocketData = [[NSMutableData alloc] init];
    }
    
    [self.cmdSocketData appendData:data];
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:self.cmdSocketData options:NSJSONReadingAllowFragments error:nil];
    
    if (!dic) {
        NSLog(@"[not a complete package]");
        return;
    }
    _cmdSocketData = nil;
    
    NSLog(@"[recvMsg]:%ld bytes\n%@", (unsigned long)data.length, dic);
    
    NSString *msg_id = [NSString stringWithFormat:@"%d", [dic[@"msg_id"] intValue]];

    int rval = [dic[@"rval"] intValue];
    if (rval < 0) {
        if ([self failureHandlerIsSupport:msg_id]) {
            NSArray *handlers = self.failureHanlders[msg_id];
            if (handlers) {
                [handlers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    void (^block)(NSDictionary *dictionnary) = obj;
                    block(dic);
                }];
            }
        }
        
        if (_cmdObject.failureBlock) {
            _cmdObject.failureBlock(dic);
        }
        
        return;
    }
    
    if ([self successHandlerIsSupport:msg_id]) {
        NSArray *handlers = self.successHandlers[msg_id];
        if (handlers) {
            [handlers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                void (^block)(NSDictionary *dictionnary) = obj;
                block(dic);
            }];
        }
    }
    
    if (_cmdObject.successBlock) {
        _cmdObject.successBlock(dic);
    }
}
- (void)systemProbe
{
//    __weak typeof(self) weakSelf = self;

    //监听Start session
    NSString *msgID = [NSString stringWithFormat:@"%u", MSGID_START_SESSION];
    [self addObserverForMsgId:msgID success:^(id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        [ACSocketService sharedSocketService].tokenNumber = [dic[@"param"] intValue];
        [ACCommandService getAllCurrentSettings];
    } failure:^(id errorObject) {
        
    }];
    
    //监听get all current settings
    msgID = [NSString stringWithFormat:@"%u", MSGID_GET_ALL_CURRENT_SETTINGS];
    [self addObserverForMsgId:msgID success:^(id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSArray *settings = dic[@"param"];
        [CameraHAM shared].settings = [[ACSettings alloc] initWithArray:settings];
        [ACCommandService getOptionsList];
    } failure:^(id errorObject) {
        
    }];
    
    //监听各种options
    msgID = [NSString stringWithFormat:@"%u", MSGID_GET_SINGLE_SETTING_OPTIONS];
    [self addObserverForMsgId:msgID success:^(id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSArray *options = dic[@"options"];
        NSString *param = dic[@"param"];
        [[CameraHAM shared].settingOptions setValue:param withOptions:options];

    } failure:^(id errorObject) {
        
    }];
}
- (void)handleDataSocket:(AsyncSocket *)sock data:(NSData *)data tag:(long)tag
{
    
}

#pragma mark - system msg id handler register
- (void)addObserverForMsgId:(NSString *)msg_id
                  success:(void (^)(id responseObject))success
                  failure:(void (^)(id errorObject))failure
{
    NSMutableArray *successHandlers = (NSMutableArray *)self.successHandlers[msg_id];
    if (!successHandlers) {
        successHandlers = [NSMutableArray array];
        self.successHandlers[msg_id] = successHandlers;
    }
    if (success) {
        [successHandlers addObject:[success copy]];
    }
    
    NSMutableArray *failureHandlers = (NSMutableArray *)self.failureHanlders[msg_id];
    if (!failureHandlers) {
        failureHandlers = [NSMutableArray array];
    }
    if (failure) {
        [failureHandlers addObject:[failure copy]];
    }
}
- (BOOL)successHandlerIsSupport:(NSString *)msg_id
{
    NSArray *allKeys = [self.successHandlers allKeys];
    if ([allKeys containsObject:msg_id]) {
        return YES;
    }
    return NO;
}
- (BOOL)failureHandlerIsSupport:(NSString *)msg_id
{
    NSArray *allKeys = [self.failureHanlders allKeys];
    if ([allKeys containsObject:msg_id]) {
        return YES;
    }
    return NO;
}

- (void)sendCommandWithSocketObject:(ACSocketObject *)socketObj success:(void (^)(id))success failure:(void (^)(id))failure
{
    ACCommandObject *obj = [ACCommandObject objectWithSocketObject:socketObj success:success failure:failure];
    [self enQueue:obj];
}

@end
