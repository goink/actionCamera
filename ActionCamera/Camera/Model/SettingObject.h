//
//  SettingObject.h
//
//  Created by neo on 16/3/22.
//  Copyright © 2016年 AC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SettingType) {
    SettingTypePlain   = 0,// 标题+值+没有箭头，点击无效果
    SettingTypeOptions = 1,// 标题+值+箭头，点击进options选择
    SettingTypeDetail  = 2,// 标题+值+箭头，点击进详情设置页
    SettingTypeSwitch  = 3,// 标题+开关
};

@interface SettingObject : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, assign) SettingType type;
@end
