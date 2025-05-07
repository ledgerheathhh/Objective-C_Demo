//
//  ViewController.m
//  MCP_Demo
//
//  Created by Ledger Heath on 2025/5/7.
//

#import "ViewController.h"
#import "MCPServerManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 启动MCP服务器
    [[MCPServerManager sharedInstance] startServer];
    
    // 设置UI
    [self setupUI];
}

- (void)setupUI {
    // 创建测试按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"测试按钮" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(100, 200, 200, 50);
    [self.view addSubview:button];
    self.testButton = button;
    
    // 创建结果标签
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 300, 200, 50)];
    label.text = @"等待点击...";
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    self.resultLabel = label;
    
    // 添加服务器状态标签
    UILabel *serverLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 100, 300, 30)];
    serverLabel.text = @"MCP服务器运行中 (端口: 8080)";
    serverLabel.textAlignment = NSTextAlignmentCenter;
    serverLabel.textColor = [UIColor greenColor];
    [self.view addSubview:serverLabel];
}

- (void)buttonTapped:(UIButton *)sender {
    self.resultLabel.text = @"按钮被点击了！";
    NSLog(@"Button tapped manually");
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 停止MCP服务器
    [[MCPServerManager sharedInstance] stopServer];
}

@end
