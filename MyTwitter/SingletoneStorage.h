//
//  SingletoneStorage.h
//  MyTwitter
//
//  Created by Robert Enderson on 24.09.16.
//  Copyright © 2016 Robert Enderson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SingletoneStorage : NSObject

+ (void)setSettingsState:(NSDictionary*) list;
+ (NSDictionary*)getSettingsState;

+ (void)setAppVariables:(NSDictionary*) list;
+ (NSDictionary*)getAppVariables;

+ (void)setTwitsStorage:(NSArray*) list;
+ (NSArray*)getTwitsStorage;

+ (const char*)getQueryToSaveSettings;
+ (const char*)getQueryToSaveTwits;

+ (void)setPathToImages:(NSString*) path;
+ (NSString*)getPathToImages;

+ (NSUInteger)checkImagesCount;

@end
