//
//  TwitModel.h
//  MyTwitter
//
//  Created by Robert Enderson on 29.09.16.
//  Copyright © 2016 Robert Enderson. All rights reserved.
//

#import <Foundation/Foundation.h>

//Модель хранения данных о каждом твите

@interface TwitModel : NSObject

-(instancetype)initWithPostAuthor:(NSString*) author
                         PostText:(NSString*) text
                  AvatarDirectory:(NSString*) directory
                           PostID:(NSNumber*) ID;

-(NSString*)getTwitAuthor;
-(NSString*)getTwitText;
-(NSString*)getTwitAvatarDirectory;
-(NSNumber*)getID;

-(void)setTwitAuthor:(NSString*) Author;
-(void)setTwitText:(NSString*) Text;
-(void)setTwitAvatarDirectory:(NSString*) Directory;
-(void)setID: (NSNumber*) iD;

@end
