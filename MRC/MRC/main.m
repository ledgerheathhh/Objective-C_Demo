//
//  main.m
//  MRC
//
//  Created by Ledger Heath on 2024/5/20.
//

#import <Foundation/Foundation.h>
#import "Person.h"
#import "Dog.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSObject *obj1 = [[NSObject alloc] init];
        NSLog(@"obj1 当前引用计数：%lu",(unsigned long)[obj1 retainCount]);
        NSObject *obj2 = [obj1 retain];
        NSLog(@"obj1 当前引用计数：%lu",(unsigned long)[obj1 retainCount]);
        [obj2 release];
        NSLog(@"obj1 当前引用计数：%lu",(unsigned long)[obj1 retainCount]);
        [obj1 release];
        
        // 只要创建一个对象默认引用计数器的值就是1
        Person *p = [[Person alloc] init];
        NSLog(@"retainCount = %lu", [p retainCount]); // 1

        // 只要给对象发送一个retain消息, 对象的引用计数器就会+1
        [p retain];

        NSLog(@"retainCount = %lu", [p retainCount]); // 2
        // 通过指针变量p,给p指向的对象发送一条release消息
        // 只要对象接收到release消息, 引用计数器就会-1
        // 只要一个对象的引用计数器为0, 系统就会释放对象

        [p release];
        // 需要注意的是: release并不代表销毁\回收对象, 仅仅是计数器-1
        NSLog(@"retainCount = %lu", [p retainCount]); // 1

        [p release]; // 0
        NSLog(@"--------");
//        [p setAge:20];    // 此时对象已经被释放
        
        
          
        Person *p2 = [[Person alloc] init]; // 执行完引用计数为1

        [p2 release]; // 执行完引用计数为0，实例对象被释放
        p2 = nil;
        [p2 release]; // 此时，p就变成了野指针，再给野指针p发送消息就会报错
        [p2 release];
        
        p = [Person new];
        Dog *d = [Dog new];

        p.dog = d; // retain
        d.owner = p; // retain  assign

        [p release];
        [d release];
        
        
        NSString *str = @"ssss";
        [str retain];
        NSLog(@"%lu",str.retainCount);
    }
    return 0;
}
