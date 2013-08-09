//
//  RootViewController.h
//  DashBoard
//
//  Created by Teddy on 8/3/13.
//  Copyright (c) 2013 DiLunTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)recording:(UIButton *)sender;

@end
