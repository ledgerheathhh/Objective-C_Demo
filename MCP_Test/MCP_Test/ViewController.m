//
//  ViewController.m
//  MCP_Test
//
//  Created by Ledger Heath on 2025/5/7.
//

#import "ViewController.h"
#import "MCPServer.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 创建状态标签
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, self.view.bounds.size.width - 40, 30)];
    self.statusLabel.text = @"等待点击...";
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.statusLabel];
    
    // 创建测试按钮
    self.testButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.testButton.frame = CGRectMake(100, 200, self.view.bounds.size.width - 200, 50);
    [self.testButton setTitle:@"点击我" forState:UIControlStateNormal];
    [self.testButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.testButton];
    
    // 显示MCP Server状态
    UILabel *serverStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 300, self.view.bounds.size.width - 40, 30)];
    serverStatusLabel.textAlignment = NSTextAlignmentCenter;
    
    if ([[MCPServer sharedServer] isRunning]) {
        serverStatusLabel.text = [NSString stringWithFormat:@"MCP Server运行中: %@", [[MCPServer sharedServer] serverURL]];
        serverStatusLabel.textColor = [UIColor greenColor];
    } else {
        serverStatusLabel.text = @"MCP Server未运行";
        serverStatusLabel.textColor = [UIColor redColor];
    }
    
    [self.view addSubview:serverStatusLabel];
}

- (void)buttonTapped:(UIButton *)sender {
    self.statusLabel.text = @"按钮被点击了！";
    
    // 2秒后重置状态
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.statusLabel.text = @"等待点击...";
    });
}

@end
