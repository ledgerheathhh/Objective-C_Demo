//
//  LocalToolManager.h
//  MCP_Test
//
//  Created by Ledger Heath on 2025/5/27.
//

#import <Foundation/Foundation.h>
#import "ModelContextProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface LocalToolManager : NSObject

+ (instancetype)sharedManager;

/// 执行指定的工具调用
/// @param toolCallInfo 包含工具名称和参数的字典
/// @return 工具执行的结果 (可以是 NSString, NSNumber, NSDictionary, NSArray 等可序列化的对象)
- (nullable id)executeToolWithInfo:(ToolCallInfo *)toolCallInfo;

@end

NS_ASSUME_NONNULL_END
