//
//  ViewController.m
//  LayoutDemo
//
//  Created by Ledger Heath on 2024/6/6.
//

#import "MViewController.h"
#import "Masonry.h"

@interface MViewController ()

@end

@implementation MViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 创建一个视图
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    view.backgroundColor = [UIColor blueColor];
    [self.view addSubview:view];
    
    // 获取视图的图层
    CALayer *layer = view.layer;
    
    // 设置圆角
    layer.cornerRadius = 20.0;
    
    // 设置边框
    layer.borderWidth = 5.0;
    layer.borderColor = [UIColor whiteColor].CGColor;
    
    // 设置阴影
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOffset = CGSizeMake(5, 5);
    layer.shadowOpacity = 0.7;
    layer.shadowRadius = 10.0;
    
    // 创建基本动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:layer.position];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(400, 100)];
    animation.duration = 2.0;
    
    // 更新图层的位置
    layer.position = CGPointMake(400, 100);
    
    // 添加动画到图层
    [layer addAnimation:animation forKey:@"positionAnimation"];
    
    // 创建一个按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"Press Me" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showAlert) forControlEvents:UIControlEventTouchUpInside];
    
    // 设置按钮的文字颜色
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal]; // 正常状态下的字体颜色
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted]; // 按下状态下的字体颜色
//    [button setBackgroundColor:UIColor.cyanColor];
    
    // 创建纯色图片作为背景图片
    UIImage *normalBackgroundImage = [self imageWithColor:[UIColor blueColor]];
    UIImage *highlightedBackgroundImage = [self imageWithColor:[UIColor lightGrayColor]];

    // 设置按钮的背景图片
    [button setBackgroundImage:normalBackgroundImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];

    // 设置按钮的圆角
    button.layer.cornerRadius = 10.0; // 设置圆角半径
    button.layer.masksToBounds = YES; // 将多余的部分裁剪掉，确保圆角生效
    
    button.translatesAutoresizingMaskIntoConstraints = NO; // 关闭自动布局，因为我们将使用约束
    
    // 将按钮添加到视图中
    [self.view addSubview:button];
    self.view.backgroundColor = UIColor.whiteColor;
    
    // 创建约束
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:button
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1.0
                                                                          constant:0.0];
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:button
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0
                                                                          constant:0.0];
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:button
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeNotAnAttribute
                                                                      multiplier:1.0
                                                                        constant:100.0];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:button
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant:50.0];
    
    // 激活约束
    [NSLayoutConstraint activateConstraints:@[centerXConstraint, centerYConstraint, widthConstraint, heightConstraint]];
}

// 颜色渲染方法
- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0, 0.0, 1.0, 1.0);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)showAlert {
    // 创建 UIAlertController 实例
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Title"
                                                                   message:@"This is a message."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    // 添加 "确定" 操作
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
        // 处理确定按钮点击事件
        NSLog(@"OK button tapped.");
    }];
    
    [alert addAction:okAction];
    
    // 显示 UIAlertController
    [self presentViewController:alert animated:YES completion:nil];
}
@end
