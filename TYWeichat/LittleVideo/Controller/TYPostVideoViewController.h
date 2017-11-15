//
//  TYPostVideoViewController.h
//  IMAPPMIOS
//
//  Created by lijun on 16/8/22.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYVideoConfig.h"


@interface TYPostVideoViewController : UIViewController

/** 视频路径*/
@property (copy, nonatomic) NSString *outputFilePath;
/** 从历史界面进来*/
@property (assign, nonatomic) BOOL fromVideoList;


@end
