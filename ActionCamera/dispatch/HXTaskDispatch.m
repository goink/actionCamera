//
//  HXTaskDispatch.m
//  ffmpeg_format_transform
//
//  Created by huangxiong on 15/12/12.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import "HXTaskDispatch.h"
#import "HXQueue.h"
#import "ffmpeg.h"

#define TASK_SUB_THREAD_NAME (@"task_sub_thread")

@interface HXTaskDispatch () {
    // 任务调度使用的队列
    HXQueue *_queue;
    // 线程, 任务调度使用子线程
    NSThread *_thread;
    // block 回调数组
    NSMutableArray *_blockArray;

}

/**
 *  用于确定是否有新任务, 同时激活新任务
 */
@property (nonatomic, assign) BOOL hasNewTask;

@end

@implementation HXTaskDispatch

#pragma mark---共享的任务调度器
+ (instancetype) shareTaskDispatch {
    
    return [[[self class] alloc] init];
}

#pragma mark---单例方法
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    // 线程锁
    @synchronized(self) {
        
        static HXTaskDispatch *taskDispath = nil;
        
        static dispatch_once_t once;
        
        dispatch_once(&once, ^{
            // 创建调度系统
            taskDispath = [super allocWithZone: zone];
            taskDispath->_queue = [[HXQueue alloc] init];
            taskDispath->_hasNewTask = NO;
            
            // 注册线程退出通知
            [[NSNotificationCenter defaultCenter] addObserver: taskDispath selector: @selector(threadExit:) name: NSThreadWillExitNotification object: nil];
            
            // 注册任务激活通知
            [taskDispath addObserver: taskDispath forKeyPath: @"hasNewTask" options:NSKeyValueObservingOptionNew context: nil];
        });
        return taskDispath;

    }
}

#pragma mark---激活线程的通知, 基于 KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    // 表示新任务激活
    if ([keyPath isEqualToString: @"hasNewTask"] ) {
        
        if (_hasNewTask == YES) {
            
            // 调度任务
            [self threadDispatch];
        } else {
            // 清理一些
            _thread = nil;
            [_blockArray removeAllObjects];
            
        }
    }
}

#pragma mark---任务的执行方法
- (void) executeTask {
    
//    NSLog(@"%@", [NSThread currentThread]);
    // 有任务就执行
    if ([_queue hasTask]) {
        
        // 从队列获得一个任务
        cmdParamter *cmd_param = [_queue queuePop];
        // 调度执行任务
        ffmpeg_main((int)cmd_param->length, cmd_param->paramter);
        
        
    } else {
        // 否则重置
        _hasNewTask = NO;
    }
    
}

#pragma mark---调度任务的方法
- (void) threadDispatch {
    
    // 如果线程还在执行, 不处理
    if (_thread.executing) {
        return;
    }
    
    if ([_queue hasTask]) {
        
        // 开新线程处理任务
        
        _thread = [[NSThread alloc] initWithTarget: self selector: @selector(executeTask) object: nil];
        // 命名线程的名字
        _thread.name = TASK_SUB_THREAD_NAME;
        // 执行线程
        [_thread start];
    }
}

#pragma mark---线程退出通知方法
- (void) threadExit: (NSNotification *)notification {
    
    // 非任务子线程, 不在往下操作
    if (![[notification.object name] isEqualToString: TASK_SUB_THREAD_NAME]) {
        return;
    }

    // 丢弃线程
    _thread = nil;
    
    
   // NSLog(@"当前线程: %@", [NSThread currentThread]);
    
    if (_blockArray && ![_blockArray[0] isKindOfClass: [NSNull class]]) {
        
        ((void(^)(BOOL finished))_blockArray[0])(YES);
        
        [_blockArray removeObjectAtIndex: 0];
        
    }
    if ([_queue hasTask]) {
        // 调度下一个任务
        [self performSelector: @selector(threadDispatch)];
    } else {
        
        // 如果任务队列中已经没有任务, 需要将 _hasNewTask 置为 NO,
        // 方便添加任务时激活任务调度程序
        self.hasNewTask = NO;
    }
//    // 回到主线程
//    dispatch_sync(dispatch_get_main_queue(), ^{
//        
//    });

    
}

- (void) addTask: (NSString *) taskCmdString finished:(void(^)(BOOL finished)) finishedBlock {
    
    // 锁定任务
    @synchronized(self) {
        //        NSLog(@"%@", [NSThread currentThread]);
        //        NSLog(@"%@", @(_queue.queueLength));
        // 入队
        [_queue queuePush: taskCmdString];
        
        if (_blockArray == nil) {
            _blockArray = [NSMutableArray array];
        }
        
        if (finishedBlock) {
            [_blockArray addObject: finishedBlock];
        } else {
            [_blockArray addObject: [NSNull null]];
        }
        
        
        // 激活任务
        if (self.hasNewTask == NO) {
            self.hasNewTask = YES;
        }
    }
}

- (BOOL)allTaskFinished {
    
    // 没有任务, 表示所有任务完成
    if (_hasNewTask == NO) {
        return YES;
    }
    
    return NO;
}

@end
