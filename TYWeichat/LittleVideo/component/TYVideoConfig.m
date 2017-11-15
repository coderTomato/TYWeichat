//
//  TYVideoConfig.m
//  IMAPPMIOS
//
//  Created by lijun on 16/8/22.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import "TYVideoConfig.h"

/** 小视频宽高比*/
CGFloat const shortVideo_w_h = (5.0 / 4);
/** 小视频历史界面圆角*/
CGFloat const video_corner = 5.0;
/** 小视频历史界面间距*/
CGFloat const videoListMargin = 17;
/** 小视频历史界面上间距*/
CGFloat const topMargin = 12;
/** 小视频历史界面每行间距*/
CGFloat const lineSpacing = 13;
/** 表情选中的通知*/
NSString *const TYEmotionDidSelectedNotification = @"TYEmotionDidSelectedNotification";
/** 表情删除通知*/
NSString *const TYEmotionDeleteNotification = @"TYEmotionDeleteNotification";

@implementation TYVideoConfig

+ (CGRect)viewFrameWithType:(YSVideoViewStyle)type
{
    if (type == YSVideoViewStyleFull) {
        return [UIScreen mainScreen].bounds;
    }
    CGFloat viewHeight = ScreenWidth/shortVideo_w_h + 130;
    return CGRectMake(0, ScreenHeight - viewHeight, ScreenWidth, viewHeight);
}


@end
