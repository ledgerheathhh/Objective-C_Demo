//
//  MCPServerManager.h
//  MCP_Demo
//

#import <Foundation/Foundation.h>

@interface MCPServerManager : NSObject

+ (instancetype)sharedInstance;
- (void)startServer;
- (void)stopServer;

@end