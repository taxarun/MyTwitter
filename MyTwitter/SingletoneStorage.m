//
//  SingletoneStorage.m
//  MyTwitter
//
//  Created by Robert Enderson on 24.09.16.
//  Copyright © 2016 Robert Enderson. All rights reserved.
//

#import "SingletoneStorage.h"
#import "TwitModel.h"

@interface SingletoneStorage()

//@property (nonatomic) BOOL avatarEnabled;
//@property (nonatomic) int numOfImages;

@property (nonatomic,strong) NSString *imagePath;

@property (nonatomic,strong) NSArray* data;
@property (nonatomic,strong) NSDictionary* settingList;
@property (nonatomic,strong) NSDictionary* appVariables;

@end

@implementation SingletoneStorage

//Получение хранилища
+ (SingletoneStorage*)getStorage
{
    static SingletoneStorage *storage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storage = [[self alloc] init];
    });
    return storage;
}

//проверка действительного числа изображений в кеше (применяется только в случае создания файла с БД)
+ (NSUInteger)checkImagesCount
{
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self getStorage].imagePath error:nil];
    return files.count;
}

//Получения пути к папке с изображениями (каждый запуск приложения путь надо получать с помощью этого метода)
+ (void)setPathToImages:(NSString*) path
{
    [self getStorage].imagePath = path;
}

+ (NSString*)getPathToImages
{
    return [self getStorage].imagePath;
}

+ (const char*)getQueryToSaveSettings
{
    NSDictionary* settings = [self getStorage].settingList;
    NSDictionary* appVars = [self getStorage].appVariables;
    NSMutableString *result = [[NSMutableString alloc] initWithString:@"INSERT INTO settings VALUES "];
    NSString *value;
    //Все настройки впишем в запрос INSERT (перед его выполнением таблица должна быть очищена)
    for (NSString* key in appVars)
    {
        value = [appVars objectForKey:key];
        //Задание формата данных (и плюс заменим двойные кавычки, чтобы не вызывать ошибку в БД)
        [result appendFormat:@"(\"%@\",\"%@\"),", key, [value stringByReplacingOccurrencesOfString:@"\"" withString:@"''"]];
    }
    for (NSString* key in settings)
    {
        value = [settings objectForKey:key];
        [result appendFormat:@"(\"%@\",\"%@\"),", key, value];
    }
    [result deleteCharactersInRange:NSMakeRange([result length]-1, 1)];
    return [result UTF8String];
}

+ (const char*)getQueryToSaveTwits
{
    NSArray* twits = [self getStorage].data;
    NSMutableString *result = [[NSMutableString alloc] initWithString:@"INSERT INTO twits VALUES "];
    NSUInteger count = twits.count;
    TwitModel *twit;
    //Все твиты впишем в запрос INSERT (перед его выполнением таблица должна быть очищена)
    for (NSUInteger i = 0; i < count; i++)
    {
        //Такая последовательность в таблице БД:
        //(twitID integer primary key, author text, post text, imageDir text)
        twit = [twits objectAtIndex:i];
        //Задание формата данных (и плюс заменим двойные кавычки, чтобы не вызывать ошибку в БД)
        [result appendFormat:@"(\"%@\",\"%@\",\"%@\",\"%@\"),",
                                             [twit getID],
                                             [[twit getTwitAuthor] stringByReplacingOccurrencesOfString:@"\"" withString:@"''"],
                                             [[twit getTwitText] stringByReplacingOccurrencesOfString:@"\"" withString:@"''"],
                                             [twit getTwitAvatarDirectory]];
    }
    [result deleteCharactersInRange:NSMakeRange([result length]-1, 1)];
    return [result UTF8String];
}

+ (NSArray*)getTwitsStorage
{
    return [self getStorage].data;
}

+ (void)setTwitsStorage:(NSArray*) list
{
    [self getStorage].data = list;
}

+ (void)setSettingsState:(NSDictionary*) list
{
    [self getStorage].settingList = list;
}

+ (NSDictionary*)getSettingsState
{
    return [self getStorage].settingList;
}

+ (void)setAppVariables:(NSDictionary*) list
{
    [self getStorage].appVariables = list;
}

+ (NSDictionary*)getAppVariables
{
    return [self getStorage].appVariables;
}

@end
