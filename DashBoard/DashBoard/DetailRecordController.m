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

@implementation DetailRecordController

@synthesize tableView1 = _tableView1;
@synthesize tableView2 = _tableView2;
@synthesize titleLabel = _titleLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil folderName:(NSString *)ifolderName andRecordName:(NSString *)irecordName
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        folderName =ifolderName;
        recordName = irecordName;
        isMove = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    totalTags = [[NSMutableArray alloc] init];
    recordTags = [[NSMutableDictionary alloc] init];
    persistence = [Persistence sharedPersistence];
    record = [persistence getRecordByFolderName:folderName andRecordName:recordName];
    //initial the tag
    for (NSString *tagName in [persistence tags]) {
        [totalTags addObject:tagName];
    }
    for (NSString *tagName in [record tagNames]) {
        [recordTags setObject:[[NSNumber alloc] initWithBool:YES] forKey: tagName];
    }
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
        
        UIImageView *image = (UIImageView *)[cell viewWithTag:103];
        UILabel *folderLabel = (UILabel *)[cell viewWithTag:104];
    if ([tableView isEqual:_tableView1]) {
            folderLabel.text = [folderNames objectAtIndex:indexPath.row];
            [image setImage:[UIImage imageNamed:@"folder_icon.png"]];
    }
    else
    {
        folderLabel.text = [totalTags objectAtIndex:indexPath.row];
        [image setImage:[UIImage imageNamed:@"tag_icon.png"]];
        if ([[recordTags objectForKey:folderLabel.text] boolValue] == YES) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else {
            cell.accessoryType =UITableViewCellAccessoryNone;
        }
    }
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:_tableView1]) {
        return folderNumber;
    }
    else {
        return [totalTags count];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:_tableView1]) {
        UITableViewCell *cell = [_tableView1 cellForRowAtIndexPath:indexPath];
        UILabel *newLabel = (UILabel *)[cell viewWithTag:104];
        NSString *newFolderName = newLabel.text;
        [persistence moveRecord:recordName fromOldFolder:folderName toNewFolder:newFolderName];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        UITableViewCell *cell = [_tableView2 cellForRowAtIndexPath:indexPath];
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            [recordTags removeObjectForKey:[totalTags objectAtIndex:indexPath.row]];
            [record removeTag:[totalTags objectAtIndex:indexPath.row]];
            [persistence removeRecord:record fromTag:[totalTags objectAtIndex:indexPath.row]];
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [recordTags setObject:[[NSNumber alloc] initWithBool:YES] forKey:[totalTags objectAtIndex:indexPath.row]];
            [record addTag:[totalTags objectAtIndex:indexPath.row]];
            [persistence addRecord:record toTag:[totalTags objectAtIndex:indexPath.row]];
        }
        [persistence updateTag];
        [persistence addRecord:record toFolder:folderName];
    }
}

- (IBAction)remove:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [actionSheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [persistence removeRecord:recordName from:folderName];
        //tag info remove
        for (NSString *tagName in recordTags) {
            [persistence removeRecord:record fromTag:tagName];
        }
        [persistence updateTag];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
