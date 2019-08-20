//
//  YBBaseRequest+Internal.h
//  YBNetwork<https://github.com/indulgeIn/YBNetwork>
//
//  Created by 波儿菜 on 2019/4/3.
//  Copyright © 2019 波儿菜. All rights reserved.
//

#import "YBBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface YBBaseRequest ()

/// 请求方法字符串
- (NSString *)requestMethodString;

/// 请求 URL 字符串
- (NSString *)validRequestURLString;

/// 请求参数字符串
- (id)validRequestParameter;

@end

NS_ASSUME_NONNULL_END
