//
//  ViewController.m
//  MCP_Test
//
//  Created by Ledger Heath on 2025/5/7.
//

#import "ViewController.h"
#import "APIService.h"
#import "LocalToolManager.h"
#import "ModelContext.h"

#define API_ENDPOINT_URL @"https://api-inference.modelscope.cn/v1/chat/completions"
#define API_KEY @""

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI {
    // --- 输入框 ---
    self.inputTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 100, self.view.frame.size.width - 40, 40)];
    self.inputTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.inputTextField.placeholder = @"请输入您的问题...";
    [self.view addSubview:self.inputTextField];

    // --- 发送按钮 ---
    self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.sendButton.frame = CGRectMake(20, 150, self.view.frame.size.width - 40, 44);
    [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(sendMessageTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sendButton];

    // --- 输出框 ---
    self.outputTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, 220, self.view.frame.size.width - 40, 200)];
    self.outputTextView.editable = NO;
    self.outputTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.outputTextView.layer.borderWidth = 1.0;
    self.outputTextView.layer.cornerRadius = 5.0;
    [self.view addSubview:self.outputTextView];
}

- (void)sendMessageTapped:(UIButton *)sender {
    NSString *inputText = self.inputTextField.text;
    if (inputText.length == 0) {
        [self showAlertWithTitle:@"提示" message:@"请输入内容后再发送。"];
        return;
    }

    self.outputTextView.text = @"正在请求模型...";
    [self callLargeModelAPI:inputText];
}

- (void)callLargeModelAPI:(NSString *)prompt {
    NSURL *url = [NSURL URLWithString:API_ENDPOINT_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];

    // --- 设置请求头 ---
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    // 如果 API 需要认证，例如 Bearer Token:
     NSString *bearerToken = [NSString stringWithFormat:@"Bearer %@", API_KEY];
     [request setValue:bearerToken forHTTPHeaderField:@"Authorization"];
    // 或者其他认证方式，如 API Key in header:
    // [request setValue:API_KEY forHTTPHeaderField:@"X-API-Key"];

    NSString *system_message = @""
        "You are a helpful assistant with access to these tools:\n\n"
//        "f"{tools_description}\n"
        "Choose the appropriate tool based on the user's question. "
        "If no tool is needed, reply directly.\n\n"
        "IMPORTANT: When you need to use a tool, you must ONLY respond with "
        "the exact JSON object format below, nothing else:\n"
        "{\n"
        "    \"tool\": \"tool-name\",\n"
        "    \"arguments\": {\n"
        "        \"argument-name\": \"value\"\n"
        "    }\n"
        "}\n\n"
        "After receiving a tool's response:\n"
        "1. Transform the raw data into a natural, conversational response\n"
        "2. Keep responses concise but informative\n"
        "3. Focus on the most relevant information\n"
        "4. Use appropriate context from the user's question\n"
        "5. Avoid simply repeating the raw data\n\n"
        "Please use only the tools that are explicitly defined above.";

    // --- 构建请求体 (根据具体 API 要求调整) ---
    // 这是一个假设的请求体结构，实际结构取决于你使用的 LLM API
    NSDictionary *requestBodyDict = @{
        @"max_tokens": @10000,
        @"model": @"deepseek-ai/DeepSeek-R1",
        @"stream": @NO,
        @"messages":@[ @{ @"role": @"system", @"content": system_message},
                       @{ @"role": @"user", @"content": prompt} ]
    };

    NSError *jsonError;
    NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:requestBodyDict options:0 error:&jsonError];

    if (jsonError) {
        NSLog(@"Error creating JSON request body: %@", jsonError.localizedDescription);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.outputTextView.text = [NSString stringWithFormat:@"请求构建失败: %@", jsonError.localizedDescription];
        });
        return;
    }

    [request setHTTPBody:requestBodyData];

    // --- 发起网络请求 ---
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // 确保在主线程更新 UI
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                NSLog(@"Network Error: %@", error.localizedDescription);
                self.outputTextView.text = [NSString stringWithFormat:@"网络错误: %@", error.localizedDescription];
                return;
            }

            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 200) { // 假设 200 是成功状态码
                NSError *parseError;
                // 解析 JSON 响应 (根据具体 API 响应结构调整)
                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];

                if (parseError) {
                    NSLog(@"JSON Parse Error: %@", parseError.localizedDescription);
                    self.outputTextView.text = [NSString stringWithFormat:@"响应解析错误: %@", parseError.localizedDescription];
                    return;
                }

                // 假设模型回复在 'choices'[0]['text'] 或类似路径下
                // 这完全取决于你的 LLM API 的响应格式
                NSString *modelReply = @"未能提取到回复"; // 默认值
                if ([jsonResponse objectForKey:@"choices"] && [[jsonResponse objectForKey:@"choices"] isKindOfClass:[NSArray class]]) {
                    NSArray *choices = [jsonResponse objectForKey:@"choices"];
                    if (choices.count > 0 && [choices[0] isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *firstChoice = choices[0];
                        if ([firstChoice objectForKey:@"text"] && [[firstChoice objectForKey:@"text"] isKindOfClass:[NSString class]]) {
                             modelReply = [firstChoice objectForKey:@"text"];
                        } else if ([firstChoice objectForKey:@"message"] && [[firstChoice objectForKey:@"message"] isKindOfClass:[NSDictionary class]]) {
                            // 另一种常见的格式，例如 OpenAI Chat API
                            NSDictionary *messageDict = [firstChoice objectForKey:@"message"];
                            if ([messageDict objectForKey:@"content"] && [[messageDict objectForKey:@"content"] isKindOfClass:[NSString class]]) {
                                modelReply = [messageDict objectForKey:@"content"];
                            }
                        }
                    }
                } else if ([jsonResponse objectForKey:@"generated_text"] && [[jsonResponse objectForKey:@"generated_text"] isKindOfClass:[NSString class]]) {
                    // 另一种可能的响应字段
                    modelReply = [jsonResponse objectForKey:@"generated_text"];
                }
                // ... 根据你的 API 文档添加更多可能的解析路径

                self.outputTextView.text = modelReply;

            } else {
                NSLog(@"API Error: Status Code %ld", (long)httpResponse.statusCode);
                NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                self.outputTextView.text = [NSString stringWithFormat:@"API 错误: %ld\n%@", (long)httpResponse.statusCode, responseString ?: @"无详细错误信息"];
            }
        });
    }];

    [dataTask resume];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
