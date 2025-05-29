//
//  MCPClient.m
//  MCP_Demo
//
//  Created by Ledger Heath on 2025/5/7.
//

#import "MCPClient.h"
#import "ToolCallParser.h"

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
    
    // 构建系统提示词，包含工具描述
    NSMutableString *systemPrompt = [NSMutableString stringWithString:@"You are a helpful assistant with access to these tools:\n\n"];
    
    // 添加工具描述
    for (NSDictionary *tool in availableTools) {
        [systemPrompt appendFormat:@"%@: %@\n", tool[@"name"], tool[@"description"]];
    }
    
    // 添加工具调用格式说明
    [systemPrompt appendString:@"Choose the appropriate tool based on the user's question."];
    [systemPrompt appendString:@"If no tool is needed, reply directly.\n\n"];
    [systemPrompt appendString:@"IMPORTANT: When you need to use a tool, you must ONLY respond with "];
    [systemPrompt appendString:@"the exact JSON object format below, nothing else"];
    [systemPrompt appendString:@"<tool>tool-name</tool>\n"];
    [systemPrompt appendString:@"<params>参数JSON</params>\n\n"];
    [systemPrompt appendString:@"例如：\n"];
    [systemPrompt appendString:@"<tool>calculator</tool>\n"];
    [systemPrompt appendString:@"<params>{\"expression\": \"1+1\"}</params>\n\n"];
    
    // 构建请求体
    NSDictionary *requestBody = @{ 
        @"max_tokens": @10000, 
        @"model": @"deepseek-ai/DeepSeek-R1",
        @"stream": @NO,
        @"messages": @[
            @{ @"role": @"system", @"content": systemPrompt}, 
            @{ @"role": @"user", @"content": message}
        ]
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
            NSDictionary *choices = jsonResponse[@"choices"][0];
            NSDictionary *message = choices[@"message"];
            NSString *content = message[@"content"];
            
            if (content) {
                // 使用工具调用解析器检查响应
                ToolCallParser *parser = [ToolCallParser sharedParser];
                NSDictionary *toolCall = [parser parseToolCallFromResponse:content];
                
                if (toolCall) {
                    // 处理工具调用
                    NSString *toolName = toolCall[@"tool_name"];
                    NSDictionary *params = toolCall[@"params"];
                    
                    if ([self.delegate respondsToSelector:@selector(didReceiveToolCall:params:)]) {
                        [self.delegate didReceiveToolCall:toolName params:params];
                    }
                }
                
                // 发送文本响应
                if ([self.delegate respondsToSelector:@selector(didReceiveResponse:)]) {
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
        @{ @"role": @"user", @"content": [NSString stringWithFormat:@"工具 %@ 的执行结果是：%@", toolName, resultString]}
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
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(didEncounterError:)]) {
                    [self.delegate didEncounterError:error];
                }
            });
            return;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
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
            NSDictionary *choices = jsonResponse[@"choices"][0];
            NSDictionary *message = choices[@"message"];
            NSString *content = message[@"content"];
            
            if (content) {
                // 使用工具调用解析器检查响应
                ToolCallParser *parser = [ToolCallParser sharedParser];
                NSDictionary *toolCall = [parser parseToolCallFromResponse:content];
                
                if (toolCall) {
                    // 处理工具调用
                    NSString *toolName = toolCall[@"tool_name"];
                    NSDictionary *params = toolCall[@"params"];
                    
                    if ([self.delegate respondsToSelector:@selector(didReceiveToolCall:params:)]) {
                        [self.delegate didReceiveToolCall:toolName params:params];
                    }
                }
                
                // 发送文本响应
                if ([self.delegate respondsToSelector:@selector(didReceiveResponse:)]) {
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

@end
