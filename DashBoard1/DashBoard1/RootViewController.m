//
//  RootViewController.m
//  DashBoard1
//
//  Created by snapshot on 13-7-9.
//  Copyright (c) 2013年 Dilun. All rights reserved.
//

#import "RootViewController.h"
#import "BobFolderDetailViewController.h"
#import <QuartzCore/QuartzCore.h>

#define LABELTAG 100
#define BUTTONTAG 101
#define IMAGETAG 102
#define TEXTFIELDTAG 103
#define BLANKINFRONT @"          "
#define KEYBOARDHEIGHT 160
#define kFilename @"data.plist"
extern NSMutableDictionary *recording;

@interface RootViewController ()
{
    NSMutableArray *myFolder;
    NSString *name;
    NSString *folderName;
    NSMutableDictionary*soundFolder;
}
@end

@implementation RootViewController

@synthesize tableView;

- (NSString *)dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kFilename];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    recording = [[NSMutableDictionary alloc] init];
    myFolderSections = [[NSMutableArray alloc] initWithObjects:@"", @"My Folder", @"My Tags", @"", nil];
    myFolder = [[NSMutableArray alloc] init];
    folderName = [[NSString alloc] init];
    [myFolder addObject:@"Enter new folder name"];
    soundFolder = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[BobFolderDetailViewController alloc] initWithNibName:@"BobFolderDetailViewController" bundle:nil name:@"Recordings" tag:0], @"Recordings", nil];
    
    //persistence begin
    NSString *filePath = [self dataFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        //made the recording save the folders' cell information and show us totally
        recording = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        for (NSString *key in [recording allKeys]) {
            NSInteger specialTag = [[recording objectForKey:key] intValue];
            if (![key isEqualToString:@"Recordings"]) {
                [myFolder insertObject:key atIndex:0];
            }
            [soundFolder setObject:[[BobFolderDetailViewController alloc] initWithNibName:@"BobFolderDetailViewController" bundle:nil name:key tag:specialTag] forKey:key];
        }
        [self.tableView reloadData];
        //need to do something
        //...
    }
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:app];
    //persistence end
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==1)
        return myFolder.count;
    else if(section==3)
        return 3;
    else
        return 1;
}

- (void)recordingsDetailInfo:(id)sender{
    [self.navigationController pushViewController:[soundFolder objectForKey:@"Recordings"] animated:YES];
}
- (void)tagsDetailInfo:(id)sender{
//    [self.navigationController pushViewController:[soundFolder objectForKey:@"My Tags"] animated:YES];
}
- (void)folderDetailInfo:(id)sender{
//    [self.navigationController pushViewController:[soundFolder objectForKey:folderName] animated:YES];
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
        [button addTarget:self action:@selector(recordingsDetailInfo:)forControlEvents:UIControlEventTouchUpInside];
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
        [button addTarget:self action:@selector(tagsDetailInfo:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

-(UITableViewCell *)myFolderTextFieldSection:(UITableView *)tableView{
    
    static NSString *lastCellId=@"LastCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:lastCellId];
    if (cell == nil) {
        cell = (UITableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"FolderCell" owner:self options:nil] lastObject];
        
        UITextField *textField=(UITextField *)[cell viewWithTag:TEXTFIELDTAG];
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    UIImageView *image = (UIImageView *)[cell viewWithTag:IMAGETAG];
    [image setImage:[UIImage imageNamed:@"folder_icon.png"]];
    
    UILabel *label=(UILabel*)[cell viewWithTag:LABELTAG];
    label.text=[myFolder objectAtIndex:indexPath.row];
    label.layer.cornerRadius = 10;
    
//    UIButton *button = (UIButton *)[cell viewWithTag:BUTTONTAG];
//    [button addTarget:self action:@selector(folderDetailInfo:) forControlEvents:UIControlEventTouchUpInside];
    }
    
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

//make the textfield always beyond the keyboards
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:self.tableView];
    CGPoint contentOffset = self.tableView.contentOffset;
    contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height - KEYBOARDHEIGHT);
    NSLog(@"contentOffset is %@", NSStringFromCGPoint(contentOffset));
    [self.tableView setContentOffset:contentOffset animated:YES];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    [self deleteSpan:textField];
    folderName= [[NSString alloc] initWithFormat:@"%@%@", BLANKINFRONT, textField.text];
    if (![textField.text isEqualToString:@""]) {
        [myFolder insertObject:folderName atIndex:myFolder.count-1];
        [soundFolder setObject:[[BobFolderDetailViewController alloc] initWithNibName:@"BobFolderDetailViewController" bundle:nil name:folderName tag:0] forKey:folderName];
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
    
    //the last blank section
    else if (indexPath.section==3){
        UITableViewCell *cell = [[UITableViewCell alloc] init];
        cell.backgroundView = [[UIView alloc] init];
        return cell;
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
    if (indexPath.section==1 && indexPath.row!=myFolder.count-1) {
        folderName = [myFolder objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:[soundFolder objectForKey:folderName] animated:YES];
    }
}

- (IBAction)camera:(id)sender {
}

- (IBAction)sound:(id)sender {
    [self.navigationController pushViewController:[soundFolder objectForKey:@"Recordings"] animated:YES];
    //把所有新建的文件夹里面的内容取出来包含进来
    for (NSString *newFolderName in myFolder) {
        if ([newFolderName isEqual: @"Enter new folder name"]) {
            continue;
        }
        NSInteger number = [[soundFolder objectForKey:newFolderName] tag];
        for (int i=0; i<number; ++i) {
            [[soundFolder objectForKey:@"Recordings"] addCellByName:newFolderName];
        }
    }
    
    [[soundFolder objectForKey:@"Recordings"] addCellByName:@"Recordings"];
}




//persistence
//..we can't use this way to save a custom object 

- (void)applicationWillResignActive:(NSNotification *)notification
{
    //need to do something
    //write to data.plist
    for (NSString *newFolderName in myFolder) {
        if ([newFolderName isEqual: @"Enter new folder name"]) {
            continue;
        }
        [recording setObject:[[soundFolder objectForKey:newFolderName] convertTagToNSString] forKey:newFolderName];
    }
    ////need to attention
    //...
    [recording setObject:[[soundFolder objectForKey:@"Recordings"] convertTagToNSString] forKey:@"Recordings"];
    [recording writeToFile:[self dataFilePath] atomically:YES];

}

@end
