//
//  ViewController.m
//  XMGDownLoader
//
//  Created by zhangzhifu on 2017/4/5.
//  Copyright © 2017年 seemygo. All rights reserved.
//

#import "ViewController.h"
#import "XMGDownloaderManager.h"

@interface ViewController ()
//@property (nonatomic, strong) XMGDownloader *downloader;
@property (nonatomic, weak) NSTimer *timer;
@end

@implementation ViewController

- (NSTimer *)timer {
    if (!_timer) {
        NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(update) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        _timer = timer;
    }
    return _timer;
}

//- (XMGDownloader *)downloader {
//    if (_downloader == nil) {
//        _downloader = [XMGDownloader new];
//    }
//    return _downloader;
//}

- (void)viewDidLoad {
    [super viewDidLoad];

//    [self timer];
}


- (IBAction)download {
    NSURL *url = [NSURL URLWithString:@"http://m4.pc6.com/xuh3/Snipmac205771.dmg"];
    
    NSURL *url1 = [NSURL URLWithString:@"http://m5.pc6.com/xuh5/snapndrag424.dmg"];
    
    [[XMGDownloaderManager sharedInstance] download:url downloadInfo:^(long long totalSize) {
        NSLog(@"下载信息 - %lld", totalSize);
    } progress:^(float progress) {
        NSLog(@"下载进度 - %f", progress);
    } success:^(NSString *filePath) {
        NSLog(@"下载成功 - 路径:%@", filePath);
    } faildedBlock:^{
        NSLog(@"下载失败");
    }];
    
    [[XMGDownloaderManager sharedInstance] download:url1 downloadInfo:^(long long totalSize) {
        NSLog(@"下载信息 - %lld", totalSize);
    } progress:^(float progress) {
        NSLog(@"下载进度 - %f", progress);
    } success:^(NSString *filePath) {
        NSLog(@"下载成功 - 路径:%@", filePath);
    } faildedBlock:^{
        NSLog(@"下载失败");
    }];
    
    //    [self.downloader setStateChangeInfo:^(XMGDownLoadState state) {
    //        NSLog(@"%zd", state);
    //    }];
}

- (IBAction)suspend {
//    [self.downloader pauseCurrentTask];
}

- (IBAction)cancel {
//    [self.downloader cancelCurrentTask];
}

- (IBAction)cancelAndClean {
//    [self.downloader cancelAndClean];
}

- (void)update {
//    NSLog(@"%zd",self.downloader.state);
}
@end
