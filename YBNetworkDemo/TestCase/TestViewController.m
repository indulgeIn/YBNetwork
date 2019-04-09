//
//  TestViewController.m
//  YBNetworkDemo
//
//  Created by 杨波 on 2019/4/9.
//  Copyright © 2019 杨波. All rights reserved.
//

#import "TestViewController.h"
#import "DefaultServerRequest.h"

@interface TestViewController () <YBResponseDelegate>
@property (nonatomic, strong) DefaultServerRequest *request;
@end

@implementation TestViewController

#pragma mark - life cycle

- (void)dealloc {
    NSLog(@"释放：%@", self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [@[@"搜索小说", @"搜索天气"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.bounds = CGRectMake(0, 0, 300, 100);
        button.center = CGPointMake(self.view.center.x, 200 + 100 * (idx + 1));
        button.tag = idx;
        button.titleLabel.font = [UIFont boldSystemFontOfSize:30];
        [button setTitle:obj forState:UIControlStateNormal];
        [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }];
}

#pragma mark - event

- (void)clickButton:(UIButton *)button {
    if (button.tag == 0) {
        [self searchNovel];
    } else {
        [self searchWeather];
    }
}

#pragma mark - request

- (void)searchNovel {
    
    DefaultServerRequest *request = [DefaultServerRequest new];
    request.requestMethod = YBRequestMethodGET;
    request.requestURI = @"novelSearchApi";
    request.requestParameter = @{@"name":@"盗墓笔记"};
    
    __weak typeof(self) weakSelf = self;
    [request startWithSuccess:^(YBNetworkResponse * _Nonnull response) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        NSLog(@"response success : \n%@", response.responseObject);
    } failure:^(YBNetworkResponse * _Nonnull response) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        NSLog(@"response failure : \n错误类型 : %@", @(response.errorType));
    }];
}

- (void)searchWeather {
    [self.request start];
}

#pragma mark - <YBResponseDelegate>

- (void)request:(__kindof YBBaseRequest *)request successWithResponse:(YBNetworkResponse *)response {
    NSLog(@"response success : \n%@", response.responseObject);
}

- (void)request:(__kindof YBBaseRequest *)request failureWithResponse:(YBNetworkResponse *)response {
    NSLog(@"response failure : \n错误类型 : %@", @(response.errorType));
}

#pragma mark - getter

- (DefaultServerRequest *)request {
    if (!_request) {
        _request = [DefaultServerRequest new];
        _request.delegate = self;
        _request.requestMethod = YBRequestMethodGET;
        _request.requestURI = @"weatherApi";
        _request.requestParameter = @{@"city":@"北京"};
    }
    return _request;
}

@end
