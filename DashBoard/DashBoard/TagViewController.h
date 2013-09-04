//
//  TagViewController.h
//  DashBoard
//
//  Created by YangYong on 8/19/13.
//  Copyright (c) 2013 DiLunTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Persistence.h"

@interface TagViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate>
{
    NSMutableArray *tagNames;
    NSUInteger removeNum;
    Persistence *persistence;
    BOOL isChangeName;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *tagName;
@property (weak, nonatomic) IBOutlet UIView *editView;

@end
