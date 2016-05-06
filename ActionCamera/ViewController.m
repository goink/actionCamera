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

@interface ViewController () <VLCMediaPlayerDelegate, CameraHAMDelegate>
@property (nonatomic, strong) ACSocketService *socketService;
@property (nonatomic, strong) UIView *playView;
@property (nonatomic, strong) VLCMediaListPlayer *mediaPlayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [[UIButton alloc] init];
    button.bounds = CGRectMake(0, 0, 200, 48);
    button.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height*2/3-50);
    [button setTitle:@"Send Commands" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    UIButton *buttonw = [[UIButton alloc] init];
    buttonw.bounds = CGRectMake(0, 0, 200, 48);
    buttonw.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height-100);
    [buttonw setTitle:@"Push Stream" forState:UIControlStateNormal];
    [buttonw setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [buttonw setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [buttonw addTarget:self action:@selector(hello) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonw];
    
    UIView *playView = [UIView new];
    playView.frame = CGRectMake(0, 50, self.view.frame.size.width, 250);
    playView.backgroundColor = [UIColor blueColor];
    _playView = playView;
    [self.view addSubview:playView];

    [[CameraHAM shared] attachCameraPreViewTo:_playView];
    
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
@end
