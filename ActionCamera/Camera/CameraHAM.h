//
//  CameraHAM.h
//  ActionCamera
//
//  Created by neo on 16/2/18.
//  Copyright © 2016年 AC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ACDefines.h"
#import "ACSocketService.h"
#import "ACSocketObject.h"
#import "ACCommandService.h"
#import "ACCommandObject.h"
#import "ACSettings.h"
#import "ACSettingOptions.h"
#import "ACModeObject.h"
#import "BatteryObject.h"

#import <MobileVLCKit/MobileVLCKit.h>

@protocol CameraHAMDelegate;

//Camera Hardware Abstract Model, 相机硬件抽象模型，维持与相机的状态同步
//应用层只和该对象交互，不直接与相机交互
@interface CameraHAM : NSObject

+ (CameraHAM *)shared;

@property (nonatomic,   weak) id <CameraHAMDelegate> delegate;

- (void)resetDetectoerTimerWithInter:(NSTimeInterval)interval;

@property (nonatomic, strong) VLCMediaPlayer *mediaPlayer;

//当前录像状态
@property (nonatomic, assign) CameraStatus cameraStatus;
@property (nonatomic, strong) BatteryObject *battery;
@property (nonatomic, strong) ACSettings  *settings;
@property (nonatomic, strong) ACSettingOptions *settingOptions;

//SettingCameraViewController2中显示项目列表，有但不一定需要显示，在这几个列表中控制显示项目
@property (nonatomic, strong) NSMutableArray *videoSettings;
@property (nonatomic, strong) NSMutableArray *photoSettings;
@property (nonatomic, strong) NSMutableArray *deviceSettings;

//相机是否准备好。正确获取到allcurrentsetting和options之后，定义为相机准备好，可以进行相关参数设置，包括模式切换
@property (nonatomic, assign) BOOL isReady;

@property (nonatomic, strong) NSString *model;
@property (nonatomic, strong) NSString *rtsp;
@property (nonatomic, strong) NSString *camera_album_status;

@property (nonatomic, assign) BOOL isZ13;
@property (nonatomic, assign) BOOL isZ16;
@property (nonatomic, assign) BOOL isSessionStarted;
@property (nonatomic, assign) BOOL isConnectedByOtherApp;

- (void)resetCameraStatus;

- (BOOL)isCameraWiFiConnected;
- (BOOL)isSessionConnected;
- (BOOL)isEnterCameraAlbum;
- (void)resetVideoFlow;
- (void)attachCameraPreViewTo:(UIView *)drawView;
- (void)preViewPlay;
- (void)preViewStop;
- (BOOL)isPreViewPlaying;
- (BOOL)isRatio4T3;

/**
 *  重新调整相机模式的排放顺序，UI上显示的位置在这里控制
 */
- (void)resortModesOrder;

/**
*  _modes中存的是所有（包括z13和z16）相机出现过的模式，使用者需要在按需使用，根据模式名字读取.
* 每次"capture"、"record"互相切时，subModes从modes抽取子模式.
*/
@property (nonatomic, strong) NSMutableDictionary *modes;
/**
 *  保存当前大模式下的小模式列表，保存的是ACModeObject对象
 */
@property (nonatomic, strong) NSMutableArray *subModes;
@property (nonatomic, strong) NSMutableArray *subModesCapture;
@property (nonatomic, strong) NSMutableArray *subModesRecord;
/**
 *  保存当前小模式中选中的模式，也即当前相机模式，与lastMode一样
 */
@property (nonatomic, strong) ACModeObject *subMode;
/**
 *  subMode在subModes中的index
 */
@property (nonatomic, assign) NSUInteger subModeIndex;

@property (nonatomic, strong) NSString *lastMode;

@property (nonatomic, strong) ACModeObject *lastSubMode;

- (void)cameraStatusSyncing;

//延时摄像时间
@property (nonatomic, assign) NSUInteger realTime;
@property (nonatomic, assign) NSUInteger videoTime;

- (BOOL)isModeCapture;
- (BOOL)isModeRecord;

- (BOOL)isSubModePreciseQuality;
- (BOOL)isSubModePreciseSelfQuality;
- (BOOL)isSubModePreciseQualityCont;
- (BOOL)isSubModeBurstQuality;

- (BOOL)isSubModeRecord;
- (BOOL)isSubModeRecordTimelapse;
- (BOOL)isSubModeRecordSlowMotion;
- (BOOL)isSubModeRecordLoop;
- (BOOL)isSubModeRecordPhoto;

- (void)cameraMode:(NSString *)mode
           success:(void (^)(id responseObject))success
           failure:(void (^)(id errorObject))failure;

- (void)switchToBigMode:(NSString *)mode
                success:(void (^)(id responseObject))success
                failure:(void (^)(id errorObject))failure;


//capture
- (void)captureWithCommandSuccess:(void (^)(id responseObject))cmdSuccess
                   ifCanStopBlock:(void (^)(BOOL canStop))canStopBlock
                         complete:(void (^)(id responseObject))complete
                          failure:(void (^)(id errorObject))failure;

- (void)captureStopWithSuccess:(void (^)(id responseObject))success
                    failure:(void (^)(id errorObject))failure;

//record
- (void)recordWithCommandSuccess:(void (^)(id responseObject))success
                        progress:(void (^)(id responseObject))progress
                         failure:(void (^)(id errorObject))failure;

- (void)recordStopWithSuccess:(void (^)(id responseObject))success
                      failure:(void (^)(id errorObject))failure;

- (void)getRecordTimeWithSuccess:(void (^)(id responseObject))success
                         failure:(void (^)(id errorObject))failure;

/**
 *  是否支持抓拍
 */
- (BOOL)isPIVSupport;

- (void)takePIV:(NSString *)mode
        success:(void (^)(id responseObject))success
        failure:(void (^)(id errorObject))failure;


- (NSString *)getResolutionString;


- (void)listenOnNotification:(NSString *)notification
                   forTarget:(id)target
                     success:(void (^)(id responseObject))success
                     failure:(void (^)(id errorObject))failure;

- (void)removeListener:(NSObject *)notification forTarget:(id)target;

- (BOOL)isVideoStandardPAL;
- (BOOL)isVideoStandardNTSC;

@end




@protocol CameraHAMDelegate <NSObject>

@optional
- (void)cameraHAM:(CameraHAM *)cameraHAM state:(NSString *)state;

@end