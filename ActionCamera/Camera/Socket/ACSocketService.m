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
#import "JSONHelper.h"
#import "NSObject+YYModel.h"
#import "AFNetworkReachabilityManager.h"

@interface notifyWrapper : NSObject <NSCopying>

- (id)initWithHandler:(void (^)(id sender))handler;

@property (nonatomic, copy) void (^handler)(id sender);

@end

@implementation notifyWrapper

- (id)initWithHandler:(void (^)(id sender))handler
{
    self = [super init];
    if (!self) return nil;
    
    self.handler = handler;
    
    return self;
}
- (id)copyWithZone:(NSZone *)zone
{
    return [[notifyWrapper alloc] initWithHandler:self.handler];
}
@end

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
@property (nonatomic, strong) NSMutableDictionary *notifyHanlders;//字典以通知名为key，value是一个"以target为key，以block为value的字典“
//@property (nullable, copy) void (^completionBlock)(void);
@property (nonatomic, strong) NSTimer *heartBeatTimer;

@end

@implementation ACSocketService
static ACSocketService *socketService = nil;

#pragma mark - life cycle
+ (ACSocketService *)shared {
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
        
        self.successHandlers = [NSMutableDictionary dictionary];
        self.failureHanlders = [NSMutableDictionary dictionary];
        self.notifyHanlders  = [NSMutableDictionary dictionary];
        
        [self systemProbe];
        __continue = YES;
        
        [CameraHAM shared].isReady = NO;
        [CameraHAM shared].isSessionStarted = NO;
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
    //暂时绕过这一层，直接给老框架发送
//    _startTime = [NSDate date];
//    _cmdObject = (ACCommandObject *)object;
//    [[ASSocketServe sharedSocketServe] sendMsgOnThread:[_cmdObject.socketObject modelToJSONString]];
//    
//    return;
    
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
            if ( self.queue.count == 0 || !self._continue ) return;
            self._continue = NO;
            id object = [self deQueue];
            _startTime = [NSDate date];
            _cmdObject = (ACCommandObject *)object;
            
            NSData *cmdData = [[_cmdObject.socketObject modelToJSONString] dataUsingEncoding:NSUTF8StringEncoding];
            if (!cmdData) return;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.cmdSocket writeData:cmdData withTimeout:-1 tag:0];
                [self resetHeartBeat];
            });
        
            if (_cmdObject.socketObject.msg_id != MSGID_HEARTBEAT) {
                NSLog(@"[sendMsg]-:%@", [_cmdObject.socketObject modelToJSONString]);
            }
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
    self.datSocket = [[AsyncSocket alloc] initWithDelegate:self];
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
    
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (![str containsString:@"16777244"]) {
        DDLogError(@"[recvMsg]:%@", str);
    }
    
        
    NSMutableArray *mutArr;
    if([[str substringFromIndex:str.length-1] isEqualToString:@"}"] )
    {
        mutArr = [JSONHelper paserData:&_cmdSocketData];
    }
    
    for (NSDictionary *dic in mutArr)
    {
        __continue = YES;
        
        //NSLog(@"--[recvMsg]:%ld bytes\n%@", (unsigned long)data.length, dic);
        
        NSString *msg_id = [NSString stringWithFormat:@"%d", [dic[@"msg_id"] intValue]];
        
        //1793命令说明有另外的app尝试连接当前相机，本app需要在800ms内回复该消息，否则相机会将控制权交给另外一个app
        //[self check1793message:msg_id];
        
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
                _cmdObject = nil;
            }
            
        } else {
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
                _cmdObject = nil;
            }
        }
    }
}

- (void)handleDataSocket:(AsyncSocket *)sock data:(NSData *)data tag:(long)tag
{
    
}

