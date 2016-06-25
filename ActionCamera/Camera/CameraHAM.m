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
#import "ACModeObject.h"
#import "NSString+Case.h"
#import "SettingObject.h"
#import "SystemInfoHelper.h"
#import "StringHelper.h"

@interface CameraHAM () <VLCMediaPlayerDelegate, NSCopying>
//相机wifi链接探测器定时器，用于周期性检查手机是否连上了相机的AP wifi，如果连上，则自动创建命令和数据端口链接，并获取相机状态
@property (nonatomic, strong) NSTimer *detectorTimer;

@end


@implementation CameraHAM

static CameraHAM *actionCamera = nil;
#pragma mark - 初始化，生命周期
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

- (id)copyWithZone:(NSZone *)zone
{
    return [CameraHAM shared];
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
        self.isSessionStarted = NO;
        self.isConnectedByOtherApp = NO;
        self.camera_album_status = EXIT_ALBUM;
        self.cameraStatus = CameraStatusNormal;
        
        [self setupMediaPlayer];
        
        _battery = [BatteryObject new];
        _battery.type = @"battery";
        _battery.level = 0;
        _realTime = 0;
        _videoTime = 0;
        
        self.isReady = YES;
        
        
        [self setupModes];
        
        [self initNotificationListeners];
    }
    return self;
}

#pragma mark - 相机状态
- (void)resetCameraStatus
{
    self.isReady = NO;
    self.isSessionStarted = NO;
    self.isZ13 = NO;
    self.isZ16 = NO;
    self.model = nil;
    [ACSocketService shared].tokenNumber = 0;

    [CameraHAM shared].settingOptions.video_resolution               = nil;
    [CameraHAM shared].settingOptions.burst_capture_number           = nil;
    [CameraHAM shared].settingOptions.video_photo_resolution         = nil;
    [CameraHAM shared].settingOptions.photo_size                     = nil;
    [CameraHAM shared].settingOptions.timelapse_video_resolution     = nil;
    [CameraHAM shared].settingOptions.timelapse_video_resolution_pal = nil;
    
}

- (BOOL)isCameraWiFiConnected
{
//    return [[ACSocketService shared].cmdSocket isConnected];
//    return [[ASSocketServe sharedSocketServe].socket isConnected];
    return YES;
}

- (BOOL)isSessionConnected
{
    return self.isSessionStarted;
}

- (BOOL)isEnterCameraAlbum
{
    NSString *status = self.camera_album_status;
    if (status) {
        if ([status isEqualToString:ENTER_ALBUM]) {
            return YES;
        }
    }
    //没有值 和 EXIT_ALBUM 两个状态都说明相机没有进入相册状态
    return NO;
}

- (BOOL)isPIVSupport
{
    if ([self.settings.piv_enable isEqualToString:ON]) {
        return YES;
    }
    return NO;
}

- (BOOL)isPreViewPlaying
{
    return _mediaPlayer.isPlaying;
}

- (BOOL)isVideoStandardNTSC
{
    if ([self.settings.video_standard isEqualToString:@"NTSC" caseSensitive:NO]) {
        return YES;
    }
    return NO;
}

- (BOOL)isVideoStandardPAL
{
    if ([self.settings.video_standard isEqualToString:@"PAL" caseSensitive:NO]) {
        return YES;
    }
    return NO;
}

#pragma mark - WiFi主动探测
- (void)cameraWIFiDetector
{
    //暂时不打开探测功能
//    if (1) {
//        return;
//    }
    
    //NSLog(@"cameraWIFiDetector++");
    
    if (![self isCameraWiFiConnected]) {
        [ACCommandService startCommandSocketSession];
        //用来控制相机相册状态的，临时，后续相机相册重写也需要依赖CameraHAM单例
        if (![[CameraHAM shared] isSessionStarted])
        {
            if ([SystemInfoHelper isSportCamera]) {
//                [[XYConnectClient sharedInstance] connectCamera];
                [ACCommandService startSession];
            }
        }
    } else {
        if (![[CameraHAM shared] isSessionStarted])
        {
//            [[XYConnectClient sharedInstance] connectCamera];
            [ACCommandService startSession];
        } else {
            [self resetDetectoerTimerWithInter:5];
        }
        
    }
}

- (void)resetDetectoerTimerWithInter:(NSTimeInterval)interval
{
    if (_detectorTimer) {
        [_detectorTimer invalidate];
        _detectorTimer = nil;
    }
    //每3秒扫描一次
    _detectorTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(cameraWIFiDetector) userInfo:nil repeats:YES];
    
}


#pragma mark - 预览流 & 播放器
- (void)setupMediaPlayer
{
    
//    if (!_mediaPlayer)
//    {
//        _mediaPlayer = [[VLCMediaPlayer alloc] initWithOptions:@[@"--noaudio",@"--no-video-title-show",@"--quiet",@"-vvv"]];//
//        _mediaPlayer.delegate = self;
//        
//        [_mediaPlayer setDeinterlaceFilter:@"blend"];
//        
//        _mediaPlayer.media = [VLCMedia mediaWithURL:[NSURL URLWithString:CAMERA_IP_RTSP]];
//        
//        NSMutableDictionary *mediaDictionary = [[NSMutableDictionary alloc] init];
//        //fix http://192.168.8.233:3000/issues/2977
//        //https://forum.videolan.org/viewtopic.php?t=118805
//        [mediaDictionary setObject:@"" forKey:@"extraintf"];
//        [mediaDictionary setObject:NetworkCachingValue forKey:kVLCSettingNetworkCaching];
//        [mediaDictionary setObject:@(0) forKey:@"clock-jitter"];
//        [_mediaPlayer.media addOptions:mediaDictionary];
//    }

}

- (void)mediaPlayerStateChanged:(NSNotification *)aNotification
{
    VLCMediaPlayer *player = (VLCMediaPlayer *)aNotification.object;
    BOOL hasVideoOutput = player.hasVideoOut;
    
    if (player.state != VLCMediaPlayerStateBuffering)
    {
        NSLog(@"[mediaPlayer]:%@, %@, hasVideoOutput:%@", player, VLCMediaPlayerStateToString(player.state), @(hasVideoOutput));
    }
    //出现流停止时，必须立刻手动停止播放器，如果stop太迟了，播放器就再也无法重启
    //相机进入相机相册后，流立即就停了，不能等到enter_album通知到了再停止播放器，应该在此处停止。
    if (player.state == VLCMediaPlayerStateStopped && hasVideoOutput == 0) {
        [_mediaPlayer stop];
    }
}

- (void)resetVideoFlow
{
    NSDictionary *params = @{@"type":@"app_status"};
    
    [ACCommandService execute:MSGID_GET_SETTING params:params success:^(id responseObject) {
        if (_isZ13 || (_isZ16 && ![_settings.app_status isEqualToString:@"vf"])) {
            //z13，或者是z16的非vf状态，两者可以reset video flow
            [ACCommandService resetVideoFlow];
        }
    } failure:^(id error) {
        
    }];
    
    
}

