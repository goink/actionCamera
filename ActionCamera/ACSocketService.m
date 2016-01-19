//
//  ACSocketService.m
//  ActionCamera
//
//  Created by 范桂盛 on 16/1/18.
//  Copyright © 2016年 AC. All rights reserved.
//

#import "ACSocketService.h"
#import "ACSocketObject.h"

#define STATUS_LOADING @"status_loading"
#define STATUS_WAITING @"status_waiting"
#define STATUS_PREPARE @"status_prepare"
#define STATUS_CANCEL @"status_cancel"

#define CAMERA_IP @"192.168.42.1"
#define CAMERA_CMD_PORT 7878
#define CMAERA_DAT_PORT 8787

#define TIMEOUT 20

enum{
    SocketOfflineByServer,
    SocketOfflineByUser,
    SocketOfflineByOffline,//wifi 断开
};

@interface ACSocketService ()
@property (nonatomic, strong) NSMutableArray *queue;
@property (nonatomic, assign) BOOL _continue;
@property (nonatomic, strong) ACSocketObject *socketObject;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *stopTime;
@end

@implementation ACSocketService
static ACSocketService *socketService = nil;

#pragma mark - 单例
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
#pragma mark - 命令队列操作
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
#pragma mark - Socket操作
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
//            NSLog(@"+++");
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
    if (sock == self.cmdSocket)
    {
        //这是异步返回的连接成功，
        NSLog(@"didConnectToHost  8787");

    }
    else
    {
        NSLog(@"didConnectToHost  7878");

        [sock readDataWithTimeout:-1 tag:0];
        
    }
    
}
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
//    if (sock == _cmdSocket)
    {
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"---%@", str);
    }
    
}
@end
