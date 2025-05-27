//
//  LocalToolManager.m
//  MCP_Test
//
//  Created by Ledger Heath on 2025/5/27.
//

#import "LocalToolManager.h"

@implementation LocalToolManager

+ (instancetype)sharedManager {
    static LocalToolManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (nullable id)executeToolWithInfo:(ToolCallInfo *)toolCallInfo {
    NSString *toolName = toolCallInfo[kToolCallName];
    NSDictionary *arguments = toolCallInfo[kToolCallArguments];

    NSLog(@"准备执行本地工具: %@, 参数: %@", toolName, arguments);

    if ([toolName isEqualToString:@"get_current_time"]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        return [formatter stringFromDate:[NSDate date]];
    } else if ([toolName isEqualToString:@"get_device_location"]) {
        // 这里只是一个占位符，实际获取位置需要 CoreLocation 框架
        // 并且需要处理权限请求等
        // 警告：直接在主线程执行耗时操作是不推荐的，这里为了简化
        // 实际应用中，地理位置获取应该是异步的
        NSLog(@"警告: get_device_location 工具未实现或为同步占位实现");
        return @"模拟位置:  Cupertino, CA"; // 模拟结果
    }
    // 可以添加更多工具
    // else if ([toolName isEqualToString:@"another_tool"]) {
    //     NSString *param = arguments[@"some_param"];
    //     return [NSString stringWithFormat:@"Tool executed with param: %@", param];
    // }

    NSLog(@"未知的工具名称: %@", toolName);
    return nil; // 或者返回一个表示错误的特定对象/字符串
}

@end
