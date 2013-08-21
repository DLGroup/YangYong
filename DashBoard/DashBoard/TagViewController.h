//
//  TagViewController.h
//  DashBoard
//
//  Created by YangYong on 8/19/13.
//  Copyright (c) 2013 DiLunTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TagViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate>
{
    NSMutableArray *tagNames;
}

//@property (strong, nonatomic) NSMutableArray *tagNames;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *tagName;
@property (weak, nonatomic) IBOutlet UIView *editView;

@end
