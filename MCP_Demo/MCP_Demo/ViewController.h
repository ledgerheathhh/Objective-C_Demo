//
//  ViewController.h
//  MCP_Demo
//
//  Created by Ledger Heath on 2025/5/7.
//

#import <UIKit/UIKit.h>
#import "MCPClient.h"
#import "ToolManager.h"

@interface ViewController : UIViewController <MCPClientDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) MCPClient *mcpClient;
@property (nonatomic, strong) ToolManager *toolManager;
@property (nonatomic, strong) NSMutableArray<MessageModel *> *messages;

@property (nonatomic, strong) UITableView *chatTableView;
@property (nonatomic, strong) UITextField *inputTextField;
@property (nonatomic, strong) UIButton *sendButton;

@end