- (void)attachCameraPreViewTo:(UIView *)drawView
{
    if (_mediaPlayer) {
        _mediaPlayer.drawable = drawView;
        //[[CameraHAM shared] resetVideoFlow];
    } else {
        [self setupMediaPlayer];
    }
}

- (void)preViewPlay
{
    NSLog(@"[CameraHAM preViewPlay][isPlaying:%@][hasVideoOut:%@]", @(_mediaPlayer.isPlaying), @(_mediaPlayer.hasVideoOut));
    if (!_mediaPlayer.isPlaying) {
        [_mediaPlayer play];
    }
}

- (void)preViewStop
{
    NSLog(@"[CameraHAM preViewStop][isPlaying:%@][hasVideoOut:%@]", @(_mediaPlayer.isPlaying), @(_mediaPlayer.hasVideoOut));
    [_mediaPlayer stop];
}

#pragma mark - 相机小模式判断

- (BOOL)isModeCapture
{
    NSString *system_mode = [CameraHAM shared].settings.system_mode;
    if ([system_mode isEqualToString:CAPTURE]) {
        return YES;
    }
    return NO;
}

- (BOOL)isModeRecord
{
    NSString *system_mode = [CameraHAM shared].settings.system_mode;
    if ([system_mode isEqualToString:RECORD]) {
        return YES;
    }
    return NO;
}

- (BOOL)isSubModePreciseQuality
{
    if ([_subMode.mode isEqualToString:PRECISE_QUALITY]) {
        return YES;
    }
    return NO;
}
- (BOOL)isSubModePreciseSelfQuality

{
    if ([_subMode.mode isEqualToString:PRECISE_SELF_QUALITY]) {
        return YES;
    }
    return NO;
}

- (BOOL)isSubModePreciseQualityCont
{
    if ([_subMode.mode isEqualToString:PRECISE_QUALITY_CONT]) {
        return YES;
    }
    return NO;
}

- (BOOL)isSubModeBurstQuality
{
    if ([_subMode.mode isEqualToString:BURST_QUALITY]) {
        return YES;
    }
    return NO;
}

- (BOOL)isSubModeRecord
{
    if ([_subMode.mode isEqualToString:RECORD]) {
        return YES;
    }
    return NO;
}

- (BOOL)isSubModeRecordTimelapse
{
    if ([_subMode.mode isEqualToString:RECORD_TIMELAPSE]) {
        return YES;
    }
    return NO;
}

- (BOOL)isSubModeRecordSlowMotion
{
    if ([_subMode.mode isEqualToString:RECORD_SLOW_MOTION]) {
        return YES;
    }
    return NO;
}

- (BOOL)isSubModeRecordLoop
{
    if ([_subMode.mode isEqualToString:RECORD_RECORD_LOOP]) {
        return YES;
    }
    return NO;
}

- (BOOL)isSubModeRecordPhoto
{
    if ([_subMode.mode isEqualToString:RECORD_RECORD_PHOTO]) {
        return YES;
    }
    return NO;
}

#pragma mark - 相机模式模型创建、获取
/**
 *  _modes中存的是所有（包括z13和z16）相机出现过的模式，使用者需要在按需使用，根据模式名字读取
 */
- (void)setupModes
{
    if (!_modes) {
        _modes = [NSMutableDictionary dictionary];
    }
    
    ACModeObject *mode = nil;
    
    //capture
    mode = [ACModeObject new];
    mode.keyOption = nil;//getOptionName(photo_size);
    mode.mode = PRECISE_QUALITY;//普通拍照
    mode.optionUnit = @"";
    mode.optionTitle = @"";
    _modes[mode.mode] = mode;
    
    mode = [ACModeObject new];
    mode.keyOption = getOptionName(precise_cont_time);//延时拍照时间间隔
    mode.mode = PRECISE_QUALITY_CONT;//延时拍照
    mode.optionUnit = @"SEC";
    mode.optionTitle = @"st_timelapse_interval";
    _modes[mode.mode] = mode;
    
    mode = [ACModeObject new];
    mode.keyOption = getOptionName(burst_capture_number);//连拍张数
    mode.mode = BURST_QUALITY;//连续拍照
    mode.optionUnit = @"P / S";
    mode.optionTitle = @"st_burst_rate";
    _modes[mode.mode] = mode;
    
    mode = [ACModeObject new];
    mode.keyOption = getOptionName(precise_selftime);//定时拍照时间
    mode.mode = PRECISE_SELF_QUALITY;//定时拍照
    mode.optionUnit = @"SEC";
    mode.optionTitle = @"st_timer_time";
    _modes[mode.mode] = mode;
    
    //record
    mode = [ACModeObject new];
    mode.keyOption = nil;//getOptionName(video_resolution);
    mode.mode = RECORD;//普通摄像
    mode.optionUnit = @"";
    mode.optionTitle = @"";
    _modes[mode.mode] = mode;
    
    mode = [ACModeObject new];
    mode.keyOption = getOptionName(timelapse_video);//时间间隔
    mode.mode = RECORD_TIMELAPSE;//延时摄像
    mode.optionUnit = @"INT/LEN";
    mode.optionTitle = @"st_timelapse_interval";
    _modes[mode.mode] = mode;
    
    mode = [ACModeObject new];
    mode.keyOption = getOptionName(slow_motion_rate);
    mode.mode = RECORD_SLOW_MOTION;//慢动作
    mode.optionUnit = @"RATE";
    mode.optionTitle = @"st_rate";
    _modes[mode.mode] = mode;
    
    mode = [ACModeObject new];
    mode.keyOption = getOptionName(loop_rec_duration);
    mode.mode = RECORD_RECORD_LOOP;//循环摄像
    mode.optionUnit = @"MIN";
    mode.optionTitle = @"st_loop_duration";
    _modes[mode.mode] = mode;
    
    mode = [ACModeObject new];
    mode.keyOption = getOptionName(record_photo_time);
    mode.mode = RECORD_RECORD_PHOTO;//摄像+拍照
    mode.optionUnit = @"SEC";
    mode.optionTitle = @"st_interval";
    _modes[mode.mode] = mode;
}

