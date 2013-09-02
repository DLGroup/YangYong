//
//  DetailRecordController.h
//  DashBoard
//
//  Created by YangYong on 8/14/13.
//  Copyright (c) 2013 DiLunTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailRecordController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *changeView;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil folderName:(NSString *)ifolderName andRecordName:(NSString *)irecordName;
- (IBAction)remove:(id)sender;
- (IBAction)tagRecord:(id)sender;
- (IBAction)move:(id)sender;

@end
