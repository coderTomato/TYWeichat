//
//  TYVideoSaveTool.m
//  IMAPPMIOS
//
//  Created by lijun on 16/8/22.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import "TYVideoSaveTool.h"
#import "TYVideoModel.h"
#import "TYVideoConfig.h"

@implementation TYVideoSaveTool

+ (BOOL)existVideo
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *nameList = [fileManager subpathsAtPath:[self videoFilePath]];
    return nameList.count > 0;
}

+ (NSMutableArray *)getVideoList
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray *modelList = [NSMutableArray array];
    NSArray *nameList = [fileManager subpathsAtPath:[self videoFilePath]];
    for (NSString *name in nameList) {
        if ([name hasSuffix:@".JPG"])
        {
            TYVideoModel *model = [[TYVideoModel alloc] init];
            NSString *thumAbsolutePath = [[self videoFilePath] stringByAppendingPathComponent:name];
            model.thumAbsolutePath = thumAbsolutePath;
            
            NSString *totalVideoPath = [thumAbsolutePath stringByReplacingOccurrencesOfString:@"JPG" withString:@"MOV"];
            if ([fileManager fileExistsAtPath:totalVideoPath]) {
                model.videoAbsolutePath = totalVideoPath;
            }
            NSString *timeString = [name substringToIndex:(name.length-4)];
            NSDateFormatter *dateformate = [[NSDateFormatter alloc]init];
            dateformate.dateFormat = @"yyyy-MM-dd_HH:mm:ss";
            NSDate *date = [dateformate dateFromString:timeString];
            model.recordTime = date;
            [modelList addObject:model];
        }
    }
    return modelList;
}

+ (NSArray *)getSortVideoList {
    NSArray *oldList = [self getVideoList];
    NSArray *sortList = [oldList sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        TYVideoModel *model1 = obj1;
        TYVideoModel *model2 = obj2;
        NSComparisonResult compare = [model1.recordTime compare:model2.recordTime];
        switch (compare) {
            case NSOrderedDescending:
                return NSOrderedAscending;
            case NSOrderedAscending:
                return NSOrderedDescending;
            default:
                return compare;
        }
    }];
    return sortList;
}

+ (void)saveThumImageWithVideoURL:(NSURL *)videoUrl second:(int64_t)second
{
    AVURLAsset *urlSet = [AVURLAsset assetWithURL:videoUrl];
    AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlSet];
    NSError *error = nil;
    CGImageRef cgImage = [imageGenerator copyCGImageAtTime:CMTimeMake(second, urlSet.duration.timescale) actualTime:nil error:&error];
    if (error)
    {
        return;
    }
    UIImage *image = [UIImage imageWithCGImage:cgImage scale:0.6 orientation:UIImageOrientationRight];
    NSData *imgData = UIImageJPEGRepresentation(image, 1.0);
    NSString *videoPath = [videoUrl.absoluteString stringByReplacingOccurrencesOfString:@"file://" withString: @""];
    NSString *thumPath = [videoPath stringByReplacingOccurrencesOfString:@"MOV" withString: @"JPG"];
    [imgData writeToFile:thumPath atomically:YES];
    CGImageRelease(cgImage);
}

//删除小视频
+ (void)deleteVideoSourceWithPath:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    [fileManager removeItemAtPath:filePath error:&error];
    if (error) {
        NSLog(@"删除视频失败:%@",error);
    }
}

+ (NSString *)videoFilePath
{
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    return [documentPath stringByAppendingPathComponent:@"smallVideo"];
}

+ (NSString *)videoAbsolutePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *videoPath = [self videoFilePath];
    NSError *error = nil;
    if (![fileManager fileExistsAtPath:videoPath])
    {
        [fileManager createDirectoryAtPath:videoPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    NSString *tempFileName = [self currentTime];
    return [videoPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.MOV",tempFileName]];
}
+ (NSString *)currentTime
{
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *formate = [[NSDateFormatter alloc] init];
    formate.dateFormat = @"yyyy-MM-dd_HH:mm:ss";
    NSString *time = [formate stringFromDate:currentDate];
    return time;
}


@end
