# YBNetwork

基于 AFNetworking 二次封装，调用方便，设计简洁，易于拓展。
(暂时没有支持 cocopods)

设计原理博客：[谈谈 iOS 网络层设计](https://www.jianshu.com/p/fe0dd50d0af1)

参考思路：[iOS应用架构谈 网络层设计方案](https://casatwy.com/iosying-yong-jia-gou-tan-wang-luo-ceng-she-ji-fang-an.html)
参考源码：[YTKNetwork](https://github.com/yuantiku/YTKNetwork) [CTNetworking](https://github.com/casatwy/CTNetworking)


## 特性

- 支持缓存写入模式、读取模式、有效时长等自定义配置 (同时享有来着 YYCache 的优越性能)
- 支持发起请求和响应回调的预处理
- 重复请求处理策略选择
- 网络请求释放策略选择
- 支持 Block 和 Delegate 回调方式
- 代码层级简单，便于功能拓展


## 安装

1. 下载 YBNetwork 文件夹所有内容并且拖入你的工程中。
2. 链接以下 frameworks：
* AFNetworking 
* YYCache

## 用法

可下载 DEMO 查看示例。

### 基本使用

#### 1、第一步
创建子类继承自`YBBaseRequest`，并且在构造方法中初始化一些通用的配置 (比如服务器地址、解析器)
```
@interface DefaultServerRequest : YBBaseRequest
@end

@implementation DefaultServerRequest
- (instancetype)init {
    self = [super init];
    if (self) {
        self.baseURI = @"https://www.baidu.com";
        self.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.requestSerializer.timeoutInterval = 30;
        self.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return self;
}
@end
```
如果项目接口来自不同的接口团队（往往通用配置不同），那么就为每一个接口团队子类化一个`YBBaseRequest`，然后分别配置通用配置。

#### 2、第二步
创建具体接口配置，有两种方式，一种是直接实例化`DefaultServerRequest`，一种是继续子类化`DefaultServerRequest`:
```
//直接实例化
DefaultServerRequest *request = [DefaultServerRequest new];
request.requestMethod = YBRequestMethodGET;
request.requestURI = @"...";
request.requestParameter = @{...};
```
```
//继续子类化
@interface SearchWeatherRequest : DefaultServerRequest
@end
@implementation SearchWeatherRequest
- (YBRequestMethod)requestMethod {
    return YBRequestMethodGET;
}
- (NSString *)requestURI {
    return @"...";
}
- (NSDictionary *)requestParameter {
    return @{...};
}
@end
```

#### 3、第三步
发起网络请求，设置回调：
```
//Block
__weak typeof(self) weakSelf = self;
[request startWithSuccess:^(YBNetworkResponse * _Nonnull response) {
    __strong typeof(weakSelf) self = weakSelf;
    if (!self) return;
} failure:^(YBNetworkResponse * _Nonnull response) {
    __strong typeof(weakSelf) self = weakSelf;
    if (!self) return;
}];

//Delegate
request.delegate = self; //代理方法回调结果
[request start];
```
目前的内部实现是，若有重复的网络请求发起，将只回调最新的 Block，而 Delegate 方式会每次都回调。

注意：虽然 Block 方式就算不弱引用`self`也不会循环引用 (内部会回调完成后破除循环)，但是为了避免延长`self`的生命周期，强烈建议使用弱引用，不然可能会导致网络请求释放策略失效。如果你是主导者，那么可以规定必须使用 Delegate 方式回调，从源头上避免延长网络响应接受者生命周期。


### 请求和响应预处理
往往我们需要为所有请求参数添加一些字段，比如设备ID，用户ID。
只需要在一级子类`DefaultServerRequest`中重载父类方法就行了：
```
@implementation DefaultServerRequest
...
//请求预处理
- (NSDictionary *)yb_preprocessParameter:(NSDictionary *)parameter {
    //预处理所有请求参数
}
- (NSString *)yb_preprocessURLString:(NSString *)URLString {
    //预处理所有请求URL字符串
}
//请求响应预处理
- (void)yb_preprocessSuccessInChildThreadWithResponse:(YBNetworkResponse *)response {
    //预处理请求成功
}
- (void)yb_preprocessSuccessInMainThreadWithResponse:(YBNetworkResponse *)response {
    //预处理请求成功
}
- (void)yb_preprocessFailureInChildThreadWithResponse:(YBNetworkResponse *)response {
    //预处理请求失败
}
- (void)yb_preprocessFailureInMainThreadWithResponse:(YBNetworkResponse *)response {
    //预处理请求失败
}
@end
```


### 缓存处理

缓存处理配置都在`request.cacheHandler`变量`YBNetworkCache`类中，支持以下配置：
- 内存/磁盘存储方式
- 缓存命中后是否继续发起网络请求
- 缓存的有效时长
- 定制缓存的 key
- 根据请求响应成功数据判断是否需要缓存（比如仅当 code=0 时数据有效允许缓存）
- 以及直接配置 YYCache

缓存命中提供了 Block 和代理方法的回调，一定要根据业务合理选择缓存机制，谨慎使用。


### 重复网络请求处理策略

`request.repeatStrategy`变量配置，三种策略：
1. 允许重复网络请求
2. 取消最旧的网络请求
3. 取消最新的网络请求

举几个例子，当接口数据并不会在短时间变化时，重复发起网络请求就会浪费网络资源，可以选择方案 2 或 3；比如在搜索业务中，用户往往频繁的调用搜索接口，而发起一次搜索时，之前的搜索请求一般是没有意义了，就可以选用方案 2。


### 网络请求释放策略
`request.releaseStrategy`变量配置，有几种方式可以选择：
1. 网络任务会持有 YBBaseRequest 实例，网络任务完成 YBBaseRequest 实例才会释放
2. 网络请求将随着 YBBaseRequest 实例的释放而取消
3. 网络请求和 YBBaseRequest 实例无关联

举几个例子，若你的控制器出栈以后希望取消未落地的网络请求，那么就使用方案 2，注意管理好`YBBaseRequest`的生命周期就行了；若你的网络请求是不论如何都不希望它取消的，那么使用方案 3；若你希望网络请求任务始终持有 YBBaseRequest 实例避免它提前释放，那么使用方案 1。




