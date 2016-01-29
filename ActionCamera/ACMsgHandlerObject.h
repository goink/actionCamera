//
//  ACMsgHandlerObject.h
//  ActionCamera
//
//  Created by neo on 16/1/29.
//  Copyright © 2016年 AC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACMsgHandlerObject : NSObject
@property (nonatomic, assign) int msg_id;
@property (nonatomic, strong) NSString *msg_id_str;
@property (nonatomic, weak) id target;
@property (nonatomic, strong) void (^block)(NSDictionary *dictionnary);
@end
