//
//  TYFullScreenPlayerViewController.m
//  IMAPPMIOS
//
//  Created by lijun on 16/9/2.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import "TYFullScreenPlayerViewController.h"
#import "TYFullScreenPlayerView.h"

@interface TYFullScreenPlayerViewController ()

/** 全屏播放player*/
@property (strong, nonatomic) TYFullScreenPlayerView *playerView;
@end

@implementation TYFullScreenPlayerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    CGFloat height = ScreenWidth / (5.0 / 4);
    
    self.playerView = [[TYFullScreenPlayerView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, height) videoPath:self.videoPath];
    self.playerView.center = self.view.center;
    self.playerView.type = TYFullScreenPlayerViewTypeFull;
    [self.view addSubview:self.playerView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Tap GestureRecognizer

- (void)tapGestureRecognizer:(UITapGestureRecognizer *)tap
{
    [self.playerView pause];
    
    if (self.navigationController)
    {
        [self.navigationController popViewControllerAnimated:NO];
    }
    else
    {
        [self dismissViewControllerAnimated:NO completion:NULL];
    }
}

@end
