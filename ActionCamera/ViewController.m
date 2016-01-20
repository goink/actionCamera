//
//  ViewController.m
//  ActionCamera
//
//  Created by Guisheng on 16/1/18.
//  Copyright © 2016年 AC. All rights reserved.
//

#import "ViewController.h"
#import "ACSocketService.h"
#import "ACCommandService.h"

@interface ViewController ()
@property (nonatomic, strong) ACSocketService *socketService;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *button = [[UIButton alloc] init];
    button.bounds = CGRectMake(0, 0, 200, 48);
    button.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [button setTitle:@"Send Commands" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    self.socketService = [ACSocketService sharedSocketService];
    
    [_socketService startCommandSocketSession];
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
    }
}


@end
