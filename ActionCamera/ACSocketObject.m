//
//  ACSocketObject.m
//  ActionCamera
//
//  Created by Guisheng on 16/1/18.
//  Copyright © 2016年 AC. All rights reserved.
//

#import "ACSocketObject.h"

@implementation ACSocketObject

- (id)initWithLoadingData:(NSDictionary *)dic
{
    if (self = [super init]) {
        self.msg_id     = [[dic valueForKey:@"msg_id"] intValue];
        self.cmd        = [dic valueForKey:@"cmd"];
        self.type       = [dic valueForKey:@"type"];
        self.status     = [dic valueForKey:@"status"];
    }
    return self;
}

- (id)initWithCommand:(NSString *)cmd
{
    if (self = [super init]) {
        self.cmd = cmd;
    }
    return self;
}

@end
