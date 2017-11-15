//
//  TYEmotionView.m
//  IMAPPMIOS
//
//  Created by lijun on 16/8/27.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import "TYEmotionView.h"

@implementation TYEmotionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.adjustsImageWhenHighlighted = NO;
    }
    return self;
}

- (void)setEmotionDict:(NSDictionary *)emotionDict
{
    _emotionDict = emotionDict;
    self.hidden = NO;
    [self setImage:[UIImage imageNamed:emotionDict[@"png"]] forState:UIControlStateNormal];
}

@end
