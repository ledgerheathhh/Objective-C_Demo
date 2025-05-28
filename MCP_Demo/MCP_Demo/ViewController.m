//
//  ViewController.m
//  MCP_Demo
//
//  Created by Ledger Heath on 2025/5/7.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化组件
    self.mcpClient = [[MCPClient alloc] initWithAPIKey:@""
                                               baseURL:@"https://api-inference.modelscope.cn/v1/chat/completions"];
    self.mcpClient.delegate = self;
    
    self.toolManager = [ToolManager sharedManager];
    self.messages = [[NSMutableArray alloc] init];
    
    // 注册本地工具
    [self registerLocalTools];
    
    // 设置UI
    [self setupUI];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 创建聊天记录表格
    self.chatTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.chatTableView.dataSource = self;
    self.chatTableView.delegate = self;
    self.chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.chatTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.chatTableView];
    
    // 创建底部输入区域
    UIView *inputContainerView = [[UIView alloc] init];
    inputContainerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:inputContainerView];
    
    // 创建输入框
    self.inputTextField = [[UITextField alloc] init];
    self.inputTextField.placeholder = @"输入消息...";
    self.inputTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.inputTextField.delegate = self;
    self.inputTextField.returnKeyType = UIReturnKeySend;
    [inputContainerView addSubview:self.inputTextField];
    
    // 创建发送按钮
    self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
    [self.sendButton addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
    [inputContainerView addSubview:self.sendButton];
    
    // 设置约束（使用手动布局）
    inputContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.chatTableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.inputTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.sendButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 输入容器约束
    [NSLayoutConstraint activateConstraints:@[
        [inputContainerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [inputContainerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [inputContainerView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
        [inputContainerView.heightAnchor constraintEqualToConstant:60]
    ]];
    
    // 聊天表格约束
    [NSLayoutConstraint activateConstraints:@[
        [self.chatTableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.chatTableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.chatTableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.chatTableView.bottomAnchor constraintEqualToAnchor:inputContainerView.topAnchor]
    ]];
    
    // 输入框和发送按钮约束
    [NSLayoutConstraint activateConstraints:@[
        [self.inputTextField.leadingAnchor constraintEqualToAnchor:inputContainerView.leadingAnchor constant:10],
        [self.inputTextField.centerYAnchor constraintEqualToAnchor:inputContainerView.centerYAnchor],
        [self.inputTextField.trailingAnchor constraintEqualToAnchor:self.sendButton.leadingAnchor constant:-10],
        [self.inputTextField.heightAnchor constraintEqualToConstant:40],
        
        [self.sendButton.trailingAnchor constraintEqualToAnchor:inputContainerView.trailingAnchor constant:-10],
        [self.sendButton.centerYAnchor constraintEqualToAnchor:inputContainerView.centerYAnchor],
        [self.sendButton.widthAnchor constraintEqualToConstant:60],
        [self.sendButton.heightAnchor constraintEqualToConstant:40]
    ]];
    
    // 注册单元格
    [self.chatTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"MessageCell"];
}

- (void)registerLocalTools {
    // 注册获取当前时间工具
    [self.toolManager registerTool:@"get_current_time" 
                        description:@"获取当前系统时间" 
                            handler:^(NSDictionary *params, ToolCompletionBlock completion) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSString *currentTime = [formatter stringFromDate:[NSDate date]];
        completion(currentTime, nil);
    }];
    
    // 注册计算器工具
    [self.toolManager registerTool:@"calculator" 
                        description:@"执行基本数学计算" 
                            handler:^(NSDictionary *params, ToolCompletionBlock completion) {
        NSString *expression = params[@"expression"];
        // 简单的计算逻辑
        NSExpression *exp = [NSExpression expressionWithFormat:expression];
        NSNumber *result = [exp expressionValueWithObject:nil context:nil];
        completion(result, nil);
    }];
    
    // 注册获取设备信息工具
    [self.toolManager registerTool:@"get_device_info" 
                        description:@"获取设备信息" 
                            handler:^(NSDictionary *params, ToolCompletionBlock completion) {
        UIDevice *device = [UIDevice currentDevice];
        NSDictionary *deviceInfo = @{
            @"name": device.name,
            @"model": device.model,
            @"systemName": device.systemName,
            @"systemVersion": device.systemVersion
        };
        completion(deviceInfo, nil);
    }];
    
    // 注册获取电池信息工具
    [self.toolManager registerTool:@"get_battery_info" 
                        description:@"获取电池信息" 
                            handler:^(NSDictionary *params, ToolCompletionBlock completion) {
        UIDevice *device = [UIDevice currentDevice];
        device.batteryMonitoringEnabled = YES;
        
        NSString *batteryLevel = [NSString stringWithFormat:@"%.0f%%", device.batteryLevel * 100];
        NSString *batteryState;
        
        switch (device.batteryState) {
            case UIDeviceBatteryStateUnknown:
                batteryState = @"未知";
                break;
            case UIDeviceBatteryStateUnplugged:
                batteryState = @"未充电";
                break;
            case UIDeviceBatteryStateCharging:
                batteryState = @"充电中";
                break;
            case UIDeviceBatteryStateFull:
                batteryState = @"已充满";
                break;
        }
        
        NSDictionary *batteryInfo = @{
            @"level": batteryLevel,
            @"state": batteryState
        };
        
        device.batteryMonitoringEnabled = NO;
        completion(batteryInfo, nil);
    }];
}

- (void)sendMessage {
    NSString *userMessage = self.inputTextField.text;
    if (userMessage.length == 0) return;
    
    // 添加用户消息
    MessageModel *userMsg = [[MessageModel alloc] init];
    userMsg.content = userMessage;
    userMsg.type = MessageTypeUser;
    userMsg.timestamp = [NSDate date];
    [self.messages addObject:userMsg];
    
    // 清空输入框
    self.inputTextField.text = @"";
    
    // 刷新界面
    [self.chatTableView reloadData];
    
    // 发送到MCP客户端
    [self.mcpClient sendMessage:userMessage withTools:[self.toolManager getAvailableTools]];
}

#pragma mark - MCPClientDelegate
- (void)didReceiveResponse:(MessageModel *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.messages addObject:message];
        [self.chatTableView reloadData];
    });
}

