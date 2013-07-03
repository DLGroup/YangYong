//
//  BobRootViewController.m
//  DashBoard1
//
//  Created by snapshot on 13-7-3.
//  Copyright (c) 2013年 Dilun. All rights reserved.
//

#import "BobRootViewController.h"
#import "BobFolderDetailViewController.h"

@implementation BobRootViewController

- (void)createMyFolderData
{
    NSMutableArray *totalFolder;
    NSMutableArray *myFolders;
    NSMutableArray *myTags;
    
    myFolderSections = [[NSMutableArray alloc] initWithObjects:@"", @"My Folder", @"MyTags", nil];
    totalFolder = [[NSMutableArray alloc] init];
    myFolders = [[NSMutableArray alloc] init];
    myTags = [[NSMutableArray alloc] init];
    
    [totalFolder addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"Recording", @"name", @"recording_icon.png", @"picture", nil]];
    
    //we will need to change this section just for add and remove folder dynamiclly
    [myFolders addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"snapshot1", @"name",  @"folder_icon.png", @"picture", nil]];
    [myFolders addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"snapshot2", @"name",  @"folder_icon.png", @"picture", nil]];
    [myFolders addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"snapshot3", @"name",  @"folder_icon.png", @"picture", nil]];
    [myFolders addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"snapshot4", @"name",  @"folder_icon.png", @"picture", nil]];
    
    [myTags addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"My Tags", @"name", @"toolset_tag.png", @"picture", nil]];
    
    myFolderData = [[NSMutableArray alloc] initWithObjects:totalFolder, myFolders, myTags, nil];
    
    
}

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
    [self createMyFolderData];
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [myFolderSections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[myFolderData objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    [[cell textLabel] setText:[[[myFolderData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"name"]];
    [[cell imageView] setImage:[UIImage imageNamed:[[[myFolderData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"picture"]]];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [myFolderSections objectAtIndex:section];
}
/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

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
    
    folderDetail.title  = [[[myFolderData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"name"];
    [self.navigationController pushViewController:folderDetail animated:YES];
}

@end