- (NSMutableArray *)videoSettings
{
    if (!_videoSettings) {
        _videoSettings = [NSMutableArray array];
    }
    
    [_videoSettings removeAllObjects];
    
    NSString *videoResolutionName = getSettingName(video_resolution);
    NSString *videoResolutionValue = _settings.video_resolution;
    NSString *title = @"setting_video_resolution";
    
    if ([self isSubModeRecord]) {
        videoResolutionName = getSettingName(video_resolution);
        videoResolutionValue = _settings.video_resolution;
    } else if ([self isSubModeRecordTimelapse]) {
        videoResolutionName = getSettingName(timelapse_video_resolution);
        videoResolutionValue = _settings.timelapse_video_resolution;
    } else if ([self isSubModeRecordSlowMotion]) {
        videoResolutionName = getOptionName(slow_motion_rate);
        videoResolutionValue = _settings.slow_motion_rate;
        title = @"st_rate";//@"slow_rate_title";
    } else if ([self isSubModeRecordLoop]) {
        videoResolutionName = getSettingName(video_resolution);
        videoResolutionValue = _settings.video_resolution;
    } else if ([self isSubModeRecordPhoto]) {
        videoResolutionName = getSettingName(video_photo_resolution);
        videoResolutionValue = _settings.video_photo_resolution;
    }
    
    SettingObject *setting = [SettingObject new];
    setting.name = videoResolutionName;
    setting.title = title;
    setting.value = videoResolutionValue;
    setting.type = SettingTypeOptions;
    [_videoSettings addObject:setting];
    
    setting = [SettingObject new];
    setting.name = getSettingName(meter_mode);
    setting.title = @"setting_meter_mode";
    setting.value = _settings.meter_mode;
    setting.type = SettingTypeOptions;
    if (_settings.meter_mode) {
        [_videoSettings addObject:setting];
    }
    
    NSString *support_auto_low_light = _settings.support_auto_low_light;
    
    if ([support_auto_low_light isEqualToString:@"on" caseSensitive:NO]) {
        setting = [SettingObject new];
        setting.name = getSettingName(auto_low_light);
        setting.title = @"setting_auto_low_light";
        setting.value = _settings.auto_low_light;
        setting.type = SettingTypeSwitch;
        if (_settings.auto_low_light) {
            [_videoSettings addObject:setting];
        }
    }
    
    setting = [SettingObject new];
    setting.name = getSettingName(video_quality);
    setting.title = @"setting_video_quality";
    setting.value = _settings.video_quality;
    setting.type = SettingTypeOptions;
    if (_settings.video_quality) {
        [_videoSettings addObject:setting];
    }
    
    if (self.isSubModeRecordTimelapse) {
        setting = [SettingObject new];
        setting.name = getOptionName(timelapse_video);
        setting.title = @"timelapse_interval_title";
        setting.value = _settings.timelapse_video;
        setting.type = SettingTypeOptions;
        if (_settings.timelapse_video) {
            [_videoSettings addObject:setting];
        }
        
        setting = [SettingObject new];
        setting.name = getSettingName(timelapse_video_duration);
        setting.title = @"timelapse_duration_title";
        setting.value = _settings.timelapse_video_duration;
        setting.type = SettingTypeOptions;
        if (_settings.timelapse_video_duration) {
            [_videoSettings addObject:setting];
        }
    }
    
    if (self.isSubModeRecordLoop) {
        setting = [SettingObject new];
        setting.name = getSettingName(loop_rec_duration);
        setting.title = @"loop_record_duration_title";
        setting.value = _settings.loop_rec_duration;
        setting.type = SettingTypeOptions;
        if (_settings.loop_rec_duration) {
            [_videoSettings addObject:setting];
        }
    }
    
    if (self.isSubModeRecordPhoto) {
        setting = [SettingObject new];
        setting.name = getOptionName(record_photo_time);
        setting.title = @"timelapse_interval_title";
        setting.value = _settings.record_photo_time;
        setting.type = SettingTypeOptions;
        if (_settings.record_photo_time) {
            [_videoSettings addObject:setting];
        }
    }
    
    if (self.isZ16 && !self.isSubModeRecordTimelapse) {
        setting = [SettingObject new];
        setting.name = getSettingName(iq_eis_enable);
        setting.title = @"setting_iq_eis_enable";
        setting.value = _settings.iq_eis_enable;
        setting.type = SettingTypeSwitch;
        if ([_settings.eis_support_status isEqualToString:@"on" caseSensitive:NO] && _settings.iq_eis_enable) {
            [_videoSettings addObject:setting];
        }
        
        setting = [SettingObject new];
        setting.name = getSettingName(iq_video_ev);
        setting.title = @"setting_iq_video_ev";
        setting.value = _settings.iq_video_ev;
        setting.type = SettingTypeOptions;
        if (_settings.iq_video_ev) {
            [_videoSettings addObject:setting];
        }
        
        setting = [SettingObject new];
        setting.name = getSettingName(iq_video_wb);
        setting.title = @"setting_iq_video_wb";
        setting.value = _settings.iq_video_wb;
        setting.type = SettingTypeOptions;
        if (_settings.iq_video_wb) {
            [_videoSettings addObject:setting];
        }
        
        setting = [SettingObject new];
        setting.name = getSettingName(iq_video_iso);
        setting.title = @"setting_iq_video_iso";
        setting.value = _settings.iq_video_iso;
        setting.type = SettingTypeOptions;
        if (_settings.iq_video_iso) {
            [_videoSettings addObject:setting];
        }
    }
    
    if (!self.isSubModeRecordTimelapse && !self.isSubModeRecordSlowMotion) {
        setting = [SettingObject new];
        setting.name = getSettingName(video_stamp);
        setting.title = @"setting_video_time_stamp";
        setting.value = _settings.video_stamp;
        setting.type = SettingTypeOptions;
        if (_settings.video_stamp) {
            [_videoSettings addObject:setting];
        }
    }
    
    
    setting = [SettingObject new];
    setting.name = getSettingName(video_standard);
    setting.title = @"setting_video_standard";
    setting.value = _settings.video_standard;
    setting.type = SettingTypeOptions;
    if (_settings.video_standard) {
        [_videoSettings addObject:setting];
    }
    
    return _videoSettings;
}

