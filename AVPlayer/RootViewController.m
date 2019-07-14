//
//  RootViewController.m
//  AVPlayer
//
//  Created by zcw on 16/10/14.
//  Copyright © 2016年 zhcw. All rights reserved.
//

#import "RootViewController.h"
#import "ViewController.h"
#define NetVideo @"NetVideo"
#define UserDefaults [NSUserDefaults standardUserDefaults]
@interface RootViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView* tableView;
@property(nonatomic,strong)NSMutableArray* dataArr;
@end

@implementation RootViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArr=[NSMutableArray array];
    UIBarButtonItem* item=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(rightAddItemBtn)];
    self.navigationItem.rightBarButtonItem=item;

    self.navigationItem.title=@"本地视频";
    [self createTableView];
}
-(void)rightAddItemBtn{
    [self initDataArr];
}
-(void)initDataArr{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString* documentDir=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSFileManager* fileManager=[NSFileManager defaultManager];
        NSError *error;
        //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
        NSArray *fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:&error];
        NSMutableArray *dirArray = [[NSMutableArray alloc] init];
        BOOL isDir;
        //在上面那段程序中获得的fileList中列出文件夹名
        for (NSString *file in fileList){
            NSString *path = [documentDir stringByAppendingPathComponent:file];
            [fileManager fileExistsAtPath:path isDirectory:(&isDir)];
            if (!isDir){
                [dirArray addObject:file];
            }
            isDir = YES;
        }
        _dataArr=dirArray;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
        });
    });

}
-(void)createTableView{
    _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_tableView];
    
    [self initDataArr];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* identifity=@"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifity];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifity];
    }
    cell.textLabel.text=_dataArr[indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ViewController* vc=[[ViewController alloc]init];
    vc.fileName=_dataArr[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString* fileName=_dataArr[indexPath.row];
            NSString* path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:fileName];
            NSFileManager* fileManager=[NSFileManager defaultManager];
            NSError* error=nil;
            BOOL success = [fileManager removeItemAtPath:path error:&error];
            if (success) {
                [_dataArr removeObjectAtIndex:indexPath.row];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                });
            }
        });
    }
}
@end
