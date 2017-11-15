//
//  TYVideoListCell.m
//  IMAPPMIOS
//
//  Created by lijun on 16/8/19.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import "TYVideoListCell.h"
#import "TYPlayerView.h"


#define btnWidth 25

@interface TYVideoListCell()<TYPlayerViewDelegate>

/** 展示缩略图*/
@property (weak, nonatomic) TYPlayerView *playerView;
/** 删除按钮*/
@property (weak, nonatomic) UIButton *deleteBtn;

@end

@implementation TYVideoListCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        TYPlayerView *playerView = [[TYPlayerView alloc] init];
        playerView.playType = TYVideoPlayAtLeastOnce;
        playerView.playMode = TYPlayerViewModePreview;
        playerView.layer.cornerRadius = video_corner;
        playerView.layer.masksToBounds = YES;
        playerView.userInteractionEnabled = NO;
        playerView.delegate = self;
        [self.contentView addSubview:playerView];
        self.playerView = playerView;
        
        UIButton *deleteBtn = [[UIButton alloc] init];
        [deleteBtn setImage:[UIImage imageNamed:@"ContactTag_redminus_button"] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:deleteBtn];
        self.deleteBtn = deleteBtn;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.playerView.frame = CGRectMake(0, 0, self.width, self.height);
    self.deleteBtn.frame = CGRectMake(self.playerView.right - btnWidth, 0, btnWidth, btnWidth);
}

- (void)setVideoModel:(TYVideoModel *)videoModel
{
    _videoModel = videoModel;
    [self.playerView showDefaultImage:videoModel];
    videoModel.playing ? [self play] : [self stop];
}

- (void)play
{
    [self.playerView playedVideoPath:self.videoModel.videoAbsolutePath];
}

- (void)stop
{
    [self.playerView stop];
}

- (void)setEdit:(BOOL)edit
{
    self.deleteBtn.hidden = !edit;
}

- (void)deleteBtnClick
{
    if (self.deleteVideoBlock)
    {
        self.deleteVideoBlock(self.videoModel);
    }
}

@end
