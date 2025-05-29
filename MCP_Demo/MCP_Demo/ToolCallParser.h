#import <Foundation/Foundation.h>

@interface ToolCallParser : NSObject

+ (instancetype)sharedParser;

// 从模型响应中解析工具调用
- (NSDictionary *)parseToolCallFromResponse:(NSString *)response;

// 检查响应是否包含工具调用
- (BOOL)containsToolCall:(NSString *)response;

// 提取工具名称
- (NSString *)extractToolName:(NSString *)response;

// 提取工具参数
- (NSDictionary *)extractToolParams:(NSString *)response;

@end 