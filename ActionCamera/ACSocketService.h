//
//  ACSocketService.h
//  ActionCamera
//
//  Created by 范桂盛 on 16/1/18.
//  Copyright © 2016年 AC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

@interface ACSocketService : NSObject
@property (nonatomic, strong) AsyncSocket *cmdSocket;
@property (nonatomic, strong) AsyncSocket *datSocket;

@end
