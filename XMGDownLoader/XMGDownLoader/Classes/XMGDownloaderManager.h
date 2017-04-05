//
//  XMGDownloaderManager.h
//  XMGDownLoader
//
//  Created by zhangzhifu on 2017/4/5.
//  Copyright © 2017年 seemygo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMGDownloader.h"

@interface XMGDownloaderManager : NSObject

+ (instancetype)sharedInstance;

- (void)download:(NSURL *)url downloadInfo:(downloadInfoType)downloadInfo progress:(progressBlockType)progressBlock success:(successBlockType)successBlock faildedBlock:(failedBlockType)failedBlock;

- (void)pauseWithURL:(NSURL *)url;
- (void)resumeWithURL:(NSURL *)url;
- (void)cancelWithURL:(NSURL *)url;

- (void)pauseAll;
- (void)resumeAll;
@end
