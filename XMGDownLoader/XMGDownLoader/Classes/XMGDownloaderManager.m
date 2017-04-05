//
//  XMGDownloaderManager.m
//  XMGDownLoader
//
//  Created by zhangzhifu on 2017/4/5.
//  Copyright © 2017年 seemygo. All rights reserved.
//

#import "XMGDownloaderManager.h"
#import "NSString+ZZF.h"

@interface XMGDownloaderManager ()
//@property (nonatomic, strong) XMGDownloader *downloader;
@property (nonatomic, strong) NSMutableDictionary *downloadInfo;
@end

@implementation XMGDownloaderManager

#pragma mark - 单例
static XMGDownloaderManager *_sharedInstance;
+ (instancetype)sharedInstance {
    if (!_sharedInstance) {
        _sharedInstance = [[self alloc] init];
    }
    return _sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (!_sharedInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _sharedInstance = [super allocWithZone:zone];
        });
    }
    return _sharedInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return _sharedInstance;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _sharedInstance;
}


// key: url的md5值 value: XMGDownloader
- (NSMutableDictionary *)downloadInfo {
    if (!_downloadInfo) {
        _downloadInfo = [NSMutableDictionary dictionary];
    }
    return _downloadInfo;
}


- (void)download:(NSURL *)url downloadInfo:(downloadInfoType)downloadInfo progress:(progressBlockType)progressBlock success:(successBlockType)successBlock faildedBlock:(failedBlockType)failedBlock {
    
    // 1. url
    NSString *urlMD5 = [url.absoluteString md5];
    
    // 2. 根据urlMD5查找相应的下载器
    XMGDownloader *downloader = self.downloadInfo[urlMD5];
    if (downloader == nil) {
        downloader = [[XMGDownloader alloc] init];
        self.downloadInfo[urlMD5] = downloader;
    }
    
    [downloader download:url downloadInfo:downloadInfo progress:progressBlock success:^(NSString *filePath) {
        
        // 下载完成后移除下载器
        [self.downloadInfo removeObjectForKey:urlMD5];
        
        successBlock(filePath);
    }faildedBlock: failedBlock];
}



- (void)pauseWithURL:(NSURL *)url {
    NSString *urlMD5 = [url.absoluteString md5];
    
    XMGDownloader *downloader = self.downloadInfo[urlMD5];
    [downloader pauseCurrentTask];
}

- (void)resumeWithURL:(NSURL *)url {
    NSString *urlMD5 = [url.absoluteString md5];
    
    XMGDownloader *downloader = self.downloadInfo[urlMD5];
    [downloader resumeCurrentTask];
}

- (void)cancelWithURL:(NSURL *)url {
    NSString *urlMD5 = [url.absoluteString md5];
    
    XMGDownloader *downloader = self.downloadInfo[urlMD5];
    [downloader cancelCurrentTask];
}

- (void)pauseAll {
    [self.downloadInfo.allValues performSelector:@selector(pauseCurrentTask) withObject:nil];
}

- (void)resumeAll {
    [self.downloadInfo.allValues performSelector:@selector(resumeCurrentTask) withObject:nil];
}


@end
