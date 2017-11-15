//
//  TYPlayerView.m
//  TestTool
//
//  Created by lijun on 16/8/20.
//  Copyright © 2016年 lijun. All rights reserved.
//

#import "TYPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import "TYPlayOperation.h"

@interface TYPlayerView()

/** 显示小视频首帧图*/
@property (weak, nonatomic) UIButton *bgBtn;
/** 小视频模型数据*/
@property (weak, nonatomic) TYVideoModel *videoModel;
/** 轻触发送*/
@property (weak, nonatomic) UILabel *selectlabel;
/** 开始按下时间*/
@property (assign, nonatomic) CFAbsoluteTime beginTapTime;
@property (strong, nonatomic) NSOperationQueue *playQueue;
/** <#注释#>*/
@property (strong, nonatomic) TYPlayOperation *playOperation;

@end

@implementation TYPlayerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.playQueue = [[NSOperationQueue alloc] init];
        self.playQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}


- (void)setPlayMode:(TYPlayerViewMode)playMode
{
    _playMode = playMode;
    if (playMode == TYPlayerViewModePreview)
    {
        UIButton *thumBtn = [[UIButton alloc] init];
        thumBtn.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:thumBtn];
        self.bgBtn = thumBtn;
        
        UILabel *label = [[UILabel alloc] init];
        label.text = @"轻触选择";
        label.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
        label.font = [UIFont systemFontOfSize:12.0];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        self.selectlabel = label;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.bgBtn.frame = self.bounds;
    self.selectlabel.frame = CGRectMake(0, self.bounds.size.height - 25, self.bounds.size.width, 20);
}

- (void)playedVideoPath:(NSString *)videoPath
{
    if(!videoPath) return;
    _urlPath = videoPath;
    [self stop];
    __weak typeof(self) weakSelf = self;
    if (self.playMode == TYPlayerViewModePreview)
    {
        self.bgBtn.hidden = YES;
        self.layer.cornerRadius = video_corner;
        self.layer.masksToBounds = YES;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 1;
        
        [UIView animateWithDuration:0.2 animations:^{
            self.transform = CGAffineTransformMakeScale(1.1, 1.1);
        }];
        self.selectlabel.hidden = NO;
    }
    TYPlayOperation *playOperation = [[TYPlayOperation alloc] initWithUrl:[NSURL fileURLWithPath:videoPath] andPlayType:self.playType];
    self.playOperation = playOperation;
    [playOperation startVithBlock:^(CGImageRef imageData) {
        weakSelf.layer.contents = (__bridge id _Nullable)(imageData);
    }];
    [self.playQueue addOperation:playOperation];
}

- (void)setPlayType:(TYVideoPlayType)playType
{
    _playType = playType;
}

- (void)stop
{
    if (self.playMode == TYPlayerViewModePreview)
    {
        self.bgBtn.hidden = NO;
        self.layer.cornerRadius = video_corner;
        self.layer.masksToBounds = YES;
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.layer.borderWidth = 0;
        self.selectlabel.hidden = YES;
        self.transform = CGAffineTransformIdentity;
    }
    [self.playQueue cancelAllOperations];
}

- (void)showDefaultImage:(TYVideoModel *)videoModel
{
    _videoModel = videoModel;
    [self.bgBtn setBackgroundImage:[UIImage imageWithContentsOfFile:videoModel.thumAbsolutePath] forState:UIControlStateNormal];
}

#pragma mark - Action
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.beginTapTime = CACurrentMediaTime();
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CFAbsoluteTime endTime = CACurrentMediaTime();
    if (endTime - self.beginTapTime > 1) return;
    if(self.delegate && [self.delegate respondsToSelector:@selector(playerViewPushToFullScreenDidPlay:)])
    {
        [self.delegate playerViewPushToFullScreenDidPlay:self];
    }
}

-(void)dealloc
{
    [self.playQueue cancelAllOperations];
}

@end
