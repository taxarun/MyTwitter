//
//  EffectsViewCell.h
//  FractObject
//
//  Created by Robert Enderson on 02.12.15.
//  Copyright © 2015 Robert Enderson. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ControlPanel : UITableViewCell

-(void)setSettingLabel:(NSString*) label;
-(BOOL)getState;
-(void)setState:(BOOL) state;

@end
