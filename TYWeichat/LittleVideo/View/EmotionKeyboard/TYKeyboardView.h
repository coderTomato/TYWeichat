//
//  TYKeyboardView.h
//  IMAPPMIOS
//
//  Created by lijun on 16/8/22.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TYKeyboardView;

@protocol TYKeyboardViewDelegate <NSObject>

- (void)keyboardViewResignFirstResponder:(TYKeyboardView *)keyboardView;

@end

@interface TYKeyboardView : UIView

/** delegate*/
@property (weak, nonatomic) id<TYKeyboardViewDelegate>delegate;

@end
