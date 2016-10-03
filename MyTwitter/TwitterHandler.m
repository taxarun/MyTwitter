//
//  TwitterHandler.m
//  MyTwitter
//
//  Created by Robert Enderson on 17.09.16.
//  Copyright © 2016 Robert Enderson. All rights reserved.
//

#import "TwitterHandler.h"
#import "TwitModel.h"
#import "SingletoneStorage.h"

#define TWITS_COUNT 100

static NSString* ConsumerKey = @"NULL";
static NSString* ConsumerSecretKey = @"NULL";
static NSString* bearerToken = @"AAAAAAAAAAAAAAAAAAAAAIQGxAAAAAAApUD8ABWvX88Iy1STSNjrK8EY0fI%3DXiFWC2OuELN3bWhDDoJs5p717YD5NYNmAcO8lnTmZAQP7uiWJK";

@interface TwitterHandler()

@end

@implementation TwitterHandler

//Очистка папки с кешем изображений
+(void)clearImagesDirectory
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *cacheImageDirectory = [SingletoneStorage getPathToImages];
    NSError *error;
    BOOL success = [fm removeItemAtPath:cacheImageDirectory error:&error];
    if (!success || error)
    {
        NSLog(@"Images wasn't deleted");
    }
    NSLog(@"Images were succesfully cleared!");
    [TwitterHandler prepareImageDirectory];
}

//ПОдготовка папки для кеширования изображений
+(void)prepareImageDirectory
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"/Images"];
    NSLog(@"Image path: %@",path);
    NSError* error;
    BOOL isDir;
    if(![fileManager fileExistsAtPath:path isDirectory:&isDir])
    {
        if(![fileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error])
        {
            NSLog(@"Create directory error %@",error);
        }
        else NSLog(@"Cache directory was made");
    }
    [SingletoneStorage setPathToImages:path];
}

+(NSString*)getNonce
{
    NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY";
    NSMutableString *random = [NSMutableString stringWithCapacity:32];
    for (int i = 0; i < 32; i++)
    {
        u_int32_t r = arc4random() % [alphabet length];
        unichar c = [alphabet characterAtIndex:r];
        [random appendFormat:@"%C", c];
    }
    NSData *data = [random dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedStringWithOptions:0];
}

