//
//  YBNetworkResponse.m
//  YBNetwork<https://github.com/indulgeIn/YBNetwork>
//
//  Created by 波儿菜 on 2019/4/6.
//  Copyright © 2019 波儿菜. All rights reserved.
//

#import "YBNetworkResponse.h"

@implementation YBNetworkResponse

#pragma mark - life cycle

+ (instancetype)responseWithSessionTask:(NSURLSessionTask *)sessionTask responseObject:(id)responseObject error:(NSError *)error {
    YBNetworkResponse *response = [YBNetworkResponse new];
    response->_sessionTask = sessionTask;
    response->_responseObject = responseObject;
    response->_error = error;
    return response;
}

#pragma mark - getter

- (NSHTTPURLResponse *)URLResponse {
    if (!self.sessionTask || ![self.sessionTask.response isKindOfClass:NSHTTPURLResponse.class]) {
        return nil;
    }
    return (NSHTTPURLResponse *)self.sessionTask.response;
}

@end
