//
//  PagedGridMenuView.m
//  PagedGridMenu
//
//  Created by Ledger Heath on 2025/4/8.
//

#import "PagedGridMenuView.h"
#import "MenuItemCell.h" // 引入你的 Cell
#import <Masonry/Masonry.h>

// --- 常量定义 ---
static const NSInteger kDefaultColumns = 4;         // 默认列数
static const NSInteger kDefaultRowsPerPage = 2;     // 每页默认行数（固定为2）
static const NSInteger kMaxItemsPerPage = kDefaultColumns * kDefaultRowsPerPage; // 每页最多项数 (8)
static const CGFloat kDefaultItemHeight = 80.0;    // 默认项高度
static const CGFloat kDefaultVerticalSpacing = 10.0; // 默认垂直间距
static const CGFloat kDefaultHorizontalSpacing = 10.0;// 默认水平间距
static const CGFloat kDefaultPageControlHeight = 20.0;// 默认 PageControl 高度
static const UIEdgeInsets kDefaultContentPadding = {10.0, 15.0, 10.0, 15.0}; // 默认内边距

@interface PagedGridMenuView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView; // 集合视图
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout; // 布局对象
@property (nonatomic, strong) UIPageControl *pageControl;       // 分页指示器

@property (nonatomic, assign) NSInteger actualRows;          // 实际显示的行数 (1 或 2)
@property (nonatomic, assign) CGFloat calculatedItemWidth;   // 计算出的项宽度
@property (nonatomic, assign) CGFloat calculatedHeight;      // 计算出的视图总高度

@end

@implementation PagedGridMenuView

#pragma mark - 初始化与设置

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupDefaults]; // 设置默认值
        [self setupViews];    // 初始化子视图
        [self setupConstraints]; // 设置约束
    }
    return self;
}

// 如果使用 Storyboard 或 XIB，会调用此方法
- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupDefaults];
    [self setupViews];
    [self setupConstraints];
}

// 设置可自定义属性的默认值
- (void)setupDefaults {
    _itemHeight = kDefaultItemHeight;
    _verticalItemSpacing = kDefaultVerticalSpacing;
    _horizontalItemSpacing = kDefaultHorizontalSpacing;
    _contentPadding = kDefaultContentPadding;
    _pageControlIndicatorTintColor = [UIColor lightGrayColor];
    _pageControlCurrentIndicatorTintColor = [UIColor systemBlueColor];

    self.backgroundColor = [UIColor clearColor]; // 视图本身背景透明
}

// 初始化子视图
- (void)setupViews {
    // --- Flow Layout ---
    _flowLayout = [[UICollectionViewFlowLayout alloc] init];
    _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal; // 水平滚动
    // 间距将在 layoutSubviews 或代理方法中设置

    // --- Collection View ---
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_flowLayout];
    _collectionView.backgroundColor = [UIColor clearColor]; // 背景由外部容器处理
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.showsHorizontalScrollIndicator = NO; // 隐藏水平滚动条
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.pagingEnabled = YES; // 开启分页
    _collectionView.bounces = YES; // 允许弹簧效果
    // 注册 Cell
    [_collectionView registerClass:[MenuItemCell class] forCellWithReuseIdentifier:NSStringFromClass([MenuItemCell class])];
    [self addSubview:_collectionView];

    // --- Page Control ---
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.hidesForSinglePage = YES; // 单页时自动隐藏
    _pageControl.userInteractionEnabled = NO; // 通常不允许用户点击切换，由滚动驱动
    _pageControl.pageIndicatorTintColor = self.pageControlIndicatorTintColor;
    _pageControl.currentPageIndicatorTintColor = self.pageControlCurrentIndicatorTintColor;
    _pageControl.backgroundColor = [UIColor clearColor];
    [self addSubview:_pageControl];
}

// 设置子视图约束
- (void)setupConstraints {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(self.contentPadding.top);
        make.leading.equalTo(self).offset(self.contentPadding.left);
        make.trailing.equalTo(self).offset(-self.contentPadding.right);
        // 底部的约束会根据 pageControl 是否可见来调整
    }];

    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.collectionView.mas_bottom).offset(5); // 与 collectionView 间距 5
        make.leading.equalTo(self).offset(self.contentPadding.left);
        make.trailing.equalTo(self).offset(-self.contentPadding.right);
        make.height.mas_equalTo(kDefaultPageControlHeight); // 固定高度
        make.bottom.equalTo(self).offset(-self.contentPadding.bottom); // 底部对齐
    }];
}

#pragma mark - 布局与尺寸计算

