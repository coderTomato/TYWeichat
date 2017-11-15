//
//  TYEmotionToolbar.h
//  IMAPPMIOS
//
//  Created by lijun on 16/9/5.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TYEmotionToolbar;

typedef NS_ENUM(NSInteger, TYEmotionType)
{
    TYEmotionTypeEmotion,
    TYEmotionTypeCustom,
    TYEmotionTypeDone
};

@protocol TYEmotionToolbarDelegate <NSObject>

@optional
- (void)emotionToolbar:(TYEmotionToolbar *)toolbar didSelectedButton:(TYEmotionType)type;

@end

@interface TYEmotionToolbar : UIView

@property (weak, nonatomic) id<TYEmotionToolbarDelegate>delegate;

@end
