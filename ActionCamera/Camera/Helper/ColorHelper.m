//
//  ColorHelper.m
//  
//
//  Created by neo on 16/3/7.
//  Copyright © 2016年 AC. All rights reserved.
//

#import "ColorHelper.h"
#import <UIKit/UIKit.h>

@implementation ColorHelper

+ (UIImage *)imageFromColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0,0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
