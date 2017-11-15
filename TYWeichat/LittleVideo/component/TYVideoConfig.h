//
//  TYVideoConfig.h
//  IMAPPMIOS
//
//  Created by lijun on 16/8/22.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TYVideoSaveTool.h"
#import "TYVideoModel.h"


typedef NS_ENUM(NSInteger, YSVideoViewStyle) {
    YSVideoViewStyleSmall = 0,//聊天界面的
    YSVideoViewStyleFull // 朋友圈界面的
};

typedef NS_ENUM(NSInteger,TYVideoPlayType){
    TYVideoPlayAtMostOnce,
    TYVideoPlayAtLeastOnce
};

/** 小视频宽高比*/
UIKIT_EXTERN CGFloat const shortVideo_w_h;
/** 小视频历史界面圆角*/
UIKIT_EXTERN CGFloat const video_corner;
/** 小视频历史界面间距*/
UIKIT_EXTERN CGFloat const videoListMargin;
/** 小视频历史界面上间距*/
UIKIT_EXTERN CGFloat const topMargin;
/** 小视频历史界面每行间距*/
UIKIT_EXTERN CGFloat const lineSpacing;

/** 表情选中的通知*/
UIKIT_EXTERN NSString *const TYEmotionDidSelectedNotification;
/** 表情删除通知*/
UIKIT_EXTERN NSString *const TYEmotionDeleteNotification;

//小视频宽
#define shortVideoWidth ((ScreenWidth - (videoListMargin * 2 + lineSpacing * 2)) / 3)
// 表情的最大行数
#define emotionMaxRows 3
// 表情的最大列数
#define emotionMaxCols 7
// 每页最多显示多少个表情
#define emotionMaxCountPerPage (emotionMaxRows * emotionMaxCols - 1)

/** 通用标题颜色*/
#define commontitleColor [UIColor colorWithHex:@"#636365"]
/** 通用标题字体*/
#define commontitleFont [UIFont systemFontOfSize:18]
/** 手离开时进度条颜色*/
#define progresswarningColor  [UIColor colorWithHex:@"#F7311C"]
/** 进度条正常颜色*/
#define progressnormalColor [UIColor colorWithHex:@"#FF6767"]
/** 双击放大字号*/
#define tintLblFont [UIFont boldSystemFontOfSize:12.0]
/** 上移取消等提示文字的颜色*/
#define tintLblColor [[UIColor colorWithHex:@"#FFFFFF"] colorWithAlphaComponent:0.9]
/** 上移取消等手离开时的提示颜色*/
#define tintwarningColor [UIColor colorWithRed:246 / 255.0 green:52/255.0 blue:41/255.0 alpha:1.0]
/** 按住拍按钮颜色*/
#define tapBtnColor [UIColor colorWithHex:@"#FF6767"]


@interface TYVideoConfig : NSObject

+ (CGRect)viewFrameWithType:(YSVideoViewStyle)type;

@end
