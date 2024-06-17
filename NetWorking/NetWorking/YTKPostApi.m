//
//  YTKPostApi.m
//  NetWorking
//
//  Created by Ledger Heath on 2024/6/5.
//

#import "YTKPostApi.h"

@implementation YTKPostApi {
    NSString *_body ;
    NSString *_title;
    NSNumber *_userId;
}

- (instancetype)initWithUserId:(NSNumber *)userId body:(NSString *)body title:(NSString *)title {
    self = [super init];
    if (self) {
        _userId = userId;
        _body = [body copy];
        _title = [title copy];
    }
    return self;
}

- (NSString *)requestUrl {
    return @"/posts";
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPOST;
}

- (id)requestArgument {
    return @{
        @"userId": _userId,
        @"body": _body,
        @"title": _title
    };
}

- (NSString *)baseUrl {
    // Optional: If you have a baseUrl configured globally, you don't need this.
    return @"";
}

- (NSTimeInterval)requestTimeoutInterval {
    return 30;
}



@end
