//
//  UIImage+Extension.m
//  Test
//
//  Created by 李军 on 13-4-10.
//  Copyright (c) 2013年 李军. All rights reserved.
//

#import "UIImage+Extension.h"

@implementation UIImage (Extension)


+ (UIImage *)imageWithName:(NSString *)name
{
    UIImage *image = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        NSString *newName = [name stringByAppendingString:@"_os7"];
        image = [UIImage imageNamed:newName];
    }
    if (image == nil) { // 没有_os7后缀的图片
        image = [UIImage imageNamed:name];
    }
    return image;
}

+ (UIImage *)resizedImage:(NSString *)name
{
    UIImage *image = [self imageWithName:name];
    return [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGFloat imageW = 100;
    CGFloat imageH = 100;
    //1.开启基于位图的上下文 NO透明
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageW, imageH), NO, 0.0);
    //2.画一个color颜色的矩形框
    [color set];
    UIRectFill(CGRectMake(0, 0, imageW, imageH));
    //3.拿到图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    //4.关闭上下文
    UIGraphicsEndImageContext();
    return image;
}
/**
 *  生成水印
 *  @param bgName  背景图片
 *  @param logNmae 水印图片
 *  @return 生成(带水印的图片)
 */
+ (instancetype)imageWithBgImageName:(NSString *)bgName log:(NSString *)logName
{
    // 0. 加载背景图片
    UIImage *image = [UIImage imageNamed:bgName];
    // 1.创建bitmap上下文
    // 执行完这一行在内存中就相遇创建了一个UIImage
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
    // 2.绘制背景图片
    [image drawAtPoint:CGPointMake(0, 0)];
    // 3.绘制水印
    UIImage *logImage = [UIImage imageNamed:logName];
    CGFloat margin = 10;
    CGFloat logY = margin;
    CGFloat logX = image.size.width - margin - logImage.size.width;
    [logImage drawAtPoint:CGPointMake(logX, logY)];
    // 4.获得图片
    UIImage *newImage =  UIGraphicsGetImageFromCurrentImageContext();
    return newImage;
}
/**
 *  @param icon   头像图片名称
 *  @param border 头像边框大小
 *  @param color  头像边框的颜色
 *  @return 生成头像
 */
+ (instancetype)imageWithIcon:(NSString *)icon border:(NSInteger)border color:(UIColor *)color
{
    // 0. 加载原有图片
    UIImage *image = [UIImage imageNamed:icon];
    // 1.创建图片上下文
    CGFloat margin = border;
    CGSize size = CGSizeMake(image.size.width + margin, image.size.height + margin);
    // YES 不透明 NO 透明
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    // 2.绘制大圆
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(ctx, CGRectMake(0, 0, size.width, size.height));
    [color set];
    CGContextFillPath(ctx);
    // 3.绘制小圆
    CGFloat smallX = margin * 0.5;
    CGFloat smallY = margin * 0.5;
    CGFloat smallW = image.size.width;
    CGFloat smallH = image.size.height;
    CGContextAddEllipseInRect(ctx, CGRectMake(smallX, smallY, smallW, smallH));
    // 4.指点可用范围, 可用范围的适用范围是在指定之后,也就说在在指定剪切的范围之前绘制的东西不受影响
    CGContextClip(ctx);
    // 5.绘图图片
    [image drawInRect:CGRectMake(smallX, smallY, smallW, smallH)];
    // 6.取出图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    return newImage;
}

+ (instancetype)mergeImage:(UIImage *)image otherImage:(UIImage *)otherImg
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
    // Draw image1
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    // Draw image2
    [otherImg drawInRect:CGRectMake(0, 0, otherImg.size.width, otherImg.size.height)];
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImg;
}
/**
 * 圆形图片
 */
- (UIImage *)circleImage
{
    // NO代表透明
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    // 获得上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // 添加一个圆
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextAddEllipseInRect(ctx, rect);
    // 裁剪
    CGContextClip(ctx);
    // 将图片画上去
    [self drawInRect:rect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/**
 *  获得某个像素的颜色
 *
 *  @param point 像素点的位置
 */
- (UIColor *)pixelColorAtLocation:(CGPoint)point {
    UIColor *color = nil;
    CGImageRef inImage = self.CGImage;
    CGContextRef contexRef = [self ARGBBitmapContextFromImage:inImage];
    if (contexRef == NULL) return nil;
    
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(contexRef, rect, inImage);
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    unsigned char* data = CGBitmapContextGetData (contexRef);
    if (data != NULL) {
        //offset locates the pixel in the data from x,y.
        //4 for 4 bytes of data per pixel, w is width of one row of data.
        int offset = 4*((w*round(point.y))+round(point.x));
        int alpha =  data[offset];
        int red = data[offset+1];
        int green = data[offset+2];
        int blue = data[offset+3];
        //		NSLog(@"offset: %i colors: RGB A %i %i %i  %i",offset,red,green,blue,alpha);
        color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
    }
    
    // When finished, release the context
    CGContextRelease(contexRef);
    // Free image data memory for the context
    if (data) { free(data); }
    
    return color;
}

/**
 *  根据CGImageRef来创建一个ARGBBitmapContext
 */
- (CGContextRef)ARGBBitmapContextFromImage:(CGImageRef) inImage {
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    NSInteger             bitmapByteCount;
    NSInteger             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    //colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);  //deprecated
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

@end
