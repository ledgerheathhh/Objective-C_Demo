//
//  ModelContext.m
//  MCP_Test
//
//  Created by Ledger Heath on 2025/5/27.
//

#import "ModelContextProtocol.h"

NSString * const kToolCallName = @"tool_name";
NSString * const kToolCallArguments = @"arguments";
NSString * const kToolCallResult = @"result";

@interface ModelContext : NSObject <ModelContextProtocol>

@property (nonatomic, strong, nullable) NSArray<ToolCallInfo *> *toolCalls;
@property (nonatomic, strong, nullable) NSArray<ToolCallInfo *> *toolResults;
@property (nonatomic, strong, nullable) NSString *userInput;
@property (nonatomic, strong, nullable) NSString *modelOutput;

@end

@implementation ModelContext
// @synthesize 会自动生成 getter 和 setter，这里只是显式写出来，通常可以省略
@synthesize toolCalls = _toolCalls;
@synthesize toolResults = _toolResults;
@synthesize userInput = _userInput;
@synthesize modelOutput = _modelOutput;

@end