- (void)check1793message:(NSString *)msgid
{
//    if ([msgid isEqualToString:@"1793"]) {
//        NSData *cmdData = [[NSString stringWithFormat:@"{\"rval\":0,\"msg_id\":1793,\"token\":%d}",[ASSocketServe sharedSocketServe].tokenNumber] dataUsingEncoding:NSUTF8StringEncoding];
//        NSString *senddata = [[NSString alloc] initWithData:cmdData encoding:NSUTF8StringEncoding];
//        NSLog(@"++++++++++++++send:%@",senddata);
//        [self.cmdSocket writeData:cmdData withTimeout:-1 tag:0];
//    }
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

- (void)listenOnNotification:(NSString *)notification forTarget:(id)target success:(void (^)(id))success failure:(void (^)(id))failure
{
    NSMutableDictionary *notifyListeners = self.notifyHanlders[notification];
    if (!notifyListeners) {
        notifyListeners = [NSMutableDictionary dictionary];
        self.notifyHanlders[notification] = notifyListeners;
    }
    notifyWrapper *t = [[notifyWrapper alloc] initWithHandler:[success copy]];
    [notifyListeners setValue:t forKey:target];
}

- (void)removeListener:(NSObject *)notification forTarget:(id)target
{
    NSMutableDictionary *notifyListeners = self.notifyHanlders[notification];
    if (notifyListeners) {
        [notifyListeners removeObjectForKey:target];
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



#pragma mark - 系统级命令监听器，主要影响cameraHAM中的参数
- (void)systemProbe
{
    __weak typeof(self) weakSelf = self;
    
    //监听Start session
    NSString *msgID = [NSString stringWithFormat:@"%u", MSGID_START_SESSION];
    [self addObserverForMsgId:msgID success:^(id responseObject) {
        NSLog(@"------------START_SESSION success success---%@", responseObject);
        [[CameraHAM shared] resetCameraStatus];
        
        NSDictionary *dic = (NSDictionary *)responseObject;
        
        [ACSocketService shared].tokenNumber = [dic[@"param"] intValue];
        
        [CameraHAM shared].isSessionStarted = YES;
        [CameraHAM shared].isConnectedByOtherApp = NO;
        
        NSString *model = [dic[@"model"] uppercaseString];
        if (model && [model isEqualToString:@"Z16"]) {
            [CameraHAM shared].model = model;
            [CameraHAM shared].isZ16 = YES;
            [CameraHAM shared].isZ13 = NO;
        } else {
            [CameraHAM shared].model = @"Z13";
            [CameraHAM shared].isZ16 = NO;
            [CameraHAM shared].isZ13 = YES;
        }
        
        //重新调整相机模式列表的排列顺序为UI需要显示的顺序
        [[CameraHAM shared] resortModesOrder];
        
        NSString *rtsp = dic[@"rtsp"];
        if (rtsp) {
            [CameraHAM shared].rtsp = rtsp;
        } else {
            [CameraHAM shared].rtsp = CAMERA_IP_RTSP;
        }
        
        NSString *album = [[dic objectForKey:ALBUM] stringValue];
        if (album) {
            if ([album isEqualToString:@"1"]) {
                [CameraHAM shared].camera_album_status = ENTER_ALBUM;
            }
        } else {
            [CameraHAM shared].camera_album_status = EXIT_ALBUM;
        }
        
        [CameraHAM shared].isReady = NO;
        [ACCommandService getAllCurrentSettings];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_SYSTEM_NETWORK_CHANGED object:@(AFNetworkReachabilityStatusNotReachable)];//0,camera wifi
        NSLog(@"------------START_SESSION success success---%@", @"OKOKOKOKOK");
    } failure:^(id errorObject) {
        NSLog(@"------------START_SESSION FAIL FAIL---%@", errorObject);
        NSDictionary *dic = (NSDictionary *)errorObject;
        if ([dic[@"rval"] integerValue] == -3) {
            [CameraHAM shared].isConnectedByOtherApp = YES;
        }
        [[CameraHAM shared] resetCameraStatus];
//        [XYConnectClient sharedInstance].connectState = XYConnectStateFailed;
    }];
    
    //监听stop session
    msgID = [NSString stringWithFormat:@"%u", MSGID_STOP_SESSION];
    [self addObserverForMsgId:msgID success:^(id responseObject) {
        [[CameraHAM shared] resetCameraStatus];
//        [XYConnectClient sharedInstance].connectState = XYConnectStateFailed;
    } failure:^(id errorObject) {
        
    }];
    
    //监听get all current settings
    msgID = [NSString stringWithFormat:@"%u", MSGID_GET_ALL_CURRENT_SETTINGS];
    [self addObserverForMsgId:msgID success:^(id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSArray *settings = dic[@"param"];
        [CameraHAM shared].settings = [[ACSettings alloc] initWithArray:settings];
        //[ACCommandService syncCameraClock];
        
        if (![CameraHAM shared].isReady) {
            if ([CameraHAM shared].isZ16) {
                [ACCommandService setClientinfo];
            }
            [ACCommandService resetVideoFlow];
            [ACCommandService getOptionsListPhase1];
            //[ACCommandService getSettingWithType:APP_STATUS];
            [ACCommandService getBatteryStatus];
        }
        
    } failure:^(id errorObject) {
        
    }];
    
    //监听各种options
    msgID = [NSString stringWithFormat:@"%u", MSGID_GET_SINGLE_SETTING_OPTIONS];
    [self addObserverForMsgId:msgID success:^(id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSArray *options = dic[@"options"];
        NSString *param = dic[@"param"];
        
        if (  ([param isEqualToString:VIDEO_RESOLUTION]
            || [param isEqualToString:VIDEO_PHOTO_RESOLUTION]
            || [param isEqualToString:PHOTO_SIZE])) {
            options = [options sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(NSString* obj1, NSString* obj2) {
                return [obj2 compare:obj1 options:NSNumericSearch range:NSMakeRange(0, 4)];
            }];
        }
        
        if ([CameraHAM shared].isZ13 && [param isEqualToString:TIMELAPSE_VIDEO_RESOLUTION]) {
            //Z13延时摄像返回列表是假的，其实只支持两种分辨率，特殊处理，写死
            if ([[CameraHAM shared] isVideoStandardNTSC]) {
                options = [NSArray arrayWithObjects:@"1920x1080 60P 16:9",@"1280x960 60P 4:3", nil];
            } else {
                options = [NSArray arrayWithObjects:@"1920x1080 48P 16:9",@"1280x960 48P 4:3", nil];
            }
        }
        
        [[CameraHAM shared].settingOptions setValue:param withOptions:options];
        
        //使用photo_size作为相机状态同步完成的标志
        NSString *lastOptionName = getOptionName(photo_size);
        if ([param isEqualToString:lastOptionName]) {
            [CameraHAM shared].isReady = YES;
            [CameraHAM shared].cameraStatus = CameraStatusNormal;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_CAMERA_IS_READY object:nil];
            [weakSelf enableHeartBeat];
        }
    } failure:^(id errorObject) {
        
    }];
    
    //监听各种setting
    msgID = [NSString stringWithFormat:@"%u", MSGID_SET_SETTING];
    [self addObserverForMsgId:msgID success:^(id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSString *type = dic[@"type"];
        NSString *param = dic[@"param"];
        if (type && param) {
            [[CameraHAM shared].settings setValue:param forSetting:type];
        }
    } failure:^(id errorObject) {
        
    }];
    
    msgID = [NSString stringWithFormat:@"%u", MSGID_GET_SETTING];
    [self addObserverForMsgId:msgID success:^(id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSString *type = dic[@"type"];
        NSString *param = dic[@"param"];
        if (type && param) {
            [[CameraHAM shared].settings setValue:param forSetting:type];
        }
    } failure:^(id errorObject) {
        
    }];
    
    //监听获取相机电源状态
    msgID = [NSString stringWithFormat:@"%u", MSGID_GET_BATTERY_LEVEL];
    [self addObserverForMsgId:msgID success:^(id responseObject) {
        
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSString *type = dic[@"type"];
        NSString *param = dic[@"param"];
        
        if ([type isEqualToString:@"battery"] || [type isEqualToString:@"adapter"]) {
            [CameraHAM shared].battery.type = type;
            [CameraHAM shared].battery.level = [param intValue];
        }
    } failure:^(id errorObject) {
        
    }];
    
    //监听相机通知 msg_id == 7
    msgID = [NSString stringWithFormat:@"%u", MSGID_CALLBACK_NOTIFICATION];
    [self addObserverForMsgId:msgID success:^(id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSString *type = dic[@"type"];
        NSString *param = dic[@"param"];
        
        if ([type isEqualToString:@"battery"] || [type isEqualToString:@"adapter"]) {
            [CameraHAM shared].battery.type = type;
            [CameraHAM shared].battery.level = [param intValue];
        }
        if ([type isEqualToString:@"adapter_status"] && ([@[@"0", @"1"] containsObject:param])) {
            if ([param isEqualToString:@"0"]) {
                [CameraHAM shared].battery.type = @"battery";
            }
            if ([param isEqualToString:@"1"]) {
                [CameraHAM shared].battery.type = @"adapter";
            }
        }
        if ([type isEqualToString:@"battery_status"] && ([@[@"0", @"1"] containsObject:param])) {
            if ([param isEqualToString:@"0"]) {
                [CameraHAM shared].battery.type = @"adapter";
            }
            if ([param isEqualToString:@"1"]) {
                [CameraHAM shared].battery.type = @"battery";
            }
        }
        if ([type isEqualToString:@"sd_card_status"] && ([@[@"insert", @"remove"] containsObject:param])) {
                [CameraHAM shared].settings.sd_card_status = param;
        }
        
        if ([type isEqualToString:@"setting_changed"]) {
            NSString *param = responseObject[@"param"];
            NSString *value = responseObject[@"value"];
            
            if (param && value) {
                [[CameraHAM shared].settings setValue:value forSetting:param];
            }
        }
        
        if ([CameraHAM shared].isZ13) {
            if ([type isEqualToString:@"switch_to_rec_mode"]) {
                [CameraHAM shared].settings.system_mode = RECORD;
            }
            if ([type isEqualToString:@"switch_to_cap_mode"]) {
                [CameraHAM shared].settings.system_mode = CAPTURE;
            }
        }

        NSMutableDictionary *blocksDic = weakSelf.notifyHanlders[type];
        if (blocksDic) {
            [blocksDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                //key 是监听者自己self
                notifyWrapper *t = obj;
                void (^block)(NSDictionary *dictionnary) = t.handler;
                block(dic);
            }];
        }
    } failure:^(id errorObject) {
        
    }];
}


#pragma mark - 心跳启动停止
- (void)enableHeartBeat
{
    if (!_heartBeatTimer) {
        _heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:HEARTBEAT_INTERVAL target:self selector:@selector(heartBeatOperation) userInfo:nil repeats:YES];
    }
}
- (void)disableHeartBeat
{
    if (_heartBeatTimer) {
        [_heartBeatTimer invalidate];
        _heartBeatTimer = nil;
    }
}
- (void)resetHeartBeat
{
    if (_heartBeatTimer) {
        [_heartBeatTimer invalidate];
        _heartBeatTimer = nil;
        _heartBeatTimer = [NSTimer scheduledTimerWithTimeInterval:HEARTBEAT_INTERVAL target:self selector:@selector(heartBeatOperation) userInfo:nil repeats:YES];
    }
}
- (void)heartBeatOperation
{
    if ([CameraHAM shared].isZ16) {
//        [LGSendCommandHandler triggerHeartBeat];
        [ACCommandService execute:MSGID_HEARTBEAT params:nil success:nil failure:nil];
    }
    
}


@end
