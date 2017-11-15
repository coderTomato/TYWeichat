//
//  UIAlertView+Extention.m
//  IMAPPMIOS
//
//  Created by lijun on 2016/9/25.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import "UIAlertView+Extention.h"
#import <objc/runtime.h>

@implementation UIAlertView (Extention)

- (void)setMessageFont:(UIFont *)messageFont
{
    unsigned int count = 0;
    Ivar *property = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i++)
    {
        Ivar var = property[i];
        const char *name = ivar_getName(var);
        NSString *messageContent = [NSString stringWithUTF8String:name];
        NSLog(@"%@",messageContent);
        /*if ([messageContent isEqualToString:@"_message"])
        {
            NSMutableDictionary *attris = [NSMutableDictionary dictionary];
            attris[NSFontAttributeName] = messageFont;
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:messageContent];
            [str addAttribute:NSFontAttributeName value:messageFont range:NSMakeRange(0, messageContent.length)];
            [self setValue:str forKeyPath:messageContent];
            break;
        }*/
    }
    Ivar message = property[7];
    
    /**
     *  字体修改
     */
    UIFont *big = [UIFont systemFontOfSize:25];
    UIFont *small = [UIFont systemFontOfSize:18];
    UIColor *red = [UIColor redColor];
    UIColor *blue = [UIColor blueColor];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:@"hello world" attributes:@{NSFontAttributeName:big,
                                                                                                                  NSForegroundColorAttributeName:red}];
    [str setAttributes:@{NSFontAttributeName:small} range:NSMakeRange(0, 2)];
    [str setAttributes:@{NSForegroundColorAttributeName:blue} range:NSMakeRange(0, 4)];
    
    //最后把message内容替换掉
    object_setIvar(self, message, str);
}

/*- (UIFont *)messageFont
{
    return [self valueForKeyPath:@"_message"];
}*/

@end
