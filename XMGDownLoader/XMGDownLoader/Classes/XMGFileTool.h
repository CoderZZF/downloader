//
//  XMGFileTool.h
//  XMGDownLoader
//
//  Created by zhangzhifu on 2017/4/5.
//  Copyright © 2017年 seemygo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMGFileTool : NSObject

+ (BOOL)fileExists:(NSString *)filePath;

+ (long long)fileSize:(NSString *)filePath;

+ (void)moveFile:(NSString *)fromPath toPath:(NSString *)toPath;

+ (void)removeFile:(NSString *)filePath;
@end
