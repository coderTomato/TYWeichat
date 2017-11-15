//
//  TYComposeToolbar.m
//  IMAPPMIOS
//
//  Created by lijun on 16/8/22.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import "TYComposeToolbar.h"

@interface TYComposeToolbar()

/** <#注释#>*/
@property (weak, nonatomic) UIButton *emotionBtn;

@end

@implementation TYComposeToolbar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self addButtonWithIcon:@"littleVedio_bvmention" highIcon:@"littleVedio_bvmention" tag:TYComposeToolbarButtonTypeMention];
        [self addButtonWithIcon:@"littleVedio_bvlocation" highIcon:@"littleVedio_bvlocation" tag:TYComposeToolbarButtonTypeLocation];
        [self addButtonWithIcon:@"littleVedio_bvauth" highIcon:@"littleVedio_bvauth" tag:TYComposeToolbarButtonTypeAuthority];
        [self addButtonWithTitle:@"公开" tag:TYComposeToolbarButtonTypePrivate];
        self.emotionBtn = [self addButtonWithIcon:@"littleVedio_chat" highIcon:@"littleVedio_chat" tag:TYComposeToolbarButtonTypeEmotion];
    }
    return self;
}

- (UIButton *)addButtonWithIcon:(NSString *)icon highIcon:(NSString *)highIcon tag:(TYComposeToolbarButtonType)tag
{
    UIButton *btn = [[UIButton alloc] init];
    btn.tag = tag;
    [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:highIcon] forState:UIControlStateHighlighted];
    [self addSubview:btn];
    return btn;
}

- (void)addButtonWithTitle:(NSString *)title tag:(TYComposeToolbarButtonType)tag
{
    UIButton *btn = [[UIButton alloc] init];
    btn.tag = tag;
    [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithHex:@"#D7D7D7"] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    [self addSubview:btn];
}

- (void)setShowEmotionButton:(BOOL)showEmotionButton
{
    _showEmotionButton = showEmotionButton;
    if (showEmotionButton)
    {
        [self.emotionBtn setImage:[UIImage imageNamed:@"littleVedio_keyboard"] forState:UIControlStateNormal];
    }
    else
    {
        [self.emotionBtn setImage:[UIImage imageNamed:@"littleVedio_chat"] forState:UIControlStateNormal];
    }
}

- (void)buttonClick:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(composeToolbar:didSelectedType:)]) {
        [self.delegate composeToolbar:self didSelectedType:btn.tag];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    NSUInteger count = self.subviews.count;
    CGFloat btnW = 44;
    CGFloat btnH = self.height;
    for (int i = 0; i < count; i++)
    {
        UIButton *btn = self.subviews[i];
        //btn.backgroundColor = [UIColor colorWithRed:(arc4random() % 256) / 255.0 green:(arc4random() % 256) / 255.0 blue:(arc4random() % 256) / 255.0 alpha:1.0];
        btn.x = i * btnW;
        if (i == count - 1) {
            btn.x = ScreenWidth - btnW;
        }
        btn.width = btnW;
        btn.height = btnH;
    }
}


@end
