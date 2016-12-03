//
//  EffectsViewCell.m
//  FractObject
//
//  Created by Robert Enderson on 02.12.15.
//  Copyright © 2015 Robert Enderson. All rights reserved.
//

#import "TwitterPost.h"
#import "TwitterHandler.h"

@interface TwitterPost()

@property (nonatomic, strong) IBOutlet UILabel *twitText;
@property (strong, nonatomic) IBOutlet UIImageView *Avatar;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *collapseConstrant;

@end

@implementation TwitterPost

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    self.Avatar.layer.masksToBounds = YES;
    [self.Avatar.layer setCornerRadius:5.0f];
    [self.Avatar.layer setBorderWidth:2.0f];
    [self.Avatar.layer setBorderColor:[UIColor blackColor].CGColor];
    
//    [self.contentView.layer setBorderColor:[UIColor blackColor].CGColor];
//    [self.contentView.layer setBorderWidth:2.5f];
//    [self.contentView.layer setCornerRadius:5.0f];
    
//    self.layer.masksToBounds = YES;
//    [self.layer setCornerRadius:5.0f];
}

-(void)setBodyText:(NSString*)text
{
    [self.twitText setText:text];
}

-(void)setTwitUser:(NSString*)user
{
    [self.userName setText:user];
}

-(void)setImageFile:(NSString*)directory
{
    [self.Avatar setImage:[UIImage imageWithContentsOfFile:directory]];
}

//Спрятан аватар или нет
-(void)avatarCollapse:(BOOL) param
{
    [self.Avatar setHidden:!param];
    //Изменим отступ для текста с пользователем (чтоб был ровно по центру)
    if(!param) self.collapseConstrant.constant = (self.Avatar.frame.size.width * -1.0f);
    else self.collapseConstrant.constant = 0.0f;
}

//Отступы для ячейки от краев экрана и других ячеек
//- (void)setFrame:(CGRect)frame
//{
//    frame.origin.y += 6;
//    frame.size.height -= 12;
//    frame.origin.x += 8;
//    frame.size.width -= 16;
//    [super setFrame:frame];
//}

@end
