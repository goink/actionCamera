//
//  DecodeFrame.m
//  MoveApp
//
//  Created by cds on 14-7-3.
//  Copyright (c) 2014年 LG. All rights reserved.
//

#import "DecodeFrame.h"



@implementation DecodeFrame

-(UIImage *)decodeFrametoRgb:(NSData *)framedata
{
    
    av_init_packet(&packet);
    packet.data = (uint8_t *)[framedata bytes];
    
    packet.size = (int)[framedata length];
    
    int gotten = 0;
    int magicTry  = 6;
    int decLen = 0;
    
    //二代相机产生的h264档需要尝试至少5次
    while (magicTry-->0 && gotten == 0) {
        decLen =  avcodec_decode_video2(codecCtx, avFrame, &gotten, &packet);
        if (gotten && (decLen > 0)) {
            NSLog(@"avcodec_decode_video2 try:%d", 6 - magicTry);
            break;
        }
    }
    
    av_free_packet(&packet);
    
    if (gotten && (decLen > 0))
    {
        if (!_swsContext &&
            ![self setupScaler]) {
            
            NSLog(@"fail setup video scaler");
            return nil;
        }
        
        sws_scale(_swsContext,
                  (const uint8_t **)avFrame->data,
                  avFrame->linesize,
                  0,
                  codecCtx->height,
                  _picture.data,
                  _picture.linesize);
        
        NSData *rgbdata =[NSData dataWithBytes:_picture.data[0]
                                        length:_picture.linesize[0] * WIDTH*codecCtx->height/codecCtx->width];
        
        
        UIImage *image = [self rgbasImage:rgbdata width:WIDTH height:WIDTH*codecCtx->height/codecCtx->width linesize:_picture.linesize[0]];
        
        if (image) {
            return image;
        }
    }
    return nil;
}


- (UIImage *) rgbasImage:(NSData*)rgbdata width:(int)width height:(int)height linesize:(int )linesize
{
    UIImage *image = nil;
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)(rgbdata));
    if (provider) {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        if (colorSpace) {
            CGImageRef imageRef = CGImageCreate(width,
                                                height,
                                                8,
                                                24,
                                                linesize,
                                                colorSpace,
                                                kCGBitmapByteOrderDefault,
                                                provider,
                                                NULL,
                                                YES, // NO
                                                kCGRenderingIntentDefault);
            
            if (imageRef) {
                image = [UIImage imageWithCGImage:imageRef];
                CGImageRelease(imageRef);
            }
            CGColorSpaceRelease(colorSpace);
        }
        CGDataProviderRelease(provider);
    }
    
    return image;
}



- (void) closeScaler
{
    if (_swsContext) {
        sws_freeContext(_swsContext);
        _swsContext = NULL;
    }
    
    if (_pictureValid) {
        avpicture_free(&_picture);
        _pictureValid = NO;
    }
}

- (BOOL) setupScaler
{
//    [self closeScaler];
    
    _pictureValid = avpicture_alloc(&_picture,
                                    PIX_FMT_RGB24,
                                    WIDTH,
                                    WIDTH*codecCtx->height/codecCtx->width) == 0;
    
	if (!_pictureValid)
        return NO;
    
	_swsContext = sws_getCachedContext(_swsContext,
                                       codecCtx->width,
                                       codecCtx->height,
                                       codecCtx->pix_fmt,
                                       WIDTH,
                                       WIDTH*codecCtx->height/codecCtx->width,
                                       PIX_FMT_RGB24,
                                       SWS_FAST_BILINEAR,
                                       NULL, NULL, NULL);
    
    return _swsContext != NULL;
}

-(void)deinitFFmpeg{
    
    [self closeScaler];
    
    if (codecCtx) {
         avcodec_close(codecCtx);
        av_free(codecCtx);
    }
    if (avFrame) {
        avcodec_free_frame(&avFrame);
    }
    
}

-(int)setupFFmpeg{
    avcodec_register_all();
    
    
    codec = avcodec_find_decoder(AV_CODEC_ID_H264);
    
    if (codec == NULL)
    {
        NSLog(@"Can not find H264 decoder.");
        return 0;
    }
    codecCtx =avcodec_alloc_context3(codec);
    if (codecCtx == NULL)
    {
        NSLog(@"Can not create codec context.");
        return 0;
    }
    if (avcodec_open2(codecCtx, codec, NULL) < 0)
    {
        NSLog(@"Can not open codec.");
        return 0;
    } 
    avFrame = avcodec_alloc_frame();
    if (avFrame == NULL)
    {
        NSLog(@"Can not allocate frame");
        return 0;
    }
    codecCtx->flags |= CODEC_FLAG_EMU_EDGE | CODEC_FLAG_LOW_DELAY;
    codecCtx->debug |= FF_DEBUG_MMCO;
    codecCtx->pix_fmt = PIX_FMT_YUV420P;
    
    return 1;
}


@end

