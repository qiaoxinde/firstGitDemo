//
//  LockViewController.m
//  AVPlayer
//
//  Created by zcw on 2016/11/22.
//  Copyright © 2016年 zhcw. All rights reserved.
//

#import "LockViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>
@interface AlertViewController : UIAlertController
@property(nonatomic)BOOL isPresent;
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


@interface LockViewController ()
@property(nonatomic,weak)AlertViewController* alert;

@end

@implementation LockViewController
-(UIViewController*)getCurrentVC{
    UINavigationController* nav=(UINavigationController*)[UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController* vc=nav.visibleViewController;
    return vc;
}
+(instancetype)shareLockViewController{
    static dispatch_once_t onceToken;
    static LockViewController* vc;
    dispatch_once(&onceToken, ^{
        vc=[[LockViewController alloc]init];

        [vc WillEnterForeground];
    });
    return vc;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(WillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];

}
-(void)WillEnterForeground{
    if (!self.isPresent) {
        [[self getCurrentVC] presentViewController:self animated:NO completion:^{
            self.isPresent=YES;
        }];
    }
    [self showTouchId:@"使用密码"];
}
-(void)didEnterBackground{
    if (!self.isPresent) {
        [[self getCurrentVC] presentViewController:self animated:NO completion:^{
            self.isPresent=YES;
        }];
    }
}
-(void)showTouchId:(NSString*)str{
    if (self.alert.isPresent) {
        return;
    }
    LAContext *context = [[LAContext alloc] init];
    // 当指纹识别失败一次后，弹框会多出一个选项，而这个属性就是用来设置那个选项的内容
    context.localizedFallbackTitle = str;
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) { // 该设备支持指纹识别
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"身份验证需要解锁指纹识别功能" reply:^(BOOL success, NSError * _Nullable error) {
            NSLog(@"%d",[NSThread isMainThread]);
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (success) {  // 验证成功
                    [self dismissViewControllerAnimated:NO completion:^{
                        self.isPresent=NO;
                    }];
                }else {
                    NSLog(@"%@", error.localizedDescription);
                    switch (error.code) {
                        case LAErrorSystemCancel:
                            NSLog(@"身份验证被系统取消（验证时当前APP被移至后台或者点击了home键导致验证退出时提示）");
                            [self createAlert:@"输入密码" message:@"指纹识别失败,请输入密码"];
                            break;
                        case LAErrorUserCancel:
                            NSLog(@"身份验证被用户取消（当用户点击取消按钮时提示）");
                            [self createAlert:@"输入密码" message:@"请输入密码"];
                            //取消
                            break;
                        case LAErrorAuthenticationFailed:
                            NSLog(@"身份验证没有成功，因为用户未能提供有效的凭据(连续3次验证失败时提示)");
                            //三次失败
                            [self createAlert:@"输入密码" message:@"指纹识别失败,请输入密码"];
                            
                            break;
                        case LAErrorPasscodeNotSet:
                            NSLog(@"Touch ID无法启动，因为没有设置密码（当系统没有设置密码的时候，Touch ID也将不会开启）");
                            [self createAlert:@"输入密码" message:@"系统没有设置密码，指纹识别不可用,请输入密码"];
                            break;
                            //                        case LAErrorTouchIDNotAvailable:
                            //                            NSLog(@"无法启动身份验证");  // 这个没有检测到，应该是出现硬件损坏才会出现
                            //                            break;
                            //                        case LAErrorTouchIDNotEnrolled:
                            //                            NSLog(@"无法启动身份验证，因为触摸标识没有注册的手指");  // 这个暂时没检测到
                            //                            break;
                        case LAErrorTouchIDLockout:
                            NSLog(@"5次失败进入,如果继续验证，则需要输入密码解锁");
                            [self createAlert:@"输入密码" message:@"指纹识别失败,请输入密码"];
                            break;
                        case LAErrorUserFallback:
                            NSLog(@"用户选择输入密码，切换主线程处理");
                            [self createAlert:@"输入密码" message:@"请输入密码"];
                            break;
                        default:
                        {
                            [self createAlert:@"输入密码" message:@"指纹识别失败,请输入密码"];
                            break;
                        }
                    }
                }
            }];
        }];
    }else {
        [self createAlert:@"输入密码" message:@"指纹识别不可用,请输入密码"];
    }
}
-(void)createAlert:(NSString*)title message:(NSString*)message{
    AlertViewController* alert=[AlertViewController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder=@"请输入密码";
        textField.secureTextEntry=YES;
        textField.textAlignment=NSTextAlignmentCenter;
        textField.clearButtonMode=UITextFieldViewModeWhileEditing;
    }];
    UIAlertAction* action=[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField* textField=(UITextField*)alert.textFields.firstObject;
        if ([[textField text] isEqualToString:@"112233"]) {
            [self dismissViewControllerAnimated:NO completion:^{
                self.isPresent=NO;
                
            }];
        }else{
            [self createAlert:@"输入密码" message:@"密码输入错误,重新输入"];
        }
    }];
    UIAlertAction* action2=[UIAlertAction actionWithTitle:@"指纹解锁" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showTouchId:@"使用密码"];
    }];
    [alert addAction:action2];
    [alert addAction:action];
    
    self.alert=alert;
    [self presentViewController:alert animated:YES completion:nil];
}

@end