- (NSMutableArray *)photoSettings
{
    if (!_photoSettings) {
        _photoSettings = [NSMutableArray array];
    }
    
    [_photoSettings removeAllObjects];
    
    SettingObject *setting = [SettingObject new];
    setting.name = getSettingName(photo_size);
    setting.title = @"setting_photo_size";
    setting.value = _settings.photo_size;
    setting.type = SettingTypeOptions;
    if (_settings.photo_size) {
        [_photoSettings addObject:setting];
    }
    
    setting = [SettingObject new];
    setting.name = getSettingName(meter_mode);
    setting.title = @"setting_meter_mode";
    setting.value = _settings.meter_mode;
    setting.type = SettingTypeOptions;
    if (_settings.meter_mode) {
        [_photoSettings addObject:setting];
    }

    if (self.isSubModePreciseQualityCont) {
        setting = [SettingObject new];
        setting.name = getSettingName(precise_cont_time);
        setting.title = PRECISE_CONT_TIME;
        setting.value = _settings.precise_cont_time;
        setting.type = SettingTypeOptions;
        if (_settings.precise_cont_time) {
            [_photoSettings addObject:setting];
        }
    }
    
    if (self.isSubModePreciseSelfQuality) {
        setting = [SettingObject new];
        setting.name = getSettingName(precise_selftime);
        setting.title = @"float_setting_countdown";
        setting.value = _settings.precise_selftime;
        setting.type = SettingTypeOptions;
        if (_settings.precise_selftime) {
            [_photoSettings addObject:setting];
        }
    }
    
    if (self.isSubModeBurstQuality) {
        setting = [SettingObject new];
        setting.name = getSettingName(burst_capture_number);
        setting.title = @"float_setting_frequency";
        setting.value = _settings.burst_capture_number;
        setting.type = SettingTypeOptions;
        if (_settings.burst_capture_number) {
            [_photoSettings addObject:setting];
        }
    }
    
    setting = [SettingObject new];
    setting.name = getSettingName(photo_stamp);
    setting.title = @"setting_photo_stamp";
    setting.value = _settings.photo_stamp;
    setting.type = SettingTypeOptions;
    if (_settings.photo_stamp) {
        [_photoSettings addObject:setting];
    }
    
    if (self.isZ16) {
        setting = [SettingObject new];
        setting.name = getSettingName(iq_photo_shutter);
        setting.title = @"setting_iq_photo_shutter";
        setting.value = _settings.iq_photo_shutter;
        setting.type = SettingTypeOptions;
        if (_settings.iq_photo_shutter) {
            [_photoSettings addObject:setting];
        }
        
        setting = [SettingObject new];
        setting.name = getSettingName(iq_photo_ev);
        setting.title = @"setting_iq_photo_ev";
        setting.value = _settings.iq_photo_ev;
        setting.type = SettingTypeOptions;
        if (_settings.iq_photo_ev) {
            [_photoSettings addObject:setting];
        }
        
        setting = [SettingObject new];
        setting.name = getSettingName(iq_photo_wb);
        setting.title = @"setting_iq_photo_wb";
        setting.value = _settings.iq_photo_wb;
        setting.type = SettingTypeOptions;
        if (_settings.iq_photo_wb) {
            [_photoSettings addObject:setting];
        }
        
        setting = [SettingObject new];
        setting.name = getSettingName(iq_photo_iso);
        setting.title = @"setting_iq_photo_iso";
        setting.value = _settings.iq_photo_iso;
        setting.type = SettingTypeOptions;
        if (_settings.iq_photo_iso) {
            [_photoSettings addObject:setting];
        }
        
    }
    
    return _photoSettings;
}

- (NSMutableArray *)deviceSettings
{
    if (!_deviceSettings) {
        _deviceSettings = [NSMutableArray array];
    }
    
    [_deviceSettings removeAllObjects];
    
    SettingObject *setting = [SettingObject new];
    setting.name = getSettingName(sw_version);
    setting.title = @"setting_sw_version";
    setting.value = [[CameraHAM shared].settings.sw_version componentsSeparatedByString:@"_"][1];
    setting.type = SettingTypeDetail;
    if (_settings.sw_version) {
        [_deviceSettings addObject:setting];
    }
    
    setting = [SettingObject new];
    setting.name = @"setting_sdcard";
    setting.title = @"setting_sdcard";
    setting.value = nil;
    setting.type = SettingTypeDetail;
    [_deviceSettings addObject:setting];

    
    if (self.isZ16) {
        if ([_settings.dewarp_support_status isEqualToString:@"on" caseSensitive:NO]) {
            setting = [SettingObject new];
            setting.name = getSettingName(warp_enable);
            setting.title = @"setting_warp_enable";
            setting.value = _settings.warp_enable;
            setting.type = SettingTypeSwitch;
            if (_settings.warp_enable) {
                [_deviceSettings addObject:setting];
            }
        }
    } else {
        setting = [SettingObject new];
        setting.name = getSettingName(warp_enable);
        setting.title = @"setting_warp_enable";
        setting.value = _settings.warp_enable;
        setting.type = SettingTypeSwitch;
        if (_settings.warp_enable) {
            [_deviceSettings addObject:setting];
        }
    }
    
    setting = [SettingObject new];
    setting.name = getSettingName(start_wifi_while_booted);
    setting.title = @"setting_start_wifi_while_booted";
    setting.value = _settings.start_wifi_while_booted;
    setting.type = SettingTypeSwitch;
    if (_settings.start_wifi_while_booted) {
        [_deviceSettings addObject:setting];
    }
    
//    if (([[LGSettingUtil getHWVersion:_settings.hw_version] intValue] >= 22
//         && ([@"1.0.0" compare:[LGSettingUtil getSWVersion:_settings.sw_version] options:NSNumericSearch] == NSOrderedAscending))
//        || (self.isZ16))
    {
        if (_settings.video_output_dev_type) {
            NSMutableString *tvAVParamValue = [[NSMutableString alloc] initWithString:_settings.video_output_dev_type];
            if ([tvAVParamValue isEqualToString:@"hdmi"]) {//hdmi暂时不支持，转成OFF
                [tvAVParamValue setString:@"off"];
            }
            setting = [SettingObject new];
            setting.name = getSettingName(video_output_dev_type);
            setting.title = @"setting_av_output";
            setting.value = _settings.video_output_dev_type;
            setting.type = SettingTypeOptions;
            if (_settings.video_output_dev_type) {
                [_deviceSettings addObject:setting];
            }
        }
    }
    
    //implment video rotate >=1.0.7支持图像翻转
//    if ((![[LGSettingUtil getSWVersion:_settings.sw_version] isVersionSmallerThan:@"1.0.7"])
//        || (self.isZ16))
    {
        if (_settings.video_rotate) {
            setting = [SettingObject new];
            setting.name = getSettingName(video_rotate);
            setting.title = @"setting_video_rotate";
            setting.value = _settings.video_rotate;
            setting.type = SettingTypeSwitch;
            if (_settings.video_rotate) {
                [_deviceSettings addObject:setting];
            }
        }
    }
    
//    if ((![[LGSettingUtil getSWVersion:_settings.sw_version] isVersionSmallerThan:@"1.0.8"])
//        || (self.isZ16))
    {
        if (_settings.emergency_file_backup) {
            setting = [SettingObject new];
            setting.name = getSettingName(emergency_file_backup);
            setting.title = @"emergency_file_backup";
            setting.value = _settings.emergency_file_backup;
            setting.type = SettingTypeOptions;
            if (_settings.emergency_file_backup) {
                [_deviceSettings addObject:setting];
            }
        }
    }
    
    setting = [SettingObject new];
    setting.name = getSettingName(buzzer_volume);
    setting.title = @"setting_buzzer_volume";
    setting.value = _settings.buzzer_volume;
    setting.type = SettingTypeOptions;
    if (_settings.buzzer_volume) {
        [_deviceSettings addObject:setting];
    }
    
    setting = [SettingObject new];
    setting.name = @"setting_wifi";
    setting.title = @"setting_wifi";
    setting.value = nil;
    setting.type = SettingTypeDetail;
    [_deviceSettings addObject:setting];
    
    
    setting = [SettingObject new];
    setting.name = getSettingName(led_mode);
    setting.title = @"setting_led_mode";
    setting.value = _settings.led_mode;
    setting.type = SettingTypeOptions;
    if (_settings.led_mode) {
        [_deviceSettings addObject:setting];
    }
    
    setting = [SettingObject new];
    setting.name = getSettingName(loop_record);
    setting.title = @"setting_loop_record";
    setting.value = _settings.loop_record;
    setting.type = SettingTypeSwitch;
    if (_settings.loop_record) {
        [_deviceSettings addObject:setting];
    }
    
    setting = [SettingObject new];
    setting.name = getSettingName(camera_clock);
    setting.title = @"setting_camera_clock";
    setting.value = _settings.camera_clock;
    setting.type = SettingTypePlain;
    if (_settings.camera_clock) {
        [_deviceSettings addObject:setting];
    }
    
    setting = [SettingObject new];
    setting.name = getSettingName(system_default_mode);
    setting.title = @"setting_system_default_mode";
    setting.value = _settings.system_default_mode;
    setting.type = SettingTypeOptions;
    if (_settings.system_default_mode) {
        [_deviceSettings addObject:setting];
    }
    
    setting = [SettingObject new];
    setting.name = getSettingName(auto_power_off);
    setting.title = @"setting_auto_power_off";
    setting.value = _settings.auto_power_off;
    setting.type = SettingTypeOptions;
    if (_settings.auto_power_off) {
        [_deviceSettings addObject:setting];
    }
    
//    if (!self.isZ16 && ![[LGSettingUtil getSWVersion:_settings.sw_version] isVersionSmallerThan:@"1.1.0"])
    {
        setting = [SettingObject new];
        setting.name = getOptionName(btc_delete_all_binded_dev);
        setting.title = @"btc_delete_all_binded_dev";
        setting.value = @"on";
        setting.type = SettingTypeDetail;
        [_deviceSettings addObject:setting];
    }
    
//    if ([XYDevFunctionManager sharedManager].cameraSaveLogEnable)
    {
        setting = [SettingObject new];
        setting.name = getOptionName(camera_save_log);
        setting.title = @"setting_save_log";
        setting.value = _settings.save_log;
        setting.type = SettingTypePlain;
        [_deviceSettings addObject:setting];
    }
    
    
    return _deviceSettings;
}

