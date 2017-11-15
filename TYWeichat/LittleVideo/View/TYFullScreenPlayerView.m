//
//  TYFullScreenPlayerView.m
//  IMAPPMIOS
//
//  Created by lijun on 16/9/2.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import "TYFullScreenPlayerView.h"

/** label高度*/
int const labelH = 20;

@interface TYFullScreenPlayerView()

@property (nonatomic, strong) NSString *videoPath;
@property (nonatomic, strong) AVPlayer *player;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
/** 轻触退出*/
@property (weak, nonatomic) UILabel *tintlabel;
/** 播放次数*/
@property (assign, nonatomic) NSInteger count;

@end

@implementation TYFullScreenPlayerView

- (instancetype)initWithFrame:(CGRect)frame videoPath:(NSString *)videoPath
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _videoPath = videoPath;
        self.backgroundColor = [UIColor clearColor];
        [self loadComponent];
    }
    return self;
}

- (void)loadComponent
{
    if (!_videoPath) return;
    AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:_videoPath]];
    __weak typeof(self) weakSelf = self;
    [asset loadValuesAsynchronouslyForKeys:@[@"playable"] completionHandler:^{
        dispatch_async( dispatch_get_main_queue(), ^{
            [weakSelf prepareToPlayAsset:asset];
        });
    }];
}

- (void)setType:(TYFullScreenPlayerViewType)type
{
    self.count = 0;
    if (type == TYFullScreenPlayerViewTypeFull)
    {
        UILabel *tintlabel = [[UILabel alloc] init];
        self.tintlabel = tintlabel;
        tintlabel.textAlignment = NSTextAlignmentCenter;
        tintlabel.text = @"轻触退出";
        tintlabel.textColor = [UIColor whiteColor];
        tintlabel.hidden = YES;
        tintlabel.font = [UIFont systemFontOfSize:13.0];
        [self addSubview:tintlabel];
    }
}

#pragma mark PrepareToplay
- (void)prepareToPlayAsset:(AVAsset *)asset
{
    NSError *error = nil;
    AVKeyValueStatus keyStatus = [asset statusOfValueForKey:@"playable" error:&error];
    if (keyStatus == AVKeyValueStatusFailed) {
        
        return;
    }
    if (!asset.playable)
    {
        
        return;
    }
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:self.playerLayer];
    [self.player play];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.playerLayer.frame = CGRectMake(0, 0, self.width, self.height - labelH);
    self.tintlabel.frame = CGRectMake(0, CGRectGetMaxY(self.playerLayer.frame) + 2, self.width, labelH - 2);
}

#pragma mark - Notification
- (void)playEnd:(NSNotification *)notification
{
    if (++self.count == 1)
    {
        self.tintlabel.hidden = NO;
    }
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
}

#pragma mark - Action
- (void)play
{
    if (self.player)
    {
        [self.player play];
    }
}

- (void)pause
{
    if (self.player)
    {
        [self.player pause];
    }
}

@end
