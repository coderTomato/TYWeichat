//
//  TYPostVideoViewController.m
//  IMAPPMIOS
//
//  Created by lijun on 16/8/22.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import "TYPostVideoViewController.h"
#import "TYPlayerView.h"
#import "TYTextView.h"
#import "TYComposeToolbar.h"
#import "TYKeyboardView.h"
#import "TYFullScreenPlayerViewController.h"
#import "ALActionSheetView.h"

@interface TYPostVideoViewController ()<UITextViewDelegate,TYComposeToolbarDelegate,TYPlayerViewDelegate>

/** 标题*/
@property (weak, nonatomic) UILabel *titleLbl;
/** 背景*/
@property (weak, nonatomic) UIView *bgView;
/** 视频播放view*/
@property (weak, nonatomic) TYPlayerView *playerView;
/** 输入框 */
@property (weak, nonatomic) TYTextView *textView;
/** 工具条 */
@property (weak, nonatomic) TYComposeToolbar *toolbar;
/** 自定义键盘*/
@property (strong, nonatomic) TYKeyboardView *keyboardView;
/** 是否正在切键盘*/
@property (assign, nonatomic,getter=isChangingKeyboard) BOOL changingKeyboard;
/** 键盘高度*/
@property (assign, nonatomic) CGFloat keyboardH;


@end

@implementation TYPostVideoViewController

- (TYKeyboardView *)keyboardView
{
    if (_keyboardView == nil) {
        self.keyboardView = [[TYKeyboardView alloc] init];
        self.keyboardView.width = ScreenWidth;
        self.keyboardView.height = 190;
        self.keyboardView.delegate = self;
    }
    return _keyboardView;
}

#pragma mark - lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    //设置标题
    [self setupTitleView];
    //添加视频
    [self setupVideoView];
    // 添加输入控件
    [self setupTextView];
    //添加工具条
    [self setupToolbar];
    
    // 监听表情选中的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emotionDidSelected:) name:TYEmotionDidSelectedNotification object:nil];
    
    // 监听删除按钮点击的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emotionDidDeleted:) name:TYEmotionDeleteNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [self.textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
     [self.navigationController setNavigationBarHidden:NO];
    [self.textView resignFirstResponder];
}
#pragma mark - view初始化
- (void)setupTitleView
{
    CGFloat titleTopEadge = 20;
    CGFloat topBarHeight = 45;
    self.view.backgroundColor = [UIColor colorWithHex:@"#1d1919"];
    
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, titleTopEadge, 60, topBarHeight)];
    [leftBtn setImage:[UIImage imageNamed:@"littleVedio_backg"] forState:UIControlStateNormal];
    leftBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -16, 0, 0);
    [leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftBtn];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, titleTopEadge, ScreenWidth, topBarHeight)];
    titleLabel.textColor = commontitleColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = commontitleFont;
    titleLabel.text = @"发布信息";
    [self.view addSubview:titleLabel];
    self.titleLbl = titleLabel;
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth - 60, titleTopEadge, 60, topBarHeight)];
    [rightBtn setTitle:@"发送" forState: UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:16.0];
    [rightBtn setTitleColor:[UIColor colorWithHex:@"D7D7D7"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(sendBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightBtn];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, ScreenWidth, 0.5)];
    lineView.backgroundColor = [UIColor colorWithHex:@"#3e3e3e"];
    [self.view addSubview:lineView];
    
    if(self.fromVideoList) return;
    UIButton *saveBtn = [[UIButton alloc] initWithFrame:CGRectMake(rightBtn.x - 30, titleTopEadge, 30, topBarHeight)];
    [saveBtn setImage:[UIImage imageNamed:@"littleVedio_bmenu"] forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveBtn];
}

- (void)setupVideoView
{
    CGFloat videoW = shortVideoWidth;
    TYPlayerView *playerView = [[TYPlayerView alloc] initWithFrame:CGRectMake(ScreenWidth - 17 - videoW, 64 + 16, videoW, videoW / (5.0/4))];
    playerView.playMode = TYPlayerViewModeFullPlay;
    playerView.playType = TYVideoPlayAtLeastOnce;
    playerView.delegate = self;
    [self.view addSubview:playerView];
    [playerView playedVideoPath:self.outputFilePath];
    self.playerView = playerView;
}

