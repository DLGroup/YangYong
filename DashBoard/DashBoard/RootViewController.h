//
//  RootViewController.h
//  DashBoard
//
//  Created by Teddy on 8/3/13.
//  Copyright (c) 2013 DiLunTech. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "Persistence.h"

@interface RootViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    Persistence *persistence;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)recording:(UIButton *)sender;

@end
