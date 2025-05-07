//
//  ViewController.m
//  NestedTextView
//
//  Created by Ledger Heath on 2025/2/27.
//

#import "ViewController.h"
#import "ParentInputView.h"

@interface ViewController ()

@property (nonatomic, strong) ParentInputView *parentInputView;
@property (nonatomic, strong) UIButton *addChildButton;
@property (nonatomic, strong) UIButton *sendButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置父输入框
    self.parentInputView = [[ParentInputView alloc] initWithFrame:CGRectMake(10, 100, 400, 40)];
    [self.view addSubview:self.parentInputView];
    
    // 添加子输入框按钮
    self.addChildButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.addChildButton setTitle:@"添加子输入框" forState:UIControlStateNormal];
    self.addChildButton.frame = CGRectMake(10, 50, 100, 30);
    [self.addChildButton addTarget:self action:@selector(addChildInputView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addChildButton];
    
    // 发送按钮
    self.sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
    self.sendButton.frame = CGRectMake(120, 50, 60, 30);
    [self.sendButton addTarget:self action:@selector(sendContent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sendButton];
}

- (void)addChildInputView {
    [self.parentInputView insertChildInputViewAtCurrentPosition];
}

- (void)sendContent {
    NSString *content = [self.parentInputView getAllContent];
    NSLog(@"发送内容: %@", content);
}

@end
