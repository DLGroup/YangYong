//
//  RootViewController.m
//  DashBoard
//
//  Created by Teddy on 8/3/13.
//  Copyright (c) 2013 DiLunTech. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RootViewController.h"
#import "RecordingViewController.h"
#import "FoldersViewController.h"
#import "FolderEditController.h"
#import "DashBoardCell.h"
#import "Persistence.h"

extern NSMutableArray *folderNames;
extern NSUInteger folderNumber;

//set cell show in the center of screen
#define TABLEVIEWPOSITIONX 169.0f
#define CELLHEIGHT 67.0F
#define FOLDERVIEW 101



@interface RootViewController ()
{
    //...
    //------
    Persistence *persistence;
}

@end

@implementation RootViewController

@synthesize tableView = _tableView;

#pragma mark - Life cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Dash Board";
        folderNumber = 0;
        folderNames = [[NSMutableArray alloc] init];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *back=[[UIBarButtonItem alloc] initWithTitle:@"DashBoard" style:UIBarButtonItemStyleBordered target:nil action:nil];
    back.tintColor=[UIColor blackColor];

    self.navigationItem.backBarButtonItem=back;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_bar_background"] forBarMetrics:UIBarMetricsDefault];
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"edit" style:UIBarButtonItemStyleBordered target:self action:@selector(edit:)];
    editButton.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = editButton;
    // reload data by the storaged file while every time push in
    persistence = [Persistence sharedPersistence];
    [self reloadFolders];
}

- (void)viewDidAppear:(BOOL)animated
{
    [_tableView reloadData];
}
- (void)viewWillAppear:(BOOL)animated
{
    
}

- (void)edit:(id)sender
{
    //....
    FolderEditController *editFolder = [[FolderEditController alloc] initWithNibName:@"FolderEditController" bundle:nil];   
    [self.navigationController pushViewController:editFolder animated:YES];
}

#pragma mark - Reload method according persistence data

- (void) reloadFolders
{
    NSMutableDictionary *folders = [persistence getFoldersName];
    for (NSString *name in [folders allKeys]) {
        [folderNames addObject:name];
        folderNumber++;
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return folderNumber + 1;
    }
    else if (section == 3){
        return 3;
    }
    else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [DashBoardCell tableView:tableView dashBoardCellWithNibName: @"DashBoardCell"];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    if (indexPath.section == 3) {
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        cell.hidden = YES;
        return cell;
    }
    else
    {
        [self configAllCellsByDifferentAttribute:indexPath];
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
            [RecordingViewController setClassName:@"Recording"];
        RecordingViewController *recordingViewController = [[RecordingViewController alloc] initWithNibName:@"RecordingViewController" bundle:nil];
        
        
        [self.navigationController pushViewController:recordingViewController animated:YES];
    }
    else if (indexPath.section == 1 && indexPath.row != folderNumber) {
        // need to remove the setFolderName method and
        // realize the initial method newly
        // 后期完善：实现长按出现folder edit界面，点击进入下一级导航
        NSString *folderName = [[NSMutableString alloc] initWithFormat:@"%@", [folderNames objectAtIndex:indexPath.row]];
        FoldersViewController *foldersViewController = [[FoldersViewController alloc] initWithNibName:@"FoldersViewController" bundle:nil folderName:folderName];
        [self.navigationController pushViewController:foldersViewController animated:YES];
        // ...
//        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//        UITapGestureRecognizer *pushInFolder = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(push:)];
////        pushInFolder.cancelsTouchesInView = NO;
//        [cell addGestureRecognizer:pushInFolder];
//        UILongPressGestureRecognizer *folderEdit = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(edit:)];
//        [cell addGestureRecognizer:folderEdit];

    }
    else{
        return;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELLHEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor colorWithWhite:0.2f alpha:0];
    if (section == 0) {
        label.text = @"";
    }
    else if (section == 1){
        label.text = @"    My Folder";
    }
    else if (section == 2){
        label.text = @"    My Tag";
    }
    else{
        label.text = @"";
    }
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 10.0f;
    }
    else{
        return 30.0f;
    }
}

#pragma mark - TextField delegate
//make the textfield always beyond the keyboards
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    textField.text = NULL;
    CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:_tableView];
    CGPoint contentOffset = _tableView.contentOffset;
    contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height - 160.0f);
    [_tableView setContentOffset:contentOffset animated:YES];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //修改：textfield编辑事件返回前禁用其他事件ex：cell的响应
    //可以添加一层蒙板效果
    [textField resignFirstResponder];
    if( ![self isBlankFloderName:textField] )
    {
        for (NSString *textFieldName in folderNames) {
            if ([textFieldName isEqualToString:textField.text]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Existed Name" message:@"The name you input already has existed.\nPlease input a new name !" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                textField.text = nil;
                return YES;
            }
        }
        folderNumber++;
        //folder name
        [folderNames addObject:textField.text];
        // add the new foleder to the storage file,folders.plist
        [persistence addFolder:textField.text];
    }
    [self.tableView reloadData];
    
    return YES;
}

#pragma used by textFieldShouldReturn:
//use c language to delete the blank beginning
-(BOOL)isBlankFloderName:(UITextField *)textField{
    
    //convert the textField.text from NSSttring* to char*
    char *str = (char *)[textField.text UTF8String];
    
    //the algorithm about delete blank beginning char
    int len = strlen(str);
    if (len <=0 ) {
        return TRUE;
    }
    char *myStr = NULL;
    for (int i=0; i<len; ++i) {
        if (str[i] != ' '){
            myStr = &str[i];
            break;
        }
    }
    if (myStr==NULL) {
//        textField.text = @"";
        return TRUE;
    }
    else{
        //convert myStr from char* to NSString and give it to textField.text
        textField.text = [NSString stringWithUTF8String:myStr];
        return FALSE;
    }
}

#pragma mark - Config every cell by different attribute
- (void)configAllCellsByDifferentAttribute: (NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        [DashBoardCell setHiddenOfTextField:YES andRowIcon:NO andDetailArraw:NO];
        [DashBoardCell setImageOfRowBG:@"recording_background" andRowIcon:@"recording_icon" andRowName:@"Recording"];
    }
    else if (indexPath.section == 1)
    {
        [DashBoardCell setImageOfRowBG:@"folder_background" andRowIcon:@"folder_icon"];
        if (indexPath.row == folderNumber)
        {
            [DashBoardCell setHiddenOfTextField:NO andRowIcon:YES andDetailArraw:YES];
            [[DashBoardCell textField] setDelegate:self];
        }
        else
        {
            [DashBoardCell setHiddenOfTextField:YES andRowIcon:NO andDetailArraw:NO];
            [DashBoardCell setRowName:[folderNames objectAtIndex:indexPath.row]];
        }
    }
    else if (indexPath.section == 2)
    {
        [DashBoardCell setHiddenOfTextField:YES andRowIcon:NO andDetailArraw:NO];
        [DashBoardCell setImageOfRowBG:@"tag_cell_bckgd" andRowIcon:@"tag_icon" andRowName:@"My Tags"];
    }
}

#pragma mark -  Touch Event
//change later according Recording
- (IBAction)recording:(UIButton *)sender {
}
@end






