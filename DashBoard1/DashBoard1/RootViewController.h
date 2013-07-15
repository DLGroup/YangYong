//
//  RootViewController.h
//  DashBoard1
//
//  Created by snapshot on 13-7-9.
//  Copyright (c) 2013年 Dilun. All rights reserved.
//

#import <UIKit/UIKit.h>

NSMutableDictionary *recording;

@interface RootViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate>
{
    NSMutableArray *myFolderSections;
    NSMutableArray *myFolderData;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)camera:(id)sender;
- (IBAction)sound:(id)sender;

//persistence
- (NSString *)dataFilePath;
- (void)applicationWillResignActive:(NSNotification *)notification;

@end