/**
 *  重新调整相机模式的排放顺序，UI上显示的位置在这里控制
 */
- (void)resortModesOrder
{    
    if (_isZ16) {
        [CameraHAM shared].settingOptions.capture_default_mode = [NSArray arrayWithObjects:@"precise quality", @"precise quality cont.", @"precise self quality", @"burst quality", nil];
        [CameraHAM shared].settingOptions.default_record_mode = [NSArray arrayWithObjects:@"record", @"record_timelapse", @"record_slow_motion", @"record_loop", @"record_photo", nil];
        
        NSMutableArray *modes = [NSMutableArray arrayWithArray:[CameraHAM shared].settingOptions.capture_default_mode];
        [modes addObjectsFromArray:[CameraHAM shared].settingOptions.default_record_mode];
        [CameraHAM shared].settingOptions.system_default_mode = modes;
    } else {
        [CameraHAM shared].settingOptions.capture_default_mode = [NSArray arrayWithObjects:@"precise quality", @"precise quality cont.", @"precise self quality", @"burst quality", nil];
        [CameraHAM shared].settingOptions.default_record_mode = [NSArray arrayWithObjects:@"record", @"record_timelapse", nil];
        [CameraHAM shared].settingOptions.system_default_mode = [NSArray arrayWithObjects:@"record", @"capture", nil];;
    }
    
    //初始化capture对象模型列表
    if (!_subModesCapture) {
        _subModesCapture = [NSMutableArray array];
    }
    
    NSArray *modeList = nil;
    
    modeList = self.settingOptions.capture_default_mode;
    
    [_subModesCapture removeAllObjects];
    
    [modeList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *modeName = (NSString *)obj;
        ACModeObject *modeObject = _modes[modeName];
        [_subModesCapture addObject:modeObject];
    }];

    //初始化record对象模型列表
    if (!_subModesRecord) {
        _subModesRecord = [NSMutableArray array];
    }
    
    modeList = self.settingOptions.default_record_mode;
    
    [_subModesRecord removeAllObjects];
    
    [modeList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *modeName = (NSString *)obj;
        ACModeObject *modeObject = _modes[modeName];
        [_subModesRecord addObject:modeObject];
    }];
    
}

/**
 *  保存当前大模式下的小模式列表，保存的是ACModeObject对象
 */
- (NSMutableArray *)subModes
{
    if ([self isModeCapture]) {
        _subModes = _subModesCapture;
    } else if ([self isModeRecord]) {
        _subModes = _subModesRecord;
    }
    
    return _subModes;
}

/**
 *  保存当前小模式中选中的模式，也即当前相机模式，与lastMode一样
 */
- (ACModeObject *)subMode
{
    NSString *system_mode = self.settings.system_mode;
    NSString *sub_mode = nil;
    
    if ([self isModeCapture]) {
        sub_mode = self.settings.capture_mode;
    } else if ([self isModeRecord]) {
        sub_mode = self.settings.rec_mode;
    } else {
        NSLog(@"subMode: but system_mode is nil(%@)", system_mode);
        NSLog(@"self: %p, shared:%p", self, [CameraHAM shared]);
        NSAssert(YES, @"Camera mode undefined!");
    }
    
    _subMode = _modes[sub_mode];
    
    return _subMode;
}

- (NSUInteger)subModeIndex
{
    return [self.subModes indexOfObject:self.subMode];
}

- (void)setCameraStatus:(CameraStatus)cameraStatus
{
    NSLog(@"set CameraStatus from(%@) to(%@)", @(_cameraStatus), @(cameraStatus));
    _cameraStatus = cameraStatus;
}

- (void)cameraStatusSyncing
{
    if ([self isSubModeRecord]) {
        self.cameraStatus = CameraStatusNormalRecording;
    } else if ([self isSubModeRecordTimelapse]) {
        self.cameraStatus = CameraStatusTimelapseRecording;
    } else if ([self isSubModeRecordSlowMotion]) {
        self.cameraStatus = CameraStatusSlowMotionRecording;
    } else if ([self isSubModeRecordLoop]) {
        self.cameraStatus = CameraStatusLoopRecording;
    } else if ([self isSubModeRecordPhoto]) {
        self.cameraStatus = CameraStatusPhotoRecording;
    } else if ([self isSubModePreciseQuality]) {
        self.cameraStatus = CameraStatusPhotoing;
    } else if ([self isSubModePreciseQualityCont]) {
        self.cameraStatus = CameraStatusPrecising;
    } else if ([self isSubModeBurstQuality]) {
        self.cameraStatus = CameraStatusBursting;
    } else if ([self isSubModePreciseSelfQuality]) {
        self.cameraStatus = CameraStatusTiming;
    }

    NSLog(@"cameraStatusSyncing:%@", @(_cameraStatus));
}

#pragma mark - 相机大小模式切换操作方法

