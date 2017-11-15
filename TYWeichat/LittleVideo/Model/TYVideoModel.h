//
//  TYVideoModel.h
//  IMAPPMIOS
//
//  Created by lijun on 16/8/22.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TYVideoModel : NSObject

// 完整视频 本地路径
@property (nonatomic, copy) NSString *videoAbsolutePath;
// 缩略图 路径
@property (nonatomic, copy) NSString *thumAbsolutePath;
// 录制时间
@property (nonatomic, strong) NSDate *recordTime;
/** 是否在播放*/
@property (assign, nonatomic) BOOL playing;

@end

