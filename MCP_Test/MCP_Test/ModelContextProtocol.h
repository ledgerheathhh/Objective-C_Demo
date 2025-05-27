//
//  ModelContextProtocol.h
//  MCP_Test
//
//  Created by Ledger Heath on 2025/5/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 定义工具调用的字典结构键名
extern NSString * const kToolCallName;      // 工具名称 (NSString)
extern NSString * const kToolCallArguments; // 工具参数 (NSDictionary)
extern NSString * const kToolCallResult;    // 工具执行结果 (id)

// 模型响应中可能包含的工具调用信息
typedef NSDictionary<NSString *, id> ToolCallInfo;

// 模型请求或响应的上下文协议
@protocol ModelContextProtocol <NSObject>

@optional

/// 模型请求调用的工具列表 (由模型填充，应用解析执行)
@property (nonatomic, strong, nullable) NSArray<ToolCallInfo *> *toolCalls;

/// 本地工具执行后的结果列表 (由应用填充，发送给模型)
@property (nonatomic, strong, nullable) NSArray<ToolCallInfo *> *toolResults;

/// 用户的输入文本
@property (nonatomic, strong, nullable) NSString *userInput;

/// 模型的回复文本
@property (nonatomic, strong, nullable) NSString *modelOutput;

@end

NS_ASSUME_NONNULL_END
