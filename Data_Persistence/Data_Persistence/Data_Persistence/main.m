//
//  main.m
//  Data_Persistence
//
//  Created by Ledger Heath on 2024/6/4.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

static int callback(void *NotUsed, int argc, char **argv, char **azColName) {
    for (int i = 0; i < argc; i++) {
        NSLog(@"%s = %s", azColName[i], argv[i] ? argv[i] : "NULL");
    }
    NSLog(@"\n");
    return 0;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSUserDefaults *defaults2 = [NSUserDefaults standardUserDefaults];
        NSLog(@"%p",defaults);
        NSLog(@"%p",defaults2);
        
        [defaults setObject:[NSDate date] forKey:@"LastLoginTime"];
        [defaults setBool:NO forKey:@"IsFirstLogin"];
        [defaults setValue:@"ledger" forKey:@"UserName"];

//        [defaults synchronize];

        NSDate *lastLoginTime = [defaults objectForKey:@"LastLoginTime"];
        BOOL isFirstLogin = [defaults boolForKey:@"IsFirstLogin"];
        NSString *userName = [defaults valueForKey:@"UserName"];

        NSLog(@"Before removal: %@--%d--%@", lastLoginTime, isFirstLogin, userName);

        [defaults removeObjectForKey:@"LastLoginTime"];
        
        lastLoginTime = [defaults objectForKey:@"LastLoginTime"];
        // 立即打印以查看删除后的状态
        NSLog(@"After  removal: %@--%d--%@", lastLoginTime, isFirstLogin, userName);
        
        
        sqlite3 *db;
        int rc = sqlite3_open("mydb.sqlite", &db);
        if (rc) {
            NSLog(@"Can't open database: %s", sqlite3_errmsg(db));
            sqlite3_close(db);
            return 1;
        }

        const char *sql = "CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age INTEGER)";
        char *errmsg = NULL;
        rc = sqlite3_exec(db, sql, NULL, NULL, &errmsg);
        if (rc != SQLITE_OK) {
            NSLog(@"SQL error: %s", errmsg);
            sqlite3_free(errmsg);
            sqlite3_close(db);
            return 1;
        }

        sql = "INSERT INTO users (name, age) VALUES ('John', 25)";
        rc = sqlite3_exec(db, sql, NULL, NULL, &errmsg);
        if (rc != SQLITE_OK) {
            NSLog(@"SQL error: %s", errmsg);
            sqlite3_free(errmsg);
            sqlite3_close(db);
            return 1;
        }

        sql = "INSERT INTO users (name, age) VALUES ('Jane', 30)";
        rc = sqlite3_exec(db, sql, NULL, NULL, &errmsg);
        if (rc != SQLITE_OK) {
            NSLog(@"SQL error: %s", errmsg);
            sqlite3_free(errmsg);
            sqlite3_close(db);
            return 1;
        }
        
        sql = "SELECT * FROM users";
        rc = sqlite3_exec(db, sql, callback, NULL, &errmsg);
        if (rc != SQLITE_OK) {
            NSLog(@"SQL error: %s", errmsg);
            sqlite3_free(errmsg);
            sqlite3_close(db);
            return 1;
        }

        sqlite3_close(db);

    }
    return 0;
}
