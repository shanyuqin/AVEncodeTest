//
//  MoveObject.m
//  AVEncodeTest
//
//  Created by ShanYuQin on 2020/3/8.
//  Copyright © 2020 ShanYuQin. All rights reserved.
//

#import "MoveObject.h"


#ifdef __cplusplus
extern "C" {
#endif
    
#include "libavformat/avformat.h"
#include "libavutil/frame.h"
#include "libavutil/samplefmt.h"
#include "libswscale/swscale.h"
#include "libswresample/swresample.h"
#include "libavutil/pixdesc.h"
#include "libavfilter/avfilter.h"



#ifdef __cplusplus
};
#endif

@interface MoveObject()

@property (nonatomic, copy) NSString *cruutenPath;

@end

@implementation MoveObject{
    AVFormatContext     *formatCtx;
    AVCodecContext      *codecCtx;
    AVFrame             *frame;
    AVStream            *stream;
    AVPacket            packet;
    AVPicture           picture;
    int                 videoStream;
    double              fps;
    BOOL                isReleaseResources;
}

- (instancetype)initWithVideo:(NSString *)moviePath {
    
    if (!(self=[super init])) return nil;
    if ([self initializeResources:[moviePath UTF8String]]) {
        self.cruutenPath = [moviePath copy];
        return self;
    } else {
        return nil;
    }
}


- (BOOL)initializeResources:(const char *)filePath {
    isReleaseResources = NO;
    AVCodec *pCodec;
    //注册解码器
    avcodec_register_all();
    av_register_all();
    avformat_network_init();
    //打开视频文件
    if (avformat_open_input(&formatCtx, filePath, NULL, NULL) != 0) {
        NSLog(@"打开文件失败");
        goto initError;
    }
    //检查数据流
    if (avformat_find_stream_info(formatCtx, NULL)<0) {
        NSLog(@"检查数据流失败");
        goto initError;
    }
    //根据数据流 找到第一个视频流
    if ((videoStream = av_find_best_stream(formatCtx, AVMEDIA_TYPE_VIDEO, -1, -1, &pCodec, 0)) < 0) {
        NSLog(@"没有找到第一个视频流");
        goto initError;
    }
    //获取视频流的编解码上下文的指针
    stream = formatCtx->streams[videoStream];
    codecCtx = stream->codec;
    
    //
    NSLog(@"打印视频流的详细信息---------start");
    av_dump_format(formatCtx, videoStream, filePath, 0);
    NSLog(@"打印视频流的详细信息---------end");
//  avg_frame_rate是一个AVRational类型的结构体
//  AVRational根据帧率来设定，如25帧，那么num = 1，den=25
    //获取fps
    if (stream->avg_frame_rate.den && stream->avg_frame_rate.num) {
        fps = av_q2d(stream->avg_frame_rate);
    }else {
        fps = 30;
    }
    //查找解码器
    pCodec = avcodec_find_decoder(codecCtx->codec_id);
    if (pCodec == NULL) {
        NSLog(@"没有找到解码器");
        goto initError;
    }
    
    //打开解码器
    if (avcodec_open2(codecCtx, pCodec, NULL)<0) {
        NSLog(@"打开解码器失败");
        goto initError;
    }
    
    // 分配视频帧
    frame = av_frame_alloc();
    _outputWidth = codecCtx->width;
    _outputHeight = codecCtx->height;
    return YES;
initError:
    return NO;

}

- (void)seekTime:(double)seconds {
    AVRational timebase = formatCtx->streams[videoStream]->time_base;
    int64_t targetFrame = (int64_t)((double)timebase.den / timebase.num * seconds);
    avformat_seek_file(formatCtx, videoStream, 0, targetFrame, targetFrame, AVSEEK_FLAG_FRAME);
    avcodec_flush_buffers(codecCtx);
}
- (BOOL)stepFrame {
    int frameFinished = 0;
    while (!frameFinished && av_read_frame(formatCtx, &packet) >= 0) {
        if (packet.stream_index == videoStream) {
            avcodec_decode_video2(codecCtx,frame,&frameFinished,&packet);
        }
    }
    if (frameFinished == 0  && isReleaseResources == NO) {
        [self releaseResources];
    }
    return frameFinished != 0;
}
- (void)replaceTheResources:(NSString *)moviePath {
    if (!isReleaseResources) {
        [self releaseResources];
    }
    self.cruutenPath = [moviePath copy];
    [self initializeResources:[moviePath UTF8String]];
}
- (void)redialPaly {
    [self initializeResources:[self.cruutenPath UTF8String]];
}
#pragma mark ------------------------------------
#pragma mark  重写属性访问方法

-(void)setOutputWidth:(int)newValue {
    if (_outputWidth == newValue) return;
    _outputWidth = newValue;
}
-(void)setOutputHeight:(int)newValue {
    if (_outputHeight == newValue) return;
    _outputHeight = newValue;
}
-(UIImage *)currentImage {
    if (!frame->data[0]) return nil;
    return [self imageFromAVPicture];
}
-(double)duration {
    return (double)formatCtx->duration / AV_TIME_BASE;
}
- (double)currentTime {
    AVRational timeBase = formatCtx->streams[videoStream]->time_base;
    return packet.pts * (double)timeBase.num / timeBase.den;
}
- (int)sourceWidth {
    return codecCtx->width;
}
- (int)sourceHeight {
    return codecCtx->height;
}
- (double)fps {
    return fps;
}

- (UIImage *)imageFromAVPicture {
    avpicture_free(&picture);
    avpicture_alloc(&picture, AV_PIX_FMT_RGB24, _outputWidth, _outputHeight);
    struct SwsContext *imgConvertCtx = sws_getContext(frame->width,
                                                      frame->height,
                                                      AV_PIX_FMT_YUV420P,
                                                      _outputWidth,
                                                      _outputHeight,
                                                      AV_PIX_FMT_RGB24,
                                                      SWS_FAST_BILINEAR,
                                                      NULL, NULL, NULL);
    if(imgConvertCtx == nil) return nil;
    sws_scale(imgConvertCtx,frame->data,frame->linesize,0,frame->height,picture.data,picture.linesize);
    sws_freeContext(imgConvertCtx);
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CFDataRef data = CFDataCreate(kCFAllocatorDefault, picture.data[0], picture.linesize[0] * _outputHeight);
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(data);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef cgImage = CGImageCreate(_outputWidth,
                                       _outputHeight,
                                       8,
                                       24,
                                       picture.linesize[0],
                                       colorSpace,
                                       bitmapInfo,
                                       provider,
                                       NULL,
                                       NO,
                                       kCGRenderingIntentDefault);
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGColorSpaceRelease(colorSpace);
    CGDataProviderRelease(provider);
    CFRelease(data);
    return image;
    
    
}

- (void)releaseResources {
    NSLog(@"释放资源");
//    SJLogFunc
    isReleaseResources = YES;
    // 释放RGB
    avpicture_free(&picture);
    // 释放frame
    av_packet_unref(&packet);
    // 释放YUV frame
    av_free(frame);
    // 关闭解码器
    if (codecCtx) avcodec_close(codecCtx);
    // 关闭文件
    if (formatCtx) avformat_close_input(&formatCtx);
    avformat_network_deinit();
}



@end
