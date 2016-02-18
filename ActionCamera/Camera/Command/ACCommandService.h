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
+ (void)resetVideoFlow;

+ (void)execute:(int)msgid
         params:(NSDictionary *)params
        success:(void (^)(id responseObject))success
        failure:(void (^)(NSError *error))failure;

+ (void) listen:(int)msgid
        success:(void (^)(id responseObject))success
        failure:(void (^)(NSError *error))failure;
@end
