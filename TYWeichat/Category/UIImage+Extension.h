//
//  UIImage+Extension.h
//  Test
//
//  Created by 李军 on 13-4-10.
//  Copyright (c) 2013年 李军. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)

/**
 *  加载图片
 *  @param name 图片名
 */
+ (UIImage *)imageWithName:(NSString *)name;

/**
 *  返回一张自由拉伸的图片
 */
+ (UIImage *)resizedImage:(NSString *)name;

//根据色值返回一个图片
+ (UIImage *)imageWithColor:(UIColor *)color;

/**
 *  生成水印
 *  @param bgName  背景图片
 *  @param logNmae 水印图片
 *  @return 生成(带水印的图片)
 */
+ (instancetype)imageWithBgImageName:(NSString *)bgName log:(NSString *)logName;

/**
 *  @param icon   头像图片名称
 *  @param border 头像边框大小
 *  @param color  头像边框的颜色
 *  @return 生成头像
 */
+ (instancetype)imageWithIcon:(NSString *)icon border:(NSInteger)border color:(UIColor *)color;

+ (instancetype)mergeImage:(UIImage *)image otherImage:(UIImage *)otherImg;

/**
 * 圆形图片
 */
- (UIImage *)circleImage;

/**
 *  获得某个像素的颜色
 *  @param point 像素点的位置
 */
- (UIColor *)pixelColorAtLocation:(CGPoint)point;

/**
 *  根据CIImage生成指定大小的UIImage
 *  @param image CIImage
 *  @param size  图片宽度
 */
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size;

@end
