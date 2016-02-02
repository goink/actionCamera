//
//  HXQueue.m
//  ffmpeg_format_transform
//
//  Created by huangxiong on 15/12/11.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "HXQueue.h"

@implementation HXQueue

- (instancetype)init {
    
    // 初始化
    if (self = [super init]) {
        // 队列初始化
        _queue = [NSMutableArray arrayWithCapacity:10];
    }
    
    return self;
}

#pragma mark---检查队列是否还有任务
- (BOOL)hasTask {
    
//    NSLog(@"队列长度:%@", @(_queue.count));
//    NSLog(@"%@", [NSThread currentThread]);
    if (_queue && _queue.count != 0) {
        return YES;
    }
    return NO;
}

#pragma mark---入队
- (void)queuePush:(NSString *)string {
    
//    NSLog(@"队列长度:%@", @(_queue.count));
//    NSLog(@"%@", [NSThread currentThread]);
    
    if (_queue == nil) {
        _queue = [NSMutableArray arrayWithCapacity: 10];
    }
    
    // 添加队列元素
    if (string && [string isKindOfClass: [NSString class]]) {
        [_queue addObject: string];
    }
}

#pragma mark---访问指定位置的参数
- (void)getCMDParamter:(cmdParamter **)cmd_param forIndex: (NSInteger) index{
    // 分割参数
    cmdParamter *cmd_paramter = *cmd_param;
    NSString *command_str = _queue[index];
    NSArray *argv_array= [command_str componentsSeparatedByString:(@" ")];
    cmd_paramter->length = (unsigned long)argv_array.count;
    cmd_paramter->paramter = (char**)malloc(sizeof(char*)*cmd_paramter->length);
    for(int i = 0; i < cmd_paramter->length; i++)
    {
        // 拼装参数
        cmd_paramter->paramter[i]=(char*)malloc(sizeof(char)*1024);
        strcpy(cmd_paramter->paramter[i],[[argv_array objectAtIndex:i] UTF8String]);
    }
}

#pragma mark---出队获得控制命令参数
- (cmdParamter *)queuePop {
    
    // 分配存储
    cmdParamter *cmd_param = (cmdParamter *)malloc(sizeof(cmdParamter));
    
    // 获得队首
    [self getCMDParamter:&cmd_param forIndex: 0];
    
    NSLog(@"当前线程: %@", [NSThread currentThread]);
    NSLog(@"出队队列长度:%@", @(_queue.count));
    
    // 移除队首
    // 这个方法才是移除指定位置的方法
    // removeObject 是移除数组中所有包含这个 object 的方法, 数组中有同样元素的时候, 就会移除失败
    [_queue removeObjectAtIndex: 0];
    
    NSLog(@"出队队列长度:%@", @(_queue.count));
    // 返回结果
    return cmd_param;
}

#pragma mark---获取队头
- (NSString *)frontOfQueue {
    return [_queue firstObject];
}

#pragma mark---队尾
- (NSString *)rearOfQueue {
    return [_queue lastObject];
}

// 队列长度
- (NSUInteger)queueLength {
    return _queue.count;
}

- (void)dealloc {
    NSLog(@"队列挂了.....队列挂了");
    _queue = nil;
}

@end
