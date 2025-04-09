//
//  MenuItemCell.h
//  PagedGridMenu
//
//  Created by Ledger Heath on 2025/4/8.
//

#import <UIKit/UIKit.h>
#import "MenuItemData.h" // 引入你的数据模型

NS_ASSUME_NONNULL_BEGIN

@interface MenuItemCell : UICollectionViewCell

@property (nonatomic, strong, readonly) UIImageView *iconImageView; // 图标视图
@property (nonatomic, strong, readonly) UILabel *titleLabel;     // 标题标签

// 配置 Cell 显示内容的方法
- (void)configureWithMenuItem:(MenuItemData *)item;

@end

NS_ASSUME_NONNULL_END
