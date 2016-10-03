//
//  DataBaseHandler.h
//  MyTwitter
//
//  Created by Robert Enderson on 20.09.16.
//  Copyright © 2016 Robert Enderson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataBaseHandler : NSObject

-(instancetype)initWithDatabaseFilename:(NSString *)dbFilename;
-(BOOL)getTwits;
-(BOOL)getSettingsAndAppVariables;
-(BOOL)clearAndReuseTable:(NSString*)tableName Query:(const char*)query;

@end
