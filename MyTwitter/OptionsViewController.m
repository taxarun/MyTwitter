//
//  TwitterList.m
//  MyTwitter
//
//  Created by Robert Enderson on 15.09.16.
//  Copyright © 2016 Robert Enderson. All rights reserved.
//

#import "OptionsViewController.h"
#import "SingletoneStorage.h"

@interface OptionsViewController()
{
    BOOL needUpdate;
}

//Лист настроек со значениями
@property(nonnull,strong) NSDictionary* settingsList;
@property(nonnull,strong) NSArray *keys;

@end

@implementation OptionsViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    //Получим закешированные настройки
    self.settingsList = [SingletoneStorage getSettingsState];
    //Получим все названия настроек для итерации по значениям (когда требуется итерация по индексу)
    self.keys = [self.settingsList allKeys];
    [self.navigationController setToolbarHidden:YES];
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    return self.settingsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"optionCellSwitch";
    ControlPanel *cell = (ControlPanel*)[theTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSString* label = [self.keys objectAtIndex:indexPath.row];
    [cell setSettingLabel:label];
    
    BOOL state = [[self.settingsList objectForKey: label] boolValue];
    [cell setState:state];
    
    return cell;
}

-(void)viewWillDisappear:(BOOL)animated
{
    //Сохранение всех данных из настроек
    NSUInteger Row = 0;
    for (NSString* key in self.settingsList)
    {
        //Прогоним все ячейки таблицы
        ControlPanel* cell = (ControlPanel*)[self.tableView cellForRowAtIndexPath:
                                             [NSIndexPath indexPathForRow:Row inSection:0]];
        
        if(cell.getState) [self.settingsList setValue:@"Y" forKey:key];
        else [self.settingsList setValue:@"N" forKey:key];
        Row++;
    }
    [self.navigationController setToolbarHidden:NO];
}

@end