// !!! 核心：为 Auto Layout 提供内容固有尺寸 !!!
- (CGSize)intrinsicContentSize {
    // 宽度通常由外部约束决定，返回 UIViewNoIntrinsicMetric
    // 高度是我们计算出的 `calculatedHeight`
    return CGSizeMake(UIViewNoIntrinsicMetric, self.calculatedHeight);
}

// 在这里进行依赖于当前视图尺寸的计算和布局更新
- (void)layoutSubviews {
    [super layoutSubviews];

    // 1. 根据数据项数量确定实际需要的行数
    self.actualRows = (self.menuItems.count <= kDefaultColumns) ? 1 : kDefaultRowsPerPage; // 最多2行

    // 2. 计算可用于放置 Item 的宽度
    CGFloat availableWidth = self.bounds.size.width - self.contentPadding.left - self.contentPadding.right;
    if (availableWidth <= 0) {
         self.calculatedHeight = self.contentPadding.top + self.contentPadding.bottom; // 至少是内边距高度
         [self invalidateIntrinsicContentSize]; // 通知 Auto Layout 尺寸可能变化
        return; // 宽度无效，无法布局
    }

    // 3. 计算每个 Item 的宽度
    // 使用 floor 避免像素小数问题
    self.calculatedItemWidth = floor((availableWidth - (kDefaultColumns - 1) * self.horizontalItemSpacing) / kDefaultColumns);
    if (self.calculatedItemWidth < 0) self.calculatedItemWidth = 0;

    // 4. 更新 FlowLayout 的间距属性
    self.flowLayout.minimumLineSpacing = self.horizontalItemSpacing; // 水平滚动时，行间距代表列间距
    self.flowLayout.minimumInteritemSpacing = self.verticalItemSpacing; // 水平滚动时，项间距代表行间距
    // Item 的尺寸由代理方法 `sizeForItemAtIndexPath` 提供

    // 5. 计算 CollectionView 内容部分所需的高度
    CGFloat collectionViewContentHeight = (self.actualRows * self.itemHeight) +
                                          ((self.actualRows > 1) ? self.verticalItemSpacing * (self.actualRows - 1) : 0);

    // 6. 判断是否需要分页，计算 PageControl 的高度（包括其顶部间距）
    BOOL needsPaging = self.menuItems.count > kMaxItemsPerPage;
    CGFloat pageControlHeightWithSpacing = needsPaging ? (kDefaultPageControlHeight + 5) : 0; // 5 是 pageControl 顶部的间距

    // 7. 计算视图总高度
    self.calculatedHeight = self.contentPadding.top +           // 顶部内边距
                            collectionViewContentHeight +        // CollectionView 内容高度
                            pageControlHeightWithSpacing +       // PageControl 高度（如果需要）
                            self.contentPadding.bottom;         // 底部内边距

    // 8. 更新 PageControl 的状态
    self.pageControl.hidden = !needsPaging;
    NSInteger numberOfPages = needsPaging ? (NSInteger)ceil((double)self.menuItems.count / kMaxItemsPerPage) : 1;
    self.pageControl.numberOfPages = numberOfPages;
    self.collectionView.scrollEnabled = needsPaging; // 只有多页时才允许滚动

    // 9. 根据 PageControl 是否可见，调整 CollectionView 的底部约束
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(self.contentPadding.top);
        make.leading.equalTo(self).offset(self.contentPadding.left);
        make.trailing.equalTo(self).offset(-self.contentPadding.right);
        if (needsPaging) {
            // 如果有 PageControl，则底部约束到 PageControl 顶部，留出间距
            make.bottom.equalTo(self.pageControl.mas_top).offset(-5);
        } else {
            // 如果没有 PageControl，则底部约束到底部内边距边缘
            // make.bottom.equalTo(self).offset(-self.contentPadding.bottom);
             // 或者直接设置高度，避免潜在的约束冲突
             make.height.mas_equalTo(collectionViewContentHeight);
             // 同时确保它不会超过底部边界（虽然上面设置高度可能更直接）
             make.bottom.lessThanOrEqualTo(self).offset(-self.contentPadding.bottom);
        }
    }];

    // 10. 如果计算出的高度变化了，通知 Auto Layout 系统
    // 可以添加判断 `if (oldHeight != self.calculatedHeight)` 来优化，避免不必要的更新
    [self.flowLayout invalidateLayout]; // 让 FlowLayout 根据新尺寸重新计算内部布局
    [self invalidateIntrinsicContentSize]; // 告诉 Auto Layout 固有尺寸已改变

    // 11. 布局完成后，更新 PageControl 的当前页指示器
     [self updatePageControlCurrentPage];
}

