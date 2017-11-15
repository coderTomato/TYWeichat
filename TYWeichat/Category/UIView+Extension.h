//
//  UIView+Extension.h
//  
//
//  Created by 李军 on 13-4-10.
//  Copyright (c) 2013年 李军. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extension)

@property (assign, nonatomic) CGFloat x;
@property (assign, nonatomic) CGFloat y;
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;
@property (assign, nonatomic) CGFloat centerX;
@property (assign, nonatomic) CGFloat centerY;
@property (assign, nonatomic) CGSize size;
@property (assign, nonatomic) CGFloat right;
@property (assign, nonatomic) CGFloat bottom;


/**
 * Removes all subviews.
 */
- (void)removeAllSubviews;
/**
 * The view controller whose view contains this view.
 */
- (UIViewController*)viewController;
/**
 * 判断一个控件是否真正显示在主窗口
 */
- (BOOL)isShowInKeyWindow;

+ (instancetype)viewFromXIB;

//在分类中声明@property,只会生成方法的声明，不会生成方法的实现和带有下划线的成员变量


@end
