//
//  EffectsViewCell.m
//  FractObject
//
//  Created by Robert Enderson on 02.12.15.
//  Copyright © 2015 Robert Enderson. All rights reserved.
//

#import "ControlPanel.h"

@interface ControlPanel()

@property (strong, nonatomic) IBOutlet UISwitch *avatarSwitch;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;

@end

@implementation ControlPanel

-(void)setSettingLabel:(NSString*) label
{
    [self.descriptionLabel setText:label];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    [self.contentView.layer setBorderColor:[UIColor blackColor].CGColor];
    [self.contentView.layer setBorderWidth:2.5f];
    [self.contentView.layer setCornerRadius:5.0f];
    self.layer.masksToBounds = YES;
    [self.layer setCornerRadius:5.0f];
}

-(BOOL)getState
{
    return self.avatarSwitch.on;
}

-(void)setState:(BOOL) state
{
    self.avatarSwitch.on = state;
}

//Отступы для ячейки откраев экрана и других ячеек
- (void)setFrame:(CGRect)frame
{
    frame.origin.y += 6;
    frame.size.height -= 12;
    frame.origin.x += 8;
    frame.size.width -= 16;
    [super setFrame:frame];
}

@end
