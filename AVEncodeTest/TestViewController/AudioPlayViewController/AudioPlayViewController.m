//
//  AudioPlayViewController.m
//  AVEncodeTest
//
//  Created by ShanYuQin on 2020/3/6.
//  Copyright © 2020 ShanYuQin. All rights reserved.
//

#import "AudioPlayViewController.h"
#import<AVFoundation/AVFoundation.h>
#import<AudioToolbox/AudioToolbox.h>
#import<CoreAudio/CoreAudioTypes.h>


static void checkStatus(OSStatus status,NSString *message,BOOL fatal) {
    if (status != noErr) {
        char  fourCC[16];
        *(UInt32 *)fourCC = CFSwapInt32HostToBig(status);
        fourCC[4] = '\0';
        if (isprint(fourCC[0])&&
            isprint(fourCC[1])&&
            isprint(fourCC[2])&&
            isprint(fourCC[3])) {
            NSLog(@"%@:%s",message,fourCC);
        }else {
            NSLog(@"%@:%d",message,status);
        }
        if (fatal) {
            exit(-1);
        }
    }
}

@interface AudioPlayViewController ()

@end

@implementation AudioPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //创建一个会话，用于管理与获取iOS设备音频的硬件信息。
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    /** 配置使用的音频硬件:
     *  AVAudioSessionCategoryPlayback:只是进行音频的播放(只使用听的硬件，比如手机内置喇叭，或者通过耳机)
     *  AVAudioSessionCategoryRecord:只是采集音频(只录，比如手机内置麦克风)
     *  AVAudioSessionCategoryPlayAndRecord:一边采集一遍播放(听和录同时用)
     */
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    //设置I/O的buffer，buffer越小说明延迟越低。
    NSTimeInterval bufferDuration = 0.002;
    [audioSession setPreferredIOBufferDuration:bufferDuration error:nil];
    
    //设置采样频率 让s硬件设备按照设置的采样频率采集或者播放音频
    double hwSampleRate = 44100.0;
    [audioSession setPreferredSampleRate:hwSampleRate error:nil];
    
    //设置完所有参数后激活audioSession
    [audioSession setActive:YES error:nil];
    
    
    //构建 AudioUnit  需要指定类型，子类型以及厂商
    AudioComponentDescription ioComponentDescription;
    /*根据功能功能设置类型*/
    //那么都有哪些type和subType呢？
    ioComponentDescription.componentType = kAudioUnitType_Output;
    //这里构建了一个RemoteIO类型的AudioUnit描述的结构体，
    ioComponentDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    /*厂商的身份验证*/
    ioComponentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    /*如果没有一个明确指定的值，那么它必须被设置为0*/
    ioComponentDescription.componentFlags = 0;
    /*如果没有一个明确指定的值，那么它必须被设置为0*/
    ioComponentDescription.componentFlagsMask = 0;
    
    /**
       使用AUGraph的结构体在应用中可以搭建出扩展性更高的系统，所以推荐第二种。
    */
    
//   1. AudioUnit裸的创建方式；
    AudioComponent ioUnitRef = AudioComponentFindNext(NULL, &ioComponentDescription);
    AudioUnit ioUnitInstance;
    AudioComponentInstanceNew(ioUnitRef, &ioUnitInstance);
    
    
//    2.AUGraph创建方式
    AUGraph processingGraph;
    NewAUGraph(&processingGraph);
    
    AUNode ioNode;
    AUGraphAddNode(processingGraph, &ioComponentDescription, &ioNode);
    
    AUGraphOpen(processingGraph);
    
    AudioUnit remoteIOUnit;
    AUGraphNodeInfo(processingGraph, ioNode, NULL, &remoteIOUnit);
    
//   启用扬声器 把RemoteIOUnit 的 Element0的 OutputScope 连接到扬声器上
    OSStatus status = noErr;
    UInt32 oneFlag = 1;
    UInt32 busZero = 0;//Element 0
    status = AudioUnitSetProperty(remoteIOUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, busZero, &oneFlag, sizeof(oneFlag));
//    判断错误
    checkStatus(status,@"Could not Connect To Speaker",YES);
    
//    启用麦克风 把RemoteIOUnit 的 Element1的 InputScope 连接到麦克风上
    UInt32 busOne = 1;//Element 1
    AudioUnitSetProperty(remoteIOUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, busOne, &oneFlag, sizeof(oneFlag));
    
    
    //设置AudioUnit的数据格式，分为输入和输出两个部分
    UInt32 bytePerSample = sizeof(Float32);
    AudioStreamBasicDescription asbd; //用来描述音视频的具体格式
    bzero(&asbd, sizeof(asbd));
    /**指定音频的编码格式  此处为PCM格式*/
    asbd.mFormatID = kAudioFormatLinearPCM;
    /**采样率*/
    asbd.mSampleRate = 44100.0;
    /**声道数*/
    asbd.mChannelsPerFrame = 1;
    /**每个Packet有几个Frame*/
    asbd.mFramesPerPacket = 1;
    /** mFormatFlags 描述声音表示格式的参数*/
    asbd.mFormatFlags = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
    /**一个声道的音频数据用多少位来表示 */
    asbd.mBitsPerChannel = 8*bytePerSample;
    /***/
    asbd.mBytesPerFrame = bytePerSample;
    asbd.mBytesPerPacket = bytePerSample;
    
    AudioUnitSetProperty(remoteIOUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &asbd, sizeof(asbd));
    
    
    
}


@end
