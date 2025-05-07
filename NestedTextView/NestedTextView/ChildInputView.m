//
//  ChildInputView.m
//  NestedTextView
//
//  Created by Ledger Heath on 2025/2/27.
//

#import "ChildInputView.h"

@interface ChildInputView () <UITextViewDelegate>
@end

@implementation ChildInputView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
        self.minWidth = 32; // 两个字的宽度
        self.minHeight = 20; // 一个字的高度
        self.font = [UIFont systemFontOfSize:16];
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.cornerRadius = 4;
    }
    return self;
}

- (void)updateSize {
    CGSize contentSize = [self sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    CGRect frame = self.frame;
    frame.size.width = MAX(contentSize.width + 10, self.minWidth); // 添加一些padding
    frame.size.height = MAX(contentSize.height, self.minHeight);
    self.frame = frame;
}

// UITextViewDelegate methods
- (void)textViewDidChange:(UITextView *)textView {
    [self updateSize];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
