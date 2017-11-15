//
//  TYEmotionTool.m
//  IMAPPMIOS
//
//  Created by lijun on 16/8/23.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import "TYEmotionTool.h"

@implementation TYEmotionTool

/** 默认表情 */
static NSArray *_defaultEmotions;
/** 自定义表情*/
static NSArray *_customEmotions;

+ (NSArray *)defaultEmotions
{
    if (!_defaultEmotions)
    {
        NSString *fileplist = [[NSBundle mainBundle] pathForResource:@"defaultEmoji.plist" ofType:nil];
        _defaultEmotions = [NSArray arrayWithContentsOfFile:fileplist];
    }
    return _defaultEmotions;
}

+ (NSArray *)customEmotions
{
    if (!_customEmotions)
    {
        NSString *fileplist = [[NSBundle mainBundle] pathForResource:@"customEmoji.plist" ofType:nil];
        _customEmotions = [NSArray arrayWithContentsOfFile:fileplist];
    }
    return _customEmotions;
}

@end
