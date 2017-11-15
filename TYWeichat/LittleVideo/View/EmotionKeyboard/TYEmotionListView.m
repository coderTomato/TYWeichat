//
//  TYEmotionListView.m
//  IMAPPMIOS
//
//  Created by lijun on 16/8/22.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import "TYEmotionListView.h"
#import "TYEmotionGridView.h"
#import "TYVideoConfig.h"

@interface TYEmotionListView()<UIScrollViewDelegate>

/** 显示所有表情的UIScrollView */
@property (nonatomic, weak) UIScrollView *scrollView;
/** 显示页码的UIPageControl */
@property (nonatomic, weak) UIPageControl *pageControl;

@end

@implementation TYEmotionListView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // 1.显示所有表情的UIScrollView
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.pagingEnabled = YES;
        scrollView.delegate = self;
        [self addSubview:scrollView];
        self.scrollView = scrollView;
        
        // 2.显示页码的UIPageControl
        UIPageControl *pageControl = [[UIPageControl alloc] init];
        pageControl.hidesForSinglePage = YES;
        [self addSubview:pageControl];
        self.pageControl = pageControl;
    }
    return self;
}

- (void)setEmotions:(NSArray *)emotions
{
    _emotions = emotions;
    NSInteger count = emotions.count;
    NSInteger totalPage = (count + emotionMaxCountPerPage - 1) / emotionMaxCountPerPage;
    self.pageControl.numberOfPages = totalPage;
    self.pageControl.currentPage = 0;
    NSInteger currentGridViewCount = self.scrollView.subviews.count;
    
    for (int i = 0; i < totalPage; i++)
    {
        TYEmotionGridView *gridView = nil;
        if (i >= currentGridViewCount)
        {
            gridView = [[TYEmotionGridView alloc] init];
            [self.scrollView addSubview:gridView];
        }
        else
        {
            gridView = self.scrollView.subviews[i];
        }
        NSInteger loc = i * emotionMaxCountPerPage;
        NSInteger len = emotionMaxCountPerPage;
        if (loc + len > count)
        {
            len = count - loc;
        }
        NSRange emotionRang = NSMakeRange(loc, len);
        gridView.emotions = [emotions subarrayWithRange:emotionRang];
        gridView.hidden = NO;
    }
    for (NSInteger i = totalPage; i < currentGridViewCount; i++)
    {
        TYEmotionGridView *gridView = self.scrollView.subviews[i];
        gridView.hidden = YES;
    }
    // 重新布局子控件
    [self setNeedsLayout];
    // 表情滚动到最前面
    self.scrollView.contentOffset = CGPointZero;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    // 1.UIPageControl的frame
    self.pageControl.width = self.width;
    self.pageControl.height = 35;
    self.pageControl.y = self.height - self.pageControl.height - 15;
    // 2.UIScrollView的frame
    self.scrollView.width = self.width;
    self.scrollView.height = self.pageControl.y;
    
    NSInteger count = self.pageControl.numberOfPages;
    self.scrollView.contentSize = CGSizeMake(count * self.scrollView.width, self.scrollView.height);
    
    CGFloat gridW = self.scrollView.width;
    CGFloat gridH = self.scrollView.height;
    for (int i = 0; i < count; i++)
    {
        TYEmotionGridView *gridView = self.scrollView.subviews[i];
        gridView.x = i * gridW;
        gridView.width = gridW;
        gridView.height = gridH;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = (int)((scrollView.contentOffset.x / scrollView.width) + 0.5);
}
@end
