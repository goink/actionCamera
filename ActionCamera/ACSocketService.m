//
//  ACSocketService.m
//  ActionCamera
//
//  Created by 范桂盛 on 16/1/18.
//  Copyright © 2016年 AC. All rights reserved.
//

#import "ACSocketService.h"

@interface ACSocketService ()
@property (nonatomic, strong) NSMutableArray *queue;
@property (nonatomic, assign) BOOL __continue;
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
        if (!self.queue) {
            
        }
        [NSThread detachNewThreadSelector:@selector(sendCommand) toTarget:self withObject:nil];
        
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
    if (!self.queue) {
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
    while (YES) {
        
        if ( self.queue.count != 0 && self.__continue )
        {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ( self.queue.count == 0 || !self.continuance )
                {
                    return ;
                }
                self.__continue = NO;
                id object = [self deQueue];
                cmdStartTime = [NSDate date];
                _dObject = object;
                NSData *cmdData = [_dObject.cmd dataUsingEncoding:NSUTF8StringEncoding];
                if (!cmdData) return;
                _dObject.status = STATUS_LOADING;
                
                [self.socket writeData:cmdData withTimeout:-1 tag:0];
                NSLog(@"【sendMsg】:%@",_dObject.cmd);
                NSDictionary *paramDic = @{MISTAT_CAMERACOMMAND:[@(_dObject.msg_id) stringValue]};
                [XYStatUtil recordCountEvent:MISTAT_CAMERACOMMAND key:MISTAT_COMMAND_SEND dictionary:paramDic];
                
            });
            
        }
        else
        {
            
            [NSThread sleepForTimeInterval:0.1];
        }
    }
}
@end
