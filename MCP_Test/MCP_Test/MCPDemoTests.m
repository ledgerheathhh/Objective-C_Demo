//
//  MCPDemoTests.m
//  MCP_Test
//
//  Created by Ledger Heath on 2025/5/7.
//

#import "MCPDemoTests.h"

@implementation MCPDemoTests

- (void)testTapViaMCPServer {
    XCTestExpectation *expectation = [self expectationWithDescription:@"MCP Tap"];
    [self tapAtX:100 y:200 completion:^(BOOL success) {
        XCTAssertTrue(success, @"通过 MCP Server 点击失败");
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)tapAtX:(NSInteger)x y:(NSInteger)y completion:(void (^)(BOOL success))completion {
    NSURL *url = [NSURL URLWithString:@"http://localhost:8001/api/tap"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    NSDictionary *body = @{@"x": @(x), @"y": @(y)};
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:body options:0 error:nil];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        BOOL success = NO;
        if (!error && data) {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            success = [result[@"status"] isEqualToString:@"success"];
        }
        if (completion) {
            completion(success);
        }
    }];
    [task resume];
}

@end
