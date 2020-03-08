//
//  MovieViewController.m
//  AVEncodeTest
//
//  Created by ShanYuQin on 2020/3/8.
//  Copyright © 2020 ShanYuQin. All rights reserved.
//

#import "MovieViewController.h"
#import "MoveObject.h"
#define LERP(A,B,C) ((A)*(1.0-C)+(B)*C)
@interface MovieViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *ImageView;
@property (weak, nonatomic) IBOutlet UILabel *fps;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *TimerBtn;
@property (weak, nonatomic) IBOutlet UILabel *TimerLabel;
@property (nonatomic , strong) MoveObject * movieObject;
@property (nonatomic, assign) float lastFrameTime;

@end

@implementation MovieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.movieObject = [[MoveObject alloc] initWithVideo:@"http://vfx.mtime.cn/Video/2019/03/19/mp4/190319222227698228.mp4"];
}

- (IBAction)playBtnAction:(id)sender {
    [self.playBtn setEnabled:NO];
    _lastFrameTime = -1;
    
    // seek to 0.0 seconds
    [self.movieObject seekTime:0.0];
    
    
    [NSTimer scheduledTimerWithTimeInterval: 1 / self.movieObject.fps
                                     target:self
                                   selector:@selector(displayNextFrame:)
                                   userInfo:nil
                                    repeats:YES];

}

- (void)displayNextFrame:(NSTimer *)timer {
    NSTimeInterval startTime = [NSDate timeIntervalSinceReferenceDate];
    self.TimerLabel.text = [self dealTime:self.movieObject.currentTime];
    
    if (![self.movieObject stepFrame]) {
        [timer invalidate];
        [self.playBtn setEnabled:YES];
        return;
    }
    
    self.ImageView.image = self.movieObject.currentImage;
    float frameTime = 1.0 / ([NSDate timeIntervalSinceReferenceDate] - startTime);
    if (_lastFrameTime < 0) {
        _lastFrameTime = frameTime;
    } else {
        _lastFrameTime = LERP(frameTime, _lastFrameTime, 0.8);
    }
    [self.fps setText:[NSString stringWithFormat:@"fps %.0f",_lastFrameTime]];
}

- (NSString *)dealTime:(double)time {
    
    int tns, thh, tmm, tss;
    tns = time;
    thh = tns / 3600;
    tmm = (tns % 3600) / 60;
    tss = tns % 60;
    
    
    //        [ImageView setTransform:CGAffineTransformMakeRotation(M_PI)];
    return [NSString stringWithFormat:@"%02d:%02d:%02d",thh,tmm,tss];
}


@end
