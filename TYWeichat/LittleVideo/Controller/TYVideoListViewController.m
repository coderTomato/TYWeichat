//
//  TYVideoListViewController.m
//  IMAPPMIOS
//
//  Created by lijun on 16/8/22.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import "TYVideoListViewController.h"
#import "TYLittleVideoViewController.h"
#import "TYVideoListCell.h"
#import "TYAddNewVideoCell.h"
#import "TYPostVideoViewController.h"
#import "TYPresentTransition.h"

#define videoMaxCount 10

@interface TYVideoListViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,UIViewControllerTransitioningDelegate,UIAlertViewDelegate,UIGestureRecognizerDelegate>

/** 背景*/
@property (weak, nonatomic) UIView *bgView;
/** 标题*/
@property (weak, nonatomic) UILabel *titleLbl;
/** 数据源*/
@property (strong, nonatomic)  NSMutableArray *videoArray;
/** 数据复本*/
@property (strong, nonatomic) NSMutableArray *duplicateArray;
/** 存放删除的数据*/
@property (strong, nonatomic) NSMutableArray *deleteArray;
/** 视频视图*/
@property (weak, nonatomic) UICollectionView *collectionView;
/** 编辑按钮*/
@property (weak, nonatomic) UIButton *editBtn;
/** 当前选中的视频*/
@property (strong, nonatomic) TYVideoModel *currentVideoModel;
/** 返回按钮*/
@property (weak, nonatomic) UIButton *leftBtn;
/** 取消按钮*/
@property (weak, nonatomic) UIButton *cancelBtn;
/** 撤销按钮*/
@property (weak, nonatomic) UIButton *revokeBtn;

@end

@implementation TYVideoListViewController

static NSString *const listIdentifier = @"listIdentifier";
static NSString *const addIdentifier = @"addIdentifier";
static NSString *const footerIdentifier = @"footIdentifier";

#pragma mark - lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.deleteArray = [NSMutableArray array];
    [self setupBgView];
}

- (void)setViewtype:(YSVideoViewStyle)viewtype
{
    _viewtype = viewtype;
    if (viewtype == YSVideoViewStyleSmall) {
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

#pragma mark - UI
//创建背景
- (void)setupBgView
{
    UIView *bgView = [[UIView alloc] initWithFrame:[TYVideoConfig viewFrameWithType:self.viewtype]];
    bgView.backgroundColor = [UIColor colorWithHex:@"#2a2524"];
    self.bgView = bgView;
    [self.view addSubview:bgView];
    [self setupTitleView];
    [self setupCollectionView];
}

- (void)setupTitleView
{
    CGFloat titleTopEadge = self.viewtype == YSVideoViewStyleFull ? 20 : 0;
    CGFloat topBarHeight = 45;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, titleTopEadge, self.bgView.width, topBarHeight)];
    titleLabel.textColor = commontitleColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = commontitleFont;
    titleLabel.text = @"小视频";
    [self.bgView addSubview:titleLabel];
    self.titleLbl = titleLabel;
    //左边按钮
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, titleTopEadge, 60, topBarHeight)];
    [leftBtn setImage:[UIImage imageNamed:@"littleVedio_backg"] forState:UIControlStateNormal];
    leftBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
    [leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    leftBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [leftBtn addTarget:self action:@selector(closeViewAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:leftBtn];
    self.leftBtn = leftBtn;
    
    self.cancelBtn = [self addBtnWithFrame:CGRectMake(0, titleTopEadge, 50, topBarHeight) action:@selector(cancelPlayer:) title:@"取消"];
    self.cancelBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 11, 0, 0);
    self.cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    self.revokeBtn = [self addBtnWithFrame:self.cancelBtn.frame action:@selector(revokeBtnClick) title:@"撤销"];
    self.revokeBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    self.revokeBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 11, 0, 0);
    //右边编辑按钮
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.bgView.width - 60, titleTopEadge, 60, topBarHeight)];
    [rightBtn setTitle:@"编辑" forState: UIControlStateNormal];
    [rightBtn setTitle:@"完成" forState: UIControlStateSelected];
    [rightBtn setTitleColor:[UIColor colorWithHex:@"D7D7D7"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(editBtnClick) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [self.bgView addSubview:rightBtn];
    self.editBtn = rightBtn;
}

- (UIButton *)addBtnWithFrame:(CGRect)frame action:(SEL)selector title:(NSString *)title
{
    UIButton *btn = [[UIButton alloc] initWithFrame:frame];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:btn];
    btn.hidden = YES;
    return btn;
}

