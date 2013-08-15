//
//  DetailRecordController.m
//  DashBoard
//
//  Created by YangYong on 8/14/13.
//  Copyright (c) 2013 DiLunTech. All rights reserved.
//

#import "DetailRecordController.h"
#import "FoldersViewController.h"
#import "Persistence.h"

extern NSMutableArray *folderNames;
extern NSUInteger folderNumber;

@interface DetailRecordController ()
{
    NSString *folderName;
    NSString *recordName;
    Persistence *persistence;
}

@end

@implementation DetailRecordController

@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil folderName:(NSString *)ifolderName andRecordName:(NSString *)irecordName
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        folderName =ifolderName;
        recordName = irecordName;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    persistence = [Persistence sharedPersistence];
    [_tableView setFrame:CGRectMake(_tableView.frame.origin.x/2, _tableView.frame.origin.y, _tableView.frame.size.width, folderNumber * 44)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *moveCellId = @"moveCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:moveCellId];
    if (cell ==nil) {
        cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"FolderEditCell" owner:self options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *folderLabel = (UILabel *)[cell viewWithTag:104];
        folderLabel.text = [folderNames objectAtIndex:indexPath.row];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return folderNumber;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    UILabel *newLabel = (UILabel *)[cell viewWithTag:104];
    NSString *newFolderName = newLabel.text;
    [persistence moveRecord:recordName fromOldFolder:folderName toNewFolder:newFolderName];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)remove:(id)sender {
    //should do something before return to super controller
//    sectionCounts--;
//    [allRecordsConfigInfo removeObject:[persistence getRecordByFolderName:folderName andRecordName:recordName]];
    [persistence removeRecord:recordName from:folderName];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)move:(id)sender {
    //no use
    //....delete later
}
@end
