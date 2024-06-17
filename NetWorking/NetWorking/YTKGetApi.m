//
//  YTKGetApi.m
//  NetWorking
//
//  Created by Ledger Heath on 2024/6/5.
//

#import "YTKGetApi.h"

@implementation YTKGetApi

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSString *)requestUrl {
    return @"/todos/1";
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodGET;
}

- (NSInteger)cacheTimeInSeconds {
    return 60 * 3; // 缓存时间为3分钟
}
@end
