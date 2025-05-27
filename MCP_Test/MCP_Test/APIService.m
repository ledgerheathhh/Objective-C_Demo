//
//  APIService.m
//  MCP_Test
//
//  Created by Ledger Heath on 2025/5/27.
//

#import "APIService.h"
#import "ModelContext.h" // 引入具体的上下文实现类

// 假设这是你的 LLM API Endpoint
static NSString * const kLlmApiEndpoint = @"YOUR_LLM_API_ENDPOINT_HERE";
// 假设这是你的 API Key
static NSString * const kApiKey = @"YOUR_API_KEY_HERE";


@implementation APIService

+ (instancetype)sharedInstance {
    static APIService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)sendMessageWithContext:(id<ModelContextProtocol>)context
             completionHandler:(APICompletionBlock)completionHandler {

    NSURL *url = [NSURL URLWithString:kLlmApiEndpoint];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", kApiKey] forHTTPHeaderField:@"Authorization"]; // 示例授权

    // 构建请求体 (这是一个非常简化的例子，具体结构取决于你的 LLM API)
    NSMutableDictionary *requestBody = [NSMutableDictionary dictionary];
    if (context.userInput) {
        requestBody[@"prompt"] = context.userInput; // 或者 "messages": [{"role":"user", "content": context.userInput}]
    }

    // 如果有工具执行结果，也需要发送给模型
    if (context.toolResults && context.toolResults.count > 0) {
        //  你需要根据你的LLM API规范来构建这部分数据
        //  例如: requestBody[@"tool_results"] = context.toolResults;
        //  或者将其合并到 messages 数组中，例如：
        //  NSMutableArray *messages = [requestBody[@"messages"] mutableCopy] ?: [NSMutableArray array];
        //  for (ToolCallInfo *toolResultInfo in context.toolResults) {
        //      [messages addObject:@{
        //          @"role": @"tool",
        //          @"tool_call_id": toolResultInfo[kToolCallId], // 假设 API 需要 tool_call_id
        //          @"content": [NSString stringWithFormat:@"%@", toolResultInfo[kToolCallResult]]
        //      }];
        //  }
        //  requestBody[@"messages"] = messages;
        NSLog(@"向模型发送工具执行结果: %@", context.toolResults);
    }


    // 告诉模型它可以调用哪些工具 (可选，但推荐)
    // 这部分也高度依赖于你的 LLM API 设计
    // requestBody[@"available_tools"] = @[
    //     @{ @"name": @"get_current_time", @"description": @"获取当前时间" },
    //     @{ @"name": @"get_device_location", @"description": @"获取设备当前位置" }
    // ];


    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requestBody options:0 error:&jsonError];

    if (jsonError) {
        NSLog(@"JSON序列化错误: %@", jsonError);
        if (completionHandler) {
            completionHandler(nil, jsonError);
        }
        return;
    }

    request.HTTPBody = jsonData;

    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"API 请求错误: %@", error);
            if (completionHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(nil, error);
                });
            }
            return;
        }

        if (!data) {
            NSError *noDataError = [NSError errorWithDomain:@"APIServiceError" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"未收到数据"}];
            if (completionHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(nil, noDataError);
                });
            }
            return;
        }

        NSError *parseError;
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];

        if (parseError) {
            NSLog(@"JSON解析错误: %@", parseError);
            if (completionHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(nil, parseError);
                });
            }
            return;
        }

        // 解析模型响应
        id<ModelContextProtocol> responseContext = [[ModelContext alloc] init];

        // 假设模型直接回复文本在 "text" 或 "content" 字段
        // 或者在 "choices":[{"message":{"content": "..."}}] 这样的结构中
        NSString *modelText = jsonResponse[@"choices"][0][@"message"][@"content"]; // 这是一个常见的 OpenAI API 结构示例
        if (!modelText) {
            modelText = jsonResponse[@"text"]; // 备用方案
        }
        responseContext.modelOutput = modelText;


        // 检查模型是否请求调用工具
        // 这部分的解析逻辑完全取决于你的 LLM API 如何返回工具调用指令
        // 假设模型在响应的 "tool_calls" 字段中返回一个工具调用数组
        // 每个元素包含 "name" 和 "arguments"
        // 例如: "tool_calls": [{"name": "get_current_time", "arguments": {}}]
        NSArray *toolCallsFromAPI = jsonResponse[@"choices"][0][@"message"][@"tool_calls"]; // 示例
        if (toolCallsFromAPI && [toolCallsFromAPI isKindOfClass:[NSArray class]] && toolCallsFromAPI.count > 0) {
            NSMutableArray<ToolCallInfo *> *parsedToolCalls = [NSMutableArray array];
            for (NSDictionary *apiToolCall in toolCallsFromAPI) {
                NSString *toolName = apiToolCall[@"function"][@"name"]; // 示例
                NSString *argumentsString = apiToolCall[@"function"][@"arguments"]; // 示例，参数可能是字符串形式的JSON
                NSDictionary *arguments = nil;
                if (argumentsString) {
                    NSData *argsData = [argumentsString dataUsingEncoding:NSUTF8StringEncoding];
                    arguments = [NSJSONSerialization JSONObjectWithData:argsData options:0 error:nil];
                }

                if (toolName) {
                    NSMutableDictionary<NSString *, id> *toolCallInfo = [NSMutableDictionary dictionary];
                    toolCallInfo[kToolCallName] = toolName;
                    if (arguments) {
                        toolCallInfo[kToolCallArguments] = arguments;
                    }
                    //  API 可能还会返回一个 tool_call_id，你需要保存它以便后续将结果关联回去
                    //  toolCallInfo[@"tool_call_id"] = apiToolCall[@"id"];
                    [parsedToolCalls addObject:toolCallInfo];
                }
            }
            if (parsedToolCalls.count > 0) {
                responseContext.toolCalls = [parsedToolCalls copy];
                responseContext.modelOutput = nil; // 如果有工具调用，通常此时没有最终文本回复
                NSLog(@"模型请求调用工具: %@", responseContext.toolCalls);
            }
        }


        if (completionHandler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(responseContext, nil);
            });
        }
    }];

    [dataTask resume];
}

@end
