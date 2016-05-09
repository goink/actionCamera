//
//  ViewController.m
//  ActionCamera
//
//  Created by Guisheng on 16/1/18.
//  Copyright © 2016年 AC. All rights reserved.
//

#import "ViewController.h"
#import "ACDefines.h"
#import "ACSocketService.h"
#import "ACCommandService.h"
#import <MobileVLCKit/MobileVLCKit.h>
#import "Camera/CameraHAM.h"
#import "Masonry.h"

@interface ViewController () <VLCMediaPlayerDelegate, CameraHAMDelegate>
@property (nonatomic, strong) ACSocketService *socketService;
@property (nonatomic, strong) UIView *playView;
@property (nonatomic, strong) VLCMediaListPlayer *mediaPlayer;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIButton *buttonw;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:@"Send Commands" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    [button mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(200, 48));
        make.bottom.mas_equalTo(self.view.mas_bottom).with.offset(-20);
        make.centerX.mas_equalTo(self.view);
    }];
    
    
    UIButton *buttonw = [[UIButton alloc] init];
    [buttonw setTitle:@"Push Stream" forState:UIControlStateNormal];
    [buttonw setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [buttonw setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [buttonw addTarget:self action:@selector(hello) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonw];
    [buttonw mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(200, 48));
        make.bottom.mas_equalTo(button.mas_top).with.offset(-20);
        make.centerX.mas_equalTo(self.view);
    }];
    
    UIView *playView = [UIView new];
    playView.backgroundColor = [UIColor blueColor];
    _playView = playView;
    [self.view addSubview:playView];
    [_playView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).with.offset(20);
        make.height.mas_equalTo(self.view.mas_width).multipliedBy(0.75);
    }];

    [[CameraHAM shared] attachCameraPreViewTo:_playView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraIsReady) name:NOTI_CAMERA_IS_READY object:nil];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self buttonClick];
    
}

- (void)cameraIsReady
{
    [self hello];
}

- (void)buttonClick
{
    if ([[CameraHAM shared] isCameraWiFiConnected]) {
        [ACCommandService startCommandSocketSession];
    }
}

- (void)hello
{
    if ([CameraHAM shared].isReady) {
        ACSettingOptions *options = [CameraHAM shared].settingOptions;
        NSLog(@"options:%@", options);
        [[CameraHAM shared] resetVideoFlow];
        [[CameraHAM shared] preViewPlay];
    }
}

- (void)videoResolutionGettingTest
{
    NSString *propertyName = getSettingName(video_resolution);
    
    NSDictionary *params = @{@"param":propertyName};
    
    [ACCommandService execute:MSGID_GET_SINGLE_SETTING_OPTIONS params:params success:^(id responseObject) {
        NSLog(@"responseObject:%@", responseObject);
    } failure:^(NSError *error) {
        NSLog(@"get video resolution failed.");
    }];
}

- (void)cameraClockSettingTest
{
    NSString *type = getSettingName(camera_clock);
    [ACCommandService getSettingWithType:type];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *twentyFour = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
    dateFormatter.locale = twentyFour;
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [NSDate date];
    NSString *time = [dateFormatter stringFromDate:date];
    
    [ACCommandService setSettingWithType:type param:time];
    [ACCommandService getSettingWithType:type];
}

- (void)cameraHAM:(CameraHAM *)cameraHAM state:(NSString *)state
{
    
}
- (void)mediaPlayerStateChanged:(NSNotification *)aNotification
{
    VLCMediaPlayer *player = (VLCMediaPlayer *)aNotification.object;
    NSLog(@"state:%@", VLCMediaPlayerStateToString(player.state));
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"willRotateToInterfaceOrientation: %ld", (long)toInterfaceOrientation);
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        [_playView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(self.view);
            make.width.mas_equalTo(_playView.mas_height).multipliedBy(4.0/3.0);
            make.centerX.mas_equalTo(self.view);
        }];
    } else {
        [_playView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.view);
            make.height.mas_equalTo(_playView.mas_width).multipliedBy(3.0/4.0);
            make.top.mas_equalTo(self.view).with.offset(20);
        }];
    }
    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"didRotateFromInterfaceOrientation: %ld", (long)fromInterfaceOrientation);
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        [_playView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(self.view);
            make.width.mas_equalTo(self.view.mas_height).multipliedBy(4.0/3.0);
            make.centerX.mas_equalTo(self.view);
        }];
    } else {
        [_playView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(self.view);
            make.top.mas_equalTo(self.view).with.offset(20);
            make.height.mas_equalTo(self.view.mas_width).multipliedBy(0.75);
        }];
    }
    
}



- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"willAnimateRotationToInterfaceOrientation: %ld", (long)toInterfaceOrientation);
}

- (void)willAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"willAnimateFirstHalfOfRotationToInterfaceOrientation: %ld", (long)toInterfaceOrientation);
}

- (void)didAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    NSLog(@"didAnimateFirstHalfOfRotationToInterfaceOrientation: %ld", (long)toInterfaceOrientation);
}

@end
