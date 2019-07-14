//
//  ViewController.m
//  AVPlayer
//
//  Created by zcw on 16/10/14.
//  Copyright © 2016年 zhcw. All rights reserved.
//

#import "ViewController.h"
#import<AVFoundation/AVFoundation.h>
#import<MediaPlayer/MediaPlayer.h>

#import "CustomSliderView.h"

#define VolumeStep 0.015
@interface ViewController ()
@property (strong, nonatomic)AVPlayer *myPlayer;//播放器
@property (strong, nonatomic)AVPlayerItem *item;//播放单元
@property (strong, nonatomic)AVPlayerLayer *playerLayer;//播放界面（layer）
@property (strong, nonatomic)CustomSliderView *avSlider;
@property (strong, nonatomic)UILabel* leftLabel;
@property (strong, nonatomic)UILabel* rightLabel;
@property (strong, nonatomic)UIView* bottomView;
@property (strong, nonatomic)UILabel* panLabel;

@property (strong, nonatomic)id timeObserver;
@property (strong, nonatomic)UIActivityIndicatorView* activityIndicatorView;
@property (nonatomic)Float64 currentTime;

@property (nonatomic)BOOL isShow;
@property (nonatomic,strong)UISlider* volumeSlider;
@property (nonatomic)BOOL pause;

@end

@implementation ViewController
@synthesize isShow;
-(float)getVolume{
    return [[AVAudioSession sharedInstance]outputVolume];
}
-(UIActivityIndicatorView*)activityIndicatorView{
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityIndicatorView.center=self.view.center;
        _activityIndicatorView.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self.view addSubview:_activityIndicatorView];
    }
    return _activityIndicatorView;
}
-(UILabel*)panLabel{
    if (!_panLabel) {
        _panLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 130, 50)];
        _panLabel.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.7];
        _panLabel.center=self.view.center;
        _panLabel.layer.cornerRadius=5;
        _panLabel.layer.masksToBounds=YES;
        _panLabel.font=[UIFont systemFontOfSize:17];
        _panLabel.textColor=[UIColor whiteColor];
        _panLabel.textAlignment=NSTextAlignmentCenter;
        _panLabel.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self.view addSubview:_panLabel];
    }
    return _panLabel;
}
-(UISlider*)volumeSlider{
    if (!_volumeSlider) {
        MPVolumeView* volumeView = [[MPVolumeView alloc]init];
        volumeView.showsRouteButton = NO;
        //默认YES，这里为了突出，故意设置一遍
        volumeView.showsVolumeSlider = NO;
//        [self.view addSubview:volumeView];

        for (UIView *view in [volumeView subviews]){
            if ([[view.class description] isEqualToString:@"MPVolumeSlider"]){
                _volumeSlider = (UISlider*)view;
                break;
            }
        }
        _volumeSlider.value=[self getVolume];
        [_volumeSlider sendActionsForControlEvents:UIControlEventValueChanged];
    }
//    NSLog(@"_volumeSlider %f %f",_volumeSlider.value,[self getVolume]);
    return _volumeSlider;
}
-(instancetype)init{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed=YES;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didRotateFromInterfaceOrientation) name:UIDeviceOrientationDidChangeNotification object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(endPlay) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];


    [self createAVplayer];
    [self createBottomView];
}
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.playerLayer.frame = self.view.bounds;
}
-(void)createGestureRecognizer{
    UIView* tapView=[[UIView alloc]initWithFrame:self.view.bounds];
    tapView.backgroundColor=self.view.backgroundColor;
    tapView.autoresizingMask=UIViewAutoresizingFlexibleWidth
    |UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:tapView atIndex:0];
    //    tapView.backgroundColor=[UIColor orangeColor];
    
    UITapGestureRecognizer* doubleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap)];
    doubleTap.numberOfTapsRequired=2;
    [tapView addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer* singleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap)];
    [tapView addGestureRecognizer:singleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    UIPanGestureRecognizer* controlPan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(controlPan:)];
    [tapView addGestureRecognizer:controlPan];

}
-(void)createBottomView{
    CGFloat h=35;
    UIView* bottomView=[[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-h, self.view.frame.size.width, h)];
    bottomView.backgroundColor=[UIColor colorWithWhite:0 alpha:0.8];
    bottomView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:bottomView];
    self.bottomView=bottomView;
    
    UILabel* leftLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, bottomView.frame.size.height)];
    leftLabel.textAlignment=NSTextAlignmentCenter;
    leftLabel.textColor=[UIColor whiteColor];
    leftLabel.text=@"00:00:00";
    leftLabel.font=[UIFont systemFontOfSize:15];
    [bottomView addSubview:leftLabel];
    self.leftLabel=leftLabel;
    
    UILabel* rightLabel=[[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-leftLabel.frame.size.width, leftLabel.frame.origin.y, leftLabel.frame.size.width, leftLabel.frame.size.height)];
    rightLabel.textAlignment=NSTextAlignmentCenter;
    rightLabel.textColor=[UIColor whiteColor];
    rightLabel.text=leftLabel.text;
    rightLabel.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin;
    rightLabel.font=leftLabel.font;
    [bottomView addSubview:rightLabel];
    self.rightLabel=rightLabel;
    
    __weak typeof(self) weakSelf=self;
    self.avSlider = [[CustomSliderView alloc]initWithFrame:CGRectMake(CGRectGetWidth(leftLabel.frame), CGRectGetMinY(leftLabel.frame), CGRectGetWidth(self.view.frame)-CGRectGetWidth(leftLabel.frame)*2, CGRectGetHeight(leftLabel.frame)) startBlock:^(Float64 value) {
        [weakSelf avSliderTouchDownAction];
    } changeBlock:^(Float64 value) {
        [weakSelf avSliderChangedAction];
        
    } endBlock:^(Float64 value) {
        [weakSelf avSliderTouchUpInsideAction];
        
    }];
    self.avSlider.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    [bottomView addSubview:self.avSlider];

}
-(void)createAVplayer{
    //静音也可以播放
    AVAudioSession* audioSession =[AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];

    NSURL *mediaURL=nil;
    NSString* path=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    mediaURL = [NSURL fileURLWithPath:[path stringByAppendingPathComponent:self.fileName]];

    self.item = [AVPlayerItem playerItemWithURL:mediaURL];
    self.myPlayer = [AVPlayer playerWithPlayerItem:self.item];
    self.myPlayer.volume=1;

    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.myPlayer];
    self.playerLayer.frame = self.view.bounds;
    self.playerLayer.backgroundColor=[UIColor blackColor].CGColor;
    [self.view.layer addSublayer:self.playerLayer];
    
    [self.item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.activityIndicatorView startAnimating];
    [self.myPlayer play];

}
-(void)addTimeObserver{
    if (!self.timeObserver) {
        __weak typeof(self) weakSelf=self;
        self.timeObserver = [self.myPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1,1) queue:NULL usingBlock:^(CMTime time) {
            Float64 total=CMTimeGetSeconds(weakSelf.item.duration);
            weakSelf.avSlider.value=CMTimeGetSeconds(time)/total;
            
            NSInteger totalH=total/3600;
            NSInteger totalM=(NSInteger)(total/60)%60;
            NSInteger totalS=(NSInteger)total%60;
            
            NSInteger currentH=CMTimeGetSeconds(time)/3600;
            NSInteger currentM=(NSInteger)(CMTimeGetSeconds(time)/60)%60;
            NSInteger currentS=(NSInteger)CMTimeGetSeconds(time)%60;
            
            weakSelf.leftLabel.text=[NSString stringWithFormat:@"%.2ld:%.2ld:%.2ld",(long)totalH,(long)totalM,(long)totalS];
            weakSelf.rightLabel.text=[NSString stringWithFormat:@"%.2ld:%.2ld:%.2ld",(long)currentH,(long)currentM,(long)currentS];
            
        }];
    }
}

- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[self.myPlayer currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

///按下时移除时间监听
-(void)avSliderTouchDownAction{
    if (self.timeObserver) {
        [self.myPlayer removeTimeObserver:self.timeObserver];
        self.timeObserver=nil;
    }
}
- (void)avSliderChangedAction{
    Float64 total=CMTimeGetSeconds(self.item.duration);
    NSInteger currentH=total*self.avSlider.value/3600;
    NSInteger currentM=(NSInteger)(total*self.avSlider.value)/60%60;
    NSInteger currentS=(NSInteger)(total*self.avSlider.value)%60;
    self.rightLabel.text=[NSString stringWithFormat:@"%.2ld:%.2ld:%.2ld",(long)currentH,(long)currentM,(long)currentS];
}
//滑动结束后设置播放进度
-(void)avSliderTouchUpInsideAction{
    //slider的value值为视频的时间
    Float64 seconds = self.avSlider.value*CMTimeGetSeconds(self.item.duration);
    //让视频从指定的CMTime对象处播放。
    CMTime startTime = CMTimeMakeWithSeconds(seconds, self.item.duration.timescale);
    //让视频从指定处播放
    __weak typeof(self) weakSelf=self;
    [self.myPlayer seekToTime:startTime completionHandler:^(BOOL finished) {
        if (finished) {
            [weakSelf addTimeObserver];
        }
    }];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:
(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        //取出status的新值
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey]intValue];
        switch (status) {
            case AVPlayerItemStatusFailed:
                NSLog(@"item 有误");
                break;
            case AVPlayerItemStatusReadyToPlay:
                NSLog(@"准好播放了");
                [self createGestureRecognizer];
                [self addTimeObserver];
                break;
            case AVPlayerItemStatusUnknown:
                NSLog(@"视频资源出现未知错误");
                break;
            default:
                break;
        }
        [self.activityIndicatorView stopAnimating];
    }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
        Float64 total=CMTimeGetSeconds(self.item.duration);
        self.avSlider.progress=[self availableDuration]/total;
        if (!self.pause) {
            if (self.avSlider.progress>self.avSlider.value) {
                if (self.myPlayer.rate == 0) {
                    [self.myPlayer play];
                }
            }else{
                if (self.myPlayer.rate != 0) {
                    [self.myPlayer pause];
                }
            }
        }
    }
}
-(void)endPlay{
//    [self.navigationController popViewControllerAnimated:YES];
}
//屏幕旋转完成的状态
-(void)didRotateFromInterfaceOrientation{
    self.playerLayer.frame = self.view.bounds;
}
//-(void)volumeChanged:(NSNotification*)notification{
////    self.volumeValue=[notification.userInfo[@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
//}
-(void)singleTap{
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
    
    if (!isShow) {
        [UIView animateWithDuration:0.2 animations:^{
            self.bottomView.transform=CGAffineTransformMakeTranslation(0, self.bottomView.frame.size.height);
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            self.bottomView.transform=CGAffineTransformIdentity;
        }];
    }
    isShow=!isShow;

}
-(void)doubleTap{

    if (self.myPlayer.rate == 0) {
        [self.myPlayer play];
    }else{
        [self.myPlayer pause];
    }
    self.pause=self.myPlayer.rate == 0;

}
-(void)controlPan:(UIPanGestureRecognizer*)pan{
    static NSInteger time=0;
    static NSString* typeStr=nil;
    static CGFloat soundsValue=0;
    static CGFloat brightnessValue=0;

    if (pan.state==UIGestureRecognizerStateBegan) {
        typeStr=nil;//还原初始值

        CGPoint v=[pan velocityInView:pan.view];
        CGFloat vx=fabs(v.x),vy=fabs(v.y);
        CGPoint startPoint=[pan locationInView:pan.view];
        NSLog(@"%f",startPoint.x);

        if (vy/vx < tan(M_PI_2/2)) {
            typeStr=@"progress";//快进
            self.currentTime=CMTimeGetSeconds(self.item.currentTime);
            self.panLabel.hidden=NO;
            [self avSliderTouchDownAction];
            
        }else if (vy/vx > tan(M_PI_2*2/3)){
            if (startPoint.x<150) {
                typeStr=@"sounds";//声音
//                self.volumeSlider.value=self.playerLayer.player.volume;
//                soundsValue=self.volumeSlider.value;
            }else if (startPoint.x>pan.view.frame.size.width-150){
                typeStr=@"brightness";//亮度
                brightnessValue=[UIScreen mainScreen].brightness;
            }
        }
    }
    
    if ([typeStr isEqualToString:@"progress"]) {
        if (pan.state==UIGestureRecognizerStateChanged) {
            CGFloat x=[pan translationInView:pan.view].x;
            NSInteger scale=(x/self.view.frame.size.width)*10*4;//偏移量
            time=MIN(MAX(self.currentTime+scale, 0), CMTimeGetSeconds(self.item.duration));
            if (time == 0) {
                scale=-self.currentTime;
            }else if (time == (NSInteger)CMTimeGetSeconds(self.item.duration)) {
                scale=CMTimeGetSeconds(self.item.duration)-self.currentTime;
            }
            NSString* str=scale>=0 ? @"前进" : @"倒退";
            self.panLabel.text=[NSString stringWithFormat:@"%@%ld秒",str,labs(scale)];
            
        }else if (pan.state==UIGestureRecognizerStateEnded || pan.state==UIGestureRecognizerStateCancelled) {
            self.panLabel.hidden=YES;
            Float64 totalTime=CMTimeGetSeconds(self.item.duration);
            self.avSlider.value=time/totalTime;
            [self avSliderTouchUpInsideAction];
        }
    }else if ([typeStr isEqualToString:@"sounds"]) {
        if (pan.state==UIGestureRecognizerStateChanged) {
            CGPoint v=[pan velocityInView:pan.view];

            if (v.y>0) {
                //音量减小
                [self.volumeSlider setValue:MAX(0, self.volumeSlider.value-VolumeStep) animated:YES];
            }else{
                [self.volumeSlider setValue:MIN(1, self.volumeSlider.value+VolumeStep) animated:YES];
            }
        }
    }else if ([typeStr isEqualToString:@"brightness"]) {
        if (pan.state==UIGestureRecognizerStateChanged) {
            CGFloat y=-[pan translationInView:pan.view].y;
            CGFloat scale=(y/self.view.frame.size.height);
            
            [UIScreen mainScreen].brightness = MIN(MAX(scale+brightnessValue, 0), 1);
        }
    }
}
-(void)dealloc{
    [self.myPlayer removeTimeObserver:self.timeObserver];
    [self.myPlayer pause];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.item removeObserver:self forKeyPath:@"status"];
    [self.item removeObserver:self forKeyPath:@"loadedTimeRanges"];
    
//    //存储音量
//    NSUserDefaults* userDefaults=[NSUserDefaults standardUserDefaults];
//    [userDefaults setFloat:self.volumeSlider.value forKey:@"QXD_VolumeValue"];
//    [userDefaults synchronize];
}

@end
