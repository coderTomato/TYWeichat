//
//  TYEmotionPopView.h
//  IMAPPMIOS
//
//  Created by lijun on 16/8/27.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TYEmotionView;

@interface TYEmotionPopView : UIView

+ (instancetype)popView;

- (void)showFromView:(TYEmotionView *)emotionView;

- (void)dismiss;

@end
