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
    NSMutableArray *totalTags;
    NSMutableDictionary *recordTags;
    BOOL isMove;
    RecordInfo *record;

}

@end

@implementation DetailRecordController

@synthesize tableView = _tableView;
@synthesize titleLabel = _titleLabel;
@synthesize changeView = _changeView;

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
        UILabel *folderLabel = (UILabel *)[cell viewWithTag:104];
        if (isMove) {
            folderLabel.text = [folderNames objectAtIndex:indexPath.row];
        }
        else {
            folderLabel.text = [totalTags objectAtIndex:indexPath.row];
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
    if (isMove) {
        return folderNumber;
    }
    else {
        return [totalTags count];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
    if (isMove) {
        UILabel *newLabel = (UILabel *)[cell viewWithTag:104];
        NSString *newFolderName = newLabel.text;
        [persistence moveRecord:recordName fromOldFolder:folderName toNewFolder:newFolderName];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
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
    
    [persistence removeRecord:recordName from:folderName];
    //...tag info remove
    for (NSString *tagName in recordTags) {
        [persistence removeRecord:record fromTag:tagName];
    }
    [persistence updateTag];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)tagRecord:(id)sender {
    isMove = NO;
    _titleLabel.text = @"Tag the record";
    [self animation];
    [_tableView reloadData];
}

- (IBAction)move:(id)sender {
    isMove = YES;
    _titleLabel.text = @"Click to move audio clip to new folder";
    [self animation];
    [_tableView reloadData];
}

- (void)animation {
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^
     {
         //animation...
         CGFloat positionY = _changeView.frame.size.height / 2;
         CGFloat y = (_changeView.layer.position.y == positionY) ? 480+positionY:positionY;
         [_changeView.layer setPosition:CGPointMake(_changeView.layer.position.x, y)];
     }completion:nil];
}

@end
