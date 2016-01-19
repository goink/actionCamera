//
//  ACSocketObject.m
//  ActionCamera
//
//  Created by 范桂盛 on 16/1/18.
//  Copyright © 2016年 AC. All rights reserved.
//

#import "ACSocketObject.h"

@implementation ACSocketObject

- (id)initWithLoadingData:(NSDictionary *)dic
{
    if (self = [super init]) {
        self.cmd        = [dic valueForKey:@"cmd"];
        self.name       = [dic valueForKey:@"name"];
        self.type       = [dic valueForKey:@"type"];
        self.msg_id     = [[dic valueForKey:@"msg_id"] intValue];
        self.path       = [dic valueForKey:@"path"];
        self.loadedData = [dic valueForKey:@"loadedData"];
        self.allSize    = [[dic valueForKey:@"allSize"] longValue];
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
