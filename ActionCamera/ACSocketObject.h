//
//  ACSocketObject.h
//  ActionCamera
//
//  Created by Guisheng on 16/1/18.
//  Copyright © 2016年 AC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACSocketObject : NSObject

@property (nonatomic,assign) int      msg_id;
@property (nonatomic,strong) NSString *cmd;
@property (nonatomic,strong) NSString *type;
@property (nonatomic,strong) NSString *status;

- (id)initWithLoadingData:(NSDictionary *)dic;
- (id)initWithCommand:(NSString *)cmd;

@end
