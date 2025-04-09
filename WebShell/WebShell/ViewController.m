//
//  ViewController.m
//  WebShell
//
//  Created by Ledger Heath on 2024/10/15.
//

#import "ViewController.h"
#import "WebKit/WebKit.h"

@interface ViewController () <WKNavigationDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [super viewDidLoad];

    // 创建 WKWebView
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    webView.navigationDelegate = self;
    [self.view addSubview:webView];
    
    // 禁用自动生成的约束
    webView.translatesAutoresizingMaskIntoConstraints = NO;

    // 设置约束，使用整个屏幕
    [NSLayoutConstraint activateConstraints:@[
        [webView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [webView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [webView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [webView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]
    ]];

    // 加载在线网页
//    NSURL *url = [NSURL URLWithString:@"https://www.apple.com"];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [webView loadRequest:request];
    
    // 获取本地 HTML 文件路径
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];

    // 允许访问的目录
    NSURL *readAccessURL = [fileURL URLByDeletingLastPathComponent];

    // 加载本地 HTML 文件
    [webView loadFileURL:fileURL allowingReadAccessToURL:readAccessURL];

}

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"页面开始加载");
}

// 页面导航完成时调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"页面导航完成");

    // 使用 dispatch_after 来延迟3秒后执行代码，而不阻塞线程
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // 在延迟后执行 JavaScript 获取性能数据
        [webView evaluateJavaScript:@"JSON.stringfy(window.performance.timing)" completionHandler:^(id result, NSError *error) {
            if (!error && result) {
                NSData *jsonData = [result dataUsingEncoding:NSUTF8StringEncoding];
                NSError *jsonError;
                NSDictionary *timingData = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&jsonError];
                
                if(jsonError){
                    NSLog(@"JSON解析失败：%@",jsonError.localizedDescription);
                    return;
                }
                // 获取白屏时间
                NSNumber *navigationStart = timingData[@"navigationStart"];
                NSNumber *responseStart = timingData[@"responseStart"];
                if (navigationStart && responseStart) {
                    NSTimeInterval whiteScreenTime = [responseStart doubleValue] - [navigationStart doubleValue];
                    NSLog(@"白屏时间: %.2f 秒", whiteScreenTime);
                }
                
                // 获取可交互时间
                NSNumber *domContentLoadedEventStart = timingData[@"domContentLoadedEventStart"];
                if (navigationStart && domContentLoadedEventStart) {
                    NSTimeInterval interactiveTime = [domContentLoadedEventStart doubleValue] - [navigationStart doubleValue];
                    NSLog(@"可交互时间: %.2f 秒", interactiveTime);
                }
            }
        }];
    });
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"页面加载失败: %@", error.localizedDescription);
}

@end
