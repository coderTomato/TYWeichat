//
//  TYEmotionToolbar.m
//  IMAPPMIOS
//
//  Created by lijun on 16/9/5.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import "TYEmotionToolbar.h"

#define TYEmotionToolbarButtonMaxCount 2

@interface TYEmotionToolbar()

/** 当前选中的按钮*/
@property (weak, nonatomic) UIButton *selectedBtn;
/** 表情按钮*/
@property (weak, nonatomic) UIButton *emotionBtn;

@end

@implementation TYEmotionToolbar

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        //添加4个工具条按钮
        self.emotionBtn = [self setupImage:[UIImage imageNamed:@"1_1"] emotionType:TYEmotionTypeEmotion];
        [self setupImage:[UIImage imageNamed:@"2_1"] emotionType:TYEmotionTypeCustom];
        //[self setupButton:@"完成" emotionType:TYEmotionTypeDone];
    }
    return self;
}

- (void)setDelegate:(id<TYEmotionToolbarDelegate>)delegate
{
    _delegate = delegate;
    [self buttonClick:self.emotionBtn];
}

- (UIButton *)setupImage:(UIImage *)image emotionType:(TYEmotionType)type
{
    UIButton *button = [[UIButton alloc] init];
    // 文字
    button.tag = type;
    [button setImage:image forState:UIControlStateNormal];
    /*[button setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
     [button setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateSelected];*/
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    return button;
}

- (UIButton *)setupButton:(NSString *)title emotionType:(TYEmotionType)type
{
    UIButton *button = [[UIButton alloc] init];
    button.tag = type;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateSelected];
    button.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    return button;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat btnW = 50;
    CGFloat btnH = self.height;
    for (int i = 0; i < TYEmotionToolbarButtonMaxCount; i++)
    {
        UIButton *btn = self.subviews[i];
        btn.x = i * btnW;
        btn.width = btnW;
        btn.height = btnH;
        /*if (i == TYEmotionToolbarButtonMaxCount - 1) {
         btn.x = ScreenWidth - btnW * 2;
         btn.width = btnW * 2;
         }*/
    }
}

- (void)buttonClick:(UIButton *)sender
{
    self.selectedBtn.selected = NO;
    sender.selected = YES;
    self.selectedBtn = sender;
    if ([self.delegate respondsToSelector:@selector(emotionToolbar:didSelectedButton:)])
    {
        [self.delegate emotionToolbar:self didSelectedButton:sender.tag];
    }
}

@end
