//
//  PKShortVideoWriter.m
//  DevelopWriterDemo
//
//  Created by jiangxincai on 16/1/14.
//  Copyright © 2016年 pepsikirk. All rights reserved.
//

#import "PKShortVideoRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import "PKShortVideoSession.h"

typedef NS_ENUM( NSInteger, PKRecordingStatus ) {
    PKRecordingStatusIdle = 0,
    PKRecordingStatusStartingRecording,
    PKRecordingStatusRecording,
    PKRecordingStatusStoppingRecording,
}; 

@interface PKShortVideoRecorder() <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, PKShortVideoSessionDelegate>

@property (nonatomic, strong) NSString *outputFilePath;

@property (nonatomic, assign) CGSize outputSize;
/** 录制队列*/
@property (nonatomic, strong) dispatch_queue_t recorderQueue;
/** 视频输出队列*/
@property (nonatomic, strong) dispatch_queue_t videoDataOutputQueue;
/** 音频输出队列*/
@property (nonatomic, strong) dispatch_queue_t audioDataOutputQueue;
/** 摄像头输出对象*/
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
/** 麦克风输出对象*/
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioDataOutput;
/**AVCaptureSession必须从AVCaptureConnection中获取实际数据*/
@property (nonatomic, strong) AVCaptureConnection *audioConnection;
/**用来在AVCaptureInput和ACaptureOutput之间建立连接 */
@property (nonatomic, strong) AVCaptureConnection *videoConnection;
/** 会话*/
@property (nonatomic, strong) AVCaptureSession *captureSession;
/** 相机"预览图层"用来快速呈现(摄像头)所收集到的原始数据*/
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
/** 视频设置*/
@property (nonatomic, strong) NSDictionary *videoCompressionSettings;
/** 音频设置*/
@property (nonatomic, strong) NSDictionary *audioCompressionSettings;
/** 视频解码器*/
@property (nonatomic) CMFormatDescriptionRef outputVideoFormatDescription;
/** 音频解码器*/
@property (nonatomic) CMFormatDescriptionRef outputAudioFormatDescription;

@property (nonatomic, assign) PKRecordingStatus recordingStatus;

@property (nonatomic, retain) PKShortVideoSession *assetSession;

@end

@implementation PKShortVideoRecorder

