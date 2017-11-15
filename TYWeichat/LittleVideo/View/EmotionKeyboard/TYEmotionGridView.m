//
//  TYEmotionGridView.m
//  IMAPPMIOS
//
//  Created by lijun on 16/8/23.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import "TYEmotionGridView.h"
#import "TYVideoConfig.h"
#import "TYEmotionView.h"
#import "TYEmotionPopView.h"

@interface TYEmotionGridView()

/** 表情数组*/
@property (strong, nonatomic) NSMutableArray *motionsArray;
/** <#注释#>*/
@property (weak, nonatomic) UIButton *deleteBtn;
/** <#注释#>*/
@property (strong, nonatomic) TYEmotionPopView *popView;

@end

@implementation TYEmotionGridView

- (NSMutableArray *)motionsArray
{
    if (_motionsArray == nil) {
        self.motionsArray = [NSMutableArray array];
    }
    return _motionsArray;
}

- (TYEmotionPopView *)popView
{
    if (_popView == nil) {
        self.popView = [TYEmotionPopView popView];
    }
    return _popView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // 添加删除按钮
        UIButton *deleteBtn = [[UIButton alloc] init];
        [deleteBtn setImage:[UIImage imageNamed:@"chat_face_delete"] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:deleteBtn];
        self.deleteBtn = deleteBtn;
        
        //给自己添加一个长按手势识别器
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] init];
        [recognizer addTarget:self action:@selector(longPress:)];
        [self addGestureRecognizer:recognizer];
    }
    return self;
}

- (void)longPress:(UILongPressGestureRecognizer *)recognizer
{
    //1.捕获触摸点
    CGPoint point = [recognizer locationInView:recognizer.view];
    //2.检测触摸点落在哪个表情上
    TYEmotionView *emotionView = [self emotionViewFromPoint:point];
    if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        // 移除表情弹出控件
        [self.popView dismiss];
        // 选中表情
        [self selecteEmotion:emotionView.emotionDict];
    }
    else// 显示表情弹出控件
    {
        [self.popView showFromView:emotionView];
    }
}

- (void)deleteClick
{
    [[NSNotificationCenter defaultCenter] postNotificationName:TYEmotionDeleteNotification object:nil];
}
/**
 *  根据触摸点返回对应的表情控件
 */
- (TYEmotionView *)emotionViewFromPoint:(CGPoint)point
{
    __block TYEmotionView *emotionView = nil;
    [self.motionsArray enumerateObjectsUsingBlock:^(TYEmotionView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectContainsPoint(obj.frame, point))
        {
            emotionView = obj;
            *stop = YES;
        }
    }];
    return emotionView;
}

/**
 *  选中表情
 */
- (void)selecteEmotion:(NSDictionary *)emotionDict
{
    if (!emotionDict) return;
    [[NSNotificationCenter defaultCenter] postNotificationName:TYEmotionDidSelectedNotification object:nil userInfo:emotionDict];
}

- (void)setEmotions:(NSArray *)emotions
{
    _emotions = emotions;
    // 添加新的表情
    NSInteger num = emotions.count;
    NSInteger currentEmotionCount = self.motionsArray.count;
    TYEmotionView *emotionBtn = nil;
    for (int i = 0; i < num; i++)
    {
        if (i >= currentEmotionCount)
        {
            emotionBtn = [[TYEmotionView alloc] init];
            [emotionBtn addTarget:self action:@selector(emotionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:emotionBtn];
            [self.motionsArray addObject:emotionBtn];
        }
        else
        {
            emotionBtn = self.motionsArray[i];
        }
        // 传递模型数据
        emotionBtn.emotionDict = emotions[i];
        emotionBtn.hidden = NO;
    }
    // 隐藏多余的emotionView
    for (NSInteger i = num; i < currentEmotionCount; i++)
    {
        TYEmotionView *emotionBtn = self.motionsArray[i];
        emotionBtn.hidden = YES;
    }
}

- (void)emotionBtnClick:(TYEmotionView *)sender
{
    // 选中表情
    [self selecteEmotion:sender.emotionDict];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat leftInset = 0;
    CGFloat topInset = 20;
    //排列所有的表情
    NSInteger count = self.emotions.count;
    CGFloat emotionW = (self.width - leftInset * 2) / emotionMaxCols;
    CGFloat emotionH = (self.height - topInset) / emotionMaxRows;
    for (int i = 0; i < count; i++)
    {
        UIButton *btn = self.motionsArray[i];
        //btn.backgroundColor = [UIColor colorWithRed:(arc4random() % 256) / 255.0 green:(arc4random() % 256) / 255.0 blue:(arc4random() % 256) / 255.0 alpha:1.0];
        CGFloat emtionX = leftInset + (i % emotionMaxCols) * emotionW;
        CGFloat emtionY = topInset + (i / emotionMaxCols) * emotionH;
        btn.frame = CGRectMake(emtionX, emtionY, emotionW, emotionH);
    }
    self.deleteBtn.frame = CGRectMake(self.width - leftInset - emotionW, self.height - emotionH, emotionW, emotionH);
}

@end
