//
//  HXTaskDispatch.h
//  ffmpeg_format_transform
//
//  Created by huangxiong on 15/12/12.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface HXTaskDispatch : NSObject


/**
 *  判断所有线程是否已完成
 */
@property (nonatomic, readonly, assign) BOOL allTaskFinished;

/**
 *  共享任务调度
 */
+ (instancetype) shareTaskDispatch;

/**
 *  添加任务(taskCmdString 应当是合法的任务)
 *  finishedBlock 回调只能判断任务程序是否完成, 不能判断任务执行是否成功, 使用者应根据 taskCmdString 包含的输出信息去判断.
 */
- (void) addTask: (NSString *) taskCmdString finished:(void(^)(BOOL finished)) finishedBlock;


@end
