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
        self.bubbleWidthConstraint.active = NO; // 初始不激活
        
        [NSLayoutConstraint activateConstraints:@[
            // 气泡视图约束
            self.bubbleLeadingConstraint,
            self.bubbleTrailingConstraint,
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
    
    // 确保宽度约束处于非激活状态，以便重新设置 constant
    self.bubbleWidthConstraint.active = NO;

    // 根据消息类型设置样式
    if (message.type == MessageTypeUser) {
        self.bubbleView.backgroundColor = [UIColor systemBlueColor];
        self.messageLabel.textColor = [UIColor whiteColor];
        
        // 用户消息靠右
        self.bubbleLeadingConstraint.active = NO;
        self.bubbleTrailingConstraint.active = YES;
        self.bubbleTrailingConstraint.constant = -10;
        
    } else {
        self.bubbleView.backgroundColor = [UIColor systemGrayColor];
        self.messageLabel.textColor = [UIColor whiteColor];
        
        // 助手消息靠左
        self.bubbleTrailingConstraint.active = NO;
        self.bubbleLeadingConstraint.active = YES;
        self.bubbleLeadingConstraint.constant = 10;
    }
    
    // 根据文本内容调整气泡宽度
    // 计算文本的实际大小
    CGFloat maxTextWidth = UIScreen.mainScreen.bounds.size.width * 0.7 - 20; // 气泡最大宽度 - 左右内边距
    CGSize constrainedSize = CGSizeMake(maxTextWidth, CGFLOAT_MAX);
    CGSize textSize = [self.messageLabel.text boundingRectWithSize:constrainedSize
                                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                      attributes:@{NSFontAttributeName: self.messageLabel.font}
                                                         context:nil].size;
    
    // 气泡的最小宽度，确保短消息也有合适的宽度
    CGFloat minBubbleWidth = MIN(UIScreen.mainScreen.bounds.size.width * 0.3, 100);
    // 气泡的实际宽度，加上左右内边距
    CGFloat calculatedBubbleWidth = MAX(textSize.width + 20, minBubbleWidth);
    // 气泡的最终宽度，不超过最大宽度
    CGFloat finalBubbleWidth = MIN(calculatedBubbleWidth, UIScreen.mainScreen.bounds.size.width * 0.7);

    // 设置宽度约束的 constant 并激活
    self.bubbleWidthConstraint.constant = finalBubbleWidth;
    self.bubbleWidthConstraint.active = YES;
    
    // 强制布局更新以获取正确的文本大小
    [self.messageLabel setNeedsLayout];
    [self.messageLabel layoutIfNeeded];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.messageLabel.text = nil;
    self.bubbleView.backgroundColor = nil;
    self.messageLabel.textColor = nil;
    
    // 重置约束的激活状态
    self.bubbleLeadingConstraint.active = YES;
    self.bubbleTrailingConstraint.active = YES;
    self.bubbleWidthConstraint.active = NO; // 禁用宽度约束，以便在 configureWithMessage 中重新设置
}

@end

@interface ViewController ()
@property (nonatomic, strong) NSLayoutConstraint *inputContainerBottomConstraint;  // 添加底部约束属性
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化组件
    self.mcpClient = [[MCPClient alloc] initWithAPIKey:@"935eb822-582f-44ea-bba6-ccef3eef1b04"
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
    
    // 添加手势识别器以在点击空白处时收起键盘
    [self setupTapToDismissKeyboard];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 移除键盘通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupTapToDismissKeyboard {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(dismissKeyboard:)];
    // 设置为NO，这样点击UITableViewCell等不会触发dismissKeyboard
    // 如果你希望点击到 TableView Cell 也收起键盘，则可以不设置或设为 YES，
    // 但通常不希望这样，因为用户可能想滚动 TableView。
//    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
}

// 手势触发的方法
- (void)dismissKeyboard:(UITapGestureRecognizer *)sender {
    // 让当前视图中任何持有第一响应者状态的控件都放弃它
    // 通常，这意味着让 self.inputTextField 失焦
//     [self.view endEditing:YES];
    // 或者，如果你明确知道是哪个输入框：
     [self.inputTextField resignFirstResponder];
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
    
    CGFloat bottomSafeAreaHeight = 0;
    if (@available(iOS 11.0, *)) {
        bottomSafeAreaHeight = self.view.safeAreaInsets.bottom;
    }
    
    // 更新输入框底部约束
    self.inputContainerBottomConstraint.constant = -keyboardHeight + bottomSafeAreaHeight;
    
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

    // 创建活动指示器
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [inputContainerView addSubview:self.activityIndicator];
    
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

    // 活动指示器约束
    [NSLayoutConstraint activateConstraints:@[
        [self.activityIndicator.trailingAnchor constraintEqualToAnchor:self.sendButton.leadingAnchor constant:-10],
        [self.activityIndicator.centerYAnchor constraintEqualToAnchor:inputContainerView.centerYAnchor]
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
    
    // 禁用输入框和发送按钮，显示活动指示器
    self.inputTextField.enabled = NO;
    self.sendButton.enabled = NO;
    [self.activityIndicator startAnimating];
    [self.inputTextField resignFirstResponder];
    
    // 刷新界面
    [self.chatTableView reloadData];
    [self scrollToBottomAnimated:YES];
    
    // 发送到MCP客户端
    [self.mcpClient sendMessage:userMessage withTools:[self.toolManager getAvailableTools]];
}

#pragma mark - MCPClientDelegate
- (void)didReceiveResponse:(MessageModel *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.messages addObject:message];
        [self.chatTableView reloadData];
        [self scrollToBottomAnimated:YES];  // 收到新消息时滚动到底部
        
        // 启用输入框和发送按钮，隐藏活动指示器
        self.inputTextField.enabled = YES;
        self.sendButton.enabled = YES;
        [self.activityIndicator stopAnimating];
    });
}

- (void)didReceiveToolCall:(NSString *)toolName params:(NSDictionary *)params {
    // 显示工具调用消息
    MessageModel *toolCallMsg = [[MessageModel alloc] init];
    toolCallMsg.content = [NSString stringWithFormat:@"正在调用工具: %@...", toolName];
    toolCallMsg.type = MessageTypeTool;
    toolCallMsg.timestamp = [NSDate date];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.messages addObject:toolCallMsg];
        [self.chatTableView reloadData];
        [self scrollToBottomAnimated:YES];
    });

    [self.toolManager executeTool:toolName withParams:params completion:^(id result, NSError *error) {
        if (error) {
            [self.mcpClient sendToolResult:toolName result:@{@"error": error.localizedDescription}];
        } else {
            [self.mcpClient sendToolResult:toolName result:result];
        }
        // 工具执行完成后，重新启用输入框和发送按钮，隐藏活动指示器
        dispatch_async(dispatch_get_main_queue(), ^{
            self.inputTextField.enabled = YES;
            self.sendButton.enabled = YES;
            [self.activityIndicator stopAnimating];
        });
    }];
}

- (void)didEncounterError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"错误"
                                                                       message:error.localizedDescription
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        
        // 启用输入框和发送按钮，隐藏活动指示器
        self.inputTextField.enabled = YES;
        self.sendButton.enabled = YES;
        [self.activityIndicator stopAnimating];
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
