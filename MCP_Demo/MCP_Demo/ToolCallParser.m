#import "ToolCallParser.h"

@implementation ToolCallParser

+ (instancetype)sharedParser {
    static ToolCallParser *sharedParser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedParser = [[self alloc] init];
    });
    return sharedParser;
}

- (NSDictionary *)parseToolCallFromResponse:(NSString *)response {
    if (![self containsToolCall:response]) {
        return nil;
    }
    
    NSString *toolName = [self extractToolName:response];
    NSDictionary *params = [self extractToolParams:response];
    
    if (!toolName) {
        return nil;
    }
    
    return @{
        @"tool_name": toolName,
        @"params": params ?: @{}
    };
}

- (BOOL)containsToolCall:(NSString *)response {
    NSRange toolRange = [response rangeOfString:@"<tool>"];
    NSRange paramsRange = [response rangeOfString:@"<params>"];
    return toolRange.location != NSNotFound && paramsRange.location != NSNotFound;
}

- (NSString *)extractToolName:(NSString *)response {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<tool>(.*?)</tool>"
                                                                          options:NSRegularExpressionDotMatchesLineSeparators
                                                                            error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:response
                                                   options:0
                                                     range:NSMakeRange(0, response.length)];
    
    if (match) {
        NSRange toolNameRange = [match rangeAtIndex:1];
        return [response substringWithRange:toolNameRange];
    }
    
    return nil;
}

- (NSDictionary *)extractToolParams:(NSString *)response {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<params>(.*?)</params>"
                                                                          options:NSRegularExpressionDotMatchesLineSeparators
                                                                            error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:response
                                                   options:0
                                                     range:NSMakeRange(0, response.length)];
    
    if (match) {
        NSRange paramsRange = [match rangeAtIndex:1];
        NSString *paramsString = [response substringWithRange:paramsRange];
        
        NSData *jsonData = [paramsString dataUsingEncoding:NSUTF8StringEncoding];
        if (jsonData) {
            NSError *error;
            NSDictionary *params = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                  options:0
                                                                    error:&error];
            if (!error) {
                return params;
            }
        }
    }
    
    return nil;
}

@end 