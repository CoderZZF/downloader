//
//  XMGDownloader.m
//  XMGDownLoader
//
//  Created by zhangzhifu on 2017/4/5.
//  Copyright © 2017年 seemygo. All rights reserved.
//

#import "XMGDownloader.h"
#import "XMGFileTool.h"


#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
#define kTempPath NSTemporaryDirectory()

@interface XMGDownloader () <NSURLSessionDataDelegate>
{
    long long _tempSize;
    long long _totalSize;
}
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, copy) NSString *downloadedPath;
@property (nonatomic, copy) NSString *downloadingPath;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, weak) NSURLSessionDataTask *dataTask;
@end


@implementation XMGDownloader

- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}


- (void)download:(NSURL *)url downloadInfo:(downloadInfoType)downloadInfo progress:(progressBlockType)progressBlock success:(successBlockType)successBlock faildedBlock:(failedBlockType)failedBlock {
    // 1. 给所有的block赋值.
    self.downloadInfo = downloadInfo;
    self.progressChange = progressBlock;
    self.successBlock = successBlock;
    self.failedBlock = failedBlock;
    
    // 2. 开始下载
    [self download:url];
}

- (void)download:(NSURL *)url {
    
    // 内部实现连个功能:1.还没开始下载,下载;2.暂停状态,继续下载.
    if ([url isEqual:self.dataTask.originalRequest.URL]) {
        if (self.state == XMGDownLoadStatePause) {
            [self resumeCurrentTask];
            return;
        }
    }
    
    // 两种可能:1.任务是不存在的 2.任务存在,但是任务的url地址不同.
    [self cancelCurrentTask];

    NSString *fileName = url.lastPathComponent;
    self.downloadedPath = [kCachePath stringByAppendingPathComponent:fileName];
    self.downloadingPath = [kTempPath stringByAppendingPathComponent:fileName];
    
    // 1. 判断url地址对应的资源已经下载完毕了(下载完成的目录里面存在这个文件)
    // 1.1 告诉外界下载完毕,并且传递相关信息(本地的路径,文件的大小),return
    if ([XMGFileTool fileExists:self.downloadedPath]) {
        // UNDO: 告诉外界已经下载完成了.
//        NSLog(@"已经下载完成了");
        
        self.state = XMGDownLoadStatePauseSuccess;
        
        return;
    }
    
    
    // 2. 检测临时文件是否存在
    // 2.1 不存在:从0开始下载,return
    if (![XMGFileTool fileExists:self.downloadingPath]) {
        // 从0开始下载
        [self downloadWithURL:url offset:0];
        return;
    }
    
 
    // 获取本地大小
    _tempSize = [XMGFileTool fileSize:self.downloadingPath];
    [self downloadWithURL:url offset:_tempSize];
}


- (void)pauseCurrentTask {
    if (self.state == XMGDownLoadStateDownLoading) {
        self.state = XMGDownLoadStatePause;
        [self.dataTask suspend];
    }
}

- (void)resumeCurrentTask {
    if (self.dataTask && self.state == XMGDownLoadStatePause) {
        [self.dataTask resume];
        self.state = XMGDownLoadStateDownLoading;
    }
}

- (void)cancelCurrentTask {
    self.state = XMGDownLoadStatePause;
    [self.session invalidateAndCancel];
    self.session = nil;
}

- (void)cancelAndClean {
    [self cancelCurrentTask];
    [XMGFileTool removeFile:self.downloadingPath];
    // 删除下载完成的文件的场景:手动删除声音的时候,统一清理缓存
}


#pragma mark - 协议方法
// 第一次接收到响应时
// 通过这个方法系统提供的代码块,可以控制继续请求还是取消本次请求
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    _totalSize = [response.allHeaderFields[@"Content-Length"] longLongValue];
    NSString *contentRangeStr = response.allHeaderFields[@"Content-Range"];
    if (contentRangeStr.length != 0) {
        _totalSize = [[[contentRangeStr componentsSeparatedByString:@"/"] lastObject] longLongValue];
    }
    
    // 传递给外界信息: 总大小&本地存储的文件路径
    if (self.downloadInfo != nil) {
        self.downloadInfo(_totalSize);
    }
    
    // 比对本地大小,总大小
    if (_tempSize == _totalSize) {
        // 1. 移动到下载完成文件夹
//        NSLog(@"移动文件到下载完成文件夹");
        [XMGFileTool moveFile:self.downloadingPath toPath: self.downloadedPath];
        
        // 2. 取消本次请求
        completionHandler(NSURLSessionResponseCancel);
        
        // 3. 修改状态
        self.state = XMGDownLoadStatePauseSuccess;
        
        return;
    }
    
    if (_tempSize > _totalSize) {
        // 1. 删除临时缓存
//        NSLog(@"删除临时缓存");
        [XMGFileTool removeFile:self.downloadingPath];
        
        // 2. 取消请求
        completionHandler(NSURLSessionResponseCancel);
        
        // 3. 重新开始下载
//        NSLog(@"重新开始下载");
        [self download:response.URL];
        
        return;
    }
    
    self.state = XMGDownLoadStateDownLoading;
    
    // 继续接受数据
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:self.downloadingPath append:YES];
    [self.outputStream open];
    completionHandler(NSURLSessionResponseAllow);
}


// 开始接收数据
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    // 这就是当前已经下载的大小
    _tempSize += data.length;
    
    self.progress = 1.0 * _tempSize / _totalSize;
    
    // 往输出流中写入数据
    [self.outputStream write:data.bytes maxLength:data.length];
}


// 请求完成
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
//    NSLog(@"请求完成");
    
    if (error == nil) {
        // 不一定是成功
        // 数据肯定是可以请求完毕
        // 判断本地缓存 == 文件总大小
        // 如果等于,验证文件是否完整
        
        [XMGFileTool moveFile:self.downloadingPath toPath:self.downloadedPath];
        self.state = XMGDownLoadStatePauseSuccess;
        
    } else {
//        NSLog(@"有问题 - %zd - %@", error.code, error.localizedDescription);
        
        if (error.code == -999) {
            self.state = XMGDownLoadStatePause;
        } else {
            self.state = XMGDownLoadStatePauseFailed;
            [self.outputStream close];
        }
    }
}


#pragma mark - 事件/数据传递
- (void)setState:(XMGDownLoadState)state {
    if (_state == state) {
        return;
    }
    _state = state;
    
    // 代理,block,通知
    if (self.stateChangeInfo) {
        self.stateChangeInfo(_state);
    }
    
    if (_state == XMGDownLoadStatePauseSuccess && self.successBlock) {
        self.successBlock(self.downloadedPath);
    }
    
    if (_state == XMGDownLoadStatePauseFailed && self.failedBlock) {
        self.failedBlock();
    }
}


- (void)setProgress:(float)progress {
    _progress = progress;
    
    if (self.progressChange) {
        self.progressChange(progress);
    }
}

#pragma mark - 私有方法
/**
 根据开始字节去请求资源
 @param url url
 @param offset offset
 */
- (void)downloadWithURL:(NSURL *)url offset:(long long)offset {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0];
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-", offset] forHTTPHeaderField:@"Range"];
    
    // session分配的任务默认情况下是挂起状态
    self.dataTask = [self.session dataTaskWithRequest:request];
    [self resumeCurrentTask];
}

@end
