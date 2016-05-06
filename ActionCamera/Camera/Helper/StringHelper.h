//
//  StringHelper.h
//  
//
//  Created by neo on 16/3/3.
//  Copyright © 2016年 AC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface StringHelper : NSObject
+ (NSString *)getFirstPart:(NSString *)from;
+ (NSString *)getSecondPart:(NSString *)from;
+ (NSString *)secondsToMMSS:(NSInteger)second;
+ (NSString *)dumpFromRect:(CGRect)rect;
+ (NSString *)stringReplace:(NSString *)from;
+ (CGSize)sizeForString:(NSString *)string;
+ (NSString *)turnPhotoResolution:(NSString *)resolution;
+ (NSString *)getVideoResolutionString:(NSString *)resolution;//1080P
+ (NSString *)convertOriginalVideoResolution:(NSString *)origin toFormat:(long)format;
+ (NSString *)convertOriginalPhotoResolution:(NSString *)origin toFormat:(long)format;
@end
