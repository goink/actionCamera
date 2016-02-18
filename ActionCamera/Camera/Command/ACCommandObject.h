//
//  ACCommandObject.h
//  ActionCamera
//
//  Created by neo on 16/2/17.
//  Copyright © 2016年 AC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACSocketObject.h"

@interface ACCommandObject : NSObject
@property (nonatomic, strong) ACSocketObject *socketObject;
@property (nonatomic, strong) void (^successBlock)(NSDictionary *dictionnary);
@property (nonatomic, strong) void (^failureBlock)(NSDictionary *dictionnary);

+ (instancetype)objectWithSocketObject:(ACSocketObject *)socketObject
                               success:(void (^)(id responseObject))success
                               failure:(void (^)(id errorObject))failure;

@end
