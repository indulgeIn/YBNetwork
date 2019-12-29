# YBNetwork

[![Cocoapods](https://img.shields.io/cocoapods/v/YBNetwork.svg)](https://cocoapods.org/pods/YBNetwork)&nbsp;
[![Cocoapods](https://img.shields.io/cocoapods/p/YBNetwork.svg)](https://github.com/indulgeIn/YBNetwork)&nbsp;
[![License](https://img.shields.io/github/license/indulgeIn/YBNetwork.svg)](https://github.com/indulgeIn/YBNetwork)&nbsp;

基于 AFNetworking 二次封装，功能细致易拓展。

设计原理博客：[谈谈 iOS 网络层设计](https://www.jianshu.com/p/fe0dd50d0af1)

参考思路：[iOS应用架构谈 网络层设计方案](https://casatwy.com/iosying-yong-jia-gou-tan-wang-luo-ceng-she-ji-fang-an.html)
<br>参考源码：[YTKNetwork](https://github.com/yuantiku/YTKNetwork) [CTNetworking](https://github.com/casatwy/CTNetworking)


## 特性

- 支持缓存写入模式、读取模式、有效时长等自定义配置 (同时享有来着 YYCache 的优越性能)
- 支持网络落地重定向
- 支持发起请求和响应回调的预处理
- 支持网络落地异步重定向
- 重复请求处理策略选择
- 网络请求释放策略选择
- 支持 Block 和 Delegate 回调方式
- 代码层级简单，便于功能拓展


## 安装

### CocoaPods

1. 在 Podfile 中添加 `pod 'YBNetwork'`。
2. 执行 `pod install` 或 `pod update`。

若搜索不到库，可使用 rm ~/Library/Caches/CocoaPods/search_index.json 移除本地索引然后再执行安装，或者更新一下 CocoaPods 版本。

### 手动导入

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
    }
    return self;
}
- (AFHTTPRequestSerializer *)requestSerializer {...}
- (AFHTTPResponseSerializer *)responseSerializer {...}
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
...
@end
```


### 重定向

网络落地重定向使用此方法：
```
- (void)yb_redirection:(void (^)(YBRequestRedirection))redirection response:(YBNetworkResponse *)response {
    // 同步或异步的做一些事情
    redirection(YBRequestRedirectionSuccess);
}
```
使用`redirection`闭包来达到可异步重定向的能力，在这之间可以做一些具体网络接口无感知的逻辑。


### 为响应对象添加属性

`YBNetworkResponse` 包含必要的响应数据，可以添加额外属性，在网络响应预处理时为这些属性赋值，那么具体接口调用方就可以很方便的拿到这些处理后的值了。建议创建一个`YBNetworkResponse`的分类，使用 Runtime 的关联属性来拓展。


### 缓存处理

缓存处理配置都在`request.cacheHandler`变量`YBNetworkCache`类中，支持以下配置：
- 内存/磁盘存储方式
- 缓存命中后是否继续发起网络请求
- 缓存的有效时长
- 定制缓存的 key
- 直接配置 YYCache

##### 缓存有效性验证

内部会在业务处理完成网络响应数据后尝试进行缓存，且提供一个`shouldCacheBlock`可根据请求响应成功数据判断是否需要缓存（比如仅当 `code == 0` 时数据有效允许缓存）。


### 重复网络请求处理策略

`request.repeatStrategy`变量配置，三种策略：
- 允许重复网络请求
- 取消最旧的网络请求
- 取消最新的网络请求

举几个例子，当接口数据并不会在短时间变化时，重复发起网络请求就会浪费网络资源，可以选择方案 2 或 3；比如在搜索业务中，用户往往频繁的调用搜索接口，而发起一次搜索时，之前的搜索请求一般是没有意义了，就可以选用方案 2。


### 网络请求释放策略
`request.releaseStrategy`变量配置，有几种方式可以选择：
- 网络任务会持有 YBBaseRequest 实例，网络任务完成 YBBaseRequest 实例才会释放
- 网络请求将随着 YBBaseRequest 实例的释放而取消
- 网络请求和 YBBaseRequest 实例无关联

举几个例子，若你的控制器出栈以后希望取消未落地的网络请求，那么就使用方案 2，注意管理好 YBBaseRequest 的生命周期就行了；若你的网络请求是不论如何都不希望它取消的，那么使用方案 3；若你希望网络请求任务始终持有 YBBaseRequest 实例避免它提前释放，那么使用方案 1。


## 业务使用 Tips

#### 1、使用 block 回调注意事项
- 外部变量和 block 相互强持有也没关系，在网络回调完成过后组件会断开循环引用。
- 尽量保证闭包内部捕获的变量是弱引用，避免延长被捕获变量的生命周期。

#### 2、使用 delegate 回调注意事项
当多个 request 的代理都是同一个对象时，需要通过返回的 request 判断具体网络请求；所以若使用代理回调建议外部应该持有这个 request 便于比较。

#### 3、重复请求
只需要持有 request，当对同一个 reqeust 多次进行 start 发起网络请求时，组件提供的几种重复请求策略便可以工作了。

#### 4、网络安全落地
若使用 block 方式回调并且 block 强持有了外部变量，那么在网络结束之前外部变量不会释放。弱外部变量在业务中已经不存在了（比如出栈了），那么此时回调会出现隐患（最常见的就是野指针）。

- 使用 block 回调时，最好做一下业务落脚点所有变量是否可用的判断（回调提取一个方法能减少判断，这时不如用 delegate 回调）。
- 使用 delegate 回调只需要保证代理者的可用性，所以比较安全。
- 在 request 未持有外部变量时，在外部变量 `dealloc` 时调用 request 的 `cancel` 方法可以取消网络请求，这样就不会有回调了，保证安全。
- 更便捷的方法是使用“网络请求将随着 request 实例的释放而取消”的策略（`request.releaseStrategy`），然后 reqeust 释放时网络请求将自动取消。


