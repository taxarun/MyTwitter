//
//  DataBaseHandler.m
//  MyTwitter
//
//  Created by Robert Enderson on 20.09.16.
//  Copyright © 2016 Robert Enderson. All rights reserved.
//

#import "DataBaseHandler.h"
#import <sqlite3.h>
#import "TwitModel.h"
#import "SingletoneStorage.h"

//Типы данных, которых вернет запрос
#define DATA_NO_DATA  0
#define DATA_TWIT     1
#define DATA_ARRAY    2
#define DATA_SETTINGS 3

//Число настроек, которые не будут отображены в таблице настроек (системные переменные)
#define NUM_OF_SYS_VAR 3

@interface DataBaseHandler()

@property (nonatomic, strong) NSMutableArray *arrColumnNames;
@property (nonatomic) int affectedRows;
@property (nonatomic) long long lastInsertedRowID;

@property (nonatomic, strong) NSString *databaseDirectory;

@property (nonatomic, strong) NSMutableArray *arrResults;

@end

@implementation DataBaseHandler

-(instancetype)initWithDatabaseFilename:(NSString *)nameOfDataBase
{
    self = [super init];
    if (self)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        self.databaseDirectory = [documentsDirectory stringByAppendingPathComponent:nameOfDataBase];
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.databaseDirectory])
        {
            //Создадим файл БД, если его нет
            NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:nameOfDataBase];
            NSError *error;
            [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:self.databaseDirectory error:&error];
            if (error != nil)
            {
                NSLog(@"%@", [error localizedDescription]);
            }
            //Создадим таблицы и заполним таблицу с настройками значениями по умолчанию
            [self runQuery:"CREATE TABLE twits(twitID text primary key, author text, post text, imageDir text);" returnData:DATA_NO_DATA];
            [self runQuery:"CREATE TABLE settings(label text primary key, value text);" returnData:DATA_NO_DATA];
            NSString* query = [NSString stringWithFormat:@"INSERT INTO settings VALUES ('imageCount', '%lu'),('lastQuery', 'taxarun'),('searchUser','Y'),('Отображать аватары:','Y');", (unsigned long)[SingletoneStorage checkImagesCount]];
            [self runQuery:[query UTF8String] returnData:DATA_NO_DATA];
        }
    }
    return self;
}

-(BOOL)getTwits
{
    return [self runQuery:"SELECT * FROM twits ORDER BY twitID DESC" returnData:DATA_TWIT];
}

-(BOOL)getSettingsAndAppVariables
{
    return [self runQuery:"SELECT * FROM settings" returnData:DATA_SETTINGS];
}

