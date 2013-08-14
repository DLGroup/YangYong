//
//  FolderEditController.m
//  DashBoard
//
//  Created by Yong Yang on 13-8-12.
//  Copyright (c) 2013年 DiLunTech. All rights reserved.
//

#import "FolderEditController.h"
#import "Persistence.h"

extern NSMutableArray *folderNames;
extern NSUInteger folderNumber;

typedef enum{CHANGE=103, NAME}FolderEditID;

@interface FolderEditController ()
{
    NSUInteger removeNum;
    Persistence *persistence;
    BOOL isChange;
}

@end

@implementation FolderEditController

@synthesize tableView = _tableView;
@synthesize folderName = _folderName;
@synthesize editView = _editView;

#pragma mark - Life cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //...
        self.title = @"Folder Edit";
        removeNum = 0;
        isChange = YES;
        persistence = [Persistence sharedPersistence];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"add" style:UIBarButtonItemStyleBordered target:self action:@selector(add:)];
    self.navigationItem.rightBarButtonItem = editButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        UIButton *change = (UIButton *)[cell viewWithTag:CHANGE];
        [change addTarget:self action:@selector(change:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [persistence removeFolder:[folderNames objectAtIndex:removeNum]];
        [folderNames removeObjectAtIndex:removeNum];
        folderNumber--;
        [tableView reloadData];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    removeNum = indexPath.row;
}

- (void)add:(id)sender
{
    isChange = NO;
    _folderName.delegate =self;
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^
     {
         //animation...
         CGFloat positionX = _editView.frame.size.width / 2;
         CGFloat x = (_editView.layer.position.x == positionX) ? 320+positionX:positionX;
         [_editView.layer setPosition:CGPointMake(x, _editView.layer.position.y)];
         
     }completion:nil];
}

- (void)change:(id)sender
{
    isChange = YES;
    UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    _folderName.delegate = self;
    _folderName.text = [folderNames objectAtIndex:indexPath.row];
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^
     {
         //animation...
         CGFloat positionX = _editView.frame.size.width / 2;
         CGFloat x = (_editView.layer.position.x == positionX) ? 320+positionX:positionX;
         [_editView.layer setPosition:CGPointMake(x, _editView.layer.position.y)];
         
     }completion:nil];
    
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
        if (isChange) {
            //...
            //add new
            //remove old
            if ([persistence changeFolderName:[folderNames objectAtIndex:removeNum] andNewName:textField.text]) {
                NSLog(@"change name successfully!");
            }
            [folderNames removeObjectAtIndex:removeNum];
            [folderNames addObject:textField.text];
        }
        else
        {
            folderNumber++;
            //folder name
            [folderNames addObject:textField.text];
            // add the new foleder to the storage file,folders.plist
            [persistence addFolder:textField.text];
        }
        
        textField.text = nil;
    }
    [self.tableView reloadData];
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^
     {
         //animation...
         CGFloat positionX = _editView.frame.size.width / 2;
         CGFloat x = (_editView.layer.position.x == positionX) ? 320+positionX:positionX;
         [_editView.layer setPosition:CGPointMake(x, _editView.layer.position.y)];
         
     }completion:nil];
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
@end


















