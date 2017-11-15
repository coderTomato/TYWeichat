//
//  TYFullScreenPlayerView.h
//  IMAPPMIOS
//
//  Created by lijun on 16/9/2.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TYFullScreenPlayerViewType) {
    TYFullScreenPlayerViewTypeFull,
    TYFullScreenPlayerViewTypeDetail
};

@interface TYFullScreenPlayerView : UIView

/** 播放类型 */
@property (assign,nonatomic) TYFullScreenPlayerViewType type;

- (instancetype)initWithFrame:(CGRect)frame videoPath:(NSString *)videoPath;
- (void)play;
- (void)pause;

@end
