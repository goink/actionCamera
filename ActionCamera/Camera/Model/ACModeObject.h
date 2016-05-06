//
//  ACModeObject.h
//
//  Created by neo on 16/3/2.
//  Copyright © 2016年 AC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACModeObject : NSObject
@property (nonatomic, strong) NSString *mode;
/**
 *  关键选项的setting名字
 */
@property (nonatomic, strong) NSString *keyOption;
@property (nonatomic, strong) NSString *optionUnit;
@property (nonatomic, strong) NSString *optionTitle;
@property (nonatomic, strong) NSString *selectedOptionValue;
@property (nonatomic, strong) NSArray  *keyOptions;
@end
