//
//  FolderEditController.h
//  DashBoard
//
//  Created by Yong Yang on 13-8-12.
//  Copyright (c) 2013年 DiLunTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Persistence.h"

#define NAME 104

@interface FolderEditController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    NSUInteger removeNum;
    Persistence *persistence;
    BOOL isChangeName;
    UIBarButtonItem *editButton;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *folderName;
@property (weak, nonatomic) IBOutlet UIView *editView;

@end
