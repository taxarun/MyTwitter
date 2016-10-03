//
//  EffectsViewCell.h
//  FractObject
//
//  Created by Robert Enderson on 02.12.15.
//  Copyright © 2015 Robert Enderson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwitterPost : UITableViewCell

-(void)setBodyText:(NSString*)text;
-(void)setTwitUser:(NSString*)user;
-(void)setImageFile:(NSString*)directory;
-(void)avatarCollapse:(BOOL) param;

@end