- (void)setupCollectionView
{
    self.videoArray = [NSMutableArray arrayWithArray:[TYVideoSaveTool getSortVideoList]];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    // 设置垂直间隙
    layout.minimumLineSpacing = lineSpacing;
    layout.itemSize = CGSizeMake(shortVideoWidth, shortVideoWidth/shortVideo_w_h);
    // 设置全局左右间隙
    layout.sectionInset = UIEdgeInsetsMake(topMargin, videoListMargin, topMargin, videoListMargin);
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.titleLbl.bottom, self.bgView.width, self.bgView.frame.size.height - self.titleLbl.height) collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.alwaysBounceVertical = YES;
    [collectionView registerClass:[TYVideoListCell class] forCellWithReuseIdentifier:listIdentifier];
    [collectionView registerClass:[TYAddNewVideoCell class] forCellWithReuseIdentifier:addIdentifier];
    [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerIdentifier];
    collectionView.backgroundColor = [UIColor colorWithHex:@"#1d1919"];
    [self.bgView addSubview:collectionView];
    self.collectionView = collectionView;
    
    collectionView.contentInset = UIEdgeInsetsMake(0, 0, layout.itemSize.height, 0);
    NSInteger lineNum = (self.videoArray.count + 2) / 3;
    CGFloat offsetHight = lineNum * (layout.itemSize.height + lineSpacing);
    [self.collectionView setContentOffset:CGPointMake(0, offsetHight) animated:YES];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    tap.delegate = self;
    [self.collectionView addGestureRecognizer:tap];
    [self showData];
}

#pragma mark - Delegate
#pragma mark  UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.editBtn.selected)
    {
        return self.videoArray.count;
    }
    else
    {
        return self.videoArray.count + 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == self.videoArray.count)
    {
        TYAddNewVideoCell *addCell = [collectionView dequeueReusableCellWithReuseIdentifier:addIdentifier forIndexPath:indexPath];
        return addCell;
    }
    
    TYVideoListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:listIdentifier forIndexPath:indexPath];
    TYVideoModel *model = self.videoArray[indexPath.item];
    cell.videoModel = model;
    [cell setEdit:self.editBtn.selected];
    
    __weak typeof(self) weakself = self;
    __weak typeof(collectionView) weakCollectionView = collectionView;
    cell.deleteVideoBlock = ^(TYVideoModel *cellModel)
    {
        if (cellModel.playing)
        {
            [self switchVideoState];
        }
        else
        {
            [weakself.deleteArray addObject:cellModel];
            NSInteger index = [weakself.videoArray indexOfObject:cellModel];
            NSIndexPath *cellIndexPath = [NSIndexPath indexPathForItem:index inSection:0];
            [weakself.videoArray removeObject:cellModel];
            [weakCollectionView deleteItemsAtIndexPaths:@[cellIndexPath]];
            weakself.revokeBtn.hidden = NO;
        }
    };
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionFooter])
    {
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:footerIdentifier forIndexPath:indexPath];
        footerView.backgroundColor = [UIColor clearColor];
        if (footerView.subviews.count < 1)
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bgView.width, 20)];
            label.textColor = [UIColor colorWithHex:@"#3A3838"];
            label.font = [UIFont systemFontOfSize:14];
            label.textAlignment = NSTextAlignmentCenter;
            label.text = [NSString stringWithFormat:@"最近 7 天拍摄的小视频"];
            label.alpha = 0.6;
            [footerView addSubview:label];
        }
        return footerView;
    }
    return nil;
}

- (void)showData
{
    NSMutableArray *dataArray = [NSMutableArray array];
    for (TYVideoModel *videoModel in self.videoArray)
    {
        NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:videoModel.recordTime];
        NSInteger day = time/60/60/24;
        if (day > 7)
        {
            [dataArray addObject:videoModel];
        }
    }
    for (TYVideoModel *videoModel in dataArray)
    {
        [TYVideoSaveTool deleteVideoSourceWithPath:videoModel.videoAbsolutePath];
        [TYVideoSaveTool deleteVideoSourceWithPath:videoModel.thumAbsolutePath];
    }
    [self.videoArray removeObjectsInArray:dataArray];
    [self.collectionView reloadData];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(self.bgView.width, 20);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item == self.videoArray.count)
    {
        [self takeVideo];
    }
    else
    {
        [self previewVideoAndSendVideoWithIndexPath:indexPath];
    }
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self switchVideoState];
}
#pragma mark UIViewControllerTransitioningDelegate
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    TYPresentTransition *animator = [[TYPresentTransition alloc] init];
    animator.presenting = YES;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    TYPresentTransition *animator = [[TYPresentTransition alloc] init];
    return animator;
}
#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:UICollectionViewCell.class] || [touch.view.superview isKindOfClass:UICollectionViewCell.class])
    {
        return NO;
    }
    return YES;
}