-(void)dataParseOfType:(int) type Data:(sqlite3_stmt*) compiledStatement
{
    //Если требуется загрузка из БД
    NSMutableArray *arrDataRow;
    //Смотрим каждую колонку полученных данных
    int totalColumns = sqlite3_column_count(compiledStatement);
    //Выбор формата возвращаемых данных
    if(type == DATA_TWIT)
    {
        NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:100];
        //Просмотрим все строчки из БД
        while(sqlite3_step(compiledStatement) == SQLITE_ROW)
        {
            //Создаем объект поста
            NSNumber* twitID;
            NSString* author;
            NSString* text;
            NSString* imageDir;
            
            char* dbID = (char *)sqlite3_column_text(compiledStatement, 0);
            twitID = [NSNumber numberWithLongLong:[[NSString stringWithUTF8String:dbID] longLongValue]];
            
            char *dbDataAsChars = (char *)sqlite3_column_text(compiledStatement, 1);
            if (dbDataAsChars != NULL)
            {
                author = [NSString stringWithUTF8String:dbDataAsChars];
            }
            
            dbDataAsChars = (char *)sqlite3_column_text(compiledStatement, 2);
            if (dbDataAsChars != NULL)
            {
                text = [NSString stringWithUTF8String:dbDataAsChars];
            }
            
            dbDataAsChars = (char *)sqlite3_column_text(compiledStatement, 3);
            if (dbDataAsChars != NULL)
            {
                imageDir = [NSString stringWithUTF8String:dbDataAsChars];
            }
            
            [result addObject:[[TwitModel alloc] initWithPostAuthor:author
                                                                    PostText:text
                                                             AvatarDirectory:imageDir
                                                                      PostID:twitID]];
        }
        //Сохраним массив твитов в хранилище
        [SingletoneStorage setTwitsStorage:result];
    }
    else if(type == DATA_SETTINGS)
    {
        NSMutableDictionary *sysVariables = [[NSMutableDictionary alloc]init];
        NSMutableDictionary *settingsList = [[NSMutableDictionary alloc]init];
        int rows = 0;
        while(sqlite3_step(compiledStatement) == SQLITE_ROW)
        {
            NSString *key;
            NSString *value;
            
            char *dbDataAsChars = (char *)sqlite3_column_text(compiledStatement, 0);
            if (dbDataAsChars != NULL)
            {
                key = [NSString stringWithUTF8String:dbDataAsChars];
            }
            else key = @"ERROR";
            
            dbDataAsChars = (char *)sqlite3_column_text(compiledStatement, 1);
            if (dbDataAsChars != NULL)
            {
                value = [NSString stringWithUTF8String:dbDataAsChars];
            }
            else value = @"ERROR";
            
            if(rows < NUM_OF_SYS_VAR) [sysVariables setObject:value forKey:key];
            else [settingsList setObject:value forKey:key];
            rows++;
        }
        [SingletoneStorage setAppVariables:sysVariables];
        [SingletoneStorage setSettingsState:settingsList];
    }
    else if(type == DATA_ARRAY)
    {
        //Подготовка массива имен колонок
        if (self.arrColumnNames != nil) [self.arrColumnNames removeAllObjects];
        else self.arrColumnNames = [[NSMutableArray alloc] init];
        //Подготовка массива результатов
        if (self.arrResults != nil) [self.arrResults removeAllObjects];
        else self.arrResults = [[NSMutableArray alloc] init];
        //Просмотр каждой строчки из БД
        while(sqlite3_step(compiledStatement) == SQLITE_ROW)
        {
            arrDataRow = [[NSMutableArray alloc] init];
            for (int i = 0; i < totalColumns; i++)
            {
                char *dbDataAsChars = (char *)sqlite3_column_text(compiledStatement, i);
                if (dbDataAsChars != NULL)
                {
                    [arrDataRow addObject:[NSString  stringWithUTF8String:dbDataAsChars]];
                }
                if (self.arrColumnNames.count != totalColumns)
                {
                    dbDataAsChars = (char *)sqlite3_column_name(compiledStatement, i);
                    [self.arrColumnNames addObject:[NSString stringWithUTF8String:dbDataAsChars]];
                }
                if (arrDataRow.count > 0)
                {
                    [self.arrResults addObject:arrDataRow];
                }
            }
        }
        //Запишем результат в хранилище
        [SingletoneStorage setTwitsStorage:self.arrResults];
    }
}

//Очистка таблицы
-(BOOL)clearAndReuseTable:(NSString*)tableName Query:(const char*)query
{
    NSString* fstQuery = [NSString stringWithFormat:@"DELETE FROM %@", tableName];
    [self runQuery:[fstQuery UTF8String] returnData:DATA_NO_DATA];
    return [self runQuery:query returnData:DATA_NO_DATA];
}

//Выполнение запроса
-(BOOL)runQuery:(const char *)query returnData:(int) type
{
    sqlite3 *sqlite3Database;
    //Открываю базу для работы с ней
    BOOL openDatabaseResult = sqlite3_open([self.databaseDirectory UTF8String], &sqlite3Database);
    if(openDatabaseResult == SQLITE_OK)
    {
        //Хранение результата запроса
        sqlite3_stmt *compiledStatement;
        BOOL prepareStatementResult = sqlite3_prepare_v2(sqlite3Database, query, -1, &compiledStatement, NULL);
        if(prepareStatementResult == SQLITE_OK)
        {
            if (type == DATA_NO_DATA)
            {
                //Если требуется произвести изменения с данными в БД
                int executeQueryResults = sqlite3_step(compiledStatement);
                if (executeQueryResults == SQLITE_DONE)
                {
                    self.affectedRows = sqlite3_changes(sqlite3Database);
                    self.lastInsertedRowID = sqlite3_last_insert_rowid(sqlite3Database);
                }
                else
                {
                    //Если не выполнился запрос
                    NSLog(@"DB Error: %s", sqlite3_errmsg(sqlite3Database));
                }
            }
            else [self dataParseOfType:type Data:compiledStatement];
        }
        else
        {
            //Если БД не открылась
            NSLog(@"%s", sqlite3_errmsg(sqlite3Database));
            return NO;
        }
        //Очистка скомпилированного запроса
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(sqlite3Database);
    return YES;
}

@end
