//
//  NSString+Case.m
//  
//
//  Created by neo on 16/1/19.
//  Copyright © 2016年 AC. All rights reserved.
//

#import "NSString+Case.h"

@implementation NSString (Case)

- (BOOL)isEqualToString:(NSString *)aString caseSensitive:(BOOL)sensitive
{
    if (sensitive) {
        return [self isEqualToString:aString];
    } else {
        NSComparisonResult result = [self caseInsensitiveCompare:aString];
        return result == NSOrderedSame ? YES : NO;
    }
}
@end
