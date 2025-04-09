//
//  MenuItemCell.m
//  PagedGridMenu
//
//  Created by Ledger Heath on 2025/4/8.
//

#import "MenuItemCell.h"
#import <Masonry/Masonry.h> // 使用 Masonry 简化布局

@interface MenuItemCell()
// 将 readonly 属性改为 readwrite 以在内部设置
@property (nonatomic, strong, readwrite) UIImageView *iconImageView;
@property (nonatomic, strong, readwrite) UILabel *titleLabel;
@end

@implementation MenuItemCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];      // 初始化子视图
        [self setupConstraints]; // 设置子视图约束
    }
    return self;
}

// 初始化和配置子视图
- (void)setupViews {
    self.contentView.backgroundColor = [UIColor whiteColor]; // 或 clear，根据设计需要
    self.contentView.clipsToBounds = YES;
    self.contentView.layer.cornerRadius = 8.0; // 示例圆角样式

    _iconImageView = [[UIImageView alloc] init];
    _iconImageView.contentMode = UIViewContentModeScaleAspectFit; // 图标显示模式
    [self.contentView addSubview:_iconImageView];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont systemFontOfSize:13.0]; // 标题字体
    _titleLabel.textColor = [UIColor darkTextColor];  // 标题颜色
    _titleLabel.textAlignment = NSTextAlignmentCenter; // 居中对齐
    _titleLabel.numberOfLines = 1; // 标题行数，根据需要调整
    [self.contentView addSubview:_titleLabel];
}

// 设置子视图的约束
- (void)setupConstraints {
    // 示例布局：图标在上，文字在下，整体居中
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        // 根据你的图标大小需求调整顶部偏移和尺寸
        make.top.equalTo(self.contentView).offset(10); // 距离顶部10
        make.width.height.equalTo(@40); // 示例尺寸 40x40
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconImageView.mas_bottom).offset(5); // 在图标下方5
        make.leading.equalTo(self.contentView).offset(4);   // 左右边距4
        make.trailing.equalTo(self.contentView).offset(-4);
        make.bottom.lessThanOrEqualTo(self.contentView).offset(-5); // 距离底部至少5，允许内容压缩
    }];
}

// 根据传入的数据模型配置 Cell 内容
- (void)configureWithMenuItem:(MenuItemData *)item {
    self.titleLabel.text = item.title;
    if (item.imageName.length > 0) {
        // 考虑设置占位图片
        self.iconImageView.image = [UIImage imageNamed:item.imageName];
    } else {
        self.iconImageView.image = nil; // 或者设置一个默认图标
    }
    // 如果需要，重置之前的状态
}

// 可选：添加高亮状态以提供视觉反馈
- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.contentView.alpha = highlighted ? 0.7 : 1.0; // 点击时变暗
}

@end
