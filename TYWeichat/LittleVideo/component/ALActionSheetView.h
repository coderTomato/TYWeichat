//
//  ALActionSheetView.h
//  ALActionSheetView
//
//  Created by WangQi on 7/4/15.
//  Copyright (c) 2015 WangQi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ALActionSheetView;

typedef void (^ALActionSheetViewDidSelectButtonBlock)(ALActionSheetView *actionSheetView, NSInteger buttonIndex);

@interface ALActionSheetView : UIView

/** 文字颜色*/
@property (strong, nonatomic) UIColor *commentTextColor;
/** 取消文字颜色*/
@property (strong, nonatomic) UIColor *cancelTextColor;
/** 分割线颜色*/
@property (strong, nonatomic) UIColor *separatorColor;

+ (ALActionSheetView *)actionSheetWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles handler:(ALActionSheetViewDidSelectButtonBlock)block;

- (instancetype)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles handler:(ALActionSheetViewDidSelectButtonBlock)block;
- (void)showInView:(UIView *)view;
- (void)dismiss;

@end
