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

@interface ViewController () <VLCMediaPlayerDelegate>
@property (nonatomic, strong) ACSocketService *socketService;
@property (nonatomic, strong) UIView *playView;
@property (nonatomic, strong) VLCMediaListPlayer *mediaPlayer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    

    UIButton *button = [[UIButton alloc] init];
    button.bounds = CGRectMake(0, 0, 200, 48);
    button.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height*2/3);
    [button setTitle:@"Send Commands" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    [self setupMediaPlayer];
    
    self.socketService = [ACSocketService sharedSocketService];
    
    [_socketService startCommandSocketSession];
}
- (void)setupMediaPlayer
{
    UIView *playView = [UIView new];
    playView.frame = CGRectMake(0, 50, self.view.frame.size.width, 250);
    playView.backgroundColor = [UIColor blueColor];
    _playView = playView;
    [self.view addSubview:playView];
    
    _mediaPlayer = [[VLCMediaListPlayer alloc] initWithOptions:@[@"--noaudio",@"--no-video-title-show",@"--quiet"]];
    _mediaPlayer.mediaPlayer.delegate = self;
    _mediaPlayer.mediaPlayer.drawable = _playView;
    _mediaPlayer.repeatMode = VLCRepeatAllItems;
    VLCMedia *media = [VLCMedia mediaWithURL:[NSURL URLWithString:CAMERA_IP_RTSP]];
    VLCMediaList *list = [[VLCMediaList alloc] initWithArray:@[media]];
    _mediaPlayer.mediaList = list;
}
- (void)buttonClick
{
    if ([_socketService.cmdSocket isConnected]) {
        
        [ACCommandService getAllCurrentSettings];
        [ACCommandService getSettingOptions:@"video_resolution"];
        [ACCommandService getSettingWithType:@"camera_clock"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *twentyFour = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
        dateFormatter.locale = twentyFour;
        [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        NSDate *date = [NSDate date];
        NSString *time = [dateFormatter stringFromDate:date];
        
        [ACCommandService setSettingWithType:@"camera_clock" param:time];
        [ACCommandService getSettingWithType:@"camera_clock"];
        [ACCommandService resetVideoFlow];
        [_mediaPlayer play];
    }
}


@end
