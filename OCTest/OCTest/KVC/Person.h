//
//  Person.h
//  OCTest
//
//  Created by Ledger Heath on 2024/5/15.
//

#import <Foundation/Foundation.h>
#import "Dog.h"

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

@property (nonatomic, readonly) NSString *personId;
@property (nonatomic, copy) NSString *personName;
@property (nonatomic, strong) Dog *dog;

@end

NS_ASSUME_NONNULL_END
