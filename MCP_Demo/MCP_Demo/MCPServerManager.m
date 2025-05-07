//
//  MCPServerManager.m
//  MCP_Demo
//

#import "MCPServerManager.h"
#import <mcp_swift_sdk/mcp_swift_sdk-Swift.h>

@interface MCPServerManager ()

@property (nonatomic, strong) MCPServer *mcpServer;

@end

@implementation MCPServerManager

+ (instancetype)sharedInstance {
    static MCPServerManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)startServer {
    if (self.mcpServer) {
        return;
    }
    
    // 创建MCP服务器配置
    MCPServerConfig *config = [[MCPServerConfig alloc] initWithPort:8080
                                                       allowedHosts:@[@"localhost"]
                                                      allowedPaths:@[@"/"]];
    
    // 创建MCP服务器
    self.mcpServer = [[MCPServer alloc] initWithConfig:config];
    
    // 注册点击工具
    [self registerClickTool];
    
    // 启动服务器
    NSError *error;
    BOOL success = [self.mcpServer startWithError:&error];
    
    if (!success) {
        NSLog(@"Failed to start MCP server: %@", error.localizedDescription);
    } else {
        NSLog(@"MCP server started successfully on port %@", @(config.port));
    }
}

- (void)stopServer {
    if (self.mcpServer) {
        [self.mcpServer stop];
        self.mcpServer = nil;
        NSLog(@"MCP server stopped");
    }
}

- (void)registerClickTool {
    // 创建点击工具
    MCPToolDefinition *clickTool = [[MCPToolDefinition alloc] 
                                   initWithName:@"perform_click"
                                   description:@"Performs a click at the specified coordinates"
                                   parameters:@{
                                       @"x": @{
                                           @"type": @"number",
                                           @"description": @"X coordinate"
                                       },
                                       @"y": @{
                                           @"type": @"number",
                                           @"description": @"Y coordinate"
                                       }
                                   }
                                   required:@[@"x", @"y"]];
    
    // 注册工具处理程序
    [self.mcpServer registerToolWithDefinition:clickTool handler:^(NSDictionary * _Nonnull params, MCPToolCallback _Nonnull callback) {
        // 获取坐标
        NSNumber *x = params[@"x"];
        NSNumber *y = params[@"y"];
        
        if (!x || !y) {
            callback(@{@"error": @"Missing x or y coordinates"}, nil);
            return;
        }
        
        // 在主线程执行点击操作
        dispatch_async(dispatch_get_main_queue(), ^{
            // 模拟点击操作
            [self simulateClickAtX:[x floatValue] y:[y floatValue]];
            
            // 返回成功响应
            callback(@{@"result": @"Click performed successfully"}, nil);
        });
    }];
}

- (void)simulateClickAtX:(CGFloat)x y:(CGFloat)y {
    // 创建一个点击事件
    CGPoint point = CGPointMake(x, y);
    
    // 获取当前窗口
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    // 查找点击位置的视图
    UIView *view = [window hitTest:point withEvent:nil];
    
    if (view) {
        NSLog(@"Simulating click on view: %@ at coordinates: (%f, %f)", view, x, y);
        
        // 触发视图的点击事件
        [view.nextResponder touchesBegan:[NSSet setWithObject:[[UITouch alloc] init]] withEvent:[[UIEvent alloc] init]];
        [view.nextResponder touchesEnded:[NSSet setWithObject:[[UITouch alloc] init]] withEvent:[[UIEvent alloc] init]];
    } else {
        NSLog(@"No view found at coordinates: (%f, %f)", x, y);
    }
}

@end