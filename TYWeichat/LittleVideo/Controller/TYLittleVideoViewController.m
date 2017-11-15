//
//  TYLittleVideoViewController.m
//  IMAPPMIOS
//
//  Created by lijun on 16/8/22.
//  Copyright © 2016年 ICBC. All rights reserved.
//

#import "TYLittleVideoViewController.h"
#import "TYPostVideoViewController.h"
#import "TYTakeVideoButton.h"
#import "TYVideoListViewController.h"
#import "TYEyeView.h"
#import "TYPresentTransition.h"
#import "PKShortVideoRecorder.h"

@interface TYLittleVideoViewController ()<TYTakeVideoButtonDelegate,PKShortVideoRecorderDelegate,UIAlertViewDelegate>

/** 录制工具类*/
@property (strong, nonatomic) PKShortVideoRecorder *recorder;
/** 背景*/
@property (strong, nonatomic) UIView *toolView;
/** 预览视图*/
@property (strong, nonatomic) UIView *videoView;
/** 相机拍摄预览图层*/
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
/** 查看历史*/
@property (weak, nonatomic) UIButton *videoListBtn;
/** 拍摄时间定时器*/
@property (weak, nonatomic) NSTimer *timer;
/** 双击放大*/
@property (weak, nonatomic) UILabel *tipLbl;
/** 进度条*/
@property (weak, nonatomic) UIView *progressView;
/** 取消*/
@property (weak, nonatomic) UIButton *leftBtn;
/** 光圈*/
@property (weak, nonatomic) UIImageView *apertureView;
/** 按住拍*/
@property (weak, nonatomic) TYTakeVideoButton *videoBtn;
/** 是否取消录制了*/
@property (assign, nonatomic) BOOL isCanceled;
/** 定时器计数*/
@property (assign, nonatomic) NSInteger currentCount;
/** 开始录制时间*/
@property (assign, nonatomic) CFAbsoluteTime beginRecordTime;
/** 视频最短时长 default is 1*/
@property (assign, nonatomic) CGFloat minLenght;
/** 视频最长时长 default is 6*/
@property (assign, nonatomic) CGFloat maxLenght;

@end

@implementation TYLittleVideoViewController

#pragma mark - UI
//检查授权
- (BOOL)checkAuthorization
{
    /*
     AVAuthorizationStatusNotDetermined = 0,// 未进行授权选择
     AVAuthorizationStatusRestricted,　　　　// 未授权
     AVAuthorizationStatusDenied,　　　　　　 // 用户拒绝App使用
     AVAuthorizationStatusAuthorized,　　　　// 已授权，可使用
     */
    BOOL allowed = NO;
    AVAuthorizationStatus videoAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    AVAuthorizationStatus audioAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if ((videoAuthorizationStatus == AVAuthorizationStatusAuthorized || videoAuthorizationStatus == AVAuthorizationStatusNotDetermined)
        && (audioAuthorizationStatus == AVAuthorizationStatusAuthorized || audioAuthorizationStatus == AVAuthorizationStatusNotDetermined)) {
        allowed = YES;
    }
    if (!allowed) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请在iPhone的\"设置-隐私\"选项中，允许访问你的摄像头和麦克风。" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
    return allowed;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
//初始化"双击放大"Label
- (void)setupzoomLabel
{
    int tipH = 20;
    UILabel *tipLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, self.videoView.bottom - tipH - 30, ScreenWidth, 20)];
    tipLbl.font = tintLblFont;
    tipLbl.text = @"双击放大";
    tipLbl.textColor = tintLblColor;
    tipLbl.textAlignment = NSTextAlignmentCenter;
    tipLbl.backgroundColor = [UIColor clearColor];
    tipLbl.alpha = 0.0;
    [self.toolView addSubview:tipLbl];
    self.tipLbl = tipLbl;
}
//时间系数设置
- (void)setup
{
    _minLenght = 1.0f;
    _maxLenght = 6.0f;
}

