//
//  TYEyeView.m
//  IMAPPMIOS
//
//  Created by lijun on 16/8/31.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import "TYEyeView.h"

@implementation TYEyeView

+ (instancetype)eyeView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"TYEyeView" owner:nil options:nil] lastObject];
}

- (void)awakeFromNib
{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.01];
}

@end