- (void)didReceiveToolCall:(NSString *)toolName params:(NSDictionary *)params {
    [self.toolManager executeTool:toolName withParams:params completion:^(id result, NSError *error) {
        if (error) {
            [self.mcpClient sendToolResult:toolName result:@{@"error": error.localizedDescription}];
        } else {
            [self.mcpClient sendToolResult:toolName result:result];
        }
    }];
}

- (void)didEncounterError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误" 
                                                                       message:error.localizedDescription 
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    });
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
    
    // 配置单元格
    MessageModel *message = self.messages[indexPath.row];
    
    // 创建气泡视图
    UIView *bubbleView = [[UIView alloc] init];
    bubbleView.layer.cornerRadius = 12;
    bubbleView.clipsToBounds = YES;
    
    // 创建消息标签
    UILabel *messageLabel = [[UILabel alloc] init];
    messageLabel.text = message.content;
    messageLabel.numberOfLines = 0;
    messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    // 根据消息类型设置样式
    if (message.type == MessageTypeUser) {
        bubbleView.backgroundColor = [UIColor systemBlueColor];
        messageLabel.textColor = [UIColor whiteColor];
        // 用户消息靠右
        bubbleView.frame = CGRectMake(cell.contentView.bounds.size.width - 260, 10, 250, 0);
    } else {
        bubbleView.backgroundColor = [UIColor systemGrayColor];
        messageLabel.textColor = [UIColor whiteColor];
        // 模型消息靠左
        bubbleView.frame = CGRectMake(10, 10, 250, 0);
    }
    
    // 设置消息标签的大小和位置
    messageLabel.frame = CGRectMake(10, 10, 230, 0);
    [messageLabel sizeToFit];
    
    // 调整气泡视图的高度
    CGRect bubbleFrame = bubbleView.frame;
    bubbleFrame.size.height = messageLabel.frame.size.height + 20;
    bubbleView.frame = bubbleFrame;
    
    // 添加到单元格
    [bubbleView addSubview:messageLabel];
    [cell.contentView addSubview:bubbleView];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 动态计算单元格高度
    MessageModel *message = self.messages[indexPath.row];
    
    // 创建临时标签计算高度
    UILabel *tempLabel = [[UILabel alloc] init];
    tempLabel.text = message.content;
    tempLabel.numberOfLines = 0;
    tempLabel.lineBreakMode = NSLineBreakByWordWrapping;
    tempLabel.frame = CGRectMake(0, 0, 230, CGFLOAT_MAX);
    [tempLabel sizeToFit];
    
    return tempLabel.frame.size.height + 40; // 额外空间用于边距
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.inputTextField) {
        [self sendMessage];
        return YES;
    }
    return NO;
}

@end
