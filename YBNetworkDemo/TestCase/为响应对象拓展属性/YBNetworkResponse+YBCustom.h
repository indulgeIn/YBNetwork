//
//  YBNetworkResponse+YBCustom.h
//  YBNetworkDemo
//
//  Created by 波儿菜 on 2019/9/27.
//  Copyright © 2019 杨波. All rights reserved.
//

#import "YBNetworkResponse.h"

NS_ASSUME_NONNULL_BEGIN

/// 网络响应错误类型
typedef NS_ENUM(NSInteger, YBResponseErrorType) {
    /// 未知
    YBResponseErrorTypeUnknown,
    /// 超时
    YBResponseErrorTypeTimedOut,
    /// 取消
    YBResponseErrorTypeCancelled,
    /// 无网络
    YBResponseErrorTypeNoNetwork,
    /// 服务器错误
    YBResponseErrorTypeServerError,
    /// 登录状态过期
    YBResponseErrorTypeLoginExpired
};

@interface YBNetworkResponse (YBCustom)

/// 请求失败类型 (使用该属性做业务处理足够)
@property (nonatomic, assign) YBResponseErrorType errorType;

@end

NS_ASSUME_NONNULL_END
