//
//  TYTakeVideoButton.m
//  IMAPPMIOS
//
//  Created by lijun on 16/8/29.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import "TYTakeVideoButton.h"

@interface TYTakeVideoButton()

/** 开始按下时间*/
@property (nonatomic, assign) CFAbsoluteTime beginTapTime;
@property (nonatomic,assign)BOOL isTouchOutside;

@end

@implementation TYTakeVideoButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(touchUp) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(touchUp) forControlEvents:UIControlEventTouchUpOutside];
        [self addTarget:self action:@selector(touchWithSender:event:) forControlEvents:UIControlEventAllTouchEvents];
    }
    return self;
}

- (void)touchDown
{
    self.beginTapTime = CACurrentMediaTime();
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeScale(2, 2);
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.transform = CGAffineTransformIdentity;
    }];
    if ([self.delegate respondsToSelector:@selector(TYTakeVideoButtonDidTouchDown)])
    {
        [self.delegate TYTakeVideoButtonDidTouchDown];
    }
}

- (void)touchUp
{
    if (self.isTouchOutside)
    {
        [self touchUpOutside];
    }
    else
    {
        [self touchUpInside];
    }
}

- (void)showAnimation
{
    [UIView animateWithDuration:0.1 animations:^{
        self.transform = CGAffineTransformMakeScale(2, 2);
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.transform = CGAffineTransformIdentity;
        self.alpha = 1;
    }];
}

- (void)touchUpInside
{
    CFAbsoluteTime endTime = CACurrentMediaTime();
    if ([self.delegate respondsToSelector:@selector(TYTakeVideoButtonDidTouchUpInside)])
    {
        [self.delegate TYTakeVideoButtonDidTouchUpInside];
    }
    if (self.beginTapTime != 0 && endTime - self.beginTapTime < 1)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.1 animations:^{
                self.alpha = 1.0;
            }];
        });
        return;
    }
    [self showAnimation];
}

- (void)touchUpOutside
{
    [self showAnimation];
    if ([self.delegate respondsToSelector:@selector(TYTakeVideoButtonDidTouchUpOutside)])
    {
        [self.delegate TYTakeVideoButtonDidTouchUpOutside];
    }
}

- (void)touchDragEnter
{
    self.isTouchOutside = NO;
    if ([self.delegate respondsToSelector:@selector(TYTakeVideoButtonDidTouchDragEnter)])
    {
        [self.delegate TYTakeVideoButtonDidTouchDragEnter];
    }
}

- (void)touchDragExit
{
    self.isTouchOutside = YES;
    NSLog(@"UIControlEventTouchDragExit");
    if ([self.delegate respondsToSelector:@selector(TYTakeVideoButtonDidTouchDragExit)])
    {
        [self.delegate TYTakeVideoButtonDidTouchDragExit];
    }
}

- (void)touchWithSender:(UIButton *)sender event:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGFloat boundsExtension = 10.0f;
    CGRect outerBounds = CGRectInset(sender.bounds, -1 * boundsExtension, -1 * boundsExtension);
    CGPoint location = [touch locationInView:sender];
    CGPoint previewLocation = [touch previousLocationInView:sender];
    BOOL touchInside = CGRectContainsPoint(outerBounds, location);
    BOOL previewTouchInside = CGRectContainsPoint(outerBounds, previewLocation);
    
    if ((location.x == previewLocation.x) && (location.y == previewLocation.y))
    {
        //这个情况不是touchDown就是touchUpInside
        self.isTouchOutside = NO;
        return;
    }
    if (touchInside)
    {
        if (!previewTouchInside)
        {
            // UIControlEventTouchDragInside
            [self touchDragEnter];
        }
    }
    else
    {
        if (previewTouchInside)
        {
            // UIControlEventTouchDragExit
            [self touchDragExit];
        }
    }
}

@end
