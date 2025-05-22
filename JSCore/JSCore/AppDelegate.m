//
//  AppDelegate.m
//  JSCore
//
//  Created by Ledger Heath on 2025/5/22.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (nonatomic, strong) dispatch_queue_t jsQueue;
@property (nonatomic, assign) BOOL isServiceRunning;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 创建专用的串行队列用于 JavaScript 服务
    self.jsQueue = dispatch_queue_create("com.jscore.service", DISPATCH_QUEUE_SERIAL);
    self.isServiceRunning = YES;
    
    // 初始化 JavaScript 服务
    [self setupJavaScriptService];
    
    // 启动服务
    [self startJSService];
    
    return YES;
}

- (void)setupJavaScriptService {
    // 创建 JavaScript 上下文
    self.jsContext = [[JSContext alloc] init];
    
    // 添加异常处理
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        NSLog(@"JS Error: %@", exception);
    };
    
    // 添加原生方法到 JavaScript 环境
    __weak typeof(self) weakSelf = self;
    
    // 添加日志方法
    self.jsContext[@"nativeLog"] = ^(NSString *message) {
        NSLog(@"JS Service: %@", message);
    };
    
    // 添加延时方法
    self.jsContext[@"nativeDelay"] = ^(NSNumber *milliseconds) {
        // 使用 dispatch_after 实现非阻塞延时
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([milliseconds doubleValue] / 1000.0 * NSEC_PER_SEC)), weakSelf.jsQueue, ^{
            // 延时结束后继续执行 JavaScript
            [weakSelf continueJSService];
        });
    };
    
    // 注入一些初始 JavaScript 代码
    NSString *jsCode = @"\
    // 模拟一个持续运行的服务\n\
    let counter = 0;\n\
    let isWaiting = false;\n\
    \n\
    function processData() {\n\
        counter++;\n\
        let data = {\n\
            timestamp: new Date().toISOString(),\n\
            counter: counter,\n\
            status: 'running'\n\
        };\n\
        \n\
        // 调用原生方法打印数据\n\
        nativeLog(JSON.stringify(data, null, 2));\n\
        \n\
        // 返回 true 表示继续运行\n\
        return true;\n\
    }\n\
    \n\
    // 服务主循环\n\
    function serviceLoop() {\n\
        if (!isWaiting) {\n\
            try {\n\
                // 处理数据\n\
                let shouldContinue = processData();\n\
                \n\
                // 如果返回 false，则停止服务\n\
                if (!shouldContinue) {\n\
                    nativeLog('服务停止运行');\n\
                    return;\n\
                }\n\
                \n\
                // 设置等待标志\n\
                isWaiting = true;\n\
                \n\
                // 使用原生方法实现延时\n\
                nativeDelay(1000);\n\
            } catch (error) {\n\
                nativeLog('服务发生错误: ' + error);\n\
                // 发生错误时等待较长时间再重试\n\
                isWaiting = true;\n\
                nativeDelay(5000);\n\
            }\n\
        }\n\
    }\n\
    \n\
    // 继续服务\n\
    function continueService() {\n\
        isWaiting = false;\n\
        serviceLoop();\n\
    }";
    
    // 执行初始化代码
    [self.jsContext evaluateScript:jsCode];
}

- (void)startJSService {
    // 在专用队列中启动服务
    dispatch_async(self.jsQueue, ^{
        // 调用 JavaScript 服务主循环
        JSValue *serviceLoop = self.jsContext[@"serviceLoop"];
        [serviceLoop callWithArguments:@[]];
    });
}

- (void)continueJSService {
    // 在专用队列中继续服务
    dispatch_async(self.jsQueue, ^{
        // 调用 JavaScript 继续服务函数
        JSValue *continueService = self.jsContext[@"continueService"];
        [continueService callWithArguments:@[]];
    });
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // 停止 JavaScript 服务
    self.isServiceRunning = NO;
    self.jsContext = nil;
    self.jsQueue = nil;
}

// 处理应用进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"应用进入后台，JavaScript 服务继续运行");
}

// 处理应用进入前台
- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"应用进入前台，JavaScript 服务状态：%@", 
          self.isServiceRunning ? @"运行中" : @"已停止");
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
}

@end
