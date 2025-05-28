#import <Foundation/Foundation.h>
#import "MessageModel.h"

@protocol MCPClientDelegate <NSObject>
- (void)didReceiveResponse:(MessageModel *)message;
- (void)didReceiveToolCall:(NSString *)toolName params:(NSDictionary *)params;
- (void)didEncounterError:(NSError *)error;
@end

@interface MCPClient : NSObject
@property (nonatomic, weak) id<MCPClientDelegate> delegate;
@property (nonatomic, strong) NSString *apiKey;
@property (nonatomic, strong) NSString *baseURL;

- (instancetype)initWithAPIKey:(NSString *)apiKey baseURL:(NSString *)baseURL;
- (void)sendMessage:(NSString *)message withTools:(NSArray *)availableTools;
- (void)sendToolResult:(NSString *)toolName result:(id)result;
@end