- (void)cameraMode:(NSString *)mode success:(void (^)(id))success failure:(void (^)(id))failure
{
    if ([self isModeCapture]) {
        NSString *param = nil;
        if ([mode isEqualToString:PRECISE_QUALITY]) {
            param = OFF;
        } else if ([mode isEqualToString:PRECISE_QUALITY_CONT]) {
            param = [CameraHAM shared].settings.precise_cont_time;
        } else if ([mode isEqualToString:PRECISE_SELF_QUALITY]) {
            param = [CameraHAM shared].settings.precise_selftime;
        } else if ([mode isEqualToString:BURST_QUALITY]) {
            param = [CameraHAM shared].settings.burst_capture_number;
        }
        
        NSString *value = [NSString stringWithFormat:@"%@;%@", mode, param];
        NSDictionary *params = @{@"param":value};

        [CameraHAM shared].lastMode = [CameraHAM shared].settings.capture_mode;
        [CameraHAM shared].lastSubMode = [CameraHAM shared].modes[_settings.capture_mode];
        
        [ACCommandService execute:MSGID_E_SET_PHOTO_TYPE params:params success:^(id responseObject) {
            
            _cameraStatus = CameraStatusNormal;
            
            if ([_settingOptions.capture_default_mode containsObject:mode]) {
                [[CameraHAM shared].settings setValue:mode forSetting:@"capture_mode"];
            } else if ([[CameraHAM shared].settingOptions.default_record_mode containsObject:mode]) {
                self.settings.rec_mode = mode;
            }
            
            //[ACCommandService syncCameraParams];
            
            success(responseObject);
            
        } failure:^(NSError *error) {
            failure(error);
        }] ;
        
        
    } else if ([self isModeRecord]) {
        NSDictionary *params = @{@"type":REC_MODE, @"param":mode};
        
        [CameraHAM shared].lastMode = [CameraHAM shared].settings.rec_mode;
        [CameraHAM shared].lastSubMode = [CameraHAM shared].modes[_settings.rec_mode];
        
        [ACCommandService execute:MSGID_SET_SETTING params:params success:^(id responseObject) {
            
            //[ACCommandService syncCameraParams];
            if ([mode isEqualToString:RECORD]) {
                [ACCommandService getPIVSupport];
            }
            
            success(responseObject);
            
        } failure:^(id error) {
            failure(error);
        }];
        
    }
}

/**
 *  切换大模式，z13切大模式后相机自动切换到对应大模式下的小模式；z16切大模式相机不动作，需要手动切换到小模式
 */
- (void)switchToBigMode:(NSString *)mode success:(void (^)(id))success failure:(void (^)(id))failure
{
    if ([mode isEqualToString:RECORD]) {
        NSDictionary *params = @{@"type":SYSTEM_MODE, @"param":mode};
        if (_isZ13) {
            [ACCommandService execute:MSGID_SET_SETTING params:params success:^(id responseObject) {
                [CameraHAM shared].settings.system_mode = RECORD;
                //[ACCommandService syncCameraParams];
                [ACCommandService getPIVSupport];
                success(responseObject);
            } failure:^(NSError *error) {
                
                failure(error);
            }];
        } else if (_isZ16) {
            [CameraHAM shared].settings.system_mode = RECORD;
            [self cameraMode:_settings.rec_mode success:^(id responseObject) {
                //[ACCommandService syncCameraParams];
                [ACCommandService getPIVSupport];
                success(responseObject);
            } failure:^(id errorObject) {
                [CameraHAM shared].settings.system_mode = CAPTURE;
                failure(errorObject);
            }];
        }
    } else if ([mode isEqualToString:CAPTURE]) {
        NSDictionary *params = @{@"type":SYSTEM_MODE, @"param":mode};
        if (_isZ13) {
            [ACCommandService execute:MSGID_SET_SETTING params:params success:^(id responseObject) {
                [CameraHAM shared].settings.system_mode = CAPTURE;
                //[ACCommandService syncCameraParams];
                success(responseObject);
            } failure:^(NSError *error) {
                
                failure(error);
            }];
        } else if (_isZ16) {
            [CameraHAM shared].settings.system_mode = CAPTURE;
            [self cameraMode:_settings.capture_mode success:^(id responseObject) {
                //[ACCommandService syncCameraParams];
                success(responseObject);
            } failure:^(id errorObject) {
                [CameraHAM shared].settings.system_mode = RECORD;
                failure(errorObject);
            }];
        }
    }
}

#pragma mark - 开始、停止拍照、录像操作方法
- (void)captureWithCommandSuccess:(void (^)(id))cmdSuccess
                   ifCanStopBlock:(void (^)(BOOL))canStopBlock
                         complete:(void (^)(id))complete
                          failure:(void (^)(id))failure
{
    NSString *mode = _subMode.mode;
    NSString *param = nil;
    NSString *completeFlag = nil;
    BOOL canStop = NO;
    
    if ([mode isEqualToString:PRECISE_QUALITY]) {
        param = OFF;
        completeFlag = PHOTO_TAKEN;
        canStop = NO;
        [CameraHAM shared].cameraStatus = CameraStatusPhotoing;
    } else if ([mode isEqualToString:PRECISE_QUALITY_CONT]) {
        param = [CameraHAM shared].settings.precise_cont_time;
        completeFlag = nil;// PRECISE_CONT_COMPLETE;
        canStop = YES;
        [CameraHAM shared].cameraStatus = CameraStatusPrecising;
    } else if ([mode isEqualToString:PRECISE_SELF_QUALITY]) {
        param = [CameraHAM shared].settings.precise_selftime;
        completeFlag = PHOTO_TAKEN;
        canStop = YES;
        [CameraHAM shared].cameraStatus = CameraStatusTiming;
    } else if ([mode isEqualToString:BURST_QUALITY]) {
        param = [CameraHAM shared].settings.burst_capture_number;
        completeFlag = BURST_COMPLETE;
        canStop = NO;
        [CameraHAM shared].cameraStatus = CameraStatusBursting;
    }

    //发送开始拍照指令后，会连续收到3此msgid=7的通知
    //(不能等命令成功返回，第一个“start_photo_capture”通知会在命令成功返回之前到达)
    //通知1
    [[ACSocketService shared] listenOnNotification:@"start_photo_capture" forTarget:self success:^(id responseObject) {
        
        NSLog(@"listen on notification 1 start_photo_capture:%@", responseObject);
        [[ACSocketService shared] removeListener:@"start_photo_capture" forTarget:self];
        if (canStopBlock) {
            canStopBlock(canStop);
        }
    } failure:^(id errorObject) {
        [[ACSocketService shared] removeListener:@"start_photo_capture" forTarget:self];
    }];
    
    //通知3
    //收到该通知说明照片已经拍好
    if (completeFlag) {
        [[ACSocketService shared] listenOnNotification:completeFlag forTarget:self success:^(id responseObject) {
            NSLog(@"listen on notification:%@", responseObject);
            //[CameraHAM shared].cameraStatus = CameraStatusNormal;
            [[ACSocketService shared] removeListener:completeFlag forTarget:self];
            complete(responseObject);
        } failure:^(id errorObject) {
            [[ACSocketService shared] removeListener:completeFlag forTarget:self];
        }];
    }
    
    NSString *value = [NSString stringWithFormat:@"%@;%@", mode, param];
    NSDictionary *params = @{@"param":value};
    
    [ACCommandService execute:MSGID_E_TAKE_PHOTO params:params success:^(id responseObject) {
        cmdSuccess(responseObject);
    } failure:^(id errorObject) {
        [CameraHAM shared].cameraStatus = CameraStatusNormal;
        failure(errorObject);
    }];
}

