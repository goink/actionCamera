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
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *button = [[UIButton alloc] init];
    button.frame = CGRectMake(40, 200, 100, 40);
    button.backgroundColor = [UIColor grayColor];
    [button setTitle:@"OK" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    UIButton *button1 = [[UIButton alloc] init];
    button1.frame = CGRectMake(40, 400, 100, 40);
    button1.backgroundColor = [UIColor grayColor];
    [button1 setTitle:@"Button" forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(buttonClick1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    self.socketService = [ACSocketService sharedSocketService];
}
- (void)buttonClick
{
    NSLog(@"button click");
    [_socketService startCommandSocketSession];
    
}
- (void)buttonClick1
{
        NSLog(@"button click1: %@", [_socketService.cmdSocket isConnected]?@"yes":@"no");
    if ([_socketService.cmdSocket isConnected]) {
        NSLog(@"ooooooo   isConnected");
//        [ACCommandService startSession];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
