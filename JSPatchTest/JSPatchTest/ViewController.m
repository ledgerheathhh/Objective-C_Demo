//
//  ViewController.m
//  JSPatchTest
//
//  Created by Ledger Heath on 2024/5/22.
//

#import "ViewController.h"

@interface ViewController ()

- (void)executeBlock:(void (^)(NSString *message))completion;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(100, 100, 100, 50);
    [button setTitle:@"Click Me" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor grayColor];
    [button addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeSystem];
    button1.frame = CGRectMake(100, 200, 100, 50);
    button.backgroundColor = [UIColor grayColor];
    [button1 setTitle:@"executeBlock" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(request:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
}

- (void)buttonClicked {
    self.view.backgroundColor = [UIColor redColor];
}

+ (void)request:(void(^)(NSString *content, BOOL success))callback
{
  callback(@"I'm content", YES);
}


typedef void (^JSBlock)(NSDictionary *dict);
+ (JSBlock)genBlock
{
  NSString *ctn = @"JSPatch";
  JSBlock block = ^(NSDictionary *dict) {
      NSLog(@"I'm %@, version: %@", ctn, dict[@"v"]);
  };
  return block;
}
+ (void)execBlock:(JSBlock)blk
{
}

@end
