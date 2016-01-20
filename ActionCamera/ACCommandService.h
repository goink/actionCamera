//
//  ACCommandService.h
//  ActionCamera
//
//  Created by Guisheng on 16/1/18.
//  Copyright © 2016年 AC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACCommandService : NSObject

+ (void)startCommandSocketSession;
+ (void)stopCommandSocketSession;
+ (void)startSession;

@end
