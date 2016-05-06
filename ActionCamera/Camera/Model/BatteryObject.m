//
//  BatteryObject.m
//
//  Created by neo on 16/2/24.
//  Copyright © 2016年 AC. All rights reserved.
//

#import "BatteryObject.h"

@implementation BatteryObject
- (NSString *)description
{
    return [NSString stringWithFormat:@"<%p>type:%@, level:%d", self, _type, (int)_level];
}
@end