//初始化
- (void)showFrom:(UIViewController *)viewController type:(YSVideoViewStyle)style animated:(BOOL)animated
{
    _viewtype = style;
    [self setup];
    if (style == YSVideoViewStyleSmall)
    {
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    [viewController presentViewController:self animated:animated completion:nil];
    [self setupBgView];
    [self addPreviewLayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkBackgroundEvent) name:EVENT_GotoBackgroud object:nil];
}
//创建背景
- (void)setupBgView
{
    self.view.backgroundColor = [UIColor blackColor];
    CGFloat titleTopEadge = self.viewtype == YSVideoViewStyleFull ? 50 : 2;
    CGFloat topBarHeight = self.viewtype == YSVideoViewStyleFull ? 45 : 22;
    
    UIView *toolView = [[UIView alloc] initWithFrame:[TYVideoConfig viewFrameWithType:self.viewtype]];
    toolView.backgroundColor = [UIColor colorWithHex:@"#1d1919"];
    self.toolView = toolView;
    [self.view addSubview:toolView];
    
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, titleTopEadge, 60, topBarHeight)];
    [leftBtn setTitle:@"取消" forState:UIControlStateNormal];
    leftBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
    [leftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(closeViewAction) forControlEvents:UIControlEventTouchUpInside];
    [toolView addSubview:leftBtn];
    self.leftBtn = leftBtn;
    [self setupVideoview];
}
//初始化视频视图
- (void)setupVideoview
{
    CGFloat videoViewH = ScreenWidth/shortVideo_w_h;
    UIView *videoView = [[UIView alloc] init];
    videoView.frame = CGRectMake(0, self.leftBtn.bottom + 5, ScreenWidth, videoViewH);
    videoView.backgroundColor = [UIColor blackColor];
    videoView.layer.masksToBounds = YES;
    self.videoView = videoView;
    [self.toolView addSubview:videoView];
    
    [self setupzoomLabel];
    [self setupControlView];
}
//初始化视频进度控制
- (void)setupControlView
{
    //进度条
    UIView *progressView = [[UIView alloc] initWithFrame:CGRectMake(0, self.videoView.bottom - 2, ScreenWidth, 2)];
    progressView.backgroundColor = progressnormalColor;
    [self.toolView addSubview:progressView];
    progressView.alpha = 0.0;
    self.progressView = progressView;
    //光圈
    UIImage *image = [UIImage imageNamed:@"littleVedio_focus"];
    UIImageView *apertureView = [[UIImageView alloc] initWithImage:image];
    [self.videoView addSubview:apertureView];
    apertureView.center = self.videoView.center;
    apertureView.alpha = 0.0;
    self.apertureView = apertureView;
    
    BOOL isSmall = self.viewtype == YSVideoViewStyleSmall;
    CGFloat btnWidth = isSmall ? 74 : 124;
    TYTakeVideoButton *tapBtn = [[TYTakeVideoButton alloc] initWithFrame:CGRectMake((ScreenWidth - btnWidth) * 0.5, self.videoView.bottom + btnWidth * (isSmall ? 0.2 : 0.4), btnWidth, btnWidth)];
    [tapBtn setTitle:isSmall ? @"" : @"按住拍" forState:UIControlStateNormal];
    [tapBtn setTitleColor:tapBtnColor forState:UIControlStateNormal];
    tapBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    tapBtn.layer.cornerRadius = btnWidth * 0.5;
    tapBtn.layer.borderColor = tapBtnColor.CGColor;
    tapBtn.layer.borderWidth = 2;
    tapBtn.delegate = self;
    [self.toolView addSubview:tapBtn];
    self.videoBtn = tapBtn;
    [self addGenstureRecognizer];
    
    if (self.viewtype == YSVideoViewStyleFull) return;
    //聊天界面需要额外添加的
    UIImage *titleImage = [UIImage imageNamed:@"littleVedio_fold"];
    CGFloat titleImageW = titleImage.size.width;
    UIImageView *titleImgView = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth * 0.5 - titleImageW * 0.5, 2, titleImageW, titleImageW)];
    titleImgView.image = titleImage;
    [self.toolView addSubview:titleImgView];
    //查看历史
    CGFloat leftEdge = 17;
    UIButton *videoListBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    videoListBtn.frame = CGRectMake(leftEdge, self.videoBtn.y + 20, 40, 30);
    videoListBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [videoListBtn addTarget:self action:@selector(videoListAction) forControlEvents:UIControlEventTouchUpInside];
    [self.toolView addSubview:videoListBtn];
    self.videoListBtn = videoListBtn;
    NSArray<TYVideoModel *> *videoList = [TYVideoSaveTool getSortVideoList];
    if (videoList.count == 0)
    {
        self.videoListBtn.hidden = YES;
    }
    else
    {
        [self.videoListBtn setBackgroundImage:[UIImage imageWithContentsOfFile:videoList[0].thumAbsolutePath] forState: UIControlStateNormal];
    }
}
//添加预览图层
- (void)addPreviewLayer
{
    //创建视频录制对象
    self.recorder = [[PKShortVideoRecorder alloc] initWithOutputFilePath:[TYVideoSaveTool videoAbsolutePath]];
    self.recorder.delegate = self;
    // 通过会话 (AVCaptureSession) 创建预览层
    self.captureVideoPreviewLayer = [self.recorder previewLayer];
    self.captureVideoPreviewLayer.frame = self.videoView.layer.bounds;
    //有时候需要拍摄完整屏幕大小的时候可以修改这个
    _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    // 显示在视图表面的图层
    [self.videoView.layer insertSublayer:self.captureVideoPreviewLayer below:self.apertureView.layer];
    [self.recorder startRunning];
    
    //开机界面
    TYEyeView *eyeView = [TYEyeView eyeView];
    eyeView.frame = self.videoView.bounds;
    [self.videoView addSubview:eyeView];
    
    //移除开机界面显示光圈动画
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [eyeView removeFromSuperview];
        [self apertureAnimationFromPoint:CGPointMake(self.videoView.width * 0.5, self.videoView.height * 0.5)];
        self.tipLbl.alpha = 1.0;
        [self showTipLblAnimation];
    });
    [self checkAuthorization];
}
#pragma mark - 手势
//添加手势
- (void)addGenstureRecognizer
{
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTapGesture.numberOfTapsRequired = 1;
    singleTapGesture.delaysTouchesBegan = YES;
    [self.videoView addGestureRecognizer:singleTapGesture];
    
    UITapGestureRecognizer *doubleTapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    doubleTapGesture.delaysTouchesBegan = YES;
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    [self.videoView addGestureRecognizer:doubleTapGesture];
}
//单击
-(void)singleTap:(UITapGestureRecognizer *)tapGesture
{
    CGPoint point = [tapGesture locationInView:self.videoView];
    //将UI坐标转化为摄像头坐标,摄像头聚焦点范围0~1
    [self apertureAnimationFromPoint:point];
    if ([self.recorder.cameraDevice lockForConfiguration:nil])
    {
        //聚焦
        if ([self.recorder.cameraDevice  isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
        {
            [self.recorder.cameraDevice  setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        //聚焦点的位置
        if ([self.recorder.cameraDevice  isFocusPointOfInterestSupported])
        {
            [self.recorder.cameraDevice  setFocusPointOfInterest:point];
        }
        //曝光模式
        if ([self.recorder.cameraDevice  isExposureModeSupported:AVCaptureExposureModeAutoExpose])
        {
            [self.recorder.cameraDevice  setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        }
        //白平衡
        if ([self.recorder.cameraDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance])
        {
            self.recorder.cameraDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeAutoWhiteBalance;
        }
        [self.recorder.cameraDevice unlockForConfiguration];
    }
}
//根据点击的位置显示聚焦光圈
- (void)apertureAnimationFromPoint:(CGPoint)point
{
    self.apertureView.center = point;
    self.apertureView.transform = CGAffineTransformMakeScale(1.5,1.5);
    self.apertureView.alpha = 1.0;
    [UIView animateWithDuration:0.6 animations:^{
        self.apertureView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.apertureView.alpha = 0.0;
    }];
}
//双击放大
-(void)doubleTap:(UITapGestureRecognizer *)tapGesture
{
    NSError *error = nil;
    if ([self.recorder.cameraDevice lockForConfiguration:&error])
    {
        if (self.recorder.cameraDevice.videoZoomFactor == 1.0) {
            [self.recorder.cameraDevice rampToVideoZoomFactor:2.0 withRate:2.0];
        }
        else
        {
            [self.recorder.cameraDevice rampToVideoZoomFactor:1.0 withRate:2.0];
        }
        [self.recorder.cameraDevice unlockForConfiguration];
    }
}
#pragma mark - RecordAction
//开始录制
- (void)startRecord
{
    //开始录制视频
    [self.recorder startRecording];
    [self setupTimer];
    [self startAnimation];
}
//取消录制
- (void)cancelRecord
{
    self.isCanceled = YES;
    [self saveRecord];
    [self removeTimer];
    [self stopAnimation];
}
//停止录制
- (void)stopRecord
{
    //结束录制
    [self stopAnimation];
    [self removeTimer];
    [self saveRecord];
    self.isCanceled = NO;
}
//结束录制会话
- (void)saveRecord
{
    //停止录制
    [self.recorder stopRecording];
}
//初始化定时器
- (void)setupTimer
{
    //清空定时计数
    self.currentCount = 0;
    if (self.timer && self.timer.isValid)
    {
        return;
    }
    [[NSRunLoop currentRunLoop] addTimer:(self.timer = [NSTimer timerWithTimeInterval:_minLenght target:self selector:@selector(updateRecord) userInfo:nil repeats:YES]) forMode:NSRunLoopCommonModes];
}
//定时器回调方法
- (void)updateRecord
{
    if (self.currentCount >= 3) {
        self.tipLbl.alpha = 0.0;
    }
    if (self.currentCount >= self.maxLenght) {
        [self stopRecord];
    }
    self.currentCount += 1;
}
//开始录制动画显示进度条
- (void)startAnimation
{
    self.progressView.frame = CGRectMake(0, self.progressView.y, ScreenWidth, self.progressView.height);
    self.progressView.backgroundColor = progressnormalColor;
    self.progressView.alpha = 1;
    [UIView animateWithDuration:_maxLenght animations:^{
        self.progressView.frame = CGRectMake(ScreenWidth/2, self.progressView.y, 0, self.progressView.height);
    } completion:^(BOOL finished) {
        self.progressView.alpha = 0;
    }];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideTipLbl) object:nil];
    self.tipLbl.text = @"↑上移取消";
    self.tipLbl.alpha = 1;
    self.tipLbl.textColor = tintLblColor;
    self.tipLbl.backgroundColor = [UIColor clearColor];
}
//移除定时器
- (void)removeTimer
{
    if (self.timer && self.timer.isValid)
    {
        [self.timer invalidate];
        self.timer = nil;
    }
}
//停止动画移除进度条
- (void)stopAnimation
{
    [self.progressView.layer removeAllAnimations];
    self.progressView.alpha = 0;
    [self showTipLblAnimation];
}
//提示文字的隐藏动画
- (void)showTipLblAnimation
{
    if (self.currentCount >= 4) return;
    self.tipLbl.alpha = 1.0;
    [self performSelector:@selector(hideTipLbl) withObject:nil afterDelay:1.6];
}
- (void)hideTipLbl
{
    self.tipLbl.alpha = 0.0;
}
#pragma mark - delegate
#pragma mark TYTakeVideoButtonDelegate
- (void)TYTakeVideoButtonDidTouchDown
{
    self.beginRecordTime = CACurrentMediaTime();
    //开始录制：上移取消
    [self startRecord];
}
//手指在范围内离开
- (void)TYTakeVideoButtonDidTouchUpInside
{
    //当前时间
    CFAbsoluteTime nowTime = CACurrentMediaTime();
    //时间太短：手指不要放开
    if (self.beginRecordTime != 0 && nowTime - self.beginRecordTime < _minLenght)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.tipLbl.text = @"手指不要放开";
            self.tipLbl.alpha = 1.0;
            self.tipLbl.textColor = tintwarningColor;
            [self cancelRecord];
        });
    }
    else
    {
        [self stopRecord];
    }
}
//手指在范围外离开
- (void)TYTakeVideoButtonDidTouchUpOutside
{
    //取消录制
    [self cancelRecord];
}
//手指拖动进入范围
- (void)TYTakeVideoButtonDidTouchDragEnter
{
    //上移取消
    self.tipLbl.text = @"↑上移取消";
    self.tipLbl.textColor = tintLblColor;
    self.progressView.backgroundColor = progressnormalColor;
}
//手指拖动离开范围
- (void)TYTakeVideoButtonDidTouchDragExit
{
    //松手取消
    self.tipLbl.text = @"↑松开取消";
    self.tipLbl.alpha = 1.0;
    self.tipLbl.textColor = tintwarningColor;
    self.progressView.backgroundColor = progresswarningColor;
}
#pragma mark - privatemethod
- (void)pushToPlay:(NSString *)filePath
{
    if (self.viewtype == YSVideoViewStyleFull)
    {
        [self dismissViewControllerAnimated:NO completion:nil];
        TYPostVideoViewController *postVc = [[TYPostVideoViewController alloc] init];
        postVc.outputFilePath = filePath;
        UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        [nav pushViewController:postVc animated:NO];
    }
    else//聊天界面处理
    {
        
    }
}
//取消
- (void)closeViewAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
//锁屏事件处理
- (void)checkBackgroundEvent
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateInactive)
    {
        //iOS6锁屏事件
        [self cancelRecord];
        [self closeViewAction];
    }
    else if (state == UIApplicationStateBackground)
    {
        [self cancelRecord];
        [self closeViewAction];
    }
}
//查看历史界面
- (void)videoListAction
{
    TYVideoListViewController *videoListVc = [[TYVideoListViewController alloc] init];
    videoListVc.viewtype = self.viewtype;
    [self presentViewController:videoListVc animated:NO completion:nil];
}
//视频录制结束回调
- (void)recorder:(PKShortVideoRecorder *)recorder didFinishRecordingToOutputFilePath:(NSString *)outputFilePath error:(NSError *)error
{
    if (self.isCanceled)
    {
        [TYVideoSaveTool deleteVideoSourceWithPath:outputFilePath];
        return;
    }
    [self pushToPlay:outputFilePath];
}
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

@end
