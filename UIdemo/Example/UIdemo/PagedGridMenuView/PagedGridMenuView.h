//
//  PagedGridMenuView.h
//  PagedGridMenu
//
//  Created by Ledger Heath on 2025/4/8.
//

#import <UIKit/UIKit.h>
#import "MenuItemData.h" // 引入数据模型

NS_ASSUME_NONNULL_BEGIN

@class PagedGridMenuView; // 前向声明

// 定义代理协议，用于将点击事件传递出去
@protocol PagedGridMenuViewDelegate <NSObject>
@optional // 代理方法设为可选
- (void)pagedGridMenuView:(PagedGridMenuView *)menuView didSelectItem:(MenuItemData *)item atIndex:(NSInteger)index;
@end

@interface PagedGridMenuView : UIView

@property (nonatomic, weak) id<PagedGridMenuViewDelegate> delegate; // 代理对象

// 设置要显示的菜单项数组
@property (nonatomic, strong) NSArray<MenuItemData *> *menuItems;

// --- 可选的自定义外观属性 ---
@property (nonatomic, assign) CGFloat itemHeight; // 单项高度，默认 80
@property (nonatomic, assign) CGFloat verticalItemSpacing; // 项之间的垂直间距（行间距），默认 10
@property (nonatomic, assign) CGFloat horizontalItemSpacing; // 项之间的水平间距（列间距），默认 10
@property (nonatomic, assign) UIEdgeInsets contentPadding; // 整体内容区域的内边距，默认 (10, 15, 10, 15)
@property (nonatomic, strong) UIColor *pageControlIndicatorTintColor; // PageControl 普通点的颜色
@property (nonatomic, strong) UIColor *pageControlCurrentIndicatorTintColor; // PageControl 当前点的颜色

// 初始化方法
- (instancetype)initWithFrame:(CGRect)frame;

// 如果在初始设置后修改了 menuItems，调用此方法刷新
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
