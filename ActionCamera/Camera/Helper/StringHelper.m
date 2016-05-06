//
//  StringHelper.m
//  
//
//  Created by neo on 16/3/3.
//  Copyright © 2016年 AC. All rights reserved.
//

#import "StringHelper.h"
#import "ACDefines.h"

@implementation StringHelper
+ (NSString *)getFirstPart:(NSString *)from
{
    NSMutableArray *array =[NSMutableArray arrayWithArray:[from componentsSeparatedByString:@" "]];
    if (array.count > 0) {
        return [array firstObject];
    }
    return from;
}

+ (NSString *)getSecondPart:(NSString *)from
{
    NSMutableArray *array =[NSMutableArray arrayWithArray:[from componentsSeparatedByString:@" "]];
    if (array.count > 1) {
        return [array objectAtIndex:1];
    }
    return from;
}

+ (NSString *)secondsToMMSS:(NSInteger)second
{
    NSString *MM = [NSString stringWithFormat:@"%02ld", (long)second/60];
    NSString *SS = [NSString stringWithFormat:@"%02ld", (long)second%60];
    
    return [NSString stringWithFormat:@"%@:%@", MM, SS];
}

+ (NSString *)dumpFromRect:(CGRect)rect
{
    return [NSString stringWithFormat:@"<x:%03.4f, y:%03.4f, width:%03.4f, height:%3.4f>", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height];
}

+ (NSString *)stringReplace:(NSString *)from
{
    NSString *to = [from stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if ([from containsString:@".0 sec"]) {
        to = [to stringByReplacingOccurrencesOfString:@".0sec" withString:@"s"];
        return to;
    }
    
    if ([from containsString:@"sec"]) {
        to = [to stringByReplacingOccurrencesOfString:@"sec" withString:@""];
    }
    if ([from containsString:@".0"]) {
        to = [to stringByReplacingOccurrencesOfString:@".0" withString:@""];
    }
    if ([from containsString:@"minutes"]) {
        to = [to stringByReplacingOccurrencesOfString:@"minutes" withString:@""];
        return to;
    }
    if ([from containsString:@"auto"]) {
        to = [to stringByReplacingOccurrencesOfString:@"auto" withString:@"Auto"];
        return to;
    }
    
    return to;
}

+ (CGSize)sizeForString:(NSString *)string
{
    CGSize size;
    CGSize highlightedSize;
    
    size = [string sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:18]}];
    highlightedSize = [string sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:18]}];
    
    return CGSizeMake(ceilf(MAX(size.width, highlightedSize.width)), ceilf(MAX(size.height, highlightedSize.height)));
}

+ (NSString *)turnPhotoResolution:(NSString *)resolution
{
    NSArray *array =[resolution componentsSeparatedByString:@" "];
    if (array.count == 0) return @"";
    NSString *outString;
    if ([array count] == 3)
    {
        outString = [NSString stringWithFormat:@"%gMP",[[array objectAtIndex:0] floatValue]];
    }
    else
    {
        outString = [NSString stringWithFormat:@"%gMP",[[array objectAtIndex:0] floatValue]];
        NSString *lastString = [array lastObject];
        NSArray *lastArray = [lastString componentsSeparatedByString:@":"];
        if (lastArray.count == 2)
        {
            outString = [NSString stringWithFormat:@"%@%@",outString,lastArray[1]];
        }
        
    }
    return outString;
}


+ (NSString *)AxBToHuman:(NSString *)number
{
    if (!number) return number;
    
    NSArray *array = [number componentsSeparatedByString:@"x"];
    
    if (array.count != 2) return number;
    
    NSInteger width = [[array objectAtIndex:0] integerValue];
    NSInteger height = [[array objectAtIndex:1] integerValue];
    
    NSString *to = nil;
    
    if (width == 2304)      to = @"2K";
    else if (width == 2560) to = @"2.5K";
    else if (width == 3840) to = @"4K";
    else to = [NSString stringWithFormat:@"%ldP",(long)height];
    
    return to;
}
/**
 *  替换第一个字段为显示格式，第二个字段P改为FPS，去掉长宽比
 *  format: "1280x720 240P 16:9 super" => "720P 240FPS super"
 *
 *  @param resolution "1280x720 240P 16:9 super"
 *
 *  @return "720P 240FPS super"
 */
+ (NSString *)turnVideoResolution:(NSString *)resolution
{
    NSString *outString;
    NSMutableArray *array =[NSMutableArray arrayWithArray:[resolution componentsSeparatedByString:@" "]];
    NSString *firstPart;
    NSString *secondPart;
    NSString *lastPart;
    
    firstPart = [StringHelper AxBToHuman:array[0]];
    
    //720P
    outString = firstPart;
    
    if (array.count > 1) {
        //720P 240FPS
        if ([[array objectAtIndex:1] rangeOfString:@"P"].location != NSNotFound) {
            secondPart = [NSString stringWithFormat:@"%ldFPS", (long)[[array objectAtIndex:1] integerValue]];
            outString = [NSString stringWithFormat:@"%@ %@", outString, secondPart];
        }
        
        //720P 240FPS super
        if ([[array lastObject] rangeOfString:@"super"].location != NSNotFound) {
            lastPart = [array lastObject];
            outString = [NSString stringWithFormat:@"%@ %@", outString, lastPart];
        }
    }
    
    return outString;
}


