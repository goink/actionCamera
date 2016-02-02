//
//  ffmpeg_param.h
//  ffmpeg_format_transform
//
//  Created by huangxiong on 15/12/11.
//  Copyright © 2015年 huangxiong. All rights reserved.
//

#ifndef ffmpeg_param_h
#define ffmpeg_param_h

typedef struct cmd_paramter {
    // 长度
    unsigned long length;
  
    // 参数内容
    char **paramter;
    
} cmdParamter;

#endif /* ffmpeg_param_h */
