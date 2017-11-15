//
//  TYLittleVideoViewController.h
//  IMAPPMIOS
//
//  Created by lijun on 16/8/22.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYVideoConfig.h"

@interface TYLittleVideoViewController : UIViewController

/** 类型*/
@property (assign, nonatomic) YSVideoViewStyle viewtype;

- (void)showFrom:(UIViewController *)viewController type:(YSVideoViewStyle)style animated:(BOOL)animated;

@end
