//
//  YBNetworkResponse+YBCustom.m
//  YBNetworkDemo
//
//  Created by 波儿菜 on 2019/9/27.
//  Copyright © 2019 杨波. All rights reserved.
//

#import "YBNetworkResponse+YBCustom.h"
#import <objc/runtime.h>

@implementation YBNetworkResponse (YBCustom)

static void const *YBNetworkResponseErrorTypeKey = &YBNetworkResponseErrorTypeKey;
- (void)setErrorType:(YBResponseErrorType)errorType {
    objc_setAssociatedObject(self, YBNetworkResponseErrorTypeKey, @(errorType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (YBResponseErrorType)errorType {
    NSNumber *tmp = objc_getAssociatedObject(self, YBNetworkResponseErrorTypeKey);
    return tmp.integerValue;
}

@end
