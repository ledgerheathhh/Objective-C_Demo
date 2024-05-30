//
//  main.m
//  Thread
//
//  Created by Ledger Heath on 2024/5/20.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
//        NSLog(@"\n Start Time:%@, \n Current Thread: %@, \n Main Thread: %@", [NSDate date], [NSThread currentThread], [NSThread mainThread]);
//        [NSThread sleepForTimeInterval:1.0];
//        //记录结束时间
//        NSLog(@"\n End Time:%@, \n Current Thread: %@, \n Main Thread: %@", [NSDate date], [NSThread currentThread], [NSThread mainThread]);
//        
        
//        //获取并行队列
//        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//        //创建异步任务，并放到并行队列中执行
//        dispatch_async(queue, ^{
//            for (int i = 0; i<2; i++) {
//                NSLog(@"task1:%d",i);
//            }
//            NSLog(@"task1----%@",[NSThread currentThread]);
//        });
//        dispatch_async(queue, ^{
//            for (int i = 0; i<2; i++) {
//                NSLog(@"task2:%d",i);
//            }
//            NSLog(@"task2----%@",[NSThread currentThread]);
//        });
//        dispatch_async(queue, ^{
//            for (int i = 0; i<2; i++) {
//                NSLog(@"task3:%d",i);
//            }
//            NSLog(@"task3----%@",[NSThread currentThread]);
//        });
        
//        //创建串行队列
//        dispatch_queue_t queue = dispatch_queue_create("test", NULL);
//        //创建异步任务
//        dispatch_async(queue, ^{
//            for (int i = 0; i<2; i++) {
//                NSLog(@"task1:%d",i);
//            }
//            NSLog(@"task1----%@",[NSThread currentThread]);
//        });
//        dispatch_async(queue, ^{
//            for (int i = 0; i<2; i++) {
//                NSLog(@"task2:%d",i);
//            }
//            NSLog(@"task2----%@",[NSThread currentThread]);
//        });
//        dispatch_async(queue, ^{
//            for (int i = 0; i<2; i++) {
//                NSLog(@"task3:%d",i);
//            }
//            NSLog(@"task3----%@",[NSThread currentThread]);
//        });

        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 1.0 秒后异步追加任务代码到主队列，并开始执行
                NSLog(@"after---%@",[NSThread currentThread]);
         });
        
//        [NSThread sleepForTimeInterval:60.0];
        
        // 创建一个 dispatch group
        dispatch_group_t group = dispatch_group_create();
        
        // 获取并行队列
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        // 创建异步任务，并放到并行队列中执行
        dispatch_group_async(group, queue, ^{
            for (int i = 0; i < 2; i++) {
                NSLog(@"task1:%d", i);
            }
            NSLog(@"task1----%@", [NSThread currentThread]);
        });
        dispatch_group_async(group, queue, ^{
            for (int i = 0; i < 2; i++) {
                NSLog(@"task2:%d", i);
            }
            NSLog(@"task2----%@", [NSThread currentThread]);
        });
        dispatch_group_async(group, queue, ^{
            for (int i = 0; i < 2; i++) {
                NSLog(@"task3:%d", i);
            }
            NSLog(@"task3----%@", [NSThread currentThread]);
        });
        
        // 等待所有任务完成
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
        
        NSLog(@"All tasks are done.");
        
        NSBlockOperation *task1 = [NSBlockOperation blockOperationWithBlock:^{
            NSLog(@"newtask1-----%@", [NSThread currentThread]);
        }];
        NSBlockOperation *task2 = [NSBlockOperation blockOperationWithBlock:^{
            NSLog(@"newtask2-----%@", [NSThread currentThread]);
        }];
        NSBlockOperation *task3 = [NSBlockOperation blockOperationWithBlock:^{
            NSLog(@"newtask3-----%@", [NSThread currentThread]);
        }];
        NSBlockOperation *task4 = [NSBlockOperation blockOperationWithBlock:^{
            NSLog(@"newtask4-----%@", [NSThread currentThread]);
        }];
        NSBlockOperation *task5 = [NSBlockOperation blockOperationWithBlock:^{
            NSLog(@"newtask5-----%@", [NSThread currentThread]);
        }];
        //创建队列
        NSOperationQueue *queue2 = [[NSOperationQueue alloc] init];
        //设置队列属性
        queue2.maxConcurrentOperationCount = 5;
        //添加任务到队列
        [queue2 addOperation:task1];
        [queue2 addOperation:task2];
        [queue2 addOperation:task3];
        [queue2 addOperation:task4];
        [queue2 addOperation:task5];
        
//        //调用start方法，会在当前线程中串行执行
//        [task1 start];
//        [task2 start];
        
        
        [NSThread sleepForTimeInterval:60.0];

    }
    return 0;
}
