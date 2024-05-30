//
//  XYZShoutingPerson.m
//  OCTest
//
//  Created by Ledger Heath on 2024/5/10.
//

#import <Foundation/Foundation.h>
#import "XYZShoutingPerson.h"

@implementation XYZShoutingPerson

- (void)saySomething:(NSString *)greeting {
    NSString *uppercaseGreeting = [greeting uppercaseString];
    NSLog(@"%@", uppercaseGreeting);
}

- (void)test{
    [super stest];
}
@end
