//
//  XMGDownloader.h
//  XMGDownLoader
//
//  Created by zhangzhifu on 2017/4/5.
//  Copyright © 2017年 seemygo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, XMGDownLoadState) {
    XMGDownLoadStatePause,
    XMGDownLoadStateDownLoading,
    XMGDownLoadStatePauseSuccess,
    XMGDownLoadStatePauseFailed
};

typedef void(^downloadInfoType)(long long totalSize);
typedef void(^progressBlockType)(float progress);
typedef void(^successBlockType)(NSString *filePath);
typedef void(^failedBlockType)();
typedef void(^stateChangeType)(XMGDownLoadState state);

// 一个下载器对应一个下载任务
@interface XMGDownloader : NSObject

- (void)download:(NSURL *)url;
- (void)download:(NSURL *)url downloadInfo:(downloadInfoType)downloadInfo progress:(progressBlockType)progressBlock success:(successBlockType)successBlock faildedBlock:(failedBlockType)failedBlock;

- (void)pauseCurrentTask;
- (void)resumeCurrentTask;
- (void)cancelCurrentTask;
- (void)cancelAndClean;

// 数据
@property (nonatomic, assign, readonly) XMGDownLoadState state;
@property (nonatomic, assign, readonly) float progress;

// 事件
@property (nonatomic, copy) downloadInfoType downloadInfo;
@property (nonatomic, copy) stateChangeType stateChangeInfo;
@property (nonatomic, copy) progressBlockType progressChange;
@property (nonatomic, copy) successBlockType successBlock;
@property (nonatomic, copy) failedBlockType failedBlock;
@end









