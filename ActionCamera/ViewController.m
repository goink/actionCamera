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
    button.center = CGPointMake(self.view.frame.size.width/2, 200);
//    button.backgroundColor = [UIColor grayColor];
    [button setTitle:@"Connect" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    UIButton *button1 = [[UIButton alloc] init];
    button1.bounds = CGRectMake(0, 0, 200, 48);
    button1.center = CGPointMake(self.view.frame.size.width/2, 400);
    button1.backgroundColor = [UIColor grayColor];
    [button1 setTitle:@"Button" forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(buttonClick1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    self.socketService = [ACSocketService sharedSocketService];
    
    [_socketService startCommandSocketSession];
}

- (void)buttonClick
{
    NSLog(@"button click");
//    [_socketService startCommandSocketSession];
    
}

- (void)buttonClick1
{
        NSLog(@"button click1: %@", [_socketService.cmdSocket isConnected]?@"yes":@"no");
    if ([_socketService.cmdSocket isConnected]) {
        NSLog(@"ooooooo   isConnected");
        [ACCommandService getAllCurrentSettings];
    }
}


@end
