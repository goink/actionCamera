//
//  yuv2rgb.h
//  DVRLibDemo
//
//  Created by Liu Leon on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EZYuv2RGB : NSObject

+ (void)setupDitherTable;
+ (void)convertYuv420ToRgb32:(uint8_t *)src0 src1:(uint8_t *)src1 src2:(uint8_t *)src2 dst:(uint8_t *)dst width:(int)width height:(int)height;

@end

