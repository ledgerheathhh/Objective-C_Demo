//
//  MenuItemData.h
//  PagedGridMenu
//
//  Created by Ledger Heath on 2025/4/8.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h> // 如果直接存储 UIImage，则需要引入

NS_ASSUME_NONNULL_BEGIN

@interface MenuItemData : NSObject
@property (nonatomic, copy) NSString *title; // 标题
@property (nonatomic, copy, nullable) NSString *imageName; // 图片名称 (或者使用 UIImage *icon;)
// 可以添加其他相关数据，例如：目标URL、操作标识符等
@end

NS_ASSUME_NONNULL_END
