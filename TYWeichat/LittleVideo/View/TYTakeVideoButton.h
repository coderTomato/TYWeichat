//
//  TYTakeVideoButton.h
//  IMAPPMIOS
//
//  Created by lijun on 16/8/29.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TYTakeVideoButtonDelegate <NSObject>

- (void)TYTakeVideoButtonDidTouchDown;//按下
- (void)TYTakeVideoButtonDidTouchUpInside;//手指在范围内离开
- (void)TYTakeVideoButtonDidTouchUpOutside;//手指在范围外离开
- (void)TYTakeVideoButtonDidTouchDragEnter;//手指拖动进入范围
- (void)TYTakeVideoButtonDidTouchDragExit;//手指拖动离开范围

@end

@interface TYTakeVideoButton : UIButton

@property (weak, nonatomic) id<TYTakeVideoButtonDelegate> delegate;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;

@end
