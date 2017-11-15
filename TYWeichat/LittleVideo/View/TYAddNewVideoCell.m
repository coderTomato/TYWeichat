//
//  TYAddNewVideoCell.m
//  IMAPPMIOS
//
//  Created by lijun on 16/8/19.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import "TYAddNewVideoCell.h"
#import "TYVideoConfig.h"


@interface TYAddNewVideoCell()

/** <#注释#>*/
@property (weak, nonatomic) UIButton *addBtn;

@end


@implementation TYAddNewVideoCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        [self setupView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.addBtn.frame = self.bounds;
}

- (void)setupView
{
    UIButton *addBtn = [[UIButton alloc] init];
    UIImage *bgImage = [UIImage imageWithColor:[UIColor colorWithRed:34 / 255.0 green:29 / 255.0 blue:29 / 255.0 alpha:1.0]];
    [addBtn setBackgroundImage:bgImage forState:UIControlStateNormal];
    [addBtn setImage:[UIImage imageNamed:@"littleVedio_bnewvideo"] forState:UIControlStateNormal];
    addBtn.layer.cornerRadius = video_corner;
    addBtn.clipsToBounds = YES;
    [self.contentView addSubview:addBtn];
    addBtn.userInteractionEnabled = NO;
    self.addBtn = addBtn;
}


@end
