//
//  ViewController.m
//  DataRetention
//
//  Created by Ledger Heath on 2024/6/4.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:[NSDate date] forKey:@"LastLoginTime"];
    [defaults setBool:NO forKey:@"IsFirstLogin"];
    [defaults setValue:@"ledger" forKey:@"UserName"];
    
    [defaults synchronize];
    
    NSDate *lastLoginTime = [defaults objectForKey:@"LastLoginTime"];
    BOOL isFirstLogin = [defaults boolForKey:@"IsFirstLogin"];
    NSString *userName = [defaults valueForKey:@"UserName"];
    
    NSLog(@"%@--%d--%@", lastLoginTime, isFirstLogin, userName);

    [defaults removeObjectForKey:@"LastLoginTime"];
    
    NSLog(@"%@--%d--%@", lastLoginTime, isFirstLogin, userName);

}


@end
