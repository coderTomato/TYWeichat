//
//  TYKeyboardView.m
//  IMAPPMIOS
//
//  Created by lijun on 16/8/22.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import "TYKeyboardView.h"
#import "TYEmotionListView.h"
#import "TYEmotionToolbar.h"
#import "TYEmotionTool.h"

@interface TYKeyboardView()<TYEmotionToolbarDelegate>

/** 表情列表*/
@property (weak, nonatomic) TYEmotionListView *listView;
/** 工具条*/
@property (weak, nonatomic) TYEmotionToolbar *toolbar;
@end

@implementation TYKeyboardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor colorWithRed:29 / 255.0 green:25 / 255.0 blue:25 / 255.0 alpha:1.0];
        //添加表情列表
        TYEmotionListView  *listView = [[TYEmotionListView alloc] init];
        [self addSubview:listView];
        self.listView = listView;
        
        //添加表情工具条
        TYEmotionToolbar *toolbar = [[TYEmotionToolbar alloc] init];
        [self addSubview:toolbar];
        toolbar.delegate = self;
        self.toolbar = toolbar;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //设置工具条的frame
    self.toolbar.width = self.width;
    self.toolbar.height = 35;
    self.toolbar.y = self.height - self.toolbar.height;
    
    //设置表情列表的frame
    self.listView.width = self.width;
    self.listView.height = self.toolbar.y;
}

- (void)emotionToolbar:(TYEmotionToolbar *)toolbar didSelectedButton:(TYEmotionType)type
{
    if(type == TYEmotionTypeEmotion)
    {
        self.listView.emotions = [TYEmotionTool defaultEmotions];
    }
    else if (type == TYEmotionTypeCustom)
    {
        self.listView.emotions = [TYEmotionTool customEmotions];
    }
    else
    {
        if([self.delegate respondsToSelector:@selector(keyboardViewResignFirstResponder:)])
        {
            [self.delegate keyboardViewResignFirstResponder:self];
        }
    }
}

@end
