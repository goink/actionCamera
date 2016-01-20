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
+ (void)getAllCurrentSettings;
+ (void)getSettingOptions:(NSString *)setting;
+ (void)setSettingWithType:(NSString *)type param:(NSString *)param;
+ (void)getSettingWithType:(NSString *)type;

@end
