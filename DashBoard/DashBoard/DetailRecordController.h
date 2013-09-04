//
//  DetailRecordController.h
//  DashBoard
//
//  Created by YangYong on 8/14/13.
//  Copyright (c) 2013 DiLunTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Persistence.h"
#import "RecordInfo.h"

@interface DetailRecordController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
{
    NSString *folderName;
    NSString *recordName;
    Persistence *persistence;
    NSMutableArray *totalTags;
    NSMutableDictionary *recordTags;
    BOOL isMove;
    RecordInfo *record;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong, nonatomic) IBOutlet UITableView *tableView1;
@property (strong, nonatomic) IBOutlet UITableView *tableView2;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil folderName:(NSString *)ifolderName andRecordName:(NSString *)irecordName;
- (IBAction)remove:(id)sender;

@end
