//
//  MCPServer.h
//  MCP_Test
//
//  Created by Ledger Heath on 2025/5/7.
//

#import <Foundation/Foundation.h>

@class GCDWebServer;

NS_ASSUME_NONNULL_BEGIN

@interface MCPServer : NSObject

+ (instancetype)sharedServer;

- (void)startServer;
- (void)stopServer;
- (BOOL)isRunning;
- (NSString *)serverURL;

@end

NS_ASSUME_NONNULL_END