//Получения токена для приложения (не нужно выполнять в готовом приложении, только для разработчика)
+(NSString *)getBase64EncodedBearerToken
{
    NSString *encodedConsumerToken = [ConsumerKey stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    encodedConsumerToken = [encodedConsumerToken stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSLog(@"%@",encodedConsumerToken);
    NSString *encodedConsumerSecret = [ConsumerSecretKey stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    encodedConsumerSecret = [encodedConsumerSecret stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSLog(@"%@",encodedConsumerSecret);
    NSString *bearerTokenCredentials = [NSString stringWithFormat:@"%@:%@", encodedConsumerToken, encodedConsumerSecret];
    NSData *data = [bearerTokenCredentials dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedStringWithOptions:0];
}

//Получения токена для приложения (не нужно выполнять в готовом приложении, только для разработчика)
+(NSString*)getBearerTokenFromTwitter
{
    NSString *post = @"grant_type=client_credentials";
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSString *host = @"api.twitter.com";
    NSString *userAgent = @"MyPostList";
    NSString *bearerToken = [NSString stringWithFormat:@"Basic %@",[self getBase64EncodedBearerToken]];
    NSString *contentType = @"application/x-www-form-urlencoded;charset=UTF-8";
    NSString *twitURL = @"https://api.twitter.com/oauth2/token";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString: twitURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:host forHTTPHeaderField:@"Host"];
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    [request setValue:bearerToken forHTTPHeaderField:@"Authorization"];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    NSURLResponse *response;
    NSError *err;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    return responseString;
}

//Загрузка изображения
+(NSString*)downloadImageToCacheWith:(NSURL*)URL SetCount:(NSUInteger*) count
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [URL lastPathComponent];
    NSString *filePath = [NSString stringWithFormat:@"%@/Images/%@", documentsDirectory,fileName];
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        NSData *urlData = [NSData dataWithContentsOfURL:URL];
        if (urlData)
        {
            [urlData writeToFile:filePath atomically:YES];
            *count = *count + 1;
        }
    }
    return fileName;
}

//Реализация запросов твитеру
+(NSArray*)getTwitsFromUserNotSearch:(BOOL)param Query:(NSString*) query
{
    //Полсчет скаченных изображений
    NSUInteger imgCount = [[[SingletoneStorage getAppVariables] objectForKey:@"imageCount"] longLongValue];
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:TWITS_COUNT];
    
    //Составление запроса
    NSString *accessTokenHeaderToPost = [NSString stringWithFormat:@"Bearer %@",bearerToken];
    NSString *twitURL;
    if(param) twitURL = @"https://api.twitter.com/1.1/statuses/user_timeline.json?screen_name=";
    else
    {
        twitURL = @"https://api.twitter.com/1.1/search/tweets.json?q=";
        query = [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    }
    twitURL = [NSString stringWithFormat:@"%@%@&count=%d", twitURL, query, TWITS_COUNT];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString: twitURL]];
    [request setHTTPMethod:@"GET"];
    [request setValue:accessTokenHeaderToPost forHTTPHeaderField:@"Authorization"];
    
    //Отправка запроса
    NSURLResponse *response;
    NSError *err;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    if (!responseData)
    {
        //Если ничего не пришло
        NSLog(@"ERROR: %@", err);
        NSNumber *twitID =[NSNumber numberWithUnsignedInt:1];
        [result addObject:[[TwitModel alloc] initWithPostAuthor:@"ERROR"
                                                       PostText:@"ERROR"
                                                AvatarDirectory:@"ERROR"
                                                         PostID:twitID]];
    }
    else
    {
        //Данные пришли
        //Преобразование JSON в NSArray массив
        NSError *e = nil;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: responseData options: NSJSONReadingMutableContainers error: &e];
        if (!jsonArray)
        {
            //Произошла ошибка парсинга
            NSLog(@"Error parsing JSON: %@", e);
            NSNumber *twitID =[NSNumber numberWithUnsignedInt:1];
            [result addObject:[[TwitModel alloc] initWithPostAuthor:@"ERROR"
                                                           PostText:@"ERROR"
                                                    AvatarDirectory:@"ERROR"
                                                             PostID:twitID]];
        }
        else
        {
            //Все данные для работы есть
            //Проверим, не пора ли очистить кеш изображений
            if(imgCount > 300)
            {
                [TwitterHandler clearImagesDirectory];
                imgCount = 0;
            }
            NSArray* twits;
            if(param)
            {
                twits = jsonArray;
            }
            else
            {
                NSDictionary* test = (NSDictionary*)jsonArray;
                twits = [test objectForKey:@"statuses"];
            }
            //Итерация по полученным твитам
            for(NSDictionary *twit in twits)
            {
                NSDictionary* userProperty = [twit objectForKey:@"user"];
                NSURL  *imageUrl = [NSURL URLWithString:[userProperty objectForKey:@"profile_image_url_https"]];
                
                TwitModel* post = [[TwitModel alloc] initWithPostAuthor:[userProperty objectForKey:@"name"]
                                                               PostText:[twit objectForKey:@"text"]
                                                        AvatarDirectory:[TwitterHandler downloadImageToCacheWith:imageUrl SetCount:&imgCount]
                                                                 PostID:[twit objectForKey:@"id"]];
                [result addObject:post];
            }
        }
    }
    //Сохраним твиты в хранилище
    [[SingletoneStorage getAppVariables] setValue:[NSString stringWithFormat:@"%lu",(unsigned long)imgCount] forKey:@"imageCount"];
    return result;
}

@end