#pragma mark - Init
- (instancetype)initWithOutputFilePath:(NSString *)outputFilePath
{
    self = [super init];
    if (self) {
        _outputFilePath = outputFilePath;
        _outputSize = CGSizeMake(320, 240);
        //session配置不能在主线程，需要自行创建串行队列
        _recorderQueue = dispatch_queue_create("com.PKShortVideoWriter.sessionQueue", DISPATCH_QUEUE_SERIAL);
        _audioDataOutputQueue = dispatch_queue_create("com.PKShortVideoWriter.audioOutput", DISPATCH_QUEUE_SERIAL);
        _videoDataOutputQueue = dispatch_queue_create("com.PKShortVideoWriter.videoOutput", DISPATCH_QUEUE_SERIAL);
        
        //既将_videoDataOutputQueue的优先级和第二个queue的优先级设置一样
        dispatch_set_target_queue(_videoDataOutputQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
        self.captureSession = [self setupCaptureSession];
        [self addDataOutputsToCaptureSession:self.captureSession];
    }
    return self;
}

- (void)dealloc
{
    [_assetSession finishRecording];
    [self stopRunning];
}

#pragma mark - Running Session
- (void)startRunning
{
    dispatch_sync(self.recorderQueue, ^{
        [self.captureSession startRunning];
    } );
}

- (void)stopRunning
{
    //必须放在后台线程处理否则ios8之前设备会出现界面卡死现象
    dispatch_sync(self.recorderQueue, ^{
        [self stopRecording];
        [self.captureSession stopRunning];
    } );
}

#pragma mark - Recording
- (void)startRecording
{
    if (TARGET_IPHONE_SIMULATOR) {
        NSLog(@"录制视频不支持模拟器");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"录制视频不支持模拟器" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
        return;
    }
    @synchronized(self) {
        if (self.recordingStatus != PKRecordingStatusIdle) {
            NSLog(@"已经在录制了");
            return;
        }   
        [self transitionToRecordingStatus:PKRecordingStatusStartingRecording error:nil];
    }
    
    self.assetSession = [[PKShortVideoSession alloc] initWithTempFilePath:self.outputFilePath];
    self.assetSession.delegate = self;
    
    [self.assetSession addVideoTrackWithSourceFormatDescription:self.outputVideoFormatDescription settings:self.videoCompressionSettings];
    [self.assetSession addAudioTrackWithSourceFormatDescription:self.outputAudioFormatDescription settings:self.audioCompressionSettings];
    
    [self.assetSession prepareToRecord];
}

- (void)stopRecording
{
    @synchronized(self) {
        if (self.recordingStatus != PKRecordingStatusRecording){
            return;
        }
        [self transitionToRecordingStatus:PKRecordingStatusStoppingRecording error:nil];
    }
    [self.assetSession finishRecording];
}

#pragma mark - Private methods
- (void)addDataOutputsToCaptureSession:(AVCaptureSession *)captureSession
{
    self.videoDataOutput = [AVCaptureVideoDataOutput new];
    self.videoDataOutput.videoSettings = nil;
    self.videoDataOutput.alwaysDiscardsLateVideoFrames = NO;
    //设置self为视频数据输出缓冲区(sampleBuffer)的代理  队列用串行
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
    //将视频数据输出对象添加到session上
    [self addOutput:self.videoDataOutput toCaptureSession:self.captureSession];
    //设置视频捕捉连接
    self.videoConnection = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    
    self.audioDataOutput = [AVCaptureAudioDataOutput new];
    [self.audioDataOutput setSampleBufferDelegate:self queue:self.audioDataOutputQueue];
    //将音频数据输出对象添加到session上
    [self addOutput:self.audioDataOutput toCaptureSession:self.captureSession];
    self.audioConnection = [self.audioDataOutput connectionWithMediaType:AVMediaTypeAudio];
    
    [self setCompressionSettings];
}

- (void)setCompressionSettings
{
    NSInteger numPixels = self.outputSize.width * self.outputSize.height;
    //每像素比特
    CGFloat bitsPerPixel = 6.0;
    NSInteger bitsPerSecond = numPixels * bitsPerPixel;
    
    // 码率和帧率设置
    /**
     *AVVideoAverageBitRateKey:视频尺寸*比率
     *AVVideoMaxKeyFrameIntervalKey:关键帧最大间隔，1为每个都是关键帧，数值越大压缩率越高
     *AVVideoProfileLevelKey:视频画质
     */
    NSDictionary *compressionProperties = @{ AVVideoAverageBitRateKey : @(bitsPerSecond),
                                    AVVideoExpectedSourceFrameRateKey : @(30),
                                        AVVideoMaxKeyFrameIntervalKey : @(30),
                                               AVVideoProfileLevelKey : AVVideoProfileLevelH264BaselineAutoLevel};
    
    self.videoCompressionSettings = [self.videoDataOutput recommendedVideoSettingsForAssetWriterWithOutputFileType:AVFileTypeMPEG4];
    //设置编码方式、图片尺寸  AVVideoWidthKey，AVVideoHeightKey分别是宽高，赋值是相反的
    self.videoCompressionSettings = @{ AVVideoCodecKey : AVVideoCodecH264,
                                 AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill,
                                       AVVideoWidthKey : @(self.outputSize.height),
                                      AVVideoHeightKey : @(self.outputSize.width),
                       AVVideoCompressionPropertiesKey : compressionProperties};
    // 音频设置
    /** 
     *AVSampleRateKey: 采样率
     *AVNumberOfChannelsKey: 通道数
     *AVEncoderBitRatePerChannelKey:每通道的音频比特率
     *AVFormatIDKey: 音频格式
     */
    self.audioCompressionSettings = @{ AVEncoderBitRatePerChannelKey : @(28000),
                                                       AVFormatIDKey : @(kAudioFormatMPEG4AAC),
                                               AVNumberOfChannelsKey : @(1),
                                                     AVSampleRateKey : @(22050)};
}

#pragma mark - SampleBufferDelegate methods
//当数据缓冲区一有数据，就会调用该方法，在该方法中，我们可以获取视频帧，处理视频帧，显示视频帧
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    //在视频元数据的输出函数中，如果捕捉连接是视频连接，则写入视频数据
    if (connection == self.videoConnection)
    {
        if (!self.outputVideoFormatDescription)
        {
            //初始化编码器
            @synchronized(self) {
                CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
                self.outputVideoFormatDescription = formatDescription;
            }
        }
        else
        {
            //拼接数据
            @synchronized(self) {
                if (self.recordingStatus == PKRecordingStatusRecording)
                {
                    [self.assetSession appendVideoSampleBuffer:sampleBuffer];
                }
            }
        }
    }
    else if (connection == self.audioConnection)//写入音频数据
    {
        if (!self.outputAudioFormatDescription)
        {
            @synchronized(self) {
                CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
                self.outputAudioFormatDescription = formatDescription;
            }
        }
        @synchronized(self) {
            if (self.recordingStatus == PKRecordingStatusRecording)
            {
                [self.assetSession appendAudioSampleBuffer:sampleBuffer];
            }
        }
    }
}

