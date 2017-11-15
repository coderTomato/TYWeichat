//
//  ViewController.m
//  TYWeichat
//
//  Created by lijun on 2016/10/19.
//  Copyright © 2016年 lijun. All rights reserved.
//

#import "ViewController.h"
#import "TYLittleVideoViewController.h"
#import "TYVideoListViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)btnClicked:(UIButton *)sender
{
    BOOL videoExist = [TYVideoSaveTool existVideo];
    if (videoExist)
    {
        TYVideoListViewController *listVc = [[TYVideoListViewController alloc] init];
        listVc.viewtype = YSVideoViewStyleFull;
        UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [nav presentViewController:listVc animated:YES completion:nil];
    }
    else
    {
        TYLittleVideoViewController *videoVc = [[TYLittleVideoViewController alloc] init];
        UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [videoVc showFrom:nav type:YSVideoViewStyleFull animated:YES];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
