//
//  FolderEditController.m
//  DashBoard
//
//  Created by Yong Yang on 13-8-12.
//  Copyright (c) 2013年 DiLunTech. All rights reserved.
//

#import "FolderEditController.h"

extern NSMutableArray *folderNames;
extern NSUInteger folderNumber;

@implementation FolderEditController

@synthesize tableView = _tableView;
@synthesize folderName = _folderName;
@synthesize editView = _editView;

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Folder Edit";
    removeNum = 0;
    persistence = [Persistence sharedPersistence];
    isChangeName = YES;
    _tableView.editing=YES;
    
    editButton = [[UIBarButtonItem alloc] initWithTitle:@"add" style:UIBarButtonItemStyleBordered target:self action:@selector(add:)];
    editButton.tintColor = [UIColor blackColor];
    self.navigationItem.rightBarButtonItem = editButton;
}

#pragma mark - Table view data source 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return folderNumber;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *folderEditID = @"FolderEdit";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:folderEditID];
    if (cell == nil) {
        cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"FolderEditCell" owner:self options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *folderName = (UILabel *)[cell viewWithTag:NAME];
        folderName.text = [folderNames objectAtIndex:indexPath.row];
    }    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
    
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    [persistence removeFolder:[folderNames objectAtIndex:indexPath.row]];
    [folderNames removeObjectAtIndex:indexPath.row];
    folderNumber--;
    [_tableView reloadData];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    isChangeName = YES;
    removeNum = indexPath.row;
    _folderName.delegate = self;
    [_folderName becomeFirstResponder];
    [self animation];
}

- (void)add:(id)sender
{
    editButton.enabled = NO;
    isChangeName = NO;
    _folderName.delegate =self;
    [_folderName becomeFirstResponder];
    [self animation];
}

#pragma mark - TextField delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.text = NULL;
    CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:_tableView];
    CGPoint contentOffset = _tableView.contentOffset;
    contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height - 160.0f);
    [_tableView setContentOffset:contentOffset animated:YES];
    
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
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
        if (isChangeName) {
            [folderNames addObject:textField.text];
            [persistence changeFolderName:[folderNames objectAtIndex:removeNum] toNewNmae:textField.text];
            [folderNames removeObjectAtIndex:removeNum];
        }
        else{
            folderNumber++;
            [folderNames addObject:textField.text];
            [persistence addFolder:textField.text];
            editButton.enabled = YES;
        }
        
        textField.text = nil;
    }
    [self.tableView reloadData];
    [self animation];
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
        return TRUE;
    }
    else{
        //convert myStr from char* to NSString and give it to textField.text
        textField.text = [NSString stringWithUTF8String:myStr];
        return FALSE;
    }
}

- (void)animation{
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^
     {
         CGFloat positionX = _editView.frame.size.width / 2;
         CGFloat x = (_editView.layer.position.x == positionX) ? 320+positionX:positionX;
         [_editView.layer setPosition:CGPointMake(x, _editView.layer.position.y)];
     }completion:nil];
}
@end


















