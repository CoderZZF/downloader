//
//  NSString+ZZF.m
//  XMGDownLoader
//
//  Created by zhangzhifu on 2017/4/5.
//  Copyright © 2017年 seemygo. All rights reserved.
//

#import "NSString+ZZF.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (ZZF)

- (NSString *)md5 {
    // 作用: 把c语言字符串转成md5字符串
    const char *data = self.UTF8String;
    unsigned char md[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data, (CC_LONG)strlen(data), md);
    
    // 转成32位
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", md[i]];
    }
    
    return result;
}

@end
