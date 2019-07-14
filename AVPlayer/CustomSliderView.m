//
//  CustomSliderView.m
//  AVPlayer
//
//  Created by zcw on 16/10/17.
//  Copyright © 2016年 zhcw. All rights reserved.
//

#import "CustomSliderView.h"
static CGFloat corner=15;
@implementation CustomSliderView{
    UISlider* _slider;
    UIProgressView* _progressView;
    
    CustomSliderViewBlock _startBlock;
    CustomSliderViewBlock _changeBlock;
    CustomSliderViewBlock _endBlock;

}
-(instancetype)initWithFrame:(CGRect)frame startBlock:(CustomSliderViewBlock)startBlock changeBlock:(CustomSliderViewBlock)changeBlock endBlock:(CustomSliderViewBlock)endBlock{
    self=[super initWithFrame:frame];
    if (self) {
//        self.backgroundColor=[UIColor orangeColor];112233
        
        UISlider* slider=[UISlider new];
        _slider=slider;
        [slider setMinimumTrackTintColor:[UIColor whiteColor]];
        [slider setMaximumTrackTintColor:[UIColor colorWithWhite:0.5 alpha:0.5]];
        
        [slider setThumbImage:[self imageWithColor:[UIColor whiteColor] size:CGSizeMake(corner, corner) alpha:1] forState:UIControlStateNormal];
        UIColor * color=[UIColor lightGrayColor];
        [slider setThumbImage:[self imageWithColor:color size:CGSizeMake(corner, corner) alpha:1] forState:UIControlStateHighlighted];
        [slider setThumbImage:[self imageWithColor:color size:CGSizeMake(corner, corner) alpha:1] forState:UIControlStateHighlighted | UIControlStateSelected];
        [slider setThumbImage:[self imageWithColor:color size:CGSizeMake(corner, corner) alpha:1] forState:UIControlStateSelected];
        
        [slider addTarget:self action:@selector(sliderViewBtnTouchDown:) forControlEvents:UIControlEventTouchDown];
        [slider addTarget:self action:@selector(sliderViewBtnValueChanged:) forControlEvents:UIControlEventValueChanged];
        [slider addTarget:self action:@selector(sliderViewBtnTouchUpInside:) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchCancel];

        [self addSubview:slider];
        [slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(corner);
            make.right.equalTo(self).offset(-corner);
            make.centerY.equalTo(self);
        }];
        
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        _progressView.trackTintColor = [UIColor clearColor];
        [self insertSubview:_progressView atIndex:0];
        
        
        
        [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(slider);
            make.centerY.equalTo(slider).offset(1);
//            make.height.mas_equalTo(2);
        }];
        
        _startBlock=startBlock;
        _changeBlock=changeBlock;
        _endBlock=endBlock;
        return self;
    }
    return self;
}
-(void)sliderViewBtnTouchDown:(UISlider*)slider{
    _startBlock(slider.value);
}
-(void)sliderViewBtnTouchUpInside:(UISlider*)slider{
    _endBlock(slider.value);
}
-(void)sliderViewBtnValueChanged:(UISlider*)slider{
    _changeBlock(slider.value);
}
-(Float64)value{
    return _slider.value;
}
-(void)setValue:(Float64)value{
    _slider.value=value;
}
-(CGFloat)progress{
    return _progressView.progress;
}
-(void)setProgress:(CGFloat)progress{
    _progressView.progress=progress;
}

-(UIImage*)imageWithColor:(UIColor*)color size:(CGSize)size alpha:(CGFloat)alpha{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetAlpha(context,alpha);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetLineWidth(context, 1);
    CGContextAddArc(context, size.width/2, size.height/2, size.width/2-1, M_PI*2, 0, 1);
    CGContextDrawPath(context, kCGPathFillStroke); //绘制路径加填充
    return UIGraphicsGetImageFromCurrentImageContext();
}

@end
