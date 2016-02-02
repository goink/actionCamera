//
//  HXQueue.h
//  ffmpeg_format_transform
//
//  Created by huangxiong on 15/12/11.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ffmpeg_param.h"

//dispatch
@interface HXQueue : NSObject {
    @private
    NSMutableArray<NSString *> *_queue;
}

// 查询是否
- (BOOL) hasTask;

// 队列长度
- (NSUInteger) queueLength;

// 入队操作
- (void) queuePush: (NSString *) string;

// 访问队首元素
- (NSString *) frontOfQueue;

// 访问队尾元素
- (NSString *) rearOfQueue;

// 出队操作
- (cmdParamter *) queuePop;

@end
