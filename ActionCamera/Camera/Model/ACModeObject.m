//
//  ACModeObject.m
//
//  Created by neo on 16/3/2.
//  Copyright © 2016年 AC. All rights reserved.
//

#import "ACModeObject.h"

@implementation ACModeObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%p>: mode:%@, keyOption:%@, selectedOption:%@", self, self.mode, self.keyOption, self.selectedOptionValue];
}
@end
