//
//  MCPServer.m
//  MCP_Test
//
//  Created by Ledger Heath on 2025/5/7.
//

#import "MCPServer.h"
#import <GCDWebServer/GCDWebServer.h>
#import <GCDWebServer/GCDWebServerDataResponse.h>
#import <GCDWebServer/GCDWebServerURLEncodedFormRequest.h>
#import <KIF/KIF.h>

@interface MCPServer ()

@property (nonatomic, strong) GCDWebServer *webServer;

@end

@implementation MCPServer

+ (instancetype)sharedServer {
    static MCPServer *sharedServer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedServer = [[self alloc] init];
    });
    return sharedServer;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _webServer = [[GCDWebServer alloc] init];
        [self setupRoutes];
    }
    return self;
}

- (void)setupRoutes {
    // 注册点击操作的API路由
    [self.webServer addHandlerForMethod:@"POST"
                                   path:@"/api/tap"
                           requestClass:[GCDWebServerURLEncodedFormRequest class]
                      processBlock:^GCDWebServerResponse * _Nullable(GCDWebServerRequest * _Nonnull request) {
        GCDWebServerURLEncodedFormRequest *formRequest = (GCDWebServerURLEncodedFormRequest *)request;
        NSDictionary *params = formRequest.jsonObject;
        
        NSInteger x = [params[@"x"] integerValue];
        NSInteger y = [params[@"y"] integerValue];
        
        // 使用KIF执行点击操作
        CGPoint point = CGPointMake(x, y);
        BOOL success = [self performTapAtPoint:point];
        
        // 返回操作结果
        NSDictionary *responseDict = @{
            @"status": success ? @"success" : @"failure",
            @"message": success ? @"点击操作成功" : @"点击操作失败"
        };
        
        return [GCDWebServerDataResponse responseWithJSONObject:responseDict];
    }];
    
    // 可以添加更多API路由，如滑动、输入文本等
}

- (BOOL)performTapAtPoint:(CGPoint)point {
    // 确保在主线程执行UI操作
    if (![NSThread isMainThread]) {
        __block BOOL result = NO;
        dispatch_sync(dispatch_get_main_queue(), ^{
            result = [self performTapAtPoint:point];
        });
        return result;
    }
    
    // 获取keyWindow并检查其有效性
    UIView *view = [[UIApplication sharedApplication] keyWindow];
    if (!view) {
        NSLog(@"MCP Server: 无法获取keyWindow");
        return NO;
    }
    
    // 检查点击坐标是否在视图范围内
    if (!CGRectContainsPoint(view.bounds, point)) {
        NSLog(@"MCP Server: 点击坐标 (%f, %f) 超出视图范围 %@", point.x, point.y, NSStringFromCGRect(view.bounds));
        return NO;
    }
    
    @try {
        // 使用KIF的UIView扩展方法执行点击
        [view tapAtPoint:point];
        return YES;
    } @catch (NSException *exception) {
        NSLog(@"MCP Server: 执行点击操作时发生异常: %@", exception);
        return NO;
    }
}

- (void)startServer {
    if (![self.webServer isRunning]) {
        // 设置服务器选项
        [self.webServer startWithPort:8001 bonjourName:nil];
        NSLog(@"MCP Server started on port 8001");
    }
}

- (void)stopServer {
    if ([self.webServer isRunning]) {
        [self.webServer stop];
        NSLog(@"MCP Server stopped");
    }
}

- (BOOL)isRunning {
    return [self.webServer isRunning];
}

- (NSString *)serverURL {
    if ([self.webServer isRunning]) {
        return [NSString stringWithFormat:@"http://localhost:%d", (int)self.webServer.port];
    }
    return nil;
}

@end