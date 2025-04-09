//
//  CViewController.m
//  UIdemo_Example
//
//  Created by Ledger Heath on 2024/5/27.
//  Copyright © 2024 82560897. All rights reserved.
//

#import "CViewController.h"

@interface CViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property(nonatomic,strong)UICollectionView *collectionView;

@end

@implementation CViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITextView *textView = [UITextView new];
    textView.backgroundColor = UIColor.lightGrayColor;
    textView.text = @"1233455";
    [self.view addSubview:textView];
    [textView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    // 设置圆角
    textView.layer.cornerRadius = 10;  // 圆角半径为 10
    textView.layer.masksToBounds = YES;  // 确保子视图的内容也会在圆角范围内裁剪

    // 设置约束来居中
    [NSLayoutConstraint activateConstraints:@[
        [textView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [textView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        
        // 设置宽度和高度约束
        [textView.widthAnchor constraintEqualToConstant:400],
        [textView.heightAnchor constraintEqualToConstant:200]
    ]];
//    [self.view addSubview:self.collectionView];
//    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        _collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
        flowLayout.minimumInteritemSpacing = 40;
        flowLayout.minimumLineSpacing = 40;
        flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        flowLayout.itemSize = CGSizeMake(50, 50);
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
    }
    return _collectionView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 84;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor grayColor];
    return cell;
}

@end
