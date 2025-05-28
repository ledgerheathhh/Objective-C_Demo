#import <Foundation/Foundation.h>

typedef void(^ToolCompletionBlock)(id result, NSError *error);

@interface ToolManager : NSObject
+ (instancetype)sharedManager;
- (void)registerTool:(NSString *)toolName 
        description:(NSString *)description 
            handler:(void(^)(NSDictionary *params, ToolCompletionBlock completion))handler;
- (void)executeTool:(NSString *)toolName 
         withParams:(NSDictionary *)params 
         completion:(ToolCompletionBlock)completion;
- (NSArray *)getAvailableTools;
@end