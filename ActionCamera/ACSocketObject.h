//
//  ACSocketObject.h
//  ActionCamera
//
//  Created by 范桂盛 on 16/1/18.
//  Copyright © 2016年 AC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACSocketObject : NSObject

@property(nonatomic,strong) NSString  *cmd;
@property(nonatomic,strong) NSString  *name;//下载的文件名
@property(nonatomic,strong) NSString  *type;//下载类型
@property(nonatomic,assign) int        msg_id;//下载类型
@property(nonatomic,strong) NSString  *path;//文件路径
@property(nonatomic,strong) NSData    *loadedData;//下载下来的data
@property(nonatomic,assign) long       allSize;//文件大小
@property(nonatomic,strong) NSString  *status;

- (id)initWithLoadingData:(NSDictionary *)dic;

@end
