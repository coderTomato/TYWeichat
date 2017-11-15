//
//  UIColor+Extension.m
//  Lottery
//
//  Created by 李军 on 13-4-10.
//  Copyright (c) 2013年 李军. All rights reserved.
//

#import "UIColor+Extension.h"

@implementation UIColor (Extension)

+ (UIColor *)colorWithHex:(NSString *)hexColor
{
    if (hexColor == nil) {
        return nil;
    }
    if(![hexColor hasPrefix:@"#"])
    {
        hexColor = [NSString stringWithFormat:@"#%@",hexColor];
    }
    unsigned int red, green, blue;
    NSRange range;
    range.length = 2;
    
    range.location = 1;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
    range.location = 3;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
    range.location = 5;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
    return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green/255.0f) blue:(float)(blue/255.0f) alpha:1.0f];
}

@end
