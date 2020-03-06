//
//  Mp3EncodeViewController.m
//  AVEncodeTest
//
//  Created by ShanYuQin on 2020/3/6.
//  Copyright © 2020 ShanYuQin. All rights reserved.
//

#import "Mp3EncodeViewController.h"
#import "CommonUtil.h"
#import "Mp3Encoder.hpp"



@interface Mp3EncodeViewController ()

@end

@implementation Mp3EncodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)btnClick:(id)sender {
    NSLog(@"按钮点击事件");
       Mp3Encoder *encoder = new Mp3Encoder();
       // 源文件的的路径
       const char* pcmFilePath = [[CommonUtil bundlePath:@"test.pcm"] cStringUsingEncoding:NSUTF8StringEncoding];
       // 要生成的mp3文件的路径
       const char *mp3FilePath = [[CommonUtil documentsPath:@"test.mp3"] cStringUsingEncoding:NSUTF8StringEncoding];
       int sampleRate = 44100;
       int channels = 2;
       int bitRate = 128 * 1024;
       // 初始化解码器，传入源文件路径，生成的文件路径，采样频率，声道数，码率
       encoder->Init(pcmFilePath, mp3FilePath, sampleRate, channels, bitRate);
       // 编码
       encoder->Encode();
       //关闭文件
       encoder->Destory();
       delete encoder;
       NSLog(@"Encode Success");
}


@end
