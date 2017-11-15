//
//  PKShortVideoWriter.h
//  DevelopWriterDemo
//
//  Created by jiangxincai on 16/1/14.
//  Copyright © 2016年 pepsikirk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class PKShortVideoRecorder;

@protocol PKShortVideoRecorderDelegate <NSObject>

@optional
- (void)recorderDidBeginRecording:(PKShortVideoRecorder *)recorder;
- (void)recorderDidEndRecording:(PKShortVideoRecorder *)recorder;
@required
- (void)recorder:(PKShortVideoRecorder *)recorder didFinishRecordingToOutputFilePath:(nullable NSString *)outputFilePath error:(nullable NSError *)error;

@end



@class AVCaptureVideoPreviewLayer;

@interface PKShortVideoRecorder : NSObject

@property (nonatomic, strong) AVCaptureDevice *cameraDevice;
@property (nonatomic, weak) id<PKShortVideoRecorderDelegate> delegate;

- (instancetype)initWithOutputFilePath:(NSString *)outputFilePath;

- (void)startRunning;
- (void)stopRunning;

- (void)startRecording;
- (void)stopRecording;

- (AVCaptureVideoPreviewLayer *)previewLayer;

@end

NS_ASSUME_NONNULL_END


