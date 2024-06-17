//
//  YTKPostApi.h
//  NetWorking
//
//  Created by Ledger Heath on 2024/6/5.
//

#import <YTKNetwork/YTKNetwork.h>

NS_ASSUME_NONNULL_BEGIN

@interface YTKPostApi : YTKRequest

- (instancetype)initWithUserId:(NSNumber *)userId body:(NSString *)body title:(NSString *)title;
@end

NS_ASSUME_NONNULL_END
