//
//  ViewController.m
//  AVEncodeTest
//
//  Created by ShanYuQin on 2020/3/5.
//  Copyright © 2020 ShanYuQin. All rights reserved.
//

#import "ViewController.h"
#import "Mp3EncodeViewController.h"
#import "FFmpeg_HelloWordController.h"
#import "SimpleDecoderViewController.h"
#import "AudioPlayViewController.h"
#import "MovieViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleArr = @[@"mp3EncodeTest",@"FFmpeg_Information",@"SimpleDecoder",@"MoviePlayTest"];
    [self.tableview reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const indefier = @"sdasd";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indefier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indefier];
    }
    cell.textLabel.text = self.titleArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        Mp3EncodeViewController * vc = [[Mp3EncodeViewController alloc] initWithNibName:@"Mp3EncodeViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 1) {
        FFmpeg_HelloWordController * vc = [[FFmpeg_HelloWordController alloc] initWithNibName:@"FFmpeg_HelloWordController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 2) {
        SimpleDecoderViewController * vc = [[SimpleDecoderViewController alloc] initWithNibName:@"SimpleDecoderViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 3) {
        MovieViewController *vc = [[MovieViewController alloc] initWithNibName:@"MovieViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}



- (void)testffmpeg {
//    const char *mp4Path = [[CommonUtil documentsPath:@"test.mp4"] cStringUsingEncoding:NSUTF8StringEncoding];
//    AVFormatContext *formatCtx = avformat_alloc_context();
////    AVIOInterruptCB int_cb = {interrupt_callback,(__bridge void *)(self)};
////    formatCtx->interrupt_callback = int_cb;
//    avformat_open_input(&formatCtx,mp4Path,NULL,NULL);
//    avformat_find_stream_info(formatCtx, NULL);
//
//


}

@end
