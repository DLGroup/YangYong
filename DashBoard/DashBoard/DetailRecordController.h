//
//  DetailRecordController.h
//  DashBoard
//
//  Created by YangYong on 8/14/13.
//  Copyright (c) 2013 DiLunTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailRecordController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil folderName:(NSString *)ifolderName andRecordName:(NSString *)irecordName;
- (IBAction)remove:(id)sender;

@end
