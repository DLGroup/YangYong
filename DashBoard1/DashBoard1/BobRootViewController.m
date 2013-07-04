//
//  BobRootViewController.m
//  DashBoard1
//
//  Created by snapshot on 13-7-3.
//  Copyright (c) 2013年 Dilun. All rights reserved.
//

#import "BobRootViewController.h"
#import "BobFolderDetailViewController.h"

#define LABELTAG 100
#define IMAGETAG 102
#define TEXTFIELDTAG 103


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


-(UITableViewCell*)recordingSection:(UITableView*)tableView{
    static NSString *str=@"RecordingCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if (cell == nil) {
        cell = (UITableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"BobMainCell" owner:self options:nil] lastObject];
        UILabel *label=(UILabel*)[cell viewWithTag:100];
        label.text=@"          Recordings";
        label.backgroundColor = [UIColor brownColor];
        UIImageView *image = (UIImageView *)[cell viewWithTag:102];
        [image setImage:[UIImage imageNamed:@"recording_icon.png"]];
    }
    
    return cell;
}

-(UITableViewCell*)tagSection:(UITableView*)tableView{
    static NSString *str=@"TagCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if (cell == nil) {
        cell = (UITableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"BobMainCell" owner:self options:nil] lastObject];
        UILabel *label=(UILabel*)[cell viewWithTag:LABELTAG];
        label.text=@"          Tag";
        label.backgroundColor = [UIColor grayColor];
        
        UIImageView *image = (UIImageView *)[cell viewWithTag:IMAGETAG];
        [image setImage:[UIImage imageNamed:@"tag_icon.png"]];
    }
    return cell;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    NSString *folderName= [[NSString alloc] initWithFormat:@"          %@", textField.text];

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
        static NSString *lastCellId=@"LastCellId";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:lastCellId];
        if (cell == nil) {
            cell = (UITableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"FolderCell" owner:self options:nil] lastObject];
            UITextField *textField=[cell viewWithTag:TEXTFIELDTAG];
            textField.delegate=self;
        }

        return cell;
    }
    else{
        static NSString *BaseCellId=@"BaseCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BaseCellId];
        if (cell == nil) {
            cell = (UITableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"BobMainCell" owner:self options:nil] lastObject];
        }
        UIImageView *image = (UIImageView *)[cell viewWithTag:IMAGETAG];
        [image setImage:[UIImage imageNamed:@"folder_icon.png"]];
        UILabel *label=(UILabel*)[cell viewWithTag:LABELTAG];
        label.text=[myFolder objectAtIndex:indexPath.row];
    
        return cell;
    }  
     
}


//
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [myFolderSections objectAtIndex:section];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    BobFolderDetailViewController *folderDetail = [[BobFolderDetailViewController alloc] initWithNibName:@"BobFolderDetailViewController" bundle:nil];
    [self.navigationController pushViewController:folderDetail animated:YES];
}

@end
