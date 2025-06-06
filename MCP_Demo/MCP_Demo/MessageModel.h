#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MessageType) {
    MessageTypeUser,
    MessageTypeAssistant,
    MessageTypeSystem,
    MessageTypeTool
};

@interface MessageModel : NSObject
@property (nonatomic, strong, nullable) NSString *content;
@property (nonatomic, assign) MessageType type;
@property (nonatomic, strong, nullable) NSDate *timestamp;
@property (nonatomic, strong, nullable) NSString *toolName;
@property (nonatomic, strong, nullable) NSDictionary *toolParams;
@end
