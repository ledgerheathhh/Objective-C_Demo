//
//  ToolManager.m
//  MCP_Demo
//
//  Created by Ledger Heath on 2025/5/7.
//

#import "ToolManager.h"

@interface ToolManager ()
@property (nonatomic, strong) NSMutableDictionary *registeredTools;
@property (nonatomic, strong) NSMutableDictionary *toolDescriptions;
@property (nonatomic, strong) NSMutableDictionary *toolHandlers;
@end

@implementation ToolManager

+ (instancetype)sharedManager {
    static ToolManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _registeredTools = [NSMutableDictionary dictionary];
        _toolDescriptions = [NSMutableDictionary dictionary];
        _toolHandlers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)registerTool:(NSString *)toolName 
        description:(NSString *)description 
            handler:(void(^)(NSDictionary *params, ToolCompletionBlock completion))handler {
    if (!toolName || !handler) return;
    
    self.registeredTools[toolName] = @YES;
    if (description) {
        self.toolDescriptions[toolName] = description;
    }
    self.toolHandlers[toolName] = handler;
}

- (void)executeTool:(NSString *)toolName 
         withParams:(NSDictionary *)params 
         completion:(ToolCompletionBlock)completion {
    if (!toolName || !self.registeredTools[toolName]) {
        if (completion) {
            NSError *error = [NSError errorWithDomain:@"ToolManagerErrorDomain" 
                                                code:404 
                                            userInfo:@{NSLocalizedDescriptionKey: @"Tool not found"}];
            completion(nil, error);
        }
        return;
    }
    
    void (^handler)(NSDictionary *, ToolCompletionBlock) = self.toolHandlers[toolName];
    if (handler) {
        handler(params ?: @{}, completion);
    } else if (completion) {
        NSError *error = [NSError errorWithDomain:@"ToolManagerErrorDomain" 
                                            code:500 
                                        userInfo:@{NSLocalizedDescriptionKey: @"Tool handler not found"}];
        completion(nil, error);
    }
}

- (NSArray *)getAvailableTools {
    NSMutableArray *tools = [NSMutableArray array];
    
    [self.registeredTools enumerateKeysAndObjectsUsingBlock:^(NSString *toolName, id obj, BOOL *stop) {
        NSMutableDictionary *toolInfo = [NSMutableDictionary dictionary];
        toolInfo[@"name"] = toolName;
        
        NSString *description = self.toolDescriptions[toolName];
        if (description) {
            toolInfo[@"description"] = description;
        }
        
        [tools addObject:toolInfo];
    }];
    
    return [tools copy];
}

@end