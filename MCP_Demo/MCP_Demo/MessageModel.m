//
//  MessageModel.m
//  MCP_Demo
//
//  Created by Ledger Heath on 2025/5/7.
//

#import "MessageModel.h"

@implementation MessageModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _timestamp = [NSDate date];
    }
    return self;
}

@end