- (void)captureStopWithSuccess:(void (^)(id))success failure:(void (^)(id))failure
{
    NSString *mode = _subMode.mode;
    
    NSString *completeFlag = nil;
    int stopCommandMsg = 0;
    
    if ([mode isEqualToString:PRECISE_QUALITY]) {
        completeFlag = PHOTO_TAKEN;
        //stopCommandMsg = MSGID_E_CAPTURE_STOP;
    } else if ([mode isEqualToString:PRECISE_QUALITY_CONT]) {
        completeFlag = PRECISE_CONT_COMPLETE;
        stopCommandMsg = MSGID_E_CAPTURE_STOP;//延时拍照可以中途停止
    } else if ([mode isEqualToString:PRECISE_SELF_QUALITY]) {
        completeFlag = PHOTO_TAKEN;
        stopCommandMsg = MSGID_STOP_TIMING_CAPTURE;//定时拍照可以中途停止
    } else if ([mode isEqualToString:BURST_QUALITY]) {
        completeFlag = BURST_COMPLETE;
        //stopCommandMsg = MSGID_E_CAPTURE_STOP;
    }
    
    if (stopCommandMsg == 0) {
        return;
    }
    
    CameraStatus cameraStatus = [CameraHAM shared].cameraStatus;
    if (cameraStatus & CameraStatusGeneralPhotoing) {
        
        //发送命令前先监听通知，因为通知可能比stop指令回馈更早到
        [[ACSocketService shared] listenOnNotification:@"self_capture_stop" forTarget:self success:^(id responseObject) {
            NSLog(@"listen on notification:%@", responseObject);
            //[CameraHAM shared].cameraStatus = CameraStatusNormal;
            success(responseObject);
            [[ACSocketService shared] removeListener:@"self_capture_stop" forTarget:self];
            [[ACSocketService shared] removeListener:completeFlag forTarget:self];
        } failure:^(id errorObject) {
            [CameraHAM shared].cameraStatus = CameraStatusNormal;
            [[ACSocketService shared] removeListener:@"self_capture_stop" forTarget:self];
            [[ACSocketService shared] removeListener:completeFlag forTarget:self];
            failure(errorObject);
        }];
        
        [ACCommandService execute:stopCommandMsg params:nil success:^(id responseObject) {
            //通知
            //收到该通知说明照片已经拍好
            if (completeFlag) {
                [[ACSocketService shared] listenOnNotification:completeFlag forTarget:self success:^(id responseObject) {
                    NSLog(@"listen on notification:%@", responseObject);
                    //[CameraHAM shared].cameraStatus = CameraStatusNormal;
                    [[ACSocketService shared] removeListener:completeFlag forTarget:self];
                    success(responseObject);
                } failure:^(id errorObject) {
                    [[ACSocketService shared] removeListener:completeFlag forTarget:self];
                    failure(errorObject);
                }];
            }
            
            
            
        } failure:^(id errorObject) {
            [CameraHAM shared].cameraStatus = CameraStatusNormal;
            failure(errorObject);
        }];
    }
}

- (void)recordWithCommandSuccess:(void (^)(id))success progress:(void (^)(id))progress failure:(void (^)(id))failure
{
    NSString *mode = _subMode.mode;
    NSString *completeFlag = VIDEO_RECORD_COMPLETE;
    
    if (![self.settingOptions.default_record_mode containsObject:mode]) {
        failure(@"error");
        return;
    }
    
    if ([self isSubModeRecord]) {
        [CameraHAM shared].cameraStatus = CameraStatusNormalRecording;
    } else if ([self isSubModeRecordTimelapse]) {
        [CameraHAM shared].cameraStatus = CameraStatusTimelapseRecording;
    } else if ([self isSubModeRecordSlowMotion]) {
        _cameraStatus = CameraStatusSlowMotionRecording;
    } else if ([self isSubModeRecordLoop]) {
        _cameraStatus = CameraStatusLoopRecording;
    } else if ([self isSubModeRecordPhoto]) {
        _cameraStatus = CameraStatusPhotoRecording;
    }
    
    NSLog(@"mode:***%@, status:%@", [CameraHAM shared].subMode.mode, @(_cameraStatus));
    
    //发送开始拍照指令后，会连续收到3此msgid=7的通知
    //(不能等命令成功返回，第一个“start_photo_capture”通知会在命令成功返回之前到达)
    //通知1
    [[ACSocketService shared] listenOnNotification:START_VIDEO_RECORD forTarget:self success:^(id responseObject) {
        NSLog(@"listen on notification start_video_record:%@", responseObject);
        if (progress) {
            progress(responseObject);
        }
        [[ACSocketService shared] removeListener:START_VIDEO_RECORD forTarget:self];
    } failure:^(id errorObject) {
        [[ACSocketService shared] removeListener:START_VIDEO_RECORD forTarget:self];
    }];
    
    //通知2
    if (completeFlag) {
        [[ACSocketService shared] listenOnNotification:completeFlag forTarget:self success:^(id responseObject) {
            NSLog(@"listen on notification:%@, status:%@", responseObject, @(_cameraStatus));
            if (_cameraStatus & CameraStatusGeneralRecording) {
                
                //_cameraStatus = CameraStatusNormal;
                [[ACSocketService shared] removeListener:completeFlag forTarget:self];
                success(responseObject);
            }
        } failure:^(id errorObject) {
            _cameraStatus = CameraStatusNormal;
            [[ACSocketService shared] removeListener:completeFlag forTarget:self];
        }];
    }
    
    //执行录像指令
    [ACCommandService execute:MSGID_RECORD_START params:nil success:^(id responseObject) {
        //启动录像指令已经送达
        NSLog(@"[CameraHAM shared] preViewPlay");
        [self preViewPlay];
    } failure:^(id errorObject) {
        _cameraStatus = CameraStatusNormal;
        failure(errorObject);
    }];
}

