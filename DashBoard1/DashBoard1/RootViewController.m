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
//need to change with NSDictionary to manage the BobFolderViewController
NSMutableDictionary*soundFolder;

@interface RootViewController ()
{
    NSMutableArray *myFolder;
    NSString *name;
    UILabel *folderLabel;
}

@end

@implementation RootViewController

@synthesize tableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    myFolderSections = [[NSMutableArray alloc] initWithObjects:@"", @"My Folder", @"My Tags", @"", nil];
    myFolder = [[NSMutableArray alloc] init];
    [myFolder addObject:@"Enter new folder name"];
    
    //the global variable
    soundFolder = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[[BobFolderDetailViewController alloc] initWithNibName:@"BobFolderDetailViewController" bundle:nil name:@"Recordings" tag:0], @"Recordings", nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


//should be good enough to combine this
//...
- (void)recordingsDetailInfo:(id)sender{
    [self.navigationController pushViewController:[soundFolder objectForKey:@"Recordings"] animated:YES];
}
- (void)tagsDetailInfo:(id)sender{
    //just nothing has happened yet
//    [self.navigationController pushViewController:[soundFolder objectForKey:@"My Tags"] animated:YES];
}

- (void)folderDetailInfo:(id)sender{
    
    //取得所在行的名字存入foldername里
    [self.navigationController pushViewController:[soundFolder objectForKey:folderLabel.text] animated:YES];
}

//...
//end change information

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
    folderLabel=(UILabel*)[cell viewWithTag:LABELTAG];
    folderLabel.text=[myFolder objectAtIndex:indexPath.row];
    folderLabel.layer.cornerRadius = 10;
    
    UIButton *button = (UIButton *)[cell viewWithTag:BUTTONTAG];
    [button addTarget:self action:@selector(folderDetailInfo:) forControlEvents:UIControlEventTouchUpInside];
    
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:self.tableView];
    CGPoint contentOffset = self.tableView.contentOffset;
    contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height - KEYBOARDHEIGHT);
    NSLog(@"contentOffset is %@", NSStringFromCGPoint(contentOffset));
    [self.tableView setContentOffset:contentOffset animated:YES];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    [self deleteSpan:textField];
    NSString *folderName= [[NSString alloc] initWithFormat:@"%@%@", BLANKINFRONT, textField.text];
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
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}
- (IBAction)camera:(id)sender {
}

- (IBAction)sound:(id)sender {
}
@end