#pragma mark - PKAssetWriterDelegate methods
- (void)sessionDidFinishPreparing:(PKShortVideoRecorder *)writer
{
    @synchronized(self)
    {
        if (self.recordingStatus != PKRecordingStatusStartingRecording){
            return;
        }
        [self transitionToRecordingStatus:PKRecordingStatusRecording error:nil];
    }
}

- (void)session:(PKShortVideoRecorder *)writer didFailWithError:(NSError *)error
{
    @synchronized(self) {
        self.assetSession = nil;
        [self transitionToRecordingStatus:PKRecordingStatusIdle error:error];
    }
}

- (void)sessionDidFinishRecording:(PKShortVideoRecorder *)writer
{
    @synchronized(self) {
        if ( self.recordingStatus != PKRecordingStatusStoppingRecording ) {
            return;
        }
    }
    self.assetSession = nil;
    @synchronized(self) {
        [self transitionToRecordingStatus:PKRecordingStatusIdle error:nil];
    }
}
#pragma mark - Recording State Machine
- (void)transitionToRecordingStatus:(PKRecordingStatus)newStatus error:(NSError *)error
{
    PKRecordingStatus oldStatus = self.recordingStatus;
    self.recordingStatus = newStatus;
    if (newStatus != oldStatus)
    {
        if (error && (newStatus == PKRecordingStatusIdle))
        {
            dispatch_async( dispatch_get_main_queue(), ^{
                @autoreleasepool {
                    if([self.delegate respondsToSelector:@selector(recorder:didFinishRecordingToOutputFilePath:error:)])
                    {
                         [self.delegate recorder:self didFinishRecordingToOutputFilePath:self.outputFilePath error:error];
                    }
                }
            });
        }
        else
        {
            error = nil;
            if (oldStatus == PKRecordingStatusStartingRecording && newStatus == PKRecordingStatusRecording)
            {
                dispatch_async( dispatch_get_main_queue(), ^{
                    @autoreleasepool {
                        if ([self.delegate respondsToSelector:@selector(recorderDidBeginRecording:)])
                        {
                            [self.delegate recorderDidBeginRecording:self];
                        }
                    }
                });
            }
            else if (oldStatus == PKRecordingStatusStoppingRecording && newStatus == PKRecordingStatusIdle)
            {
                dispatch_async( dispatch_get_main_queue(), ^{
                    @autoreleasepool {
                        //[self.delegate recorderDidEndRecording:self];
                        if([self.delegate respondsToSelector:@selector(recorder:didFinishRecordingToOutputFilePath:error:)])
                        {
                            [self.delegate recorder:self didFinishRecordingToOutputFilePath:self.outputFilePath error:error];
                        }
                    }
                });
            }
        }
    }
}
#pragma mark - Capture Session Setup
- (AVCaptureSession *)setupCaptureSession
{
    //初始化会话 负责把AVCaptureDevice捕捉到的视频或声音数据输出到输出设备中，
    AVCaptureSession *captureSession = [AVCaptureSession new];
    if (self.isBigSize)
    {
        //设置音视频录制的质量
        captureSession.sessionPreset = AVCaptureSessionPresetMedium;//360 x 480 小视频一般不会超过此尺寸
    }
    else {
        captureSession.sessionPreset = AVCaptureSessionPreset1280x720;//720 x 1280 小视频一般不会超过此尺寸
    }
    
    if (![self addDefaultCameraInputToCaptureSession:captureSession]){
        NSLog(@"加载摄像头失败");
    }
    if (![self addDefaultMicInputToCaptureSession:captureSession]){
        NSLog(@"加载麦克风失败");
    }
    return captureSession;
}

