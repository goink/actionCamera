//
//  ImageHelper.h
//  
//
//  Created by 范桂盛 on 16/4/8.
//  Copyright © 2016年 AC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageHelper : NSObject
+ (UIImage *)squareInMiddle:(UIImage *)fromImage;
//+ (UIImage *)imageForCameraMode:(NSString *)mode;
+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation;
+ (UIImage *)getImageforView:(UIView *)view;
@end
