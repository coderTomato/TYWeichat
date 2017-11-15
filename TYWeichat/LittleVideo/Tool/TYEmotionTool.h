//
//  TYEmotionTool.h
//  IMAPPMIOS
//
//  Created by lijun on 16/8/23.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TYEmotionTool : NSObject

/**
 *  默认表情
 */
+ (NSArray *)defaultEmotions;

/**
 *  自定义表情
 */
+ (NSArray *)customEmotions;

@end
