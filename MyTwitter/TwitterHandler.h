//
//  TwitterHandler.h
//  MyTwitter
//
//  Created by Robert Enderson on 17.09.16.
//  Copyright © 2016 Robert Enderson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterHandler : NSObject

+(NSString*)getNonce;
+(NSArray*)getTwitsFromUserNotSearch:(BOOL)param Query:(NSString*) query;
+(NSString*)getBase64EncodedBearerToken;
+(NSString*)getBearerTokenFromTwitter;
+(void)prepareImageDirectory;
+(NSString*)downloadImageToCacheWith:(NSURL*)URL SetCount:(NSUInteger*) count;
+(void)clearImagesDirectory;

@end
