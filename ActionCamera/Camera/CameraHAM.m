//
//  CameraHAM.m
//  ActionCamera
//
//  Created by neo on 16/2/18.
//  Copyright © 2016年 AC. All rights reserved.
//

#import "CameraHAM.h"
#import "AsyncSocket.h"
#import "ACDefines.h"

#import "ACSocketService.h"
#import "ACSocketObject.h"
#import "ACCommandService.h"
#import "ACCommandObject.h"
#import "ACSettings.h"
#import "ACSettingOptions.h"

@interface CameraHAM ()
//相机wifi链接探测器定时器，用于周期性检查手机是否连上了相机的AP wifi，如果连上，则自动创建命令和数据端口链接，并获取相机状态
@property (nonatomic, strong) NSTimer *detectorTimer;
@end

@implementation CameraHAM

static CameraHAM *actionCamera = nil;
#pragma mark - 初始化，生命
+ (CameraHAM *)shared {
    @synchronized(self) {
        if(actionCamera == nil) {
            actionCamera = [[[self class] alloc] init];
        }
    }
    return actionCamera;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (actionCamera == nil)
        {
            actionCamera = [super allocWithZone:zone];
            return actionCamera;
        }
    }
    return nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        //初始化一些其他内部成员属性
        
        if (!_detectorTimer) {
            //每3秒扫描一次
            _detectorTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(cameraWIFiDetector) userInfo:nil repeats:YES];
        }
        
        self.settingOptions = [ACSettingOptions new];
    }
    return self;
}

#pragma mark - 
- (BOOL)isCameraWiFiConnected
{
    return [[ACSocketService sharedSocketService].cmdSocket isConnected];
}

- (void)cameraWIFiDetector
{
//    NSLog(@"cameraWIFiDetector++");
    if (![self isCameraWiFiConnected]) {
        [ACCommandService startCommandSocketSession];
    }
}

@end
