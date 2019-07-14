//
//  LockViewController.h
//  AVPlayer
//
//  Created by zcw on 2016/11/22.
//  Copyright © 2016年 zhcw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LockViewController : UIViewController
@property(nonatomic)BOOL isPresent;
+(instancetype)shareLockViewController;
-(void)showTouchId:(NSString*)str;
@end
