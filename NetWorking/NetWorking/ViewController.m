//
//  ViewController.m
//  NetWorking
//
//  Created by Ledger Heath on 2024/6/3.
//

#import "ViewController.h"
#import "AFNetworking.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self fetchDataFromAPI];
    
//    [self sendPostRequest];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:@"https://jsonplaceholder.typicode.com/todos/1"
      parameters:nil
         headers:nil
        progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             NSLog(@"JSON: %@", responseObject);
         }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"Error: %@", error);
         }];


}

- (void)fetchDataFromAPI {
    // 创建URL
    NSURL *url = [NSURL URLWithString:@"https://jsonplaceholder.typicode.com/todos/1"];

    // 创建NSURLSession对象
    NSURLSession *session = [NSURLSession sharedSession];

    // 创建数据任务
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Error: %@", error.localizedDescription);
            });
            return;
        }

        if (data) {
            NSError *jsonError;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"JSON Error: %@", jsonError.localizedDescription);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"JSON response: %@", jsonObject);
                });
            }
        }
    }];

    // 启动任务
    [dataTask resume];
}

- (void)sendPostRequest {
    // 创建URL
    NSURL *url = [NSURL URLWithString:@"https://jsonplaceholder.typicode.com/posts"];
    
    // 创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    // 设置请求头
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // 创建要发送的JSON数据
    NSDictionary *jsonBodyDict = @{@"title": @"foo", @"body": @"bar", @"userId": @1};
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonBodyDict options:0 error:&jsonError];
    
    if (jsonError) {
        NSLog(@"JSON Error: %@", jsonError.localizedDescription);
        return;
    }
    
    request.HTTPBody = jsonData;
    
    // 创建NSURLSession对象
    NSURLSession *session = [NSURLSession sharedSession];
    
    // 创建数据任务
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Error: %@", error.localizedDescription);
            });
            return;
        }
        
        if (data) {
            NSError *jsonError;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (jsonError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"JSON Error: %@", jsonError.localizedDescription);
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"JSON response: %@", jsonObject);
                });
            }
        }
    }];
    
    // 启动任务
    [dataTask resume];
}

@end
