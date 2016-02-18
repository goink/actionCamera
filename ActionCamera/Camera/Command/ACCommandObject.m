//
//  ACCommandObject.m
//  ActionCamera
//
//  Created by neo on 16/2/17.
//  Copyright © 2016年 AC. All rights reserved.
//

#import "ACCommandObject.h"

@implementation ACCommandObject

+ (instancetype)objectWithSocketObject:(ACSocketObject *)socketObject success:(void (^)(id))success failure:(void (^)(id errorObject))failure
{
    ACCommandObject *obj = [[ACCommandObject alloc] init];
    if (obj) {
        obj.socketObject = socketObject;
        obj.successBlock = success;
        obj.failureBlock = failure;
    }
    
    return obj;
}
@end
