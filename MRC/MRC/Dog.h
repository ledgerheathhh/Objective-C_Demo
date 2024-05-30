//
//  Dog.h
//  MRC
//
//  Created by Ledger Heath on 2024/5/20.
//

#import <Foundation/Foundation.h>
@class Person;

NS_ASSUME_NONNULL_BEGIN

@interface Dog : NSObject

@property(nonatomic, retain)Person *owner;

@end

NS_ASSUME_NONNULL_END