- (BOOL)addDefaultCameraInputToCaptureSession:(AVCaptureSession *)captureSession
{
    NSError *error;
    //获取视频输入设备，该方法默认返回iPhone的后置摄像头
    AVCaptureDevice *cameraDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [AVCaptureDevice devices];
    //根据cameraDevice,初始化输入对象captureDeviceInput
    AVCaptureDeviceInput *cameraDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:cameraDevice error:&error];
    if (error)
    {
        NSLog(@"配置摄像头输入错误: %@", [error localizedDescription]);
        return NO;
    }
    else
    {
        //将captureDeviceInput添加给session管理
        BOOL success = [self addInput:cameraDeviceInput toCaptureSession:captureSession];
        self.cameraDevice = cameraDeviceInput.device;
        return success;
    }
}
- (BOOL)addInput:(AVCaptureDeviceInput *)input toCaptureSession:(AVCaptureSession *)captureSession
{
    //将输入设备添加到会话
    if ([captureSession canAddInput:input])
    {
        [captureSession addInput:input];
        return YES;
    }
    else
    {
        NSLog(@"不能添加输入: %@", [input description]);
    }
    return NO;
}

- (BOOL)addDefaultMicInputToCaptureSession:(AVCaptureSession *)captureSession
{
    NSError *error;
    //初始化麦克风输入对象
    AVCaptureDeviceInput *micDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] error:&error];
    if (error){
        NSLog(@"配置麦克风输入错误: %@", [error localizedDescription]);
        return NO;
    } else {
        BOOL success = [self addInput:micDeviceInput toCaptureSession:captureSession];
        return success;
    }
}
- (BOOL)addOutput:(AVCaptureOutput *)output toCaptureSession:(AVCaptureSession *)captureSession
{
    if ([captureSession canAddOutput:output]){
        [captureSession addOutput:output];
        return YES;
    }
    else {
        NSLog(@"不能添加输出 %@", [output description]);
    }
    return NO;
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices ) {
        if ( device.position == position ) {
            return device;
        }
    }
    return nil;
}

#pragma mark - 懒加载
- (AVCaptureVideoPreviewLayer *)previewLayer
{
    if (!_previewLayer && _captureSession)
    {
        //根据session创建previewlayer
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    }
    return _previewLayer;
}

- (BOOL)isBigSize
{
    if (self.outputSize.width > 360 || self.outputSize.width/self.outputSize.height > 4/3)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end
