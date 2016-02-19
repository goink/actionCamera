//
//  CameraHAM.h
//  ActionCamera
//
//  Created by neo on 16/2/18.
//  Copyright © 2016年 AC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACDefines.h"
#import "ACSocketService.h"
#import "ACSocketObject.h"
#import "ACCommandService.h"
#import "ACCommandObject.h"
#import "ACSettings.h"
#import "ACSettingOptions.h"

@protocol CameraHAMDelegate;

//Camera Hardware Abstract Model, 相机硬件抽象模型，维持与相机的状态同步
//应用层只和该对象交互，不直接与相机交互
@interface CameraHAM : NSObject

@property (nonatomic,   weak) id <CameraHAMDelegate> delegate;

//当前模式
@property (nonatomic, assign) CurrentMode currentMode;

//当前拍照模式
@property (nonatomic, assign) CurrentPhotoMode currentPhotoMode;

//将要设置的拍照模式
@property (nonatomic, assign) CurrentPhotoMode willSetPhotoMode;

//当前录像模式
@property (nonatomic, assign) CurrentRecordMode currentRecordMode;

//将要设置的录像模式
@property (nonatomic, assign) CurrentRecordMode willSetRecordMode;

//当前录像状态
@property (nonatomic, assign) CameraStatus cameraStatus;

@property (nonatomic, strong) ACSettings  *settings;
@property (nonatomic, strong) ACSettingOptions *settingOptions;

@property (nonatomic, strong) NSString *model;
@property (nonatomic, strong) NSString *rtsp;

@property (nonatomic, assign) BOOL isZ13;
@property (nonatomic, assign) BOOL isZ16;

+ (CameraHAM *)shared;

- (BOOL)isCameraWiFiConnected;
- (BOOL)isSessionConnected;

@end

@protocol CameraHAMDelegate <NSObject>

@optional
- (void)cameraHAM:(CameraHAM *)cameraHAM state:(NSString *)state;

@end