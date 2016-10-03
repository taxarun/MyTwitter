//
//  TwitterList.m
//  MyTwitter
//
//  Created by Robert Enderson on 15.09.16.
//  Copyright © 2016 Robert Enderson. All rights reserved.
//

#import "TwitterList.h"
#import "TwitterHandler.h"
#import "SingletoneStorage.h"
#import "TwitModel.h"

#define USER_SEARCH 0
#define TAG_SEARCH 1
#define TIME_TO_UPDATE 60
#define ERROR_TIME_TO_UPDATE 10

@interface TwitterList()
{
    int timeToUpdate;
}

@property (strong, nonatomic) IBOutlet UIBarButtonItem *updateButton;
@property (strong, nonatomic) IBOutlet UISegmentedControl *searchSelector;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong) NSTimer *updateTimer;

//Хранилище твитов
@property (strong, nonatomic) NSArray *data;

//Всякие переменные, в которых хранится важная информация
@property (strong, nonatomic) NSDictionary *appVariables;

//Переменные, связанные с таблицей настроек
@property (strong, nonatomic) NSDictionary *settingsStore;

@property (strong, nonatomic) NSString *imagePath;

@end

@implementation TwitterList

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    UITextField *searchField = [self.searchBar valueForKey:@"_searchField"];
    searchField.textColor = [UIColor lightGrayColor];
    
    //Таймер для обновления ленты
    self.updateTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
    timeToUpdate = 0;
    
    //Достанем закешированные твиты
    self.data = [SingletoneStorage getTwitsStorage];
    
    //Достанем закешированные настройки
    self.appVariables = [SingletoneStorage getAppVariables];
    self.settingsStore = [SingletoneStorage getSettingsState];
    
    //Получим путь к изображениям
    self.imagePath = [SingletoneStorage getPathToImages];
    
    if([[self.appVariables objectForKey:@"searchUser"] isEqualToString:@"Y"]) [self.searchSelector setSelectedSegmentIndex:USER_SEARCH];
    else [self.searchSelector setSelectedSegmentIndex:TAG_SEARCH];
    
    [self.searchBar setText:[self.appVariables objectForKey:@"lastQuery"]];
    self.searchBar.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    //На случай, если в настройках поменяли внешний вид
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

//Заполнение данных таблицы
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"twitterPost";
    TwitterPost *cell = (TwitterPost*)[theTableView dequeueReusableCellWithIdentifier:cellIdentifier];

    TwitModel *twitData = [self.data objectAtIndex:indexPath.row];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", self.imagePath,[twitData getTwitAvatarDirectory]];
    
    [cell setTwitUser:[twitData getTwitAuthor]];
    [cell setBodyText:[twitData getTwitText]];
    [cell setImageFile:filePath];
    
    BOOL avatarEnabled = [[self.settingsStore objectForKey:@"Отображать аватары:"] boolValue];
    [cell avatarCollapse:avatarEnabled];
    
    return cell;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //Спрячем клавиатуру
    [searchBar resignFirstResponder];
    if(self.searchSelector.selectedSegmentIndex == USER_SEARCH)
    {
        //Проверка, корректно ли введено имя юзера (только английский без пробелов)
        NSString *nameRegex = @"[A-Za-z0-9]+";
        NSPredicate *nameTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", nameRegex];
        if(![nameTest evaluateWithObject:self.searchBar.text])
        {
            //Сообщение о правильном использованни поля
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Неверные данные"
                                                            message:@"Вы ввели в поле перехода к пользователю Твиттера имя в неверном формате. В Твиттере используются имена пользователей на английском и без пробелов"
                                                           delegate:self
                                                  cancelButtonTitle:@"Продолжить"
                                                  otherButtonTitles:nil];
            [alert show];
            //Стираем некорректный запрос
            [self.searchBar setText:[self.appVariables objectForKey:@"lastQuery"]];
            return;
        }
    }
    [self.appVariables setValue:searchBar.text forKey:@"lastQuery"];
    [self twitterSearch:searchBar.text autoUpdate:NO];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    //Уберем клавиатуру
    [searchBar resignFirstResponder];
}

