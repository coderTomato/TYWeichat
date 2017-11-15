//
//  TYVideoListCell.h
//  IMAPPMIOS
//
//  Created by lijun on 16/8/19.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYVideoConfig.h"

@interface TYVideoListCell : UICollectionViewCell

/** 模型数据*/
@property (strong, nonatomic) TYVideoModel *videoModel;
@property (strong, nonatomic) void(^deleteVideoBlock)(TYVideoModel *);
/** 是否点击了编辑*/
@property (assign, nonatomic) BOOL edit;

- (void)play;
- (void)stop;

@end
