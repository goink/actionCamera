//
//  ACSettings.m
//  ActionCamera
//
//  Created by Guisheng on 16/1/20.
//  Copyright © 2016年 AC. All rights reserved.
//

#import "ACSettings.h"
#import <objc/runtime.h>

@interface ACSettings ()
@property (strong, nonatomic) NSMutableDictionary *properties;
@end


@implementation ACSettings

- (instancetype)initWithArray:(NSArray *)settingDics
{
    if (!settingDics || settingDics.count <= 0) {
        return self;
    }
    
    [self reset];
    
    for (NSDictionary *dic in settingDics)
    {
        NSArray *keys = [dic allKeys];
        NSString *key = [keys objectAtIndex:0];
        NSString *value = [dic objectForKey:key];
        
        if ([self containsOf:key]) {
            [self setValue:value forKeyPath:key];
        } else {
            NSLog(@"@property (strong, nonatomic) NSString *%@; // %@", key, value);
        }
    }
    return self;
}

- (void)reset
{
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    
    NSString *ivarName = nil;
    
    for (int i = 0; i < count; i++) {
        ivarName = [[NSString stringWithUTF8String:ivar_getName(ivars[i])] substringFromIndex:1];
        [self setValue:nil forKey:ivarName];
    }
}

- (BOOL)containsOf:(NSString *)key
{
    if (!key) return NO;
    
    if (self.properties) {
        if (_properties[key]) {
            return YES;
        }
    }
    return NO;
}

- (NSMutableDictionary *)properties
{
    if (!_properties) {
        
        _properties = [NSMutableDictionary dictionary];
        
        unsigned int count = 0;
        Ivar *ivars = class_copyIvarList([self class], &count);
        NSString *ivarName;
        
        for (int i = 0; i < count; i++) {
            ivarName = [[NSString stringWithUTF8String:ivar_getName(ivars[i])] substringFromIndex:1];
            if ([ivarName isEqualToString:@"properties"]) continue;
            _properties[ivarName] = ivarName;
        }
        
    }
    return _properties;
}

- (void)setValue:(id)value for:(NSString *)key
{
    if ([self containsOf:key]) {
        [self setValue:value forKey:key];
    }
}
- (NSString *)description
{
    NSMutableString *mutString = [[NSMutableString alloc] init];
    [mutString appendString:@"description:\n---\n"];
    if (_properties) {
        for (NSString *p in _properties) {
            NSString *value = [self valueForKey:p];
            if (value) {
                [mutString appendString:[NSString stringWithFormat:@"    .%@ = %@\n", p, value]];
            }
        }
    }
    [mutString appendString:@"---"];
    return mutString;
}
@end