-(void)twitterSearch:(NSString*)query autoUpdate:(BOOL) param
{
    //Остановим таймер
    [self.updateTimer invalidate];
    self.updateTimer = nil;
    //Сохраним состояние кнопки обновления
    BOOL wasButtonEnabled = self.updateButton.enabled;
    NSString* lastTitle = self.updateButton.title;
    [self.updateButton setTitle:@"Получение данных..."];
    [self.updateButton setEnabled:NO];
    //Если это автообновление, нужно посмотреть в кеше, кого искали в прошлый раз - пользователя или хештеги
    BOOL userSearch;
    if(param) userSearch = [[self.appVariables objectForKey:@"searchUser"] boolValue];
    else
    {
        NSString* state;
        if(self.searchSelector.selectedSegmentIndex == USER_SEARCH)
        {
            userSearch = YES;
            state = @"Y";
        }
        else
        {
            userSearch = NO;
            state = @"N";
        }
        [self.appVariables setValue:state forKey:@"searchUser"];
    }
    //Асинхронный блок, в котором выполняется запрос
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        //Посмотрим последний полученный ID твита чтобы понять, есть ли новые данные
        NSNumber* lastID;
        if(self.data.count == 0) lastID = nil;
        else lastID = [[self.data objectAtIndex:0] getID];
        //Новые данные
        NSArray *cache = [TwitterHandler getTwitsFromUserNotSearch:userSearch Query:query];
        dispatch_async(dispatch_get_main_queue(),^{
            //Возвращаемся в главный поток программы и проверяем данные
            NSNumber *errorID =[NSNumber numberWithUnsignedInt:1];
            if([[[cache objectAtIndex:0] getID] isEqual:errorID])
            {
                //Произошла ошибка получения данных
                [self.updateButton setTitle:@"Ошибка соединения"];
                [self.updateButton setEnabled:NO];
                timeToUpdate = ERROR_TIME_TO_UPDATE;
            }
            else
            {
                //Данные получены корректно
                self.data = cache;
                if(param)
                {
                    //Если это автообновление
                    if(![lastID isEqual:[[self.data objectAtIndex:0] getID]])
                    {
                        //Если есть новые данные
                        [self.updateButton setTitle:@"Показать новые записи"];
                        [self.updateButton setEnabled:YES];
                    }
                }
                else
                {
                    //Если запрос из строки поиска
                    timeToUpdate = TIME_TO_UPDATE;
                    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                    [self.tableView reloadData];
                    [self.updateButton setEnabled:wasButtonEnabled];
                    [self.updateButton setTitle:lastTitle];
                }
            }
            //Сохраним полученные данные
            [SingletoneStorage setTwitsStorage:self.data];
            //Запустим таймер заново
            self.updateTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:self.updateTimer forMode:NSRunLoopCommonModes];
        });
    });
}

- (void)handleTimer:(NSTimer *)timer
{
    if(timeToUpdate == 0)
    {
        [self twitterSearch:[self.appVariables objectForKey:@"lastQuery"] autoUpdate:YES];
        timeToUpdate = TIME_TO_UPDATE;
    }
    else
    {
        //Если кнопка включена, значит есть новые данные, не надо писать время до обновления, как пользователь надмет, так и посмотрит новые данные
        if(self.updateButton.enabled == NO)
        {
            NSString* title = [NSString stringWithFormat:@"До обновления ленты: %d секунд",timeToUpdate];
            [self.updateButton setTitle:title];
        }
        timeToUpdate--;
    }
}

- (IBAction)getNewData
{
    [self.updateButton setEnabled:NO];
    [self.updateButton setTitle:@"Записи обновлены"];
    [self.tableView reloadData];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

@end
