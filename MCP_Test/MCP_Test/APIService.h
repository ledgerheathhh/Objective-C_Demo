//
//  APIService.h
//  MCP_Test
//
//  Created by Ledger Heath on 2025/5/27.
//
#import <Foundation/Foundation.h>
#import "ModelContextProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^APICompletionBlock)(id<ModelContextProtocol> _Nullable context, NSError * _Nullable error);

@interface APIService : NSObject

+ (instancetype)sharedInstance;

/// 发送对话请求到 LLM API
/// @param context 包含用户输入和可能的先前工具结果的上下文
/// @param completionHandler 完成回调
- (void)sendMessageWithContext:(id<ModelContextProtocol>)context
             completionHandler:(APICompletionBlock)completionHandler;

@end

NS_ASSUME_NONNULL_END
