//
//  main.m
//  OCTest
//
//  Created by Ledger Heath on 2024/4/29.
//

#import <Foundation/Foundation.h>
#import "XYZPerson.h"
#import "XYZShoutingPerson.h"
#import "Dog.h"
#import "Person.h"
#import "FunctionClass.h"

void testKVC(void){
    Person *person = [[Person alloc] init];
    Dog *dog = [[Dog alloc] init];
    //使用KVC设值
    [dog setValue:@"tom" forKey:@"dogName"];
    [person setValue:@"ledger" forKey:@"personName"];
    [person setValue:dog forKey:@"dog"];
    [person setValue:@2 forKeyPath:@"dog.dogAge"];
    //使用KVC取值
    NSString *personName = [person valueForKey:@"personName"];
    NSString *dogName = [person valueForKeyPath:@"dog.dogName"];
    NSNumber *dogAge = [person valueForKeyPath:@"dog.dogAge"];
    NSLog(@"%@的宠物狗名叫%@，它%@岁了.",personName,dogName,dogAge);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        
        NSLog(@"Hello, World!");
        NSString *string = @"oop:ack:bork:greeble:ponies";
        NSArray *chunks = [string componentsSeparatedByString: @":"];
        string = [chunks componentsJoinedByString: @" "];
        NSLog(@"%@",chunks);
        NSLog(@"%@",string);
        
        XYZPerson *person = [[XYZPerson alloc] init];
        [person sayHello];
        person.lastName=@"Heath";
        [person setLastName:@"Jobs"];
        NSLog(@"%@",person.lastName);
        
        XYZShoutingPerson *sp = [XYZShoutingPerson new];
        [sp test];

        
        XYZShoutingPerson *spp = [XYZShoutingPerson new];
        spp = (XYZPerson*)spp;
        NSLog(@"%@",spp.className);
        
        XYZPerson *personp = [[XYZPerson alloc] init];
        personp = (XYZShoutingPerson*)personp;
        NSLog(@"%@",personp.className);
        
        NSLog(@"%@",[XYZShoutingPerson person]);
        
        XYZShoutingPerson *shoutingPerson = [XYZShoutingPerson person];
        [shoutingPerson sayHello];
        NSLog(@"%@",shoutingPerson);
        
        XYZShoutingPerson *shoutingPersonTest;
        if(!shoutingPersonTest){
            NSLog(@"this is a nil object.");
        }

        NSArray *array = @[@123,@"ios"];
        id obj = array[0];
        NSLog(@"%@",obj);
        
//        两种方法初始化字典
        NSDictionary *personData =
            [NSDictionary dictionaryWithObjectsAndKeys:
                @"Matt", @"firstName",
                @"Galloway", @"lastName",
                nil,
                @28, @"age",
                nil];
        NSLog(@"%@",personData);
        
        NSDictionary *personData2 =
            @{@"firstName" : @"Matt",
//              @"lastName" : nil,
              @"age" : @28};
        NSLog(@"%@",personData2);
        
//        计算哈希码
        NSUInteger stringHash = [@"a string" hash];
        NSLog(@"%lu",stringHash);
        
        //使用类方法创建
        NSNumber * intNum = [NSNumber numberWithInt:10];
        NSNumber * floatNum = [NSNumber numberWithFloat:3.14];
        NSNumber * integerNum = [NSNumber numberWithInteger:100];
        NSNumber * doubleNum = [NSNumber numberWithDouble:100.01];
        
        //转换成基本数据类型
        int intBasic = [intNum intValue];
        float floatBasic = [floatNum floatValue];
        double doubleBasic = [doubleNum doubleValue];
        NSInteger integerBasic = [integerNum integerValue];
        NSLog(@"%d %f %f %ld",intBasic,floatBasic, doubleBasic,(long)integerBasic);
        
        //获取时间
        NSDate *date = [NSDate date];
        //打印当前标准时间
        NSLog(@"国际标准时间: %@", date);
        /*将当前世界标准时间转换成本地时间*/
        // 获取系统当前时区
        NSTimeZone *zone = [NSTimeZone systemTimeZone];
        // 获取当前时区与格林尼治时间的间隔
        NSInteger interval = [zone secondsFromGMTForDate:date];
        // 获取本地时间
        NSDate *localDate = [NSDate dateWithTimeIntervalSinceNow:interval];
        NSLog(@"当前时区时间: %@", localDate);
        
        //block的定义
        double (^multiplyTwoValues)(double, double) = ^(double number1, double number2) {
            NSLog(@"......");
            return number1 * number2;
        };
        //block的调用
        double doubleNumber = multiplyTwoValues(5.0,5.6);
        NSLog(@"multiplyTwoValues: %f",doubleNumber);
        
        
        //如果在一个方法中声明了Block，那么Block中也可以访问在该方法中定义的变量，前提是该变量的定义在Block定义之前。
        int i =  100;
        void (^beginBlock)(void) = ^(void) {
            NSLog(@"i 在Block中获取的值:%d",i);
        };
        beginBlock();
        //修改i的值
        i = 200;
        beginBlock();
        NSLog(@"i 的当前值: %d",i);
        //在Block中是不能对i值进行修改的
        
        //在Block中，假如需要更新在Block之外定义的变量时，那么在定义变量时，必须加上__block关键字。如果这样定义，当i的值发生变化时，block中“捕捉”的i值会随时变化。此时，在Block中可以对i的值进行修改。
        __block int i2 =  100;
        void (^withBlockWord)(void) = ^(void) {
            NSLog(@"i2 在Block中获取的值:%d",i2);
            i2 = 200;
        };
        withBlockWord();
        i2 = 300;
        withBlockWord();
        NSLog(@"i2 的当前值: %d",i2);
        
//        [Function cntReference];
        
        
        testKVC();
        __weak Person *p1 = [[Person alloc] init];
        __strong Person *p2 = [[Person alloc] init];
        NSLog(@"%@", p1.personId);
        
        Person *pp = [[Person alloc] init];
        NSString *name = [NSMutableString stringWithFormat:@"iOS"];
        pp.personName = name;

        NSLog(@"%@", pp.personName);

        name = @"iOS Source Probe";

        NSLog(@"%@", pp.personName);
        
        NSLog(@"%@", [name class]);
        
        XYZPerson *xyz = [XYZShoutingPerson new];
        NSLog(@"%@", [xyz class]);
        
    }
    return 0;
}
