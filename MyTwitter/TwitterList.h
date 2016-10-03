//
//  TwitterList.h
//  MyTwitter
//
//  Created by Robert Enderson on 15.09.16.
//  Copyright © 2016 Robert Enderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwitterPost.h"

@interface TwitterList : UITableViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

- (IBAction)getNewData;

@end
