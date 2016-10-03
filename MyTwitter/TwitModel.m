//
//  TwitModel.m
//  MyTwitter
//
//  Created by Robert Enderson on 29.09.16.
//  Copyright © 2016 Robert Enderson. All rights reserved.
//

#import "TwitModel.h"

@interface TwitModel()

@property(nonatomic) NSString* postAuthor;
@property(nonatomic) NSString* textBody;
@property(nonatomic) NSString* imageDir;
@property(nonatomic) NSNumber* twitID;

@end

@implementation TwitModel

-(instancetype)initWithPostAuthor:(NSString*) author
                         PostText:(NSString*) text
                  AvatarDirectory:(NSString*) directory
                           PostID:(NSNumber*) ID
{
    self = [super init];
    if(self)
    {
        self.postAuthor = author;
        self.textBody = text;
        self.imageDir = directory;
        self.twitID = ID;
    }
    return self;
}

-(NSString*)getTwitAuthor
{
    return self.postAuthor;
}

-(NSString*)getTwitText
{
    return self.textBody;
}

-(NSString*)getTwitAvatarDirectory
{
    return self.imageDir;
}

-(NSNumber*)getID
{
    return self.twitID;
}

-(void)setTwitAuthor:(NSString*) Author
{
    self.postAuthor = Author;
}

-(void)setTwitText:(NSString*) Text
{
    self.textBody = Text;
}

-(void)setTwitAvatarDirectory:(NSString*) Directory
{
    self.imageDir = Directory;
}

-(void)setID: (NSNumber*) iD
{
    self.twitID = iD;
}

@end
