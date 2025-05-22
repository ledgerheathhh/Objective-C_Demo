//
//  AppDelegate.h
//  JSCore
//
//  Created by Ledger Heath on 2025/5/22.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) JSContext *jsContext;
@property (nonatomic, strong) NSTimer *jsServiceTimer;

@end