- (void)recordStopWithSuccess:(void (^)(id))success failure:(void (^)(id))failure
{
    NSString *mode = _subMode.mode;
    NSString *completeFlag = VIDEO_RECORD_COMPLETE;
    
    if (![self.settingOptions.default_record_mode containsObject:mode]) {
        failure(@"error");
        return;
    }
    
    //收到该通知说明录像视频已经拍摄完成
    if (completeFlag) {
        //同一个target只能有一个监听block，这里设置后，startRecord中设置的video_record_complete回调block就失效了
        [[ACSocketService shared] listenOnNotification:completeFlag forTarget:self success:^(id responseObject) {
            //有可能在CameraViewController中被使用了
            if (_cameraStatus & CameraStatusGeneralRecording) {
                NSLog(@"HAM listen on notification:%@, status:%@", responseObject, @(_cameraStatus));
                //[CameraHAM shared].cameraStatus = CameraStatusNormal;
                [[ACSocketService shared] removeListener:completeFlag forTarget:self];
                success(responseObject);
            }
        } failure:^(id errorObject) {
            _cameraStatus = CameraStatusNormal;
            [[ACSocketService shared] removeListener:completeFlag forTarget:self];
        }];
    } else {
        
    }
    
    [ACCommandService execute:MSGID_RECORD_STOP params:nil success:^(id responseObject) {
        //通知
        
    } failure:^(id error) {
        _cameraStatus = CameraStatusNormal;
        failure(error);
    }];
}

- (void)getRecordTimeWithSuccess:(void (^)(id))success failure:(void (^)(id))failure
{
    int msgid = MSGID_GET_RECORD_TIME;
    if ([self.subMode.mode isEqualToString:RECORD]) {
        msgid = MSGID_GET_RECORD_TIME;
    } else if([self.subMode.mode isEqualToString:RECORD_TIMELAPSE]) {
        msgid = MSGID_GET_TIMELAPSE_RECORD_TIME;
    }
    [ACCommandService execute:msgid params:nil success:^(id responseObject) {
        success(responseObject);
    } failure:^(id error) {
        failure(error);
    }];
}



- (void)takePIV:(NSString *)mode success:(void (^)(id))success failure:(void (^)(id))failure
{
    [ACCommandService execute:MSGID_E_TAKE_PIV params:nil success:success failure:failure];
}

- (NSString *)getResolutionString
{
    NSString *resolution = nil;
    NSString *mode = self.subMode.mode;
    
    if ([self isModeCapture]) {
        resolution = [StringHelper turnPhotoResolution:self.settings.photo_size];
    } else {
        resolution = [StringHelper convertOriginalVideoResolution:self.settings.video_resolution toFormat:0];
        
        if ([mode isEqualToString:RECORD_TIMELAPSE]) {
            resolution = [StringHelper convertOriginalVideoResolution:self.settings.timelapse_video_resolution toFormat:0];
        } else if ([mode isEqualToString:RECORD_RECORD_PHOTO]) {
            resolution = [StringHelper convertOriginalVideoResolution:_settings.video_photo_resolution toFormat:0];
        } else if ([mode isEqualToString:RECORD_SLOW_MOTION]) {
//            unsigned int rate = [self.settings.slow_motion_rate intValue];
//            unsigned int index = (unsigned int)log2f(rate) - 1;
            NSString *video_standard = _settings.video_standard;
            NSString *originalResolution = nil;
            if ([video_standard isEqualToString:@"PAL" caseSensitive:NO]) {
//                originalResolution = [StringHelper getLocalOptions].slow_motion_resolution_pal[index];
            } else {
//                originalResolution = [LGSettingUtil getLocalOptions].slow_motion_resolution[index];
            }
            resolution = [StringHelper convertOriginalVideoResolution:originalResolution toFormat:0];
            //resolution = [NSString stringWithFormat:@"%@ / %d", resolution, rate];
        }
    }
    
    return resolution;
}

- (BOOL)isRatio4T3
{
    NSString *resolution = nil;
    NSString *mode = self.subMode.mode;
    
    if ([self isModeCapture]) {
        resolution = self.settings.photo_size;
    } else {
        resolution = self.settings.video_resolution;
        
        if ([mode isEqualToString:RECORD_TIMELAPSE]) {
            resolution = _settings.timelapse_video_resolution;
        } else if ([mode isEqualToString:RECORD_RECORD_PHOTO]) {
            resolution = _settings.video_photo_resolution;
        } else if ([mode isEqualToString:RECORD_SLOW_MOTION]) {
            //慢动作都是16:9
            return NO;
        }
    }
    
    if ([resolution containsString:@"4:3"]) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - 监听msg_id==7相机通知
- (void)listenOnNotification:(NSString *)notification forTarget:(id)target success:(void (^)(id))success failure:(void (^)(id))failure
{
    [[ACSocketService shared] listenOnNotification:notification forTarget:target success:success failure:failure];
}

- (void)removeListener:(NSObject *)notification forTarget:(id)target
{
    [[ACSocketService shared] removeListener:notification forTarget:target];
}

- (void)initNotificationListeners
{
    [self listenOnNotification:SETTING_CHANGED forTarget:self success:^(id responseObject) {
        //{"msg_id":7,"type":"setting_changed","param":"rec_mode","value":"record"}
        //NSString *type = responseObject[SETTING_CHANGED];
        NSString *param = responseObject[@"param"];
        NSString *value = responseObject[@"value"];
        
        if (param && value) {
            [[CameraHAM shared].settings setValue:value forSetting:param];
        }
        if ([param isEqualToString:REC_MODE]) {
            _settings.system_mode = RECORD;
        } else if ([param isEqualToString:CAPTURE_MODE]) {
            _settings.system_mode = CAPTURE;
        }
        
    } failure:^(id errorObject) {
        
    }];
    
    [self listenOnNotification:EXIT_ALBUM forTarget:self success:^(id responseObject) {
        [CameraHAM shared].camera_album_status = EXIT_ALBUM;
        
        //相机侧退出相册，发出通知后，相机还处于系统忙状态，推迟1秒再复位预览流；
        //TODO: 这是app侧临时解决办法，后续固件会等相机准备好自己状态后再发出该退出相册通知。
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
            [[CameraHAM shared] resetVideoFlow];
            
            if (!_isReady) {
                [ACCommandService getAllCurrentSettings];
            }
        });
        
    } failure:^(id errorObject) {
        
    }];
    
    [self listenOnNotification:ENTER_ALBUM forTarget:self success:^(id responseObject) {
        [CameraHAM shared].camera_album_status = ENTER_ALBUM;
        [[CameraHAM shared] preViewStop];
    } failure:^(id errorObject) {
        
    }];
    
    [self listenOnNotification:VF_START forTarget:self success:^(id responseObject) {
        if (!_mediaPlayer.isPlaying && [CameraHAM shared].isReady) {
            NSLog(@"[CameraHAM shared] preViewPlay");
            [self preViewPlay];
        }
    } failure:^(id errorObject) {
        
    }];
    
    [self listenOnNotification:START_VIDEO_RECORD forTarget:self success:^(id responseObject) {
        [CameraHAM shared].cameraStatus = CameraStatusGeneralRecording;
        [CameraHAM shared].settings.app_status = RECORD;
    } failure:^(id errorObject) {
        
    }];
    
    [self listenOnNotification:START_PHOTO_CAPTURE forTarget:self success:^(id responseObject) {
        [CameraHAM shared].cameraStatus = CameraStatusGeneralPhotoing;
        [CameraHAM shared].settings.app_status = CAPTURE;
    } failure:^(id errorObject) {
        
    }];
}


@end