//"3840x2160 30P 16:9",
//"3840x2160 30P 16:9 super",
+ (NSString *)convertOriginalVideoResolution:(NSString *)origin toFormat:(long)format
{
    NSString *to = nil;
    
    if (!origin) return origin;
    
    NSArray *parts = [origin componentsSeparatedByString:@" "];
    
    if (!parts || parts.count < 3) return origin;
    
    NSString *part0 = parts[0];//3840x2160
    NSString *part1 = parts[1];//240P
    NSString *ratio = parts[2];//16:9
    NSString *part3 = parts.count>3 ?parts[3]:nil;//super
    
    NSString *AxBHumanFormat       = [StringHelper AxBToHuman:part0];//4K
    NSString *PtoFPS               = [part1 stringByReplacingOccurrencesOfString:@"P" withString:@"FPS"];//120FPS
    NSString *FPSNumeric           = [part1 stringByReplacingOccurrencesOfString:@"P" withString:@""];//120
    NSString *humanAndAxB          = [NSString stringWithFormat:@"%@(%@)", AxBHumanFormat, part0];//4K(3840x2160)
    NSString *humanAndAxBWithSuper = humanAndAxB;
    NSString *AxBWithSuper         = AxBHumanFormat;
    
    if (part3 && ([part3 isEqualToString:@"super"] || [part3 isEqualToString:@"UltraView"])) {
        AxBWithSuper = [NSString stringWithFormat:@"%@ %@", AxBHumanFormat, @"Ultra"];//4K Ultra
        humanAndAxBWithSuper = [NSString stringWithFormat:@"%@ %@", humanAndAxB, @"Ultra"];////4K(3840x2160) Ultra
    }
    
    switch (format) {
        case 0:// "4K Ultra/240/16:9"
        {
            to = [NSString stringWithFormat:@"%@ / %@", AxBWithSuper, FPSNumeric];
            //            to = [NSString stringWithFormat:@"%@/%@/%@", AxBWithSuper, FPSNumeric, ratio];
            break;
        }
        case 1://"4K(3840x2160) Ultra 120FPS 16:9"
        {
            to = [NSString stringWithFormat:@"%@ %@ %@", humanAndAxBWithSuper, PtoFPS, ratio];
            break;
        }
        default:
        {
            to = nil;
            break;
        }
            
    }
    return to;
    
}

/**
 *  按照格式种类转换照片分辨率字符串
 *
 *  @param origin "12MP (4000x3000 4:3) fov:w"
 *  @param format 0,1,2
 *
 *  @return ""12MP (4000x3000 4:3) w""
 */
+ (NSString *)convertOriginalPhotoResolution:(NSString *)origin toFormat:(long)format
{
    if (!origin || [origin isEqualToString:@""]) return origin;
    
    NSString *outString = origin;
    
    switch (format) {
        case 0: //"12MP (4000x3000 4:3) fov:w"==>"12MP (4000x3000 4:3) w"
        {
            if ([origin rangeOfString:@"fov:m"].location != NSNotFound) {
                outString = [origin stringByReplacingOccurrencesOfString:@"fov:m" withString:@"m"];
            }
            
            if ([origin rangeOfString:@"fov:w"].location != NSNotFound) {
                outString = [origin stringByReplacingOccurrencesOfString:@"fov:w" withString:@"w"];
            }
            break;
        }
        case 1:
        {
            break;
        }
        default:
            break;
    }
    
    return outString;
}
+ (NSString *)getOriginVideoResolutionString:(NSString *)resolution
{
    NSMutableArray *array =[NSMutableArray arrayWithArray:[resolution componentsSeparatedByString:@" "]];
    NSString *outString = [array firstObject];
    if ([[array lastObject] isEqualToString:@"super"]) {
        return [outString stringByAppendingString:@" super"];
    }
    return outString;
}

+ (NSString *)getVideoResolutionString:(NSString *)resolution
{
    NSString *resForShow = [self turnVideoResolution:resolution];//resForShow format: "4K 30FPS", "4K 30FPS UltraView"
    NSArray *array = [resForShow componentsSeparatedByString:@" "];
    NSString *outString = [array firstObject];
    NSString *lastPart = [array lastObject];
    
    if ([lastPart isEqualToString:@"super"]) {
        outString = [outString stringByAppendingString:@"(U)"];
    }
    
    //outString format: "4K", "4K Super"
    return outString;
}

@end
