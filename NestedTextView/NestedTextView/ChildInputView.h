//
//  ChildInputView.h
//  NestedTextView
//
//  Created by Ledger Heath on 2025/2/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChildInputView : UITextView

@property (nonatomic, weak) UITextView *parentTextView;
@property (nonatomic, assign) CGFloat minWidth;
@property (nonatomic, assign) CGFloat minHeight;

- (void)updateSize;

@end

NS_ASSUME_NONNULL_END
