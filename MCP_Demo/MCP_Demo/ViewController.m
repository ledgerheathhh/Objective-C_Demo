//
//  ViewController.m
//  MCP_Demo
//
//  Created by Ledger Heath on 2025/5/7.
//

#import "ViewController.h"

// 添加自定义消息单元格
@interface MessageCell : UITableViewCell
@property (nonatomic, strong) UIView *bubbleView;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) NSLayoutConstraint *bubbleLeadingConstraint;
@property (nonatomic, strong) NSLayoutConstraint *bubbleTrailingConstraint;
@property (nonatomic, strong) NSLayoutConstraint *bubbleWidthConstraint;  // 添加宽度约束

- (void)configureWithMessage:(MessageModel *)message;
@end

@implementation MessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        // 创建气泡视图
        self.bubbleView = [[UIView alloc] init];
        self.bubbleView.layer.cornerRadius = 12;
        self.bubbleView.clipsToBounds = YES;
        self.bubbleView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.bubbleView];
        
        // 创建消息标签
        self.messageLabel = [[UILabel alloc] init];
        self.messageLabel.numberOfLines = 0;
        self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.bubbleView addSubview:self.messageLabel];
        
        // 设置气泡视图约束
        self.bubbleLeadingConstraint = [self.bubbleView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:10];
        self.bubbleTrailingConstraint = [self.bubbleView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-10];
        
        // 设置最大宽度约束（屏幕宽度的70%）
        CGFloat maxWidth = UIScreen.mainScreen.bounds.size.width * 0.7;
        self.bubbleWidthConstraint = [self.bubbleView.widthAnchor constraintLessThanOrEqualToConstant:maxWidth];
        
        [NSLayoutConstraint activateConstraints:@[
            // 气泡视图约束
            self.bubbleLeadingConstraint,
            self.bubbleTrailingConstraint,
            self.bubbleWidthConstraint,
            [self.bubbleView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:10],
            [self.bubbleView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-10],
            
            // 消息标签约束
            [self.messageLabel.leadingAnchor constraintEqualToAnchor:self.bubbleView.leadingAnchor constant:10],
            [self.messageLabel.trailingAnchor constraintEqualToAnchor:self.bubbleView.trailingAnchor constant:-10],
            [self.messageLabel.topAnchor constraintEqualToAnchor:self.bubbleView.topAnchor constant:10],
            [self.messageLabel.bottomAnchor constraintEqualToAnchor:self.bubbleView.bottomAnchor constant:-10]
        ]];
    }
    return self;
}

- (void)configureWithMessage:(MessageModel *)message {
    self.messageLabel.text = message.content;
    
    // 根据消息类型设置样式
    if (message.type == MessageTypeUser) {
        self.bubbleView.backgroundColor = [UIColor systemBlueColor];
        self.messageLabel.textColor = [UIColor whiteColor];
        
        // 用户消息靠右
        self.bubbleLeadingConstraint.active = NO;
        self.bubbleTrailingConstraint.active = YES;
        self.bubbleTrailingConstraint.constant = -10;
        
        // 设置最小宽度约束，确保短消息也有合适的宽度
        CGFloat minWidth = MIN(UIScreen.mainScreen.bounds.size.width * 0.3, 100);
        [self.bubbleView.widthAnchor constraintGreaterThanOrEqualToConstant:minWidth].active = YES;
    } else {
        self.bubbleView.backgroundColor = [UIColor systemGrayColor];
        self.messageLabel.textColor = [UIColor whiteColor];
        
        // 助手消息靠左
        self.bubbleTrailingConstraint.active = NO;
        self.bubbleLeadingConstraint.active = YES;
        self.bubbleLeadingConstraint.constant = 10;
        
        // 设置最小宽度约束，确保短消息也有合适的宽度
        CGFloat minWidth = MIN(UIScreen.mainScreen.bounds.size.width * 0.3, 100);
        [self.bubbleView.widthAnchor constraintGreaterThanOrEqualToConstant:minWidth].active = YES;
    }
    
    // 强制布局更新以获取正确的文本大小
    [self.messageLabel setNeedsLayout];
    [self.messageLabel layoutIfNeeded];
    
    // 根据文本内容调整气泡宽度
    CGSize textSize = [self.messageLabel.text boundingRectWithSize:CGSizeMake(UIScreen.mainScreen.bounds.size.width * 0.7 - 20, CGFLOAT_MAX)
                                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                      attributes:@{NSFontAttributeName: self.messageLabel.font}
                                                         context:nil].size;
    
    // 设置气泡宽度约束
    CGFloat bubbleWidth = MIN(textSize.width + 20, UIScreen.mainScreen.bounds.size.width * 0.7);
    self.bubbleWidthConstraint.constant = bubbleWidth;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.messageLabel.text = nil;
    self.bubbleView.backgroundColor = nil;
    self.messageLabel.textColor = nil;
    
    // 重置约束
    self.bubbleLeadingConstraint.active = YES;
    self.bubbleTrailingConstraint.active = YES;
    self.bubbleWidthConstraint.constant = UIScreen.mainScreen.bounds.size.width * 0.7;
}

@end

@interface ViewController ()
@property (nonatomic, strong) NSLayoutConstraint *inputContainerBottomConstraint;  // 添加底部约束属性
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
    
    // 注册键盘通知
    [self registerForKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 移除键盘通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillShow:)
                                               name:UIKeyboardWillShowNotification
                                             object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(keyboardWillHide:)
                                               name:UIKeyboardWillHideNotification
                                             object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    // 获取键盘高度
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = keyboardFrame.size.height;
    
    // 获取动画时长
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 更新输入框底部约束
    self.inputContainerBottomConstraint.constant = -keyboardHeight;
    
    // 使用键盘动画时长执行动画
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
    
    // 滚动到最新消息
    [self scrollToBottomAnimated:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    // 获取动画时长
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 恢复输入框位置
    self.inputContainerBottomConstraint.constant = 0;
    
    // 使用键盘动画时长执行动画
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    if (self.messages.count > 0) {
        NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
        [self.chatTableView scrollToRowAtIndexPath:lastIndexPath
                                 atScrollPosition:UITableViewScrollPositionBottom
                                         animated:animated];
    }
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 创建聊天记录表格
    self.chatTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.chatTableView.dataSource = self;
    self.chatTableView.delegate = self;
    self.chatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.chatTableView.backgroundColor = [UIColor whiteColor];
    self.chatTableView.estimatedRowHeight = 60;
    self.chatTableView.rowHeight = UITableViewAutomaticDimension;
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
    
    // 设置约束（使用自动布局）
    inputContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.chatTableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.inputTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.sendButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 输入容器约束
    self.inputContainerBottomConstraint = [inputContainerView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor];
    [NSLayoutConstraint activateConstraints:@[
        [inputContainerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [inputContainerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        self.inputContainerBottomConstraint,
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
    
    // 注册自定义单元格
    [self.chatTableView registerClass:[MessageCell class] forCellReuseIdentifier:@"MessageCell"];
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
    
//    [self scrollToBottomAnimated:YES];
    
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
        [self scrollToBottomAnimated:YES];  // 收到新消息时滚动到底部
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
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
    MessageModel *message = self.messages[indexPath.row];
    [cell configureWithMessage:message];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    // 开始编辑时滚动到最新消息
    [self scrollToBottomAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.inputTextField) {
        [self sendMessage];
        [textField resignFirstResponder];  // 发送后收起键盘
        return YES;
    }
    return NO;
}

@end
