//
//  ParentInputView.h
//  NestedTextView
//
//  Created by Ledger Heath on 2025/2/27.
//

#import <UIKit/UIKit.h>
@class ChildInputView;

NS_ASSUME_NONNULL_BEGIN

@interface ParentInputView : UITextView

@property (nonatomic, strong) NSMutableArray<ChildInputView *> *childInputViews;
@property (nonatomic, assign) CGFloat minHeight;

- (void)insertChildInputViewAtCurrentPosition;
- (NSString *)getAllContent;

@end

NS_ASSUME_NONNULL_END
