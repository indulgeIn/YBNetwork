//
//  YBNetworkResponse.h
//  YBNetwork<https://github.com/indulgeIn/YBNetwork>
//
//  Created by 波儿菜 on 2019/4/6.
//  Copyright © 2019 波儿菜. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YBNetworkDefine.h"

NS_ASSUME_NONNULL_BEGIN

/**
 网络请求响应对象
 如果想拓展一些属性，使用 runtime 关联属性，然后重写预处理方法进行计算并赋值就行了。
 */
@interface YBNetworkResponse : NSObject

/// 请求成功数据
@property (nonatomic, strong, nullable) id responseObject;

/// 请求失败 NSError
@property (nonatomic, strong, readonly, nullable) NSError *error;

/// 请求任务
@property (nonatomic, strong, readonly, nullable) NSURLSessionTask *sessionTask;

/// sessionTask.response
@property (nonatomic, strong, readonly, nullable) NSHTTPURLResponse *URLResponse;

/// 便利构造
+ (instancetype)responseWithSessionTask:(nullable NSURLSessionTask *)sessionTask
                         responseObject:(nullable id)responseObject
                                  error:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
