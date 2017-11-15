//
//  TYVideoSaveTool.h
//  IMAPPMIOS
//
//  Created by lijun on 16/8/22.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TYVideoModel;

@interface TYVideoSaveTool : NSObject

/*
 *  有视频的存在
 */
+ (BOOL)existVideo;

/*
 *  时间倒序 后的视频列表
 */
+ (NSArray *)getSortVideoList;

/*
 *  保存缩略图
 *
 *  @param videoUrl 视频路径
 *  @param second   第几秒的缩略图
 */
+ (void)saveThumImageWithVideoURL:(NSURL *)videoUrl second:(int64_t)second;

+ (NSString *)videoFilePath;
+ (NSString *)videoAbsolutePath;
/*
 *  删除视频
 */
+ (void)deleteVideoSourceWithPath:(NSString *)filePath;

@end
