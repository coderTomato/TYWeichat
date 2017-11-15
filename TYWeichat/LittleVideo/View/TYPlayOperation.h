//
//  TYPlayOperation.h
//  IMAPPMIOS
//
//  Created by lijun on 2016/11/18.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYVideoConfig.h"

typedef void(^VideoDecodeBlock) (CGImageRef imageData);

@interface TYPlayOperation : NSBlockOperation

/** 视频url*/
@property (strong, nonatomic) NSURL *videoUrl;
/** 视频播放类型*/
@property (assign, nonatomic) TYVideoPlayType videoPlayType;
/** 操作*/
@property (copy, nonatomic) VideoDecodeBlock decodeBlock;

- (void)startVithBlock:(VideoDecodeBlock)video;

- (instancetype)initWithUrl:(NSURL *)url
               andPlayType:(TYVideoPlayType)type;

@end
