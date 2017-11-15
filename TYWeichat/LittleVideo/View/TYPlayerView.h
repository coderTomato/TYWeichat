//
//  TYPlayerView.h
//  TestTool
//
//  Created by lijun on 16/8/20.
//  Copyright © 2016年 lijun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYVideoModel.h"
#import "TYVideoConfig.h"

typedef NS_ENUM(NSInteger, TYPlayerViewMode)
{
    TYPlayerViewModePreview,
    TYPlayerViewModeFullPlay
};

@class TYPlayerView;

@protocol TYPlayerViewDelegate <NSObject>
@optional
- (void)playerViewPushToFullScreenDidPlay:(TYPlayerView *)playerView;

@end

@interface TYPlayerView : UIView

/** 视频Url*/
@property (strong, nonatomic) NSString *urlPath;
@property (weak, nonatomic) id<TYPlayerViewDelegate>delegate;
/** 播放模式*/
@property (assign, nonatomic) TYPlayerViewMode playMode;
/** <#注释#>*/
@property (assign, nonatomic) TYVideoPlayType playType;

/**
 设置视频源
 @param videoPath 本地视频地址
 */
- (void)playedVideoPath:(NSString *)videoPath;
- (void)stop;
- (void)showDefaultImage:(TYVideoModel *)videoModel;

@end
