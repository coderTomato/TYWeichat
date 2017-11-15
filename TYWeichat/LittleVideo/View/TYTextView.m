//
//  TYTextView.m
//  IMAPPMIOS
//
//  Created by lijun on 16/8/22.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import "TYTextView.h"

@interface TYTextView()

@property (weak, nonatomic) UILabel *placeHolderLbl;

@end

@implementation TYTextView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setupBase];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self setupBase];
    }
    return self;
}

- (void)setupBase
{
    self.backgroundColor = [UIColor clearColor];
    // 添加一个显示提醒文字的label（显示占位文字的label）
    UILabel *placeHolderLbl = [[UILabel alloc] init];
    placeHolderLbl.numberOfLines = 0;
    placeHolderLbl.backgroundColor = [UIColor clearColor];
    self.placeHolderLbl = placeHolderLbl;
    [self addSubview:placeHolderLbl];
    
    // 设置默认的占位文字颜色
    self.placeHolderColor = [UIColor lightGrayColor];
    // 设置默认的字体
    self.font = [UIFont systemFontOfSize:14.0f];
    
    // 监听内部文字改变,监听自己发出的通知，如果object：nil整个项目所有textView发生的通知都能知道
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:self];
}

- (void)textDidChange
{
    self.placeHolderLbl.hidden = self.hasText;
}

- (void)setPlaceHolder:(NSString *)placeHolder
{
    _placeHolder = [placeHolder copy];
    // 设置文字
    self.placeHolderLbl.text = placeHolder;
    //重新计算子控件的frame
    [self setNeedsLayout];
}

- (void)setPlaceHolderColor:(UIColor *)placeHolderColor
{
    _placeHolderColor = placeHolderColor;
    // 设置颜色
    self.placeHolderLbl.textColor = placeHolderColor;
}

//别人在外面修改我的字体显示label的字体不能跟着改，所以需要重写set方法
- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    self.placeHolderLbl.font = self.font;
    //重新计算子控件的frame
    [self setNeedsLayout];
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    
    [self textDidChange];
}

//输入emoji主动调通知
- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    [self textDidChange];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.placeHolderLbl.x = 5;
    self.placeHolderLbl.y = 8;
    self.placeHolderLbl.width = self.width - self.placeHolderLbl.x*2;
    CGSize textSize = CGSizeMake(self.width, MAXFLOAT);
    CGSize placeholderSize = [self.placeHolder sizeWithFont:self.font constrainedToSize:textSize];
    self.placeHolderLbl.height = placeholderSize.height;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
