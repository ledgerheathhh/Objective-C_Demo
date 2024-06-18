//
//  ViewController.m
//  DataPersistence
//
//  Created by Ledger Heath on 2024/6/5.
//

#import "ViewController.h"
#import "sqlite3.h"
#import "MMKV.h"
#import "FMDB.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self Plistmethod];
    
//    [self UserDefaultsmethod];
    
//    [self SQmethod];
    
//    [self MMKVmethod];

    [self FMDBfunc];
}

-(void) Plistmethod {
//    首先准备需要写入的数据对象，例如：一个字典或数组对象，并在其中存储一些数据
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@"ledger" forKey:@"Name"];
    NSLog(@"%@",dict);
    
//    准备Plist文件的路径，通常，我们考虑写入到沙盒中的Documents目录中
    NSArray *documentsArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [documentsArr objectAtIndex:0];
    NSString *dictPlistPath = [documentsPath stringByAppendingPathComponent:@"dict.plist"];
    
//    使用NSArray类或NSDictionary类中提供的writeToFile:方法，写入指定的Plist文件
    [dict writeToFile:dictPlistPath atomically:YES];

}

-(void) UserDefaultsmethod {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSUserDefaults *defaults2 = [NSUserDefaults standardUserDefaults];
    NSLog(@"%p",defaults);
    NSLog(@"%p",defaults2);
    
    [defaults setObject:[NSDate date] forKey:@"LastLoginTime"];
    [defaults setBool:NO forKey:@"IsFirstLogin"];
    [defaults setValue:@"ledger" forKey:@"UserName"];

//    [defaults synchronize];

    NSDate *lastLoginTime = [defaults objectForKey:@"LastLoginTime"];
    BOOL isFirstLogin = [defaults boolForKey:@"IsFirstLogin"];
    NSString *userName = [defaults valueForKey:@"UserName"];

    NSLog(@"Before removal: %@--%d--%@", lastLoginTime, isFirstLogin, userName);

    [defaults removeObjectForKey:@"LastLoginTime"];
    
    lastLoginTime = [defaults objectForKey:@"LastLoginTime"];
    // 立即打印以查看删除后的状态
    NSLog(@"After  removal: %@--%d--%@", lastLoginTime, isFirstLogin, userName);
}

-(void) SQmethod {
    // 数据库文件路径
    NSString *databasePath;

    // 获取应用的Documents目录
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = dirPaths[0];

    // 数据库文件完整路径
    databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: @"test.db"]];
    
    sqlite3 *db;
    int rc = sqlite3_open([databasePath UTF8String], &db);
    if (rc) {
        NSLog(@"Can't open database: %s", sqlite3_errmsg(db));
        sqlite3_close(db);
    }

    const char *sql = "CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER)";
    char *errmsg = NULL;
    rc = sqlite3_exec(db, sql, NULL, NULL, &errmsg);
    if (rc != SQLITE_OK) {
        NSLog(@"SQL error: %s", errmsg);
        sqlite3_free(errmsg);
        sqlite3_close(db);
    }

    sql = "INSERT INTO users (name, age) VALUES ('John', 25)";
    rc = sqlite3_exec(db, sql, NULL, NULL, &errmsg);
    if (rc != SQLITE_OK) {
        NSLog(@"SQL error: %s", errmsg);
        sqlite3_free(errmsg);
        sqlite3_close(db);
    }

    sql = "INSERT INTO users (name, age) VALUES ('Jane', 30)";
    rc = sqlite3_exec(db, sql, NULL, NULL, &errmsg);
    if (rc != SQLITE_OK) {
        NSLog(@"SQL error: %s", errmsg);
        sqlite3_free(errmsg);
        sqlite3_close(db);
    }
    
    
    sql = "SELECT * FROM users";
    
    rc = sqlite3_exec(db, sql, callback, NULL, &errmsg);
    if (rc != SQLITE_OK) {
        NSLog(@"SQL error: %s", errmsg);
        sqlite3_free(errmsg);
        sqlite3_close(db);
    }
    
    sqlite3_close(db);
}

// 回调函数，用于处理查询结果
int callback(void *NotUsed, int argc, char **argv, char **azColName) {
    for (int i = 0; i < argc; i++) {
        NSLog(@"%s = %s", azColName[i], argv[i] ? argv[i] : "NULL");
    }
    NSLog(@"\n");
    return 0;
}

-(void) MMKVmethod {
    // 初始化 MMKV
    [MMKV initializeMMKV:nil];
    
    // 获取默认的 MMKV 实例
    MMKV *mmkv = [MMKV defaultMMKV];
    
    // 存储数据
    [mmkv setObject:@"Hello MMKV" forKey:@"myString"];
    [mmkv setInt32:12345 forKey:@"myInt"];
    [mmkv setBool:YES forKey:@"myBool"];
    
    // 读取数据
    NSString *myString = [mmkv getObjectOfClass:[NSString class] forKey:@"myString"];
    int myInt = [mmkv getInt32ForKey:@"myInt"];
    BOOL myBool = [mmkv getBoolForKey:@"myBool"];
    
    NSLog(@"String: %@", myString);
    NSLog(@"Int: %d", myInt);
    NSLog(@"Bool: %d", myBool);
    
    // 更新数据
    [mmkv setObject:@"Updated MMKV" forKey:@"myString"];
    
    myString = [mmkv getObjectOfClass:[NSString class] forKey:@"myString"];
    NSLog(@"String: %@", myString);
    
    // 删除数据
    [mmkv removeValueForKey:@"myInt"];
    
    myInt = [mmkv getInt32ForKey:@"myInt"];
    NSLog(@"Int: %d", myInt);
    
//    [mmkv clearAll];
}

-(void) FMDBfunc {
    // 获取数据库文件路径
    NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *dbPath = [docsPath stringByAppendingPathComponent:@"FMDB_example.db"];

    // 创建数据库实例
    FMDatabase *database = [FMDatabase databaseWithPath:dbPath];

    // 打开数据库
    if (![database open]) {
        NSLog(@"Could not open database");
        return;
    }
    
    //创建表
    NSString *createTableSQL = @"CREATE TABLE IF NOT EXISTS Users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER)";
    if (![database executeUpdate:createTableSQL]) {
        NSLog(@"Failed to create table: %@", [database lastErrorMessage]);
    }
    
    
}

@end
