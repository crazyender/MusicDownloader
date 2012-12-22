//
//  QMMusicManager.m
//  MusicDownloader
//
//  Created by user on 12-12-22.
//  Copyright (c) 2012年 crazyender. All rights reserved.
//

#import "QMMusicManager.h"
#import "QMTaskModel.h"
#import <sqlite3.h>
#import <sys/types.h>
#import <sys/stat.h>
static QMMusicManager* _instance = nil;

@implementation QMMusicManager
{
    sqlite3* database;
}

-(id)init
{
    self = [super init];
    database = NULL;
    
    // 若没有数据库文件夹，新建一个
    // 建立在~/.MusicDownloader/music.db下
    NSString *homeDirectory = NSHomeDirectory();
    
    NSString* dbPath = [homeDirectory stringByAppendingPathComponent:@".MusicDownloader"];
    if( ![[NSFileManager defaultManager]fileExistsAtPath:dbPath] )
    {
        mkdir([dbPath UTF8String], S_IRUSR|S_IWUSR|S_IXUSR|S_IROTH|S_IRGRP);
    }
    
    NSString* dbFile = [dbPath stringByAppendingPathComponent:@"music.db"];
    if( SQLITE_OK != sqlite3_open([dbFile UTF8String], &database) )
        return  nil;
    
    // 没有表则新建表
    char *errorMsg;
    const char *createSql="create table if not exists musics (url text primary key, \
        local text, title text, alumb text, \
        author test, size text)";
    
    if (sqlite3_exec(database, createSql, NULL, NULL, &errorMsg)!=SQLITE_OK) {
        NSLog(@"create fail.");
        return nil;
    }

    
    return self;
}

-(void)close
{
    if (database) {
        sqlite3_close(database);
    }
}

-(BOOL)ExecSql:(NSString*)sql
{
    char *errorMsg;
    if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &errorMsg)!=SQLITE_OK) {
        NSLog(@"insert fail.");
        return NO;
    }
    
    return YES;
}

-(BOOL)InsertRecord:(QMTaskModel*)item MatchLocal:(NSString*) Local
{
    if(!database)
        return NO;
    NSString* insertSql = [NSString stringWithFormat:@"insert into musics (url, local, title, alumb, author, size) \
        values('%@', '%@','%@','%@','%@', '%@')",item.url, Local, item.title, item.alumb, item.author, (item.size == nil)?@"":item.size];
    return [self ExecSql:insertSql];
}

-(BOOL)UpdateRecord:(QMTaskModel*)item WithLocal:(NSString*)local
{
    if (!database) {
        return NO;
    }
    NSString* updateSql = [NSString stringWithFormat:@"update musics set local='%@', \
                           title='%@', alumb='%@', author='%@', size='%@' \
                           where url='%@'", local, item.title, item.alumb, item.author, item.size, item.url];
    
    return [self ExecSql:updateSql];
}

-(BOOL)DeleteRecord:(NSString*)url
{
    if(!database)
        return NO;
    
    NSString* deleteSql = [NSString stringWithFormat:@"delete from musics where url='%@'", url];
    
    return [self ExecSql:deleteSql];
    
}

-(BOOL)IsRecordExist:(NSString*)url
{
    if(!database)
        return NO;
    
    NSString* selectSql = [NSString stringWithFormat:@"select url from musics where url='%@'", url];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [selectSql UTF8String], -1, &statement, nil)!=SQLITE_OK) {
        NSLog(@"select fail.");
    }
    BOOL ret = NO;
    
    if (sqlite3_step(statement)==SQLITE_ROW) {
        ret = YES;
    }
    
    sqlite3_finalize(statement);
    
    return ret;
    
}


-(NSMutableArray*)GetAllItem
{
    NSMutableArray* ret = [[NSMutableArray alloc]init];
    NSString* selectSql = [NSString stringWithFormat:@"select url,title,alumb,author,size,local from musics"];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [selectSql UTF8String], -1, &statement, nil)!=SQLITE_OK) {
        NSLog(@"select fail.");
    }
    
    
    
    while (sqlite3_step(statement)==SQLITE_ROW) {
        char* url=(char *)sqlite3_column_text(statement, 0);
        char* title=(char *)sqlite3_column_text(statement, 1);
        char* alumb=(char *)sqlite3_column_text(statement, 2);
        char* author=(char *)sqlite3_column_text(statement, 3);
        char* size=(char *)sqlite3_column_text(statement, 4);
        char* local=(char*)sqlite3_column_text(statement, 5);
        
        QMTaskModel* item = [[QMTaskModel alloc]init];
        item.url = [NSString stringWithCString:url encoding:NSUTF8StringEncoding];
        item.title = [NSString stringWithCString:title encoding:NSUTF8StringEncoding];
        item.alumb = [NSString stringWithCString:alumb encoding:NSUTF8StringEncoding];
        item.author = [NSString stringWithCString:author encoding:NSUTF8StringEncoding];
        item.size = [NSString stringWithCString:size encoding:NSUTF8StringEncoding];
        item.progress = 100;
        NSString *strLocal = [NSString stringWithUTF8String:local];
        
        if (item.size == nil || [item.size length]==0 || [item.size isEqualToString:@"(null)"]) {
            NSError* error = nil;
            NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:strLocal error:&error];
            long long size = [fileAttributes fileSize];
            item.size = [NSString stringWithFormat:@"%lld", size == 0 ? size : size / 1024];
        }
        item->destFile = strLocal;
        
        [ret addObject:item];
        
    }
    
    sqlite3_finalize(statement);
    
    return ret;
}

-(void)RemoveNotExistRecord
{
    NSMutableArray* ret = [[NSMutableArray alloc]init];
    NSString* selectSql = [NSString stringWithFormat:@"select url,local from musics"];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [selectSql UTF8String], -1, &statement, nil)!=SQLITE_OK) {
        NSLog(@"select fail.");
    }
    
    
    
    while (sqlite3_step(statement)==SQLITE_ROW) {
        char* url=(char *)sqlite3_column_text(statement, 0);
        char* local=(char*)sqlite3_column_text(statement, 1);
        if( ![[NSFileManager defaultManager]fileExistsAtPath:[NSString stringWithUTF8String:local]]){
            [ret addObject:[NSString stringWithUTF8String:url]];
        }
    }
    
    sqlite3_finalize(statement);
    
    for (NSString* url in ret) {
        [self DeleteRecord:url];
    }
}

+(id)GetInstance
{
    if (_instance == nil) {
        _instance = [[QMMusicManager alloc]init];
    }
    return _instance;
}

@end
