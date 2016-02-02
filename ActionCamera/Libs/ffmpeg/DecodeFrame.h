//
//  DecodeFrame.h
//  MoveApp
//
//  Created by cds on 14-7-3.
//  Copyright (c) 2014年 LG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libavcodec/avcodec.h>
#import <libavformat/avformat.h>
#import <libavdevice/avdevice.h>
#import <libswscale/swscale.h>

#import "EZYuv2RGB.h"

#define SWS_FAST_BILINEAR     1

@interface DecodeFrame : NSObject{
    AVPacket packet;
    AVCodec *codec;
    AVCodecContext *codecCtx;
    AVFrame *avFrame;
    
     uint8_t *rgbBuffer;
    
    struct SwsContext   *_swsContext;
    
    BOOL                _pictureValid;
    
    AVPicture           _picture;
}
-(int)setupFFmpeg;
-(void)deinitFFmpeg;

-(UIImage *)decodeFrametoRgb:(NSData *)framedata;

@end

