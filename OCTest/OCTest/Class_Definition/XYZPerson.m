//
//  XYZPerson.m
//  OCTest
//
//  Created by Ledger Heath on 2024/5/10.
//

#import <Foundation/Foundation.h>
#import "XYZPerson.h"

@interface XYZPerson()
//- (void)sayHello;
//@property (readonly) NSString *firstName;
//@property (readonly) NSString *lastName;
@end

@implementation XYZPerson

+ (instancetype)person {
    return [[self alloc] init];
}

- (void)saySomething:(NSString *)greeting {
    NSLog(@"%@", greeting);
}

- (void)sayHello {
    [self saySomething:@"Hello, world!!"];
}

-(void)stest {
    NSLog(@"%@", self);
}

@end
