//
//  ViewController.m
//  JSBridgeTest
//
//  Created by Ledger Heath on 2024/5/22.
//

#import "ViewController.h"
#import <WebViewJavascriptBridge/WebViewJavascriptBridge.h>

@interface ViewController ()

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) WebViewJavascriptBridge *bridge;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(50, 50, 250, 50);
    [btn setTitle:@"点击发送消息到h5" forState:UIControlStateNormal];
    // 设置 UIButton 的背景颜色
    btn.backgroundColor = [UIColor lightGrayColor];
    
    // 设置 UIButton 标题的颜色
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    // 设置 UIButton 的字体
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    
    [btn addTarget:self action:@selector(sendMessageToH5:) forControlEvents:UIControlEventTouchUpInside];
    //添加UIButton到控制器view
    [self.view addSubview:btn];
    
    // 初始化并添加 UIWebView
   
    CGFloat halfHeight = self.view.bounds.size.height / 2;
    
    // 创建并初始化 UIWebView，设置其大小和位置
    CGRect webViewFrame = CGRectMake(0, halfHeight, self.view.bounds.size.width, halfHeight);
    self.webView = [[UIWebView alloc] initWithFrame:webViewFrame];
//    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    
    // 初始化并添加 WKWebView
//    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
//    self.webView.navigationDelegate = self;
    
    [self.view addSubview:self.webView];
    
    // 初始化 WebViewJavascriptBridge
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    [self.bridge setWebViewDelegate:self];
    
    // 注册一个从 H5 接收消息的方法
    [self.bridge registerHandler:@"sendMessageToOC" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"接收到 H5 消息: %@", data);
        responseCallback(@"收到了消息");
    }];
    
    // 加载网页
//    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [self.webView loadRequest:request];
    
    // 加载本地 HTML 文件
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSString *htmlContent = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:htmlContent baseURL:[[NSBundle mainBundle] bundleURL]];

}

- (void)sendMessageToH5:(UIButton *) button {
    [self.bridge callHandler:@"showMessage" data:@{@"message": @"Hello from Objective-C!"} responseCallback:^(id responseData) {
        NSLog(@"收到来自 H5 的响应: %@", responseData);
    }];
}

@end
