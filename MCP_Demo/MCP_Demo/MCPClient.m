//
//  MCPClient.m
//  MCP_Demo
//
//  Created by Ledger Heath on 2025/5/7.
//

#import "MCPClient.h"

@interface MCPClient ()
@property (nonatomic, strong) NSURLSession *session;
@end

@implementation MCPClient

- (instancetype)initWithAPIKey:(NSString *)apiKey baseURL:(NSString *)baseURL {
    self = [super init];
    if (self) {
        _apiKey = apiKey;
        _baseURL = baseURL ?: @"https://api.openai.com/v1";
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}

- (void)sendMessage:(NSString *)message withTools:(NSArray *)availableTools {
    if (!message || message.length == 0) {
        if ([self.delegate respondsToSelector:@selector(didEncounterError:)]) {
            NSError *error = [NSError errorWithDomain:@"MCPClientErrorDomain" 
                                                code:400 
                                            userInfo:@{NSLocalizedDescriptionKey: @"Message cannot be empty"}];
            [self.delegate didEncounterError:error];
        }
        return;
    }
    
    // 构建请求URL
    NSURL *url = [NSURL URLWithString:self.baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    // 设置请求头
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", self.apiKey] forHTTPHeaderField:@"Authorization"];
    
    // 构建请求体
    NSString *systemMessage = @"你是一个有用的AI助手，可以回答用户的问题并提供帮助。";
    
    NSDictionary *requestBody = @{ 
        @"max_tokens": @10000, 
        @"model": @"deepseek-ai/DeepSeek-R1", 
        @"stream": @NO, 
        @"messages": @[
            @{ @"role": @"system", @"content": systemMessage}, 
            @{ @"role": @"user", @"content": message}
        ]
    };
    
    // 添加工具信息
    NSMutableDictionary *mutableRequestBody = [requestBody mutableCopy];
//    if (availableTools.count > 0) {
//        mutableRequestBody[@"tools"] = availableTools;
//        mutableRequestBody[@"tool_choice"] = @"auto";
//    }
    
    // 序列化请求体
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutableRequestBody options:0 error:&jsonError];
    
    if (jsonError) {
        if ([self.delegate respondsToSelector:@selector(didEncounterError:)]) {
            [self.delegate didEncounterError:jsonError];
        }
        return;
    }
    
    request.HTTPBody = jsonData;
    
    // 打印请求信息以便调试
    NSLog(@"Request URL: %@", url);
    NSLog(@"Request Headers: %@", [request allHTTPHeaderFields]);
    NSString *requestBodyString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"Request Body: %@", requestBodyString);
    
    // 创建任务
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(didEncounterError:)]) {
                    [self.delegate didEncounterError:error];
                }
            });
            return;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSLog(@"Response Status Code: %ld", (long)httpResponse.statusCode);
        
        if (data) {
            NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Response Body: %@", responseString);
        }
        
        if (httpResponse.statusCode >= 400) {
            NSString *errorMessage = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ?: @"未知错误";
            NSError *apiError = [NSError errorWithDomain:@"MCPClientErrorDomain" 
                                                   code:httpResponse.statusCode 
                                               userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(didEncounterError:)]) {
                    [self.delegate didEncounterError:apiError];
                }
            });
            return;
        }
        
        // 解析JSON响应
        NSError *jsonError;
        NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if (jsonError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(didEncounterError:)]) {
                    [self.delegate didEncounterError:jsonError];
                }
            });
            return;
        }
        
        // 处理响应
        dispatch_async(dispatch_get_main_queue(), ^{
            // 检查是否有工具调用
            NSDictionary *choices = jsonResponse[@"choices"][0];
            NSDictionary *message = choices[@"message"];
            NSArray *toolCalls = message[@"tool_calls"];
            
            if (toolCalls && toolCalls.count > 0) {
                // 处理工具调用
                NSDictionary *toolCall = toolCalls[0];
                NSDictionary *function = toolCall[@"function"];
                NSString *toolName = function[@"name"];
                NSString *argsString = function[@"arguments"];
                
                NSError *paramsError;
                NSDictionary *params = [NSJSONSerialization JSONObjectWithData:[argsString dataUsingEncoding:NSUTF8StringEncoding] 
                                                                      options:0 
                                                                        error:&paramsError];
                
                if (!paramsError && [self.delegate respondsToSelector:@selector(didReceiveToolCall:params:)]) {
                    [self.delegate didReceiveToolCall:toolName params:params];
                }
            } else {
                // 处理文本响应
                NSString *content = message[@"content"];
                if (content && [self.delegate respondsToSelector:@selector(didReceiveResponse:)]) {
                    MessageModel *responseMessage = [[MessageModel alloc] init];
                    responseMessage.content = content;
                    responseMessage.type = MessageTypeAssistant;
                    
                    [self.delegate didReceiveResponse:responseMessage];
                }
            }
        });
    }];
    
    [task resume];
}

- (void)sendToolResult:(NSString *)toolName result:(id)result {
    // 构建请求URL
    NSURL *url = [NSURL URLWithString:self.baseURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    // 设置请求头
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"Bearer %@", self.apiKey] forHTTPHeaderField:@"Authorization"];
    
    // 构建请求体
    NSString *systemMessage = @"你是一个有用的AI助手，可以回答用户的问题并提供帮助。";
    
    // 添加工具结果消息
    NSString *resultString;
    if ([result isKindOfClass:[NSString class]]) {
        resultString = result;
    } else if ([result isKindOfClass:[NSNumber class]]) {
        resultString = [result stringValue];
    } else if ([result isKindOfClass:[NSDictionary class]] || [result isKindOfClass:[NSArray class]]) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingPrettyPrinted error:nil];
        resultString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    } else if (result) {
        resultString = [result description];
    } else {
        resultString = @"null";
    }
    
    // 构建包含工具结果的消息数组
    NSArray *messages = @[
        @{ @"role": @"system", @"content": systemMessage},
        @{ @"role": @"assistant", @"content": [NSNull null], @"tool_calls": @[
            @{
                @"id": [NSString stringWithFormat:@"call_%@", toolName],
                @"type": @"function",
                @"function": @{
                    @"name": toolName,
                    @"arguments": @"{}"
                }
            }
        ]},
        @{ @"role": @"tool", @"tool_call_id": [NSString stringWithFormat:@"call_%@", toolName], @"content": resultString}
    ];
    
    NSDictionary *requestBody = @{ 
        @"max_tokens": @10000, 
        @"model": @"deepseek-ai/DeepSeek-R1", 
        @"stream": @NO, 
        @"messages": messages
    };
    
    // 序列化请求体
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:requestBody options:0 error:&jsonError];
    
    if (jsonError) {
        if ([self.delegate respondsToSelector:@selector(didEncounterError:)]) {
            [self.delegate didEncounterError:jsonError];
        }
        return;
    }
    
    request.HTTPBody = jsonData;
    
    // 打印请求信息以便调试
    NSLog(@"Tool Result Request URL: %@", url);
    NSLog(@"Tool Result Request Headers: %@", [request allHTTPHeaderFields]);
    NSString *requestBodyString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"Tool Result Request Body: %@", requestBodyString);
    
    // 创建任务
    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // 处理响应...
        // 保持原有的响应处理代码不变
    }];
    
    [task resume];
}

@end
