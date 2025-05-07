//
//  ParentInputView.m
//  NestedTextView
//
//  Created by Ledger Heath on 2025/2/27.
//

#import "ParentInputView.h"
#import "ChildInputView.h"

@interface ParentInputView () <UITextViewDelegate>
@end

@implementation ParentInputView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.childInputViews = [NSMutableArray array];
        self.delegate = self;
        self.minHeight = 20; // 一个字的高度
        self.font = [UIFont systemFontOfSize:16];
        self.scrollEnabled = YES;
        // 修改 frame 的宽度
        CGRect newFrame = self.frame;
        newFrame.size.width = 400;
        self.frame = newFrame;
    }
    return self;
}

- (void)insertChildInputViewAtCurrentPosition {
    if (self.childInputViews.count >= 2) {
        return; // 最多两个子输入框
    }
    
    NSRange selectedRange = self.selectedRange;
    ChildInputView *childView = [[ChildInputView alloc] initWithFrame:CGRectMake(0, 0, 32, 20)]; // 初始大小为两个字宽，一个字高
    childView.parentTextView = self;
    [self addSubview:childView];
    
    // 在当前光标位置插入特殊字符作为占位符
    NSAttributedString *attachment = [[NSAttributedString alloc] initWithString:@"\uFFFC"];
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    [attrText insertAttributedString:attachment atIndex:selectedRange.location];
    self.attributedText = attrText;
    
    [self.childInputViews addObject:childView];
    
    // 更新子视图位置
    [self layoutIfNeeded];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 更新所有子输入框的位置
    for (ChildInputView *childView in self.childInputViews) {
        // 计算子视图在父视图中的位置
        [childView updateSize];
    }
}

- (NSString *)getAllContent {
    NSMutableString *content = [NSMutableString string];
    NSAttributedString *text = self.attributedText;
    [content appendString:text.string];
    
    for (ChildInputView *childView in self.childInputViews) {
        [content appendString:childView.text];
    }
    
    return content;
}

// UITextViewDelegate methods
- (void)textViewDidChange:(UITextView *)textView {
    CGFloat newHeight = MAX(self.contentSize.height, self.minHeight);
    CGRect frame = self.frame;
    frame.size.height = newHeight;
    self.frame = frame;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