- (void)setupTextView
{
    // 1.创建输入控件
    TYTextView *textView = [[TYTextView alloc] initWithFrame:CGRectMake(17, self.playerView.y, self.playerView.x - 5 - 17, self.playerView.bottom)];
    [self.view addSubview:textView];
    textView.showsVerticalScrollIndicator = NO;
    textView.alwaysBounceVertical = YES;//永远可以上下拖拽
    textView.contentInset = UIEdgeInsetsMake(-7, 0, 0, 0);
    //textView.delegate = self;
    self.textView = textView;
    
    // 2.设置提醒文字（占位文字）
    textView.placeHolder = @"说点什么吧...";
    textView.placeHolderColor = [UIColor colorWithHex:@"#666666"];
    textView.textColor = [UIColor colorWithHex:@"#FFFFFF"];
    // 3.设置字体
    textView.font = [UIFont systemFontOfSize:16.0];
    
    // 4.监听键盘
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)setupToolbar
{
    TYComposeToolbar *toolbar = [[TYComposeToolbar alloc] init];
    toolbar.width = self.view.width;
    toolbar.height = 35;
    toolbar.y = self.view.height - toolbar.height;
    toolbar.delegate = self;
    self.toolbar = toolbar;
    [self.view addSubview:toolbar];
}
#pragma mark - NSNotification
#pragma mark 键盘事件
- (void)keyboardWillHide:(NSNotification *)note
{
    if (self.isChangingKeyboard)
    {
        self.changingKeyboard = NO;
        return;
    }
    // 1.键盘弹出需要的时间
    CGFloat time = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 2.动画
    [UIView animateWithDuration:time animations:^{
        self.toolbar.transform = CGAffineTransformIdentity;
        self.textView.transform = CGAffineTransformIdentity;
    }];
}
/**
 *  键盘即将弹出
 */
- (void)keyboardWillShow:(NSNotification *)note
{
    // 1.键盘弹出需要的时间
    CGFloat time = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardF = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.keyboardH = keyboardF.size.height;
    
    [UIView animateWithDuration:time animations:^{
        self.toolbar.transform = CGAffineTransformMakeTranslation(0, -self.keyboardH);
    } completion:^(BOOL finished) {
        self.textView.height = ScreenHeight - self.keyboardH - self.toolbar.height * 2 - 64;
    }];
}
#pragma mark 拼接表情
- (void)emotionDidSelected:(NSNotification *)note
{
    NSDictionary *dict = [note userInfo];
    [self.textView insertText:dict[@"chs"]];
}

- (void)emotionDidDeleted:(NSNotification *)note
{
    [self.textView deleteBackward];
}

#pragma mark - TYComposeToolbarDelegate
- (void)composeToolbar:(TYComposeToolbar *)toolbar didSelectedType:(TYComposeToolbarButtonType)type
{
    switch (type) {
        case TYComposeToolbarButtonTypeMention:
            [self openMention];
            break;
        case TYComposeToolbarButtonTypeLocation:
            [self openLocation];
            break;
        case TYComposeToolbarButtonTypeAuthority:
            [self openAuthority];
            break;
        case TYComposeToolbarButtonTypePrivate:
            [self openPrivate];
            break;
        case TYComposeToolbarButtonTypeEmotion:
            [self openEmotion];
            break;
        default:
            break;
    }
}

#pragma mark - Action
- (void)openMention
{
    
}

- (void)openLocation
{
    
}

- (void)openAuthority
{
    
}

- (void)openPrivate
{
    
}

- (void)openEmotion
{
    self.changingKeyboard = YES;
    if (self.textView.inputView)
    {
        self.textView.inputView = nil;
    }
    else
    {
        self.textView.inputView = self.keyboardView;
    }
    self.toolbar.showEmotionButton = !self.toolbar.showEmotionButton;
    [self.textView resignFirstResponder];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.textView becomeFirstResponder];
    });
}

- (void)sendBtnClick
{
    [TYVideoSaveTool saveThumImageWithVideoURL:[NSURL fileURLWithPath:self.outputFilePath] second:1];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self sendObject:nil];
        [self closeViewAction];
    });
}

- (void)cancelBtnClick
{
    [self closeViewAction];
    if (self.fromVideoList) return;
    [TYVideoSaveTool deleteVideoSourceWithPath:self.outputFilePath];
}

- (void)closeViewAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)save
{
    ALActionSheetView *actionSheet = [ALActionSheetView actionSheetWithTitle:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@[@"临时保存小视频"] handler:^(ALActionSheetView *actionSheetView, NSInteger buttonIndex) {
        if (buttonIndex == 0)
        {
            [self compressVideo];
        }
        else
        {
            [TYVideoSaveTool deleteVideoSourceWithPath:self.outputFilePath];
        }
    }];
    [actionSheet showInView:[UIApplication sharedApplication].windows.lastObject];
}

// 压缩视频
- (void)compressVideo
{
    [TYVideoSaveTool saveThumImageWithVideoURL:[NSURL fileURLWithPath:self.outputFilePath] second:1];
}
#pragma mark - delegate
- (void)playerViewPushToFullScreenDidPlay:(TYPlayerView *)playerView
{
    TYFullScreenPlayerViewController *playerVc = [[TYFullScreenPlayerViewController alloc] init];
    playerVc.videoPath = self.outputFilePath;
    [self presentViewController:playerVc animated:NO completion:NULL];
}
#pragma mark TYKeyboardViewDelegate
- (void)keyboardViewResignFirstResponder:(TYKeyboardView *)keyboardView
{
    [self.textView resignFirstResponder];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