#pragma mark - Action
- (void)pushToPostVideoVcWithModel:(TYVideoModel *)videoModel
{
    if(self.viewtype == YSVideoViewStyleFull)
    {
        if (self.editBtn.selected)
        {
            return;
        }
        TYPostVideoViewController *postVc = [[TYPostVideoViewController alloc] init];
        postVc.outputFilePath = videoModel.videoAbsolutePath;
        postVc.fromVideoList = YES;
        postVc.transitioningDelegate = self;
        [self presentViewController:postVc animated:YES completion:nil];
        [postVc receiveObject:^(id object) {
            UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
            [nav dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    else//聊天
    {
        
    }
}
- (void)previewVideoAndSendVideoWithIndexPath:(NSIndexPath *)indexPath
{
    if (self.editBtn.selected)
    {
        self.cancelBtn.hidden = YES;
        self.leftBtn.hidden = YES;
    }
    else
    {
        self.cancelBtn.hidden = NO;
        self.leftBtn.hidden = YES;
        self.editBtn.hidden = YES;
    }
    //如果小视频是播放状态就跳到发布页面
    TYVideoModel *model = self.videoArray[indexPath.item];
    if (self.editBtn.selected && model.playing)
    {
        [self switchVideoState];
    }
    else
    {
        if (self.editBtn.hidden == YES && model.playing)
        {
            [self pushToPostVideoVcWithModel:model];
        }
        //预览小视频
        for (TYVideoModel *videoModel in self.videoArray)
        {
            videoModel.playing = NO;
        }
        model.playing = YES;
        self.collectionView.backgroundColor = [UIColor colorWithRed:153.0 / 255.0 green:153.0 / 255.0 blue:153.0 / 255.0 alpha:1.0];
        [self.collectionView reloadData];
    }
}

- (void)tapAction
{
    [self switchVideoState];
}

- (void)switchVideoState
{
    for (TYVideoModel *videoModel in self.videoArray)
    {
        videoModel.playing = NO;
    }
    [self.collectionView reloadData];
    
    if (self.editBtn.selected)
    {
        self.cancelBtn.hidden = YES;
        self.leftBtn.hidden = YES;
    }
    else
    {
        self.cancelBtn.hidden = YES;
        self.leftBtn.hidden = NO;
        self.editBtn.hidden = NO;
    }
}

- (void)closeViewAction:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
//取消预览播放
- (void)cancelPlayer:(UIButton *)sender
{
    [self switchVideoState];
}
//撤销删除操作
- (void)revokeBtnClick
{
    self.revokeBtn.hidden = YES;
    //将数据还原
    [self.deleteArray removeAllObjects];
    self.videoArray = nil;
    self.videoArray = [NSMutableArray arrayWithArray:self.duplicateArray];
    [self.collectionView reloadData];
}
// 录制新的小视频
- (void)takeVideo
{
    if (self.videoArray.count >= videoMaxCount)
    {
        return;
    }
    [self dismissViewControllerAnimated:NO completion:nil];
    UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    if ([nav.presentedViewController isKindOfClass:TYLittleVideoViewController.class]) return;
    TYLittleVideoViewController *videoVc = [[TYLittleVideoViewController alloc] init];
    [videoVc showFrom:nav type:self.viewtype animated:YES];
}
//编辑按钮事件
- (void)editBtnClick
{
    //数据备份
    self.duplicateArray = [NSMutableArray arrayWithArray:self.videoArray];
    if (self.deleteArray.count > 0)
    {
        for (TYVideoModel *cellModel in self.deleteArray)
        {
            [TYVideoSaveTool deleteVideoSourceWithPath:cellModel.videoAbsolutePath];
            [TYVideoSaveTool deleteVideoSourceWithPath:cellModel.thumAbsolutePath];
        }
    }
    self.editBtn.selected = !self.editBtn.selected;
    self.leftBtn.hidden = self.editBtn.selected;
    self.revokeBtn.hidden = YES;
    [self switchVideoState];
    self.editBtn.hidden = NO;
    [self.collectionView reloadData];
}

@end
