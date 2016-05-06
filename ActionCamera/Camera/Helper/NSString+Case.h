//
//  NSString+Case.h
//  
//
//  Created by neo on 16/1/19.
//  Copyright © 2016年 AC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Case)
- (BOOL)isEqualToString:(NSString *)aString caseSensitive:(BOOL)sensitive;
@end
