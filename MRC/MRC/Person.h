//
//  Person.h
//  MRC
//
//  Created by Ledger Heath on 2024/5/20.
//

#import <Foundation/Foundation.h>
@class  Dog;

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

@property(nonatomic, retain)Dog *dog;

@end

NS_ASSUME_NONNULL_END
