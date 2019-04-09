//
//  DefaultRequest.m
//  YBNetworkDemo
//
//  Created by 杨波 on 2019/4/9.
//  Copyright © 2019 杨波. All rights reserved.
//

#import "DefaultServerRequest.h"

@implementation DefaultServerRequest

#pragma mark - life cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.baseURI = @"https://www.apiopen.top";
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.requestSerializer.timeoutInterval = 25;
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [self.cacheHandler setShouldCacheBlock:^BOOL(YBNetworkResponse * _Nonnull response) {
            // 检查数据正确性，保证缓存有用的内容
            return YES;
        }];
    }
    return self;
}

#pragma mark - ovveride

- (NSDictionary *)yb_preprocessParameter:(NSDictionary *)parameter {
    NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:parameter ?: @{}];
    tmp[@"deviceID"] = @"test250";  //给每一个请求，添加额外的参数
    return tmp;
}

- (NSString *)yb_preprocessURLString:(NSString *)URLString {
    return URLString;
}

- (void)yb_preprocessSuccessInChildThreadWithResponse:(YBNetworkResponse *)response {
    NSMutableDictionary *res = [NSMutableDictionary dictionaryWithDictionary:response.responseObject];
    res[@"test_user"] = @"indulge_in"; //为每一个返回结果添加字段
    response.responseObject = res;
}

- (void)yb_preprocessSuccessInMainThreadWithResponse:(YBNetworkResponse *)response {
    
}

- (void)yb_preprocessFailureInChildThreadWithResponse:(YBNetworkResponse *)response {
    if (response.errorType == YBResponseErrorTypeCancelled) {
        NSLog(@"取消网络请求"); //打印每一个取消错误
    }
}

- (void)yb_preprocessFailureInMainThreadWithResponse:(YBNetworkResponse *)response {
    
}

@end
