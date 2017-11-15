//
//  TYEmotionPopView.m
//  IMAPPMIOS
//
//  Created by lijun on 16/8/27.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import "TYEmotionPopView.h"
#import "TYEmotionView.h"

@interface TYEmotionPopView()

@property (weak, nonatomic) IBOutlet TYEmotionView *emotionView;

@end

@implementation TYEmotionPopView

+ (instancetype)popView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"TYEmotionPopView" owner:nil options:nil] lastObject];
}

- (void)showFromView:(TYEmotionView *)emotionView
{
    if (!emotionView) return;
    // 1.显示表情
    self.emotionView.emotionDict = emotionView.emotionDict;
    // 2.添加到窗口上
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    [window addSubview:self];
    
    // 3.设置位置
    CGFloat centerX = emotionView.centerX;
    CGFloat centerY = emotionView.centerY - self.height * 0.5;
    CGPoint center = CGPointMake(centerX, centerY);
    //self.center = [window convertPoint:center fromView:emotionView.superview];
    self.center = [emotionView.superview convertPoint:center toView:window];
}

- (void)dismiss
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeFromSuperview];
    });
}

- (void)drawRect:(CGRect)rect
{
    [[UIImage imageNamed:@"emoticon_keyboard_magnifier"] drawInRect:rect];
}


@end