#pragma mark - 数据处理

- (void)setMenuItems:(NSArray<MenuItemData *> *)menuItems {
    _menuItems = [menuItems copy]; // 使用 copy 保护数据
    [self reloadData]; // 设置新数据后刷新视图
}

// 刷新视图的核心方法
- (void)reloadData {
    // 触发 layoutSubviews 来重新计算尺寸和布局
    [self setNeedsLayout];
    // 可以选择立即布局，确保在 reloadData 前尺寸是最新的
    // [self layoutIfNeeded];

    // 刷新 CollectionView 数据
    [self.collectionView reloadData];

    // 重置滚动位置到第一页
    if (self.menuItems.count > 0) {
        [self.collectionView setContentOffset:CGPointZero animated:NO];
    }
    // 重置 PageControl 到第一页
    self.pageControl.currentPage = 0;
}

#pragma mark - UICollectionViewDataSource (数据源)

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1; // 只有一个 Section
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.menuItems.count; // 返回数据项的总数
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 复用 Cell
    MenuItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([MenuItemCell class]) forIndexPath:indexPath];

    // 配置 Cell
    if (indexPath.item < self.menuItems.count) {
        MenuItemData *item = self.menuItems[indexPath.item];
        [cell configureWithMenuItem:item];
    } else {
        // 理论上不应发生，但做防御性处理
        [cell configureWithMenuItem:nil]; // 或者清空 Cell 内容
    }

    return cell;
}

#pragma mark - UICollectionViewDelegate (交互代理)

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // 处理点击事件
    if (indexPath.item < self.menuItems.count) {
        MenuItemData *item = self.menuItems[indexPath.item];
        // 调用代理方法，将事件传递出去
        if (self.delegate && [self.delegate respondsToSelector:@selector(pagedGridMenuView:didSelectItem:atIndex:)]) {
            [self.delegate pagedGridMenuView:self didSelectItem:item atIndex:indexPath.item];
        }
        NSLog(@"点击了项目: %@", item.title); // 示例日志输出
    }
     // 点击后取消选中状态（视觉效果）
     [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

#pragma mark - UICollectionViewDelegateFlowLayout (布局代理)

// 提供每个 Item 的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    // 宽度在 layoutSubviews 中计算好了，高度是固定的（或由属性 itemHeight 控制）
    return CGSizeMake(self.calculatedItemWidth, self.itemHeight);
}

// 注意：本实现中，Section 的内边距是通过视图自身的 contentPadding 和约束来控制的，
// 所以不需要在这里实现 `insetForSectionAtIndex`。
// 行间距和列间距已在 layoutSubviews 中设置给 flowLayout。

#pragma mark - UIScrollViewDelegate (滚动代理 - 用于 PageControl)

// 用户手动滑动，滚动减速完全停止后调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        [self updatePageControlCurrentPage]; // 更新 PageControl 指示器
    }
}

// 通过代码设置滚动动画结束（例如 setContentOffset:animated:YES）后调用
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
     if (scrollView == self.collectionView) {
        [self updatePageControlCurrentPage];
    }
}

// 辅助方法：根据当前滚动位置更新 PageControl 的页码
- (void)updatePageControlCurrentPage {
    // 仅在 PageControl 可见时更新
    if (!self.pageControl.isHidden) {
        CGFloat pageWidth = self.collectionView.bounds.size.width;
        if (pageWidth > 0) {
            // 计算当前页码（基于滚动视图中心点所在的页）
            NSInteger currentPage = round(self.collectionView.contentOffset.x / pageWidth);

            // 确保页码在有效范围内
            currentPage = MAX(0, currentPage);
            currentPage = MIN(self.pageControl.numberOfPages - 1, currentPage);

            // 只有当页码实际改变时才更新，避免不必要的重绘
            if (self.pageControl.currentPage != currentPage) {
                 self.pageControl.currentPage = currentPage;
            }
        }
    }
}

#pragma mark - 自定义属性 Setters (可选)

// 如果允许外部修改外观属性，提供 setter 方法并在其中触发重新布局
- (void)setItemHeight:(CGFloat)itemHeight {
    if (_itemHeight != itemHeight) {
        _itemHeight = itemHeight;
        [self setNeedsLayout]; // 标记需要重新布局
    }
}
// ... 为 verticalItemSpacing, horizontalItemSpacing, contentPadding, pageControl 颜色等添加类似的 setter ...
// 修改尺寸相关的属性后，都需要调用 [self setNeedsLayout];
// 修改颜色相关的属性，直接更新对应的控件即可，例如 self.pageControl.pageIndicatorTintColor = color;

@end
