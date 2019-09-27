//
//  DefaultRequest.m
//  YBNetworkDemo
//
//  Created by 波儿菜 on 2019/4/9.
//  Copyright © 2019 波儿菜. All rights reserved.
//

#import "DefaultServerRequest.h"

@implementation DefaultServerRequest

#pragma mark - life cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        self.baseURI = @"http://japi.juhe.cn";
        
        [self.cacheHandler setShouldCacheBlock:^BOOL(YBNetworkResponse * _Nonnull response) {
            // 检查数据正确性，保证缓存有用的内容
            return YES;
        }];
    }
    return self;
}

#pragma mark - override

- (AFHTTPRequestSerializer *)requestSerializer {
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer new];
    serializer.timeoutInterval = 25;
    return serializer;
}

- (AFHTTPResponseSerializer *)responseSerializer {
    AFHTTPResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
    NSMutableSet *types = [NSMutableSet set];
    [types addObject:@"text/html"];
    [types addObject:@"text/plain"];
    [types addObject:@"application/json"];
    [types addObject:@"text/json"];
    [types addObject:@"text/javascript"];
    serializer.acceptableContentTypes = types;
    return serializer;
}

- (void)start {
    NSLog(@"发起请求：%@", self.requestIdentifier);
    [super start];
}

- (void)yb_redirection:(void (^)(YBRequestRedirection))redirection response:(YBNetworkResponse *)response {
    
    // 处理错误的状态码
    if (response.error) {
        YBResponseErrorType errorType;
        switch (response.error.code) {
            case NSURLErrorTimedOut:
                errorType = YBResponseErrorTypeTimedOut;
                break;
            case NSURLErrorCancelled:
                errorType = YBResponseErrorTypeCancelled;
                break;
            default:
                errorType = YBResponseErrorTypeNoNetwork;
                break;
        }
        response.errorType = errorType;
    }
    
    // 自定义重定向
    NSDictionary *responseDic = response.responseObject;
    if ([[NSString stringWithFormat:@"%@", responseDic[@"error_code"]] isEqualToString:@"2"]) {
        redirection(YBRequestRedirectionFailure);
        response.errorType = YBResponseErrorTypeServerError;
        return;
    }
    redirection(YBRequestRedirectionSuccess);
}

- (NSDictionary *)yb_preprocessParameter:(NSDictionary *)parameter {
    NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:parameter ?: @{}];
    tmp[@"test_deviceID"] = @"test250";  //给每一个请求，添加额外的参数
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
    
}

- (void)yb_preprocessFailureInMainThreadWithResponse:(YBNetworkResponse *)response {
    
}

@end
