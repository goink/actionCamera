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
#import "ACSettings.h"

@interface ACSocketService ()
@property (nonatomic, strong) NSMutableArray *queue;
@property (nonatomic, assign) BOOL _continue;
@property (nonatomic, strong) ACSocketObject *socketObject;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *stopTime;
@property (strong, nonatomic) NSMutableData *cmdSocketData;
@property (strong, nonatomic) NSMutableData *datSocketData;

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
        [NSThread detachNewThreadSelector:@selector(commandLoop) toTarget:self withObject:nil];
        
    }
    return self;
}
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}
//- (NSMutableData *)cmdSocketData
//{
//    if (!_cmdSocketData) {
//        _cmdSocketData = [[NSMutableData alloc] init];
//    }
//    return _cmdSocketData;
//}
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
                _socketObject = object;
                
                NSData *cmdData = [_socketObject.cmd dataUsingEncoding:NSUTF8StringEncoding];
                if (!cmdData) return;
                [self.cmdSocket writeData:cmdData withTimeout:-1 tag:0];
                
                _socketObject.status = STATUS_LOADING;
                NSLog(@"[sendMsg]:%@", _socketObject.cmd);

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

- (void)sendCommandToSocket:(NSString *)cmd
{
    if (!cmd) {
        return;
    }
    ACSocketObject *obj = [[ACSocketObject alloc] initWithCommand:cmd];
    [self enQueue:obj];
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
    }
    else if (sock == _datSocket){
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
        NSLog(@"not a complete package---");
        return;
    }
    _cmdSocketData = nil;
    
    NSLog(@"[recvMsg]:%ld bytes\n%@", data.length, dic);
    
    int msg_id  = [dic[@"msg_id"] intValue];
    NSLog(@"msg_id:%d", msg_id);
    
    int rval = [dic[@"rval"] intValue];
    if (rval < 0) {
        return;
    }

    switch (msg_id) {
        case MSGID_START_SESSION:
        {
            self.tokenNumber = [dic[@"param"] intValue];
            break;
        }
        case MSGID_GET_ALL_CURRENT_SETTINGS:
        {
            NSArray *settings = dic[@"param"];
            NSLog(@"setting count:%ld", settings.count);
            
            _allSettings = [[ACSettings alloc] initWithArray:settings];
            NSLog(@"all settings:%@", _allSettings);
            break;
        }
        default:
            break;
    }
    
}

- (void)handleDataSocket:(AsyncSocket *)sock data:(NSData *)data tag:(long)tag
{
    
}
@end
