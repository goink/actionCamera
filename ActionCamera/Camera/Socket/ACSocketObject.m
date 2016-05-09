//
//  ACSocketObject.m
//  ActionCamera
//
//  Created by Guisheng on 16/1/18.
//  Copyright © 2016年 AC. All rights reserved.
//

#import "ACSocketObject.h"
#import "ACSocketService.h"

@implementation ACSocketObject

+ (instancetype)objectWithMsgID:(int)msg_id heartbeat:(NSString *)heartbeat
{
    ACSocketObject *m = [[ACSocketObject alloc] init];
    if (m) {
        m.msg_id = msg_id;
        m.heartbeat = heartbeat;
        m.token = [ACSocketService shared].tokenNumber;
    }
    return m;
}

+ (instancetype)objectWithMsgID:(int)msg_id type:(NSString *)type param:(NSString *)param path:(NSString *)path
{
    ACSocketObject *m = [[ACSocketObject alloc] init];
    if (m) {
        m.msg_id = msg_id;
        m.type = type;
        m.param = param;
        m.path = path;
        m.token = [ACSocketService shared].tokenNumber;
    }
    return m;
}

+ (instancetype)objectWithMsgID:(int)msg_id type:(NSString *)type param:(NSString *)param token:(int)token
{
    ACSocketObject *m = [[ACSocketObject alloc] init];
    if (m) {
        m.msg_id = msg_id;
        m.type = type;
        m.param = param;
        m.token = token;
    }
    return m;
}

+ (instancetype)objectWithMsgID:(int)msg_id type:(NSString *)type param:(NSString *)param
{
    ACSocketObject *m = [ACSocketObject objectWithMsgID:msg_id type:type param:param token:[ACSocketService shared].tokenNumber];
    return m;
}

+ (instancetype)objectWithMsgID:(int)msg_id type:(NSString *)type
{
    ACSocketObject *m = [ACSocketObject objectWithMsgID:msg_id type:type param:nil token:[ACSocketService shared].tokenNumber];
    return m;
}

+ (instancetype)objectWithMsgID:(int)msg_id
{
    ACSocketObject *m = [ACSocketObject objectWithMsgID:msg_id type:nil param:nil token:[ACSocketService shared].tokenNumber];
    return m;
}
@end
