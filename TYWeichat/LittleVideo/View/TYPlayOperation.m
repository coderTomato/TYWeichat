//
//  TYPlayOperation.m
//  IMAPPMIOS
//
//  Created by lijun on 2016/11/18.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import "TYPlayOperation.h"
#define MAIN(block) dispatch_async(dispatch_get_main_queue(),block)

@implementation TYPlayOperation

-(instancetype)initWithUrl:(NSURL *)url
               andPlayType:(TYVideoPlayType)type
{
    if (self = [super init])
    {
        self.videoUrl = url;
        self.videoPlayType = type;
    }
    return self;
}

-(void)startVithBlock:(VideoDecodeBlock)video
{
    _decodeBlock = video;
    __weak typeof(self) weakSelf = self;
    [self addExecutionBlock:^{
        [weakSelf videoPlayTask];
    }];
}

-(void)videoPlayTask
{
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.videoUrl options:nil];
    NSError *error;
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if (!videoTracks.count) return;
    
    AVAssetTrack *videoTrack = videoTracks.firstObject;
    UIImageOrientation orientation = [self orientationFromAVAssetTrack:videoTrack];
    
    int m_pixelFormatType = kCVPixelFormatType_32BGRA;
    NSDictionary* options = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt: (int)m_pixelFormatType] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    AVAssetReaderTrackOutput* videoReaderOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:options];
    [reader addOutput:videoReaderOutput];
    [reader startReading];
    while ([reader status] == AVAssetReaderStatusReading && videoTrack.nominalFrameRate > 0&&(!self.isCancelled))
    {
        @autoreleasepool {
            CMSampleBufferRef sampleBuffer = [videoReaderOutput copyNextSampleBuffer];
            if (!sampleBuffer) break;
            CGImageRef videoImage = [TYPlayOperation imageFromSampleBuffer:sampleBuffer rotation:orientation];
            MAIN(^{
                if (_decodeBlock)
                {
                    _decodeBlock(videoImage);
                }
                if (sampleBuffer)
                {
                    CFRelease(sampleBuffer);
                }
                if (videoImage)
                {
                    CGImageRelease(videoImage);
                }
            });
            [NSThread sleepForTimeInterval:CMTimeGetSeconds(videoTrack.minFrameDuration)];
        }
    }
    if (self.videoPlayType == TYVideoPlayAtLeastOnce && reader.status == AVAssetReaderStatusCompleted)
    {
        [self videoPlayTask];
        return;
    }
    [reader cancelReading];
}

- (UIImageOrientation)orientationFromAVAssetTrack:(AVAssetTrack *)videoTrack
{
    UIImageOrientation orientation;
    CGAffineTransform t = videoTrack.preferredTransform;
    if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
        // Portrait
        //        degress = 90;
        orientation = UIImageOrientationRight;
    }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
        // PortraitUpsideDown
        //        degress = 270;
        orientation = UIImageOrientationLeft;
    }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
        // LandscapeRight
        //        degress = 0;
        orientation = UIImageOrientationUp;
    }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
        // LandscapeLeft
        //        degress = 180;
        orientation = UIImageOrientationDown;
    }
    return orientation;
}

//用AVFoundation捕捉视频帧，把某一帧转换成CGImageRef
+ (CGImageRef) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer rotation:(UIImageOrientation)orientation
{
    // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
     // 锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // 得到pixel buffer的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // 得到pixel buffer的基地址
    unsigned char* pixel = (unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
    
    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
    CGContextRef context=CGBitmapContextCreate(pixel, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little|kCGImageAlphaPremultipliedFirst);
    // 根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef image = CGBitmapContextCreateImage(context);
    // 释放context和颜色空间
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    UIGraphicsEndImageContext();
    
    if (orientation == UIImageOrientationUp) {
        return image;
    }
    CGImageRef imageRef = [self image:image rotation:orientation];
    return imageRef;
}


+ (CGImageRef)image:(CGImageRef)image rotation:(UIImageOrientation)orientation
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    CGSize size = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
    
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, size.height, size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, size.height, size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, size.width, size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, size.width, size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    CGContextScaleCTM(context, scaleX, scaleY);
    
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image);
    CGImageRef imageRef=CGBitmapContextCreateImage(context);
    UIGraphicsEndImageContext();
    if (image) {
        CGImageRelease(image);
    }
    return imageRef;
}

@end
