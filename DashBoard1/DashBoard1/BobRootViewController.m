//
//  BobRootViewController.m
//  DashBoard1
//
//  Created by snapshot on 13-7-3.
//  Copyright (c) 2013年 Dilun. All rights reserved.
//

#import "BobRootViewController.h"
#import "BobFolderDetailViewController.h"
#import <QuartzCore/QuartzCore.h>

#define LABELTAG 100
#define BUTTONTAG 101
#define IMAGETAG 102
#define TEXTFIELDTAG 103
#define BLANKINFRONT @"          "


@interface BobRootViewController()
{
    NSMutableArray *myFolder;
}

@end

@implementation BobRootViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    myFolderSections = [[NSMutableArray alloc] initWithObjects:@"", @"My Folder", @"My Tags" ,nil];
    myFolder = [[NSMutableArray alloc] init];
    [myFolder addObject:@"Enter new folder name"];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==1)
        return myFolder.count;
    else
        return 1;
}

- (void)detailInfo:(id)sender{
    BobFolderDetailViewController *folderDetail = [[BobFolderDetailViewController alloc] initWithNibName:@"BobFolderDetailViewController" bundle:nil];
    [self.navigationController pushViewController:folderDetail animated:YES];
}

-(UITableViewCell*)recordingSection:(UITableView*)tableView{
    static NSString *str=@"RecordingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if (cell == nil) {
        cell = (UITableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"BobMainCell" owner:self options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *label=(UILabel*)[cell viewWithTag:100];
        label.text = [[NSString alloc] initWithFormat:@"%@Recording", BLANKINFRONT];
        label.backgroundColor = [UIColor brownColor];
        label.layer.cornerRadius = 10;
        UIImageView *image = (UIImageView *)[cell viewWithTag:102];
        [image setImage:[UIImage imageNamed:@"recording_icon.png"]];
        UIButton *button = (UIButton *)[cell viewWithTag:BUTTONTAG];
        [button addTarget:self action:@selector(detailInfo:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

-(UITableViewCell*)tagSection:(UITableView*)tableView{
    static NSString *str=@"TagCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if (cell == nil) {
        cell = (UITableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"BobMainCell" owner:self options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *label=(UILabel*)[cell viewWithTag:LABELTAG];
        label.text = [[NSString alloc] initWithFormat:@"%@Tag", BLANKINFRONT];
        label.backgroundColor = [UIColor grayColor];
        label.layer.cornerRadius = 10;
    
        UIImageView *image = (UIImageView *)[cell viewWithTag:IMAGETAG];
        [image setImage:[UIImage imageNamed:@"tag_icon.png"]];
        UIButton *button = (UIButton *)[cell viewWithTag:BUTTONTAG];
        [button addTarget:self action:@selector(detailInfo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

-(UITableViewCell *)myFolderTextFieldSection:(UITableView *)tableView{
    static NSString *lastCellId=@"LastCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:lastCellId];
    if (cell == nil) {
        cell = (UITableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"FolderCell" owner:self options:nil] lastObject];
        UITextField *textField=[cell viewWithTag:TEXTFIELDTAG];
        textField.layer.cornerRadius = 10;
        textField.delegate=self;
    }
    return cell;
}

-(UITableViewCell *)myFolderSection:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    static NSString *BaseCellId=@"BaseCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BaseCellId];
    if (cell == nil) {
        cell = (UITableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"BobMainCell" owner:self options:nil] lastObject];
    }
    UIImageView *image = (UIImageView *)[cell viewWithTag:IMAGETAG];
    [image setImage:[UIImage imageNamed:@"folder_icon.png"]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UILabel *label=(UILabel*)[cell viewWithTag:LABELTAG];
    label.text=[myFolder objectAtIndex:indexPath.row];
    label.layer.cornerRadius = 10;
    UIButton *button = (UIButton *)[cell viewWithTag:BUTTONTAG];
    [button addTarget:self action:@selector(detailInfo:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

//use c language to delete the blank beginning
-(void)deleteSpan:(UITextField *)textField{
    //convert the textField.text from NSSttring* to char*
    char *str = [textField.text UTF8String];
    
    //the algorithm about delete blank beginning char
    int len = strlen(str);
    if (len <=0 ) {
        return;
    }
    char *myStr = NULL;
    for (int i=0; i<len; ++i) {
        if (str[i] == ' ') {
        }
        else{
            myStr = &str[i];
            break;
        }
    }
    if (myStr==NULL) {
        textField.text = @"";
    }
    else{
        //convert myStr from char* to NSString and give it to textField.text
        textField.text = [NSString stringWithUTF8String:myStr];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    [self deleteSpan:textField];
    NSString *folderName= [[NSString alloc] initWithFormat:@"%@%@", BLANKINFRONT, textField.text];

    if (![textField.text isEqualToString:@""]) {
        [myFolder insertObject:folderName atIndex:myFolder.count-1];
    }

    [self.tableView reloadData];
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Recording section
    if(indexPath.section==0){
        return [self recordingSection:tableView];
    }
    
    //Tag section
    else if(indexPath.section==2){
        return [self tagSection:tableView];
    }
    
    //the last folder section
    else if(indexPath.row == myFolder.count-1){
        return [self myFolderTextFieldSection:tableView];
    }
    else{
        return [self myFolderSection:tableView indexPath:indexPath];
    }  
     
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [myFolderSections objectAtIndex:section];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == myFolder.count-1) {
        //made the textField no responding
        //...
    }
    else if (indexPath.section == 1 && indexPath.row != myFolder.count-1){
        //need to improve
        //mabye delete the selected folder
        
    }
    else{
        
    }
}

@end
