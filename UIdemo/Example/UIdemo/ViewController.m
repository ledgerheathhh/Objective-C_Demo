//
//  ViewController.m
//  PagedGridMenu
//
//  Created by Ledger Heath on 2025/4/8.
//

#import "ViewController.h"
#import "PagedGridMenuView.h" // 引入你的菜单视图头文件
#import "MenuItemData.h"    // 引入你的数据模型头文件
#import <Masonry/Masonry.h> // 或者使用系统自带的 NSLayoutAnchor

@interface ViewController () <PagedGridMenuViewDelegate> // 遵守代理协议

@property (nonatomic, strong) PagedGridMenuView *menuView; // 持有菜单视图
@property (nonatomic, strong) NSArray<MenuItemData *> *menuItems; // 持有菜单数据

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor]; // 设置背景色方便观察

    // 1. 创建菜单数据 (示例)
    // 传入不同数量测试效果 (例如 3, 7, 12)
    self.menuItems = [self createSampleMenuItems:12];

    // 2. 创建菜单视图实例
    self.menuView = [[PagedGridMenuView alloc] initWithFrame:CGRectZero]; // 初始 frame 不重要
    self.menuView.translatesAutoresizingMaskIntoConstraints = NO; // 必须设置 NO 以使用 Auto Layout
    self.menuView.delegate = self; // 设置代理，接收点击事件
    self.menuView.backgroundColor = [UIColor whiteColor]; // 给菜单容器设置背景色
    self.menuView.layer.cornerRadius = 12.0; // 设置圆角
    self.menuView.layer.masksToBounds = YES; // 配合圆角裁剪

    // --- 可选：自定义外观 ---
    // self.menuView.itemHeight = 90; // 修改项高度
    // self.menuView.horizontalItemSpacing = 15; // 修改水平间距
    // self.menuView.contentPadding = UIEdgeInsetsMake(15, 20, 15, 20); // 修改内边距
    // self.menuView.pageControlCurrentIndicatorTintColor = [UIColor orangeColor]; // 修改 PageControl 颜色
    // -----------------------

    [self.view addSubview:self.menuView]; // 添加到视图层级

    // 3. 设置数据 (可以在添加到视图层级之后设置)
    self.menuView.menuItems = self.menuItems;

    // 4. 设置约束 (示例使用 Masonry)
    [self.menuView mas_makeConstraints:^(MASConstraintMaker *make) {
        // 顶部约束到安全区域上方 20
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(20);
        // 左右约束到父视图边缘，留出 15 边距
        make.leading.equalTo(self.view).offset(15);
        make.trailing.equalTo(self.view).offset(-15);
        // !!! 高度由 intrinsicContentSize 决定，不需要设置高度约束 !!!
    }];
}

// 辅助方法：创建示例数据
- (NSArray<MenuItemData *> *)createSampleMenuItems:(NSInteger)count {
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:count];
    for (NSInteger i = 0; i < count; i++) {
        MenuItemData *item = [[MenuItemData alloc] init];
        item.title = [NSString stringWithFormat:@"功能 %ld", (long)i + 1];
        // 可以根据需要设置不同的图片，或者保持 imageName 为 nil
        // 假设你有 "icon_placeholder_1", "icon_placeholder_2", ... 的图片资源
        item.imageName = [NSString stringWithFormat:@"icon_placeholder_%ld", (i % 3) + 1];
        [items addObject:item];
    }
    return [items copy];
}

#pragma mark - PagedGridMenuViewDelegate (实现代理方法)

// 处理菜单项点击事件
- (void)pagedGridMenuView:(PagedGridMenuView *)menuView didSelectItem:(MenuItemData *)item atIndex:(NSInteger)index {
    NSLog(@"代理方法：点击了 '%@'，索引是 %ld", item.title, (long)index);

    // 在这里执行你的操作，例如页面跳转、执行任务等
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"菜单项被点击"
                                                                   message:[NSString stringWithFormat:@"你选择了: %@", item.title]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
