//
//  AlertViewController.m
//  AVPlayer
//
//  Created by zcw on 2016/11/22.
//  Copyright © 2016年 zhcw. All rights reserved.
//

#import "AlertViewController.h"

@interface AlertViewController ()

@end

@implementation AlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"%d %d",self.isBeingPresented,self.isBeingDismissed);
    self.isPresent=self.isBeingPresented;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"%d %d",self.isBeingPresented,self.isBeingDismissed);
    self.isPresent=self.isBeingPresented;

}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"%d %d",self.isBeingPresented,self.isBeingDismissed);
    self.isPresent=self.isBeingPresented;

}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    NSLog(@"%d %d",self.isBeingPresented,self.isBeingDismissed);
    self.isPresent=self.isBeingPresented;

}
-(void)dealloc{
    
}
@end
