//
//  CustomSliderView.h
//  AVPlayer
//
//  Created by zcw on 16/10/17.
//  Copyright © 2016年 zhcw. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^CustomSliderViewBlock)(Float64 value);

@interface CustomSliderView : UIView<UIGestureRecognizerDelegate>
-(instancetype)initWithFrame:(CGRect)frame startBlock:(CustomSliderViewBlock)startBlock changeBlock:(CustomSliderViewBlock)changeBlock endBlock:(CustomSliderViewBlock)endBlock;
@property(nonatomic)Float64 value;//0-1取值
@property(nonatomic)CGFloat progress;//0-1取值

@end
