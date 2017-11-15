//
//  TYComposeToolbar.h
//  IMAPPMIOS
//
//  Created by lijun on 16/8/22.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TYComposeToolbarButtonType) {
    TYComposeToolbarButtonTypeMention, //提到@
    TYComposeToolbarButtonTypeLocation, //位置
    TYComposeToolbarButtonTypeAuthority, //权限
    TYComposeToolbarButtonTypePrivate, //私密
    TYComposeToolbarButtonTypeEmotion,// 表情
};

@class TYComposeToolbar;

@protocol TYComposeToolbarDelegate <NSObject>

- (void)composeToolbar:(TYComposeToolbar *)toolbar didSelectedType:(TYComposeToolbarButtonType)type;

@end

@interface TYComposeToolbar : UIView

/** */
@property (weak, nonatomic) id<TYComposeToolbarDelegate> delegate;
/** 显示表情*/
@property (assign, nonatomic,getter = isShowEmotionButton) BOOL showEmotionButton;

@end
