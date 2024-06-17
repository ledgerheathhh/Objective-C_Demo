//
//  UViewController.m
//  UIdemo
//
//  Created by 82560897 on 05/27/2024.
//  Copyright (c) 2024 82560897. All rights reserved.
//

#import "UViewController.h"

@interface UViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView * tableView;
@property (strong, nonatomic) NSMutableArray *data;

@end

@implementation UViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //    UIButton *myButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    myButton.frame = CGRectMake(50, 50, 250, 50);
    //    [myButton setTitle:@"正常状态" forState:UIControlStateNormal];
    //    [myButton setTitle:@"高亮状态" forState:UIControlStateHighlighted];
    //    [myButton setImage:[UIImage imageNamed:@"img1"] forState:UIControlStateNormal];
    //    [myButton setImage:[UIImage imageNamed:@"img2"] forState:UIControlStateHighlighted];
    //    myButton.backgroundColor = [UIColor redColor];
    //    [self.view addSubview:myButton];
    //
    //    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"image"]];
    //    //创建一个与屏幕等宽等高的滚动视图
    //    UIScrollView *myScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    //    //设置滚动区域的大小
    //    myScrollView.contentSize = imageView.bounds.size;
    //    //设置滚动视图的其他属性
    //    myScrollView.backgroundColor = [UIColor redColor];
    //    myScrollView.contentOffset = CGPointMake(0, 0);
    //    myScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    //    //添加子视图
    //    [myScrollView addSubview:imageView];
    //    [self.view addSubview:myScrollView];
    
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    NSArray *array=@[@"iphone-1",@"iphone-2",@"iphone-3",@"iphone-4",@"iphone-5",@"iphone-6",@"iphone-7",@"iphone-8",@"iphone-9",@"iphone-10",@"iphone-11",@"iphone-12",@"iphone-13",@"iphone-14",@"iphone-15",@"iphone-16"];
    // 设置可变数组
    self.data= [NSMutableArray arrayWithArray: array];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.dataSource = self; //设置数据源对象
        _tableView.delegate = self;
    }
    return _tableView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.data.count;
}

-(__kindof UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //初始化cell
    static NSString *cellID = @"cell";
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    //    if (cell == nil) {
    //        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    //    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    //随机数据
    //    NSString *text = [NSString stringWithFormat:@"%d", arc4random_uniform(1000000)];
    NSString *text = self.data[indexPath.row];
    
    //设值
    cell.textLabel.text = text;
    return cell;
}

- (nullable NSArray <UITableViewRowAction *>*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"添加" handler:nil];
    UITableViewRowAction *action2 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"移动" handler:nil];
    UITableViewRowAction *action3 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:nil];
    NSArray *actionArray = @[action1,action2,action3];
    return actionArray;
}


- (nullable NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"调用tableView:willSelectRowAtIndexPath:%@",indexPath);
    return indexPath;
}

- (nullable NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"调用tableView:willDeselectRowAtIndexPath:%@",indexPath);
    return indexPath;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"调用tableView:didSelectRowAtIndexPath:方法");
//}

//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"调用tableView:didDeselectRowAtIndexPath:方法");
//}

@end
