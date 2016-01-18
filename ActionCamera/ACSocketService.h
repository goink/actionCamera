//
//  ACSocketService.h
//  ActionCamera
//
//  Created by 范桂盛 on 16/1/18.
//  Copyright © 2016年 AC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

@protocol AsyncSocketDelegate;

@interface ACSocketService : NSObject <AsyncSocketDelegate>

@property (nonatomic, strong) AsyncSocket *cmdSocket;
@property (nonatomic, strong) AsyncSocket *datSocket;

+ (ACSocketService *)sharedSocketService;

- (void)startCommandSocketSession;
- (void)stopCommandSocketSession;

